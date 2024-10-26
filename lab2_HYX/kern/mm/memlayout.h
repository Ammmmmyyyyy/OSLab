#ifndef __KERN_MM_MEMLAYOUT_H__
#define __KERN_MM_MEMLAYOUT_H__

/* All physical memory mapped at this address */
#define KERNBASE            0xFFFFFFFFC0200000 // = 0x80200000(物理内存里内核的起始位置, KERN_BEGIN_PADDR) + 0xFFFFFFFF40000000(偏移量, PHYSICAL_MEMORY_OFFSET)
//把原有内存映射到虚拟内存空间的最后一页
#define KMEMSIZE            0x7E00000          // the maximum amount of physical memory
// 0x7E00000 = 0x8000000 - 0x200000
// QEMU 缺省的RAM为 0x80000000到0x88000000, 128MiB, 0x80000000到0x80200000被OpenSBI占用
#define KERNTOP             (KERNBASE + KMEMSIZE) // 0x88000000对应的虚拟地址

#define PHYSICAL_MEMORY_END         0x88000000
#define PHYSICAL_MEMORY_OFFSET      0xFFFFFFFF40000000
#define KERNEL_BEGIN_PADDR          0x80200000
#define KERNEL_BEGIN_VADDR          0xFFFFFFFFC0200000


#define KSTACKPAGE          2                           // # of pages in kernel stack
#define KSTACKSIZE          (KSTACKPAGE * PGSIZE)       // sizeof kernel stack

#ifndef __ASSEMBLER__

#include <defs.h>
#include <atomic.h>
#include <list.h>

typedef uintptr_t pte_t;
typedef uintptr_t pde_t;

/* *
 * struct Page - Page descriptor structures. Each Page describes one
 * physical page. In kern/mm/pmm.h, you can find lots of useful functions
 * that convert Page to other data types, such as physical address.
 * */
struct Page {
    int ref;                        // page frame's reference counter
    uint64_t flags;                 // array of flags that describe the status of the page frame  是一个 64 位无符号整数，作为页面状态的标志位数组（位图）。
    unsigned int property;          // the num of free block, used in first fit pm manager //用来表示当前空闲块的大小。特别是在合并相邻的连续空闲页面时，这个字段会记录块的大小。
    list_entry_t page_link;         // free list link
};

/* Flags describing the status of a page frame */
#define PG_reserved                 0       // if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0 
#define PG_property                 1       // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.

#define SetPageReserved(page)       set_bit(PG_reserved, &((page)->flags))  //将 page 的 flags 中的 PG_reserved 位设置为 1。
#define ClearPageReserved(page)     clear_bit(PG_reserved, &((page)->flags)) //将 page 的 flags 中的 PG_reserved 位清除为 0。
#define PageReserved(page)          test_bit(PG_reserved, &((page)->flags)) //检查 page 的 flags 中的 PG_reserved 位。
#define SetPageProperty(page)       set_bit(PG_property, &((page)->flags)) //将 page 的 flags 中的 PG_property 位设置为 1。可用
#define ClearPageProperty(page)     clear_bit(PG_property, &((page)->flags)) //将 page 的 flags 中的 PG_property 位清除为 0。取消页面的属性标记，表示该页面不再具有该属性。
#define PageProperty(page)          test_bit(PG_property, &((page)->flags)) //检查 page 的 flags 中的 PG_property ；如果该位为 1，则返回 true，表示页面具有某种属性；否则返回 false

// convert list entry to page
#define le2page(le, member)                 \
    to_struct((le), struct Page, member) //用于从链表节点指针 le 转换回其所属的 struct Page 结构体

/* free_area_t - maintains a doubly linked list to record free (unused) pages */
typedef struct {
    list_entry_t free_list;         // the list header
    unsigned int nr_free;           // number of free pages in this free list
} free_area_t;

#endif /* !__ASSEMBLER__ */

#endif /* !__KERN_MM_MEMLAYOUT_H__ */
