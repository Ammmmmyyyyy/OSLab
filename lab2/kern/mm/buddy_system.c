#include <pmm.h>
#include <list.h>
#include <string.h>
#include <stdio.h>
#include <buddy_system.h>

struct buddy {
    size_t size;
    uintptr_t *longest;
    size_t longest_num;
    size_t total_num;
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
buddy_init_memmap(struct Page *base, size_t n) {
    // 获取当前 buddy 结构体，并递增 id_ 以准备下一个
    struct buddy *bu = &b[id_++];

    // 计算 n 的下一个 2 的幂
    if(!IS_POWER_OF_2(n)){
        size_t s = next_power_of_2(n);
    }
    else{
        size_t s = n;
    }
    // 计算额外空间
    size_t e = s - n;

    // 初始化 buddy 结构体的大小和当前可用空间
    bu->size = s;
    bu->curr_free = s - e;

    // 将最长空闲块的物理地址转换为内核虚拟地址
    bu->longest = KADDR(page2pa(base));

    // 计算开始页的地址，ROUNDUP 确保对齐到页大小
    bu->begin_page = pa2page(PADDR(ROUNDUP(bu->longest + 2 * s * sizeof(uintptr_t), PGSIZE)));

    // 计算 longest 数组中有效块的数量
    bu->longest_num = bu->begin_page - base;

    // 计算总页数
    bu->total_num = n - bu->longest_num;

    // 初始化空闲块大小
    size_t sn = bu->size * 2;

    // 填充 longest 数组
    for (int i = 0; i < 2 * bu->size - 1; i++) {
        // 如果 i+1 是 2 的幂，减小空闲块大小
        if (IS_POWER_OF_2(i + 1)) {
            sn /= 2;
        }
        // 设置当前块的大小
        bu->longest[i] = sn;
    }

    // 查找并标记大小为 e 的空闲块
    int id = 0;
    while (1) {
        if (bu->longest[id] == e) {
            bu->longest[id] = 0; // 标记为空闲块
            break;
        }
        // 移动到右子节点
        id = RIGHT_LEAF(id);
    }

    // 更新父节点的大小信息
    while (id) {
        id = PARENT(id);
        bu->longest[id] = MAX(bu->longest[LEFT_LEAF(id)], bu->longest[RIGHT_LEAF(id)]);
    }

    // 清理从 begin_page 到 curr_free 之间的页面
    struct Page *p = bu->begin_page;
    for (; p != base + bu->curr_free; p++) {
        assert(PageReserved(p)); // 确保页面是保留的
        p->flags = p->property = 0; // 重置标志和属性
        set_page_ref(p, 0); // 设置引用计数为0
    }
}


struct buddy* buddy_new( int size ) {
  struct buddy* self;
  unsigned node_size;
  int i;

  if (size < 1 || !IS_POWER_OF_2(size))
    return NULL;

  self = (struct buddy2*)ALLOC( 2 * size * sizeof(unsigned));
  self->size = size;
  node_size = size * 2;

  for (i = 0; i < 2 * size - 1; ++i) {
    if (IS_POWER_OF_2(i+1))
      node_size /= 2;
    self->longest[i] = node_size;
  }
  return self;
}

static struct Page *buddy_alloc_pages(size_t n) {
    // 确保请求的页面数量大于 0
    assert(n > 0);
    unsigned index = 0;
    unsigned node_size;
    unsigned offset = 0;

    if (!IS_POWER_OF_2(n))
        n = fixsize(size);

    struct buddy *bu = NULL;
    for(int i = 0 ; i < id_ ; i++){//遍历所有的 buddy，找到一个可以满足页面请求的 buddy
        if(b[i].longest[i] > n){
            bu = &b[i];
            break;
        }
    }

    if (!buddy) {
        return NULL;
    }

    for (node_size = bu -> size ; node_size != n ; node_size /= 2 ){
        // 检查左子节点是否满足大小需求
        if (buddy->longest[LEFT_LEAF(index)] >= n)
            index = LEFT_LEAF(index);
        // 否则检查右子节点
        else
            index = RIGHT_LEAF(index);
    }

    bu->longest[index] = 0;
    offset = (index + 1) * node_size - bu->size;

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
            bu = t;
        }
    }

    unsigned node_size, index = 0;
    unsigned left_longest, right_longest;

    // 确保 self 指针有效，offset 在合法范围内
    assert(bu && offset >= 0 && offset < size);

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
    buddy->curr_free += sn;

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