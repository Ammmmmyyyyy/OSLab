#ifndef __KERN_MM_VMM_H__
#define __KERN_MM_VMM_H__

#include <defs.h>
#include <list.h>
#include <memlayout.h>
#include <sync.h>

//pre define
struct mm_struct;

// the virtual continuous memory area(vma), [vm_start, vm_end), 虚拟连续内存区域 (vma)，范围为 [vm_start, vm_end)
// addr belong to a vma means  vma.vm_start<= addr <vma.vm_end 地址属于 vma 的条件是 vma.vm_start <= addr < vma.vm_end
struct vma_struct {
    struct mm_struct *vm_mm; // the set of vma using the same PDT 使用相同页目录表 (PDT) 的 vma 集合
    uintptr_t vm_start;      // start addr of vma      
    uintptr_t vm_end;        // end addr of vma, not include the vm_end itself
    uint_t vm_flags;       // flags of vma
    list_entry_t list_link;  // linear list link which sorted by start addr of vma 线性链表链接，按 vma 的起始地址排序
};

// 从链表元素转换为 vma_struct 结构体的宏
#define le2vma(le, member)                  \
    to_struct((le), struct vma_struct, member)

#define VM_READ                 0x00000001
#define VM_WRITE                0x00000002
#define VM_EXEC                 0x00000004

// the control struct for a set of vma using the same PDT 管理使用相同页目录表 (PDT) 的一组 vma 的控制结构体
struct mm_struct {
    list_entry_t mmap_list;        // linear list link which sorted by start addr of vma
    struct vma_struct *mmap_cache; // current accessed vma, used for speed purpose 当前访问的 vma，用于加速查找
    pde_t *pgdir;                  // the PDT of these vma这些 vma 的页目录表 (PDT)
    int map_count;                 // the count of these vma这些 vma 的数量
    void *sm_priv;                   // the private data for swap manager交换管理器的私有数据，用于存储交换管理器在页面置换过程中所需的特定数据结构或信息
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

