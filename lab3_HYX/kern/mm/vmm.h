#ifndef __KERN_MM_VMM_H__
#define __KERN_MM_VMM_H__

#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <sync.h>


/////////////定义了一个虚拟内存管理模块（Virtual Memory Management, VMM），用于操作系统中虚拟内存的管理和操作///////////////

//typedef uintptr_t pde_t;uintptr_t: 这是一个无符号整型，用于存储指针的整数表示
//pre define
struct mm_struct;//mm_struct 表示一个进程的虚拟内存管理器，它管理一个进程的所有 VMA//一个 VMA 是虚拟地址空间中一段连续的地址范围，通常用于表示某种特定用途的内存段例如：代码段：

// the virtual continuous memory area(vma), [vm_start, vm_end), 
// addr belong to a vma means  vma.vm_start<= addr <vma.vm_end 
struct vma_struct { //表示一个进程的虚拟内存区域。
    struct mm_struct *vm_mm; // the set of vma using the same PDT  指向与该 VMA 相关的内存管理结构体（mm_struct）的指针,这个字段表示使用相同页目录表（Page Directory Table, PDT）的 VMA 集合
    uintptr_t vm_start;      // start addr of vma      
    uintptr_t vm_end;        // end addr of vma, not include the vm_end itself
    uint_t vm_flags;       // flags of vma VMA 的标志，通常用于描述该内存区域的属性，如是否可读、可写、可执行等。
    list_entry_t list_link;  // linear list link which sorted by start addr of vma 链表节点，类型为 list_entry_t，用于将该 VMA 链接到其他 VMA 的链表中
    /*
    list_link 使得单个 VMA 能够被插入到 mmap_list 中，以形成完整的 VMA 列表。
    mmap_list 是链表的头部，管理整个进程的所有 VMA，属于 mm_struct。
   list_link 是链表的节点，链接每个单独的 VMA，属于 vma_struct。
    */
};
/*
#define to_struct(ptr, type, member)                               \
    ((type *)((char *)(ptr) - offsetof(type, member)))
*/
#define le2vma(le, member)                  \
    to_struct((le), struct vma_struct, member)

#define VM_READ                 0x00000001
#define VM_WRITE                0x00000002
#define VM_EXEC                 0x00000004

// the control struct for a set of vma using the same PDT
struct mm_struct {
    list_entry_t mmap_list;        // linear list link which sorted by start addr of vma这是一个链表节点，用于链接进程的虚拟内存区域（VMA）
    struct vma_struct *mmap_cache; // current accessed vma, used for speed purpose 指向当前访问的 VMA 的指针。这是一个缓存，用于提高性能，因为在频繁访问相同 VMA 时，可以避免每次都遍历整个链表。
    pde_t *pgdir;                  // the PDT of these vma 页目录表（Page Directory Table）的指针。页目录表用于管理虚拟地址到物理地址的映射，是实现虚拟内存的核心结构之一。
    int map_count;                 // the count of these vma //表示当前进程中 VMA 的数量
    void *sm_priv;                   // the private data for swap manager //指向交换管理器的私有数据。这个字段可以存储与内存交换（swap）相关的特定信息，以支持内存分页和管理策略。
};

struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr);
struct vma_struct *vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags);
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma);

struct mm_struct *mm_create(void);
void mm_destroy(struct mm_struct *mm);

void vmm_init(void);

int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr);

extern volatile unsigned int pgfault_num;
extern struct mm_struct *check_mm_struct;

#endif /* !__KERN_MM_VMM_H__ */

