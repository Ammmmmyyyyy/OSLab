#include <pmm.h>
#include <buddy_system.h>

struct buddy {
    size_t size;
    uintptr_t *longest;
    size_t curr_free;
    struct Page *begin_page;
};

struct buddy b[MAX_BUDDY_NUMBER];
int id_ = 0;

static size_t next_power_of_2(size_t size) {
    size |= size >> 1;
    size |= size >> 2;
    size |= size >> 4;
    size |= size >> 8;
    size |= size >> 16;
    return size + 1;
}
static size_t last_power_of_2(size_t n){
    // 将n最高位的1保留，其余位为0
    n |= (n >> 1);
    n |= (n >> 2);
    n |= (n >> 4);
    n |= (n >> 8);
    n |= (n >> 16);

    // 返回小于等于n的最大2的幂
    return n - (n >> 1);
}

static void
buddy_init() {

}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    cprintf("n: %d\n", n);
    struct buddy *buddy = &b[id_++];
    size_t s;
    if(!IS_POWER_OF_2(n)){
        s = last_power_of_2(n);
    }
    else{
        s = n;
    }
    

    buddy->size = s;//buddy的大小
    buddy->curr_free = s;//当前空闲的可用页数
    buddy->longest = KADDR(page2pa(base));// 指向 base 的内存地址
    buddy->begin_page = base;

    size_t node_size = buddy->size * 2;

    for (int i = 0; i < 2 * buddy->size - 1; i++) {
        if (IS_POWER_OF_2(i + 1)) {
            node_size /= 2;
        }
        buddy->longest[i] = node_size;
    }

    struct Page *p = buddy->begin_page;
    for (; p != base + buddy->curr_free; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = s;
    SetPageProperty(base);
}

// 定义一个函数用于在 buddy system 中分配页面
static struct Page *buddy_alloc_pages(size_t n) {
    // 确保请求的页面数量大于 0
    assert(n > 0);

    // 如果 n 不是 2 的幂，将其调整为下一个最接近的 2 的幂
    if (!IS_POWER_OF_2(n))
        n = next_power_of_2(n);

    size_t index = 0;
    size_t node_size;
    size_t offset = 0;

    struct buddy *buddy = NULL;

    // 遍历所有的 buddy，找到一个可以满足页面请求的 buddy
    for (int i = 0; i < id_; i++) {
        if (b[i].longest[index] >= n) {
            buddy = &b[i];
            break;
        }
    }

    // 如果没有找到合适的 buddy，则返回 NULL，表示分配失败
    if (!buddy) {
        return NULL;
    }

    // 在 buddy 的管理树中查找一个大小适中的块来分配
    for (node_size = buddy->size; node_size != n; node_size /= 2) {
        // 检查左子节点是否满足大小需求
        if (buddy->longest[LEFT_LEAF(index)] >= n)
            index = LEFT_LEAF(index);
        // 否则检查右子节点
        else
            index = RIGHT_LEAF(index);
    }

    // 将找到的块标记为已用
    buddy->longest[index] = 0;

    // 计算该块在 buddy 的页面范围内的偏移量
    offset = (index + 1) * node_size - buddy->size;

    // 向上更新树的状态，确保父节点表示它的两个子节点中较大的空闲块
    while (index) {
        index = PARENT(index);
        buddy->longest[index] = MAX(buddy->longest[LEFT_LEAF(index)], buddy->longest[RIGHT_LEAF(index)]);
    }

    // 减少 buddy 的当前空闲页面数
    buddy->curr_free -= n;

    // 返回分配的页面的起始地址
    return buddy->begin_page + offset;
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
    uintptr_t *va = KADDR(pa);

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
