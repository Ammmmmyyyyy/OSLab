#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <buddy_system.h>

struct buddy {
    size_t size;
    uintptr_t *longest;
    size_t curr_free;
    struct Page *begin_page;
};

struct buddy b[11];
int id_ = 0;

static size_t next_power_of_2(size_t size) {
    size |= size >> 1;
    size |= size >> 2;
    size |= size >> 4;
    size |= size >> 8;
    size |= size >> 16;
    return size + 1;
}

static void
buddy_init() {

}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    // 获取当前 buddy 结构体，并递增 id_ 以准备下一个
    struct buddy *bu = &b[id_++];
    size_t s;
    // 计算 n 的下一个 2 的幂
    if(!IS_POWER_OF_2(n)){
        s = next_power_of_2(n);
    }
    else{
        s = n;
    }
    // 计算额外空间
    size_t e = s - n;

    // 初始化 buddy 结构体的大小和当前可用空间
    bu->size = s;
    bu->curr_free = s - e;

    // 将最长空闲块的物理地址转换为内核虚拟地址
    bu->longest =  (uintptr_t *)PADDR(page2pa(base));

    // 开始页的地址
    bu->begin_page = base;


    // 初始化空闲块大小
    size_t node_size = bu->size * 2;

    // 填充 longest 数组
    for (int i = 0; i < 2 * bu->size - 1; i++) {
        // 如果 i+1 是 2 的幂，减小空闲块大小
        if (IS_POWER_OF_2(i + 1)) {
            node_size /= 2;
        }
        // 设置当前块的大小
        bu->longest[i] = node_size;
    }

    // 查找并标记大小为 e 的空闲块
    int id = 0;
    int num_e = 0;
    while (1) {
        if (bu->longest[id] == 1) {
            bu->longest[id] = 0; // 标记为空闲块
            num_e++;
            if(num_e == e)
                break;
        }
         // 如果当前不是叶子节点，继续向下遍历
        if (LEFT_LEAF(id) < 2 * bu->size - 1) {
            // 如果左子节点是空闲块，移动到左子节点
            if (bu->longest[LEFT_LEAF(id)] > 0) {
                id = LEFT_LEAF(id);
            }
            // 如果左子节点不可用，检查右子节点
            else if (bu->longest[RIGHT_LEAF(id)] > 0) {
                id = RIGHT_LEAF(id);
            }
        }
        // 如果当前是叶子节点，或者左右子节点都不可用，回溯到父节点
        else {
            while (id != 0 && (id == RIGHT_LEAF(PARENT(id)) || bu->longest[RIGHT_LEAF(PARENT(id))] == 0)) {
                id = PARENT(id);  // 回溯到父节点
            }
            // 如果父节点的右子节点可用，移动到右子节点
            if (id != 0) {
                id = RIGHT_LEAF(PARENT(id));
            }
        }
    }

    // 更新父节点的大小信息
    for (int id = 2 * bu->size - 1; id > 0; id--) {
        int i = PARENT(id);
        bu->longest[i] = MAX(bu->longest[LEFT_LEAF(i)], bu->longest[RIGHT_LEAF(i)]);
    }

    // 清理从 begin_page 到 curr_free 之间的页面
    struct Page *p = bu->begin_page;
    for (; p != base + bu->curr_free; p++) {
        assert(PageReserved(p)); // 确保页面是保留的
        p->flags = p->property = 0; // 重置标志和属性
        set_page_ref(p, 0); // 设置引用计数为0
    }
    base->property = n;
    SetPageProperty(base);
}


static struct Page *buddy_alloc_pages(size_t n) {
    // 确保请求的页面数量大于 0
    assert(n > 0);
    unsigned index = 0;
    unsigned node_size;
    unsigned offset = 0;

    if (!IS_POWER_OF_2(n))
        n = next_power_of_2(n);

    struct buddy *bu = NULL;
    for(int i = 0 ; i < id_ ; i++){//遍历所有的 buddy，找到一个可以满足页面请求的 buddy
        if(b[i].longest[index] > n){
            bu = &b[i];
            break;
        }
    }

    if (!bu || n > bu->curr_free) {
        return NULL;
    }

    for (node_size = bu -> size ; node_size != n ; node_size /= 2 ){
        // 检查左子节点是否满足大小需求
        if (bu->longest[LEFT_LEAF(index)] >= n)
            index = LEFT_LEAF(index);
        // 否则检查右子节点
        else
            index = RIGHT_LEAF(index);
    }

    bu->longest[index] = 0;
    offset = (index + 1) * node_size - bu->size; //bu->size 是这棵 buddy 树的根节点表示的块大小，node_size 是当前分配的块大小，index 是 longest 数组中节点的索引

    while (index) {
        index = PARENT(index);
        bu->longest[index] =MAX(bu->longest[LEFT_LEAF(index)], bu->longest[RIGHT_LEAF(index)]);
    }

    // 减少 buddy 的当前空闲页面数
    bu->curr_free -= n;

    // 返回分配的页面的起始地址
    return bu->begin_page + offset;
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    struct buddy *bu = NULL;
    for(int i = 0 ; i < id_ ; i++){//寻找base在哪个b[i]里
        struct buddy *bb = &b[i];
        if(base >= bb -> begin_page && base < bb -> begin_page + bb -> size){
            bu = bb;
        }
    }

    unsigned node_size, index = 0;
    unsigned left_longest, right_longest;
    unsigned offset = base - bu->begin_page;

    // 确保 self 指针有效，offset 在合法范围内
    assert(bu && offset >= 0 && offset < bu->size);

    // 初始化节点大小为1
    node_size = 1;
    // 计算当前节点在 longest 数组中的索引
    index = offset + bu->size - 1;

    // 从当前索引向上遍历父节点，直到找到第一个未被占用的节点
    for (; bu->longest[index]; index = PARENT(index)) {
        // 每次向上遍历，节点大小翻倍
        node_size *= 2;
        // 如果已经到达根节点，退出循环
        if (index == 0)
            return;
    }

    // 在找到的空闲节点位置设置当前节点的大小
    bu->longest[index] = node_size;
    bu->curr_free += node_size;

    // 更新父节点的大小信息
    while (index) {
        index = PARENT(index); // 移动到父节点
        node_size *= 2; // 节点大小翻倍

        // 获取左子节点和右子节点的最长空闲块大小
        left_longest = bu->longest[LEFT_LEAF(index)];
        right_longest = bu->longest[RIGHT_LEAF(index)];

        // 如果左子节点和右子节点的大小和等于当前节点大小，则更新父节点大小
        if (left_longest + right_longest == node_size)
            bu->longest[index] = node_size;
        else
            // 否则，将父节点设置为左子节点和右子节点中的较大值
            bu->longest[index] = MAX(left_longest, right_longest);
    }
}

static size_t
buddy_nr_free_pages(void) {
    size_t total_free_pages = 0;
    for (int i = 0; i < id_; i++) {
        total_free_pages += b[i].curr_free;
    }
    return total_free_pages;
}

static void
buddy_check(void) {

    cprintf("New test case: testing memory block validation...\n");

    // 分配一页内存
    struct Page *p_ = buddy_alloc_pages(1);  // 假定1表示一页
    assert(p_ != NULL);

    // 获取页面的物理地址，并转换为可用的虚拟地址。这里需要根据你的实现来完成。
    // 注意：你可能需要使用其他函数来获取/转换地址，依据你的内核/平台实现。
    uintptr_t pa = page2pa(p_);
    uintptr_t va = PADDR(pa);

    // 写入数据到分配的内存块
    int *data_ptr = (int *)va;
    *data_ptr = 0xdeadbeef;  // 写入一个魔数，稍后用于验证

    // 读取并验证数据
    assert(*data_ptr == 0xdeadbeef);

    // 释放内存块
    buddy_free_pages(p_, 1);

    // 验证是否可以正常释放，例如再次分配相同的内存块并检查地址是否相同
    struct Page *p_2 = buddy_alloc_pages(1);
    assert(p_ == p_2);  // 假定相同的内存块地址会被重新分配，这取决于你的内存分配器实现

    // 清理
    buddy_free_pages(p_2, 1);

    cprintf("Memory block validation test passed!\n");
}



const struct pmm_manager buddy_pmm_manager = {
        .name = "buddy_pmm_manager",
        .init = buddy_init,
        .init_memmap = buddy_init_memmap,
        .alloc_pages = buddy_alloc_pages,
        .free_pages = buddy_free_pages,
        .nr_free_pages = buddy_nr_free_pages,
        .check = buddy_check,
};