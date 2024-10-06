#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>

/* In the first fit algorithm, the allocator keeps a list of free blocks (known as the free list) and,
   on receiving a request for memory, scans along the list for the first block that is large enough to
   satisfy the request. If the chosen block is significantly larger than that requested, then it is 
   usually split, and the remainder added to the list as another free block.
   Please see Page 196~198, Section 8.2 of Yan Wei Min's chinese book "Data Structure -- C programming language"
*/
// you should rewrite functions: default_init,default_init_memmap,default_alloc_pages, default_free_pages.
/*
 * Details of FFMA
 * (1) Prepare: In order to implement the First-Fit Mem Alloc (FFMA), we should manage the free mem block use some list.
 *              The struct free_area_t is used for the management of free mem blocks. At first you should
 *              be familiar to the struct list in list.h. struct list is a simple doubly linked list implementation.
 *              You should know howto USE: list_init, list_add(list_add_after), list_add_before, list_del, list_next, list_prev
 *              Another tricky method is to transform a general list struct to a special struct (such as struct page):
 *              you can find some MACRO: le2page (in memlayout.h), (in future labs: le2vma (in vmm.h), le2proc (in proc.h),etc.)
 * (2) default_init: you can reuse the  demo default_init fun to init the free_list and set nr_free to 0.
 *              free_list is used to record the free mem blocks. nr_free is the total number for free mem blocks.
 * (3) default_init_memmap:  CALL GRAPH: kern_init --> pmm_init-->page_init-->init_memmap--> pmm_manager->init_memmap
 *              This fun is used to init a free block (with parameter: addr_base, page_number).
 *              First you should init each page (in memlayout.h) in this free block, include:
 *                  p->flags should be set bit PG_property (means this page is valid. In pmm_init fun (in pmm.c),
 *                  the bit PG_reserved is setted in p->flags)
 *                  if this page  is free and is not the first page of free block, p->property should be set to 0.
 *                  if this page  is free and is the first page of free block, p->property should be set to total num of block.
 *                  p->ref should be 0, because now p is free and no reference.
 *                  We can use p->page_link to link this page to free_list, (such as: list_add_before(&free_list, &(p->page_link)); )
 *              Finally, we should sum the number of free mem block: nr_free+=n
 * (4) default_alloc_pages: search find a first free block (block size >=n) in free list and reszie the free block, return the addr
 *              of malloced block.
 *              (4.1) So you should search freelist like this:
 *                       list_entry_t le = &free_list;
 *                       while((le=list_next(le)) != &free_list) {
 *                       ....
 *                 (4.1.1) In while loop, get the struct page and check the p->property (record the num of free block) >=n?
 *                       struct Page *p = le2page(le, page_link);
 *                       if(p->property >= n){ ...
 *                 (4.1.2) If we find this p, then it' means we find a free block(block size >=n), and the first n pages can be malloced.
 *                     Some flag bits of this page should be setted: PG_reserved =1, PG_property =0
 *                     unlink the pages from free_list
 *                     (4.1.2.1) If (p->property >n), we should re-caluclate number of the the rest of this free block,
 *                           (such as: le2page(le,page_link))->property = p->property - n;)
 *                 (4.1.3)  re-caluclate nr_free (number of the the rest of all free block)
 *                 (4.1.4)  return p
 *               (4.2) If we can not find a free block (block size >=n), then return NULL
 * (5) default_free_pages: relink the pages into  free list, maybe merge small free blocks into big free blocks.
 *               (5.1) according the base addr of withdrawed blocks, search free list, find the correct position
 *                     (from low to high addr), and insert the pages. (may use list_next, le2page, list_add_before)
 *               (5.2) reset the fields of pages, such as p->ref, p->flags (PageProperty)
 *               (5.3) try to merge low addr or high addr blocks. Notice: should change some pages's p->property correctly.
 */
free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;//空闲快总数
}
/*
 * default_init_memmap - 初始化一个内存块并将其插入空闲链表
 * @base:   指向需要初始化的第一个页面
 * @n:      需要初始化的页面数量
 *
 * 该函数用于初始化从 base 开始的 n 个连续页面，将这些页面的状态设置为“空闲”，
 * 并将这个空闲块插入到全局空闲链表 `free_list` 中，维护空闲块的有序性。
 * 该函数假设所有页面的起始地址和大小都合法，并对页面的相关属性进行设置。
 */
static void
default_init_memmap(struct Page *base, size_t n) {
    // 确保 n 大于 0，保证至少有一个页面需要初始化
    assert(n > 0);

    // 初始化从 base 开始的 n 个页面
    struct Page *p = base;
    for (; p != base + n; p++) {
        // 断言这些页面已经被标记为保留（PageReserved 为 1）
        assert(PageReserved(p));

        // 清除页面的 flags 和 property，标记这些页面为空闲
        p->flags = p->property = 0;

        // 设置页面的引用计数为 0，表示页面当前没有被使用
        set_page_ref(p, 0);
    }

    // 设置第一个页面的 property 属性为 n，表示这是一个大小为 n 的空闲块
    base->property = n;

    // 设置第一个页面的 flags 中的 PG_property 位，表示它是一个空闲块的开始
    SetPageProperty(base);

    // 增加系统中空闲页面的总数
    nr_free += n;

    // 如果空闲链表为空，直接将这个块加入链表
    if (list_empty(&free_list)) {//双向链表
        // 将 base 页面链接到空闲链表的头部
        list_add(&free_list, &(base->page_link));
    } else {
        // 如果空闲链表非空，找到合适的位置插入这个块
        list_entry_t *le = &free_list;

        // 遍历空闲链表，找到合适的插入位置（按地址从低到高排序）
        while ((le = list_next(le)) != &free_list) {
            // 将通用的链表项转换为 Page 结构
            struct Page *page = le2page(le, page_link);

            // 找到第一个地址比 base 大的页面，将 base 插入到它之前
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            }
            // 如果已经到达链表的末尾，则将 base 插入到链表末尾
            else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }
}

/*
 * default_alloc_pages - 从空闲链表中分配指定数量的页面
 * @n:     需要分配的页面数量
 *
 * 该函数实现了“首次适配”（First-Fit Allocation）算法，从空闲链表 `free_list` 中找到第一个满足分配需求的内存块。
 * 如果找到的块大于需求，则分割该块，将剩余部分继续作为空闲块存放在空闲链表中。
 * 返回找到的页面块的起始地址，如果没有足够的空闲页面，则返回 NULL。
 */
static struct Page *
default_alloc_pages(size_t n) {
    // 确保 n 大于 0，即需要分配至少一个页面
    assert(n > 0);

    // 如果请求的页面数大于系统中可用的页面总数，则无法分配，返回 NULL
    if (n > nr_free) {
        return NULL;
    }

    struct Page *page = NULL;  // 用于存储找到的空闲页面块
    list_entry_t *le = &free_list;  // 从空闲链表的头部开始遍历

    // 遍历空闲链表，寻找第一个满足要求的页面块（块大小 >= n）
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);  // 将链表项转换为页面结构体
        if (p->property >= n) {  // 检查页面块的大小是否满足需求
            page = p;  // 找到合适的页面块
            break;
        }
    }

    // 如果找到合适的页面块
    if (page != NULL) {
        // 获取页面块前一个链表项，准备修改空闲链表
        list_entry_t* prev = list_prev(&(page->page_link));

        // 将该页面块从空闲链表中删除
        list_del(&(page->page_link));

        // 如果找到的块比请求的页面数大，需要拆分
        if (page->property > n) {
            struct Page *p = page + n;  // 找到剩余的空闲块起始地址
            p->property = page->property - n;  // 更新剩余块的大小
            SetPageProperty(p);  // 设置剩余块的属性标志位
            list_add(prev, &(p->page_link));  // 将剩余块重新插入空闲链表
        }

        // 更新系统中可用的页面总数
        nr_free -= n;

        // 清除当前页面块的 PG_property 标志位，表示它不再是空闲块
        ClearPageProperty(page);
    }

    // 返回找到的页面块的起始地址
    return page;
}

/*
 * default_free_pages - 将指定的页面块释放并插入到空闲链表
 * @base:   指向需要释放的第一个页面
 * @n:      需要释放的页面数量
 *
 * 该函数用于释放从 base 开始的 n 个连续页面，将这些页面标记为空闲并插入到空闲链表中。
 * 它还会尝试合并相邻的空闲块，以减少碎片化。
 */
static void
default_free_pages(struct Page *base, size_t n) {
    // 确保 n 大于 0，保证至少有一个页面需要释放
    assert(n > 0);

    // 初始化每个页面的标志位，清除保留和属性标志，并将引用计数设为 0
    struct Page *p = base;
    for (; p != base + n; p++) {
        // 确保页面既不是保留页，也不是属性页
        assert(!PageReserved(p) && !PageProperty(p));

        // 清除页面的所有标志位
        p->flags = 0;

        // 设置页面的引用计数为 0
        set_page_ref(p, 0);
    }

    // 设置第一个页面的 property 属性为 n，表示这是一个大小为 n 的空闲块
    base->property = n;

    // 设置第一个页面的 flags 中的 PG_property 位，标记它为空闲块的开始
    SetPageProperty(base);

    // 更新系统中可用的页面总数
    nr_free += n;

    // 将空闲块插入空闲链表
    if (list_empty(&free_list)) {
        // 如果空闲链表为空，将这个块直接加入链表
        list_add(&free_list, &(base->page_link));
    } else {
        // 如果空闲链表非空，找到合适的位置插入
        list_entry_t* le = &free_list;
        while ((le = list_next(le)) != &free_list) {
            struct Page* page = le2page(le, page_link);
            // 找到比 base 页面的地址大的块，将 base 插入到它之前
            if (base < page) {
                list_add_before(le, &(base->page_link));
                break;
            }
            // 如果已经到达链表末尾，将 base 插入到末尾
            else if (list_next(le) == &free_list) {
                list_add(le, &(base->page_link));
            }
        }
    }

    // 尝试与前一个块合并
    list_entry_t* le = list_prev(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        // 如果前一个块紧邻当前块，则合并这两个块
        if (p + p->property == base) {
            p->property += base->property;  // 合并块的大小
            ClearPageProperty(base);  // 清除 base 块的属性标志
            list_del(&(base->page_link));  // 从链表中删除 base 块
            base = p;  // 更新 base 指针，指向合并后的块
        }
    }

    // 尝试与后一个块合并
    le = list_next(&(base->page_link));
    if (le != &free_list) {
        p = le2page(le, page_link);
        // 如果后一个块紧邻当前块，则合并这两个块
        if (base + base->property == p) {
            base->property += p->property;  // 合并块的大小
            ClearPageProperty(p);  // 清除 p 块的属性标志
            list_del(&(p->page_link));  // 从链表中删除 p 块
        }
    }
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}

static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
    assert(alloc_pages(4) == NULL);
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
    assert((p1 = alloc_pages(3)) != NULL);
    assert(alloc_page() == NULL);
    assert(p0 + 2 == p1);

    p2 = p0 + 1;
    free_page(p0);
    free_pages(p1, 3);
    assert(PageProperty(p0) && p0->property == 1);
    assert(PageProperty(p1) && p1->property == 3);

    assert((p0 = alloc_page()) == p2 - 1);
    free_page(p0);
    assert((p0 = alloc_pages(2)) == p2 + 1);

    free_pages(p0, 2);
    free_page(p2);

    assert((p0 = alloc_pages(5)) != NULL);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}
//这个结构体在
const struct pmm_manager default_pmm_manager = {
    .name = "default_pmm_manager",
    .init = default_init,
    .init_memmap = default_init_memmap,
    .alloc_pages = default_alloc_pages,
    .free_pages = default_free_pages,
    .nr_free_pages = default_nr_free_pages,
    .check = default_check,
};

