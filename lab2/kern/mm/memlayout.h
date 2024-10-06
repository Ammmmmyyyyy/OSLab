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
    int ref;                        // page frame's reference counter   页帧的引用计数
    uint64_t flags;                 // array of flags that describe the status of the page frame    描述页帧状态的标志位
    unsigned int property;          // the num of free block, used in first fit pm manager  记录空闲块的大小，在首次适配（first fit）内存分配中使用
    list_entry_t page_link;         // free list link   链表节点，用于将页帧加入空闲链表
};

/* Flags describing the status of a page frame */
#define PG_reserved                 0       // if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0 
#define PG_property                 1       // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.

#define SetPageReserved(page)       set_bit(PG_reserved, &((page)->flags))//设置页面的 PG_reserved 标志为 1，表示该页面被保留（即不可以被分配或使用）。
#define ClearPageReserved(page)     clear_bit(PG_reserved, &((page)->flags))//清除页面的 PG_reserved 标志，表示该页面不再被保留，可以被分配。
#define PageReserved(page)          test_bit(PG_reserved, &((page)->flags))//检查页面的 PG_reserved 标志。如果该标志为 1，则返回真，表示该页面是保留的；否则返回假。
#define SetPageProperty(page)       set_bit(PG_property, &((page)->flags))//设置页面的 PG_property 标志为 1
#define ClearPageProperty(page)     clear_bit(PG_property, &((page)->flags))//清除页面的 PG_property 标志
#define PageProperty(page)          test_bit(PG_property, &((page)->flags))//检查页面的 PG_property 标志。如果该标志为 1，则返回真，表示该页面具有该属性；否则返回假。

// convert list entry to page
#define le2page(le, member)                 \
    to_struct((le), struct Page, member)//le：链表节点，通常是 struct list_entry 类型的指针 member：struct Page 结构体中的链表成员（即链表节点在 struct Page 中的字段名）

/* free_area_t - maintains a doubly linked list to record free (unused) pages */
typedef struct {
    list_entry_t free_list;         // the list header
    unsigned int nr_free;           // number of free pages in this free list
} free_area_t;

#endif /* !__ASSEMBLER__ */

#endif /* !__KERN_MM_MEMLAYOUT_H__ */
