#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <assert.h>
#include <slub_pmm.h>
#include <pmm.h>
#include <stdio.h>

//这个结构体定义了一个小块内存分配的单元，称为 "slob"（Simple List of Blocks）。它用于管理分配的内存块。
struct slob_block {
	int units;//块的大小,单位是“块”（units）,每个块的大小由 SLOB_UNIT 定义。
	struct slob_block *next;//下一个slot块
};
typedef struct slob_block slob_t;

#define SLOB_UNIT sizeof(slob_t) //每个内存块的基本单位是 slob_t 结构体的大小，也就是 sizeof(slob_t)
#define SLOB_UNITS(size) (((size) + SLOB_UNIT - 1)/SLOB_UNIT) //这个宏用于将请求的字节数转换为需要分配的内存块数。这个公式确保总的分配内存是 size 字节或更大，并且向上取整为完整的 SLOB_UNIT 数量。

struct bigblock {
	int order;//order 表示大块内存的大小，通常和页大小相关联.举例来说，如果 order 是 4096，表示分配 1 页（假设每页为 4KB），如果 order 是 8196，表示分配 2 页（即 8KB），依此类推。
	void *pages;//这个字段存储了一个指向分配的大块内存的起始地址。pages 是一个通用指针，指向内存中的一块区域，这块区域的大小是 2^order 页。
	struct bigblock *next; //next 指向下一个 bigblock，用于将多个大块内存块链接成一个链表结构。
};
typedef struct bigblock bigblock_t;

static slob_t arena = { .next = &arena, .units = 1 }; //这个声明初始化了一个 slob_t 类型的变量 arena，这是一个用于管理小块内存分配的结构体。它是链表管理的起始点或初始状态。初始化 units 为 1，表示当前 arena 块的大小是 1 个 slob_t 单位。
static slob_t *slobfree = &arena;//slobfree：用于指向当前空闲的小块内存的链表头。初始化为 arena，表示当前没有其他可用的内存块（因为 arena 自指向自己）。
static bigblock_t *bigblocks;

static void slob_free(void *b, int size);//一个静态函数声明，表示在后续的代码中将实现一个函数 slob_free，用于释放小块内存。

static void *slob_alloc(size_t size) //函数返回类型是 void*，即返回指向已分配内存块的指针。
{
    assert(size < PGSIZE);//确保请求的内存大小小于页面大小（PGSIZE，通常为 4KB），这是因为 slob_alloc 函数用于处理小块内存分配，如果内存大小大于等于一页，就不应该使用该函数。超出页面大小的分配将由其他机制（例如大块分配）处理。

	slob_t *prev, *cur;//prev 和 cur 都是 slob_t* 类型的指针，用于遍历空闲块链表。
	int  units = SLOB_UNITS(size);

	prev = slobfree;
	cur = prev->next;	
	while(1){
	     if (cur->units >= units) { //cur->units 代表当前块的大小（以 slob_t 为单位）。如果当前块的大小大于或等于请求的大小（units），则说明该块可以满足分配请求。

			if (cur->units == units)//如果当前块的大小刚好等于请求的大小，则将该块从空闲链表中移除（prev->next = cur->next），因为它将被完全分配。
				prev->next = cur->next;
			else {
			        //太大就要合并一部分然后把剩余的分给在下一块
				prev->next = cur + units;
				prev->next->units = cur->units - units;
				prev->next->next = cur->next;
				cur->units = units;
			}
			slobfree = prev;
			return cur;
             }
	     if (cur == slobfree) {
			//if (size == PGSIZE)
			//	return 0;
			//如果没有找到合适的块，调用 alloc_pages(1) 分配一整页的内存，并将该页转换为 slob_t 类型指针。如果分配失败，返回 0。
			cur = (slob_t *)alloc_pages(1);
			if (!cur)
				return 0;
			slob_free(cur, PGSIZE);//将新分配的页面释放到空闲列表
			cur = slobfree;
	     }
	     prev=cur;
	     cur=cur->next;
	}
}

static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;//cur：用于遍历空闲链表的指针。b：将 block 转换为 slob_t* 类型，这是释放的内存块。slob_t 是内存块的基本结构，表示一个小块内存单元。
	if (!block)
		return;
	if (size)
		b->units = SLOB_UNITS(size);

	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)//这里通过遍历空闲链表，寻找释放块 b 应该插入的位置。遍历的链表是从 slobfree 开始的，cur 表示当前遍历到的空闲块。
		if (cur >= cur->next && (b > cur || b < cur->next))
			break;
        /*
        检查释放的块 b 是否与它后面的空闲块 cur->next 相邻。
      如果相邻：将它们合并，即：
   b->units += cur->next->units;：增加 b 的大小，包含 cur->next 的单元数。
   b->next = cur->next->next;：跳过 cur->next，直接指向它的后继块，完成链表的合并。
        */
	if (b + b->units == cur->next) {
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else{
		b->next = cur->next;
		}
     //与前面块相邻
	if (cur + cur->units == b) {
		cur->units += b->units;
		cur->next = b->next;
	} else{
		cur->next = b;
		}

	slobfree = cur;
}

void 
slub_init(void) {
    cprintf("slub_init() succeeded!\n");
}

void *slub_alloc(size_t size)
{
      //m：用于存储 slob_alloc 分配的小块内存块。
     //bb：用于存储大块内存块的 bigblock_t 结构体指针。
	slob_t *m;
	bigblock_t *bb;

	if (size < PGSIZE - SLOB_UNIT) {//如果 size 小于 PGSIZE - SLOB_UNIT（页面大小减去一个 slob_t 的大小），则认为这是一个小块内存请求。
		//m = slob_alloc(size + SLOB_UNIT);
		m = slob_alloc(size);
		return m ? (void *)(m + 1) : 0;
	}

	bb = slob_alloc(sizeof(bigblock_t));//尽管 slob_alloc() 返回的是一个 slob_t*，但从内存分配的角度来看，slob_t* 实际上就是一个指向内存块的指针。slob_t* 只是 void* 类型的替代形式，用于在分配时将管理结构与内存关联起来。
	if (!bb)
		return 0;

	//bb->order = ((size-1) >> PGSHIFT) + 1;//个公式通过右移 PGSHIFT 位，将 size 转换为页面数
	bb->order=size/4096+1;
	bb->pages = (void *)alloc_pages(bb->order);

	if (bb->pages) {
		bb->next = bigblocks;
		bigblocks = bb;
		return bb->pages;
	}

	slob_free(bb, sizeof(bigblock_t));//如果大块页面分配失败，释放 bigblock_t 结构体所占用的内存。调用 slob_free(bb, sizeof(bigblock_t)) 将 bb 释放回空闲链表，然后返回 0，表示分配失败
	return 0;
}


void slub_free(void *block)//这段代码实现了 slub_free 函数，用于释放通过 slub_alloc 分配的内存
{

	if (!block)
		return;

	if (!((unsigned long)block & (PGSIZE-1))) {//这个条件判断传入的 block 是否为页面对齐的地址（即大块内存）。页面对齐意味着 block 的地址是 PGSIZE（通常为 4KB）的倍数。是提取 block 地址的最低位，判断它是否与 PGSIZE 对齐。这是与号，就是0xFFF与12个0
	        bigblock_t *bb, **last = &bigblocks;
		bb=bigblocks;
	        while(bb){
			if (bb->pages == block) {//如果 bb->pages 指向的内存块与 block 相同，说明找到了对应的大块内存块。
				*last = bb->next;
				free_pages((struct Page *)block, bb->order);//调用 free_pages 函数，释放大块内存块，bb->order 指示了分配的页数。
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
	                last=&bb->next;
	                bb=bb->next;
	        }
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
//这段代码实现了一个函数 slub_size，用于返回传入的 block（内存块）的实际大小。
unsigned int slub_size(const void *block)
{
	bigblock_t *bb;
	unsigned long flags;

	if (!block)
		return 0;

	if (!((unsigned long)block & (PGSIZE-1))) {
		for (bb = bigblocks; bb; bb = bb->next)
			if (bb->pages == block) {
				return bb->order << PGSHIFT;//左移12位
			}
	}

	return ((slob_t *)block - 1)->units * SLOB_UNIT;//小块内存在分配时，slob_t 结构体存储在内存块的前面，所以通过 block - 1 向前偏移一个 slob_t 单位，访问管理该块的 slob_t 结构体。
}

int slobfree_len()
{
    int len = 0;
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
        len ++;
    return len;
}

void slub_check()
{
    cprintf("slub check begin\n");
    cprintf("slobfree len: %d\n", slobfree_len());
    void* p1 = slub_alloc(4096);
    cprintf("slobfree len: %d\n", slobfree_len());
    void* p2 = slub_alloc(2);
    void* p3 = slub_alloc(2);
    cprintf("slobfree len: %d\n", slobfree_len());
    slub_free(p2);
    cprintf("slobfree len: %d\n", slobfree_len());
    slub_free(p3);
    cprintf("slobfree len: %d\n", slobfree_len());
    cprintf("slub check end\n");
}

