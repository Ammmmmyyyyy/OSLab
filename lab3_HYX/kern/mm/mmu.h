#ifndef __KERN_MM_MMU_H__
#define __KERN_MM_MMU_H__

#ifndef __ASSEMBLER__
#include <defs.h>
#endif /* !__ASSEMBLER__ */

// A linear address 'la' has a four-part structure as follows:
//
// +--------9-------+-------9--------+-------9--------+---------12----------+
// | Page Directory | Page Directory |   Page Table   | Offset within Page  |
// |     Index 1    |    Index 2     |                |                     |
// +----------------+----------------+----------------+---------------------+
//  \-- PDX1(la) --/ \-- PDX0(la) --/ \--- PTX(la) --/ \---- PGOFF(la) ----/
//  \-------------------PPN(la)----------------------/
//
// The PDX1, PDX0, PTX, PGOFF, and PPN macros decompose linear addresses as shown.
// To construct a linear address la from PDX(la), PTX(la), and PGOFF(la),
// use PGADDR(PDX(la), PTX(la), PGOFF(la)).

// RISC-V uses 39-bit virtual address to access 56-bit physical address!
// Sv39 virtual address:
// +----9----+----9---+----9---+---12--+
// |  VPN[2] | VPN[1] | VPN[0] | PGOFF |
// +---------+----+---+--------+-------+
//
// Sv39 physical address:
// +----26---+----9---+----9---+---12--+
// |  PPN[2] | PPN[1] | PPN[0] | PGOFF |
// +---------+----+---+--------+-------+
//
// Sv39 page table entry:
// +----26---+----9---+----9---+---2----+-------8-------+
// |  PPN[2] | PPN[1] | PPN[0] |Reserved|D|A|G|U|X|W|R|V|
// +---------+----+---+--------+--------+---------------+

// page directory index
#define PDX1(la) ((((uintptr_t)(la)) >> PDX1SHIFT) & 0x1FF)//获取一级页目录索引。
#define PDX0(la) ((((uintptr_t)(la)) >> PDX0SHIFT) & 0x1FF)//获取二级页目录索引。

// page table index
#define PTX(la) ((((uintptr_t)(la)) >> PTXSHIFT) & 0x1FF)//获取页表索引。

// page number field of address
#define PPN(la) (((uintptr_t)(la)) >> PTXSHIFT)//获取页面编号（去掉偏移部分的线性地址）。。

// offset in page
#define PGOFF(la) (((uintptr_t)(la)) & 0xFFF)// 获取页内偏移。

// construct linear address from indexes and offset
#define PGADDR(d1, d0, t, o) ((uintptr_t)((d1) << PDX1SHIFT | (d0) << PDX0SHIFT | (t) << PTXSHIFT | (o)))

// address in page table or page directory entry
// 把页表项里存储的地址拿出
#define PTE_ADDR(pte)   (((uintptr_t)(pte) & ~0x3FF) << (PTXSHIFT - PTE_PPN_SHIFT))//将高位物理地址段 (PPN) 移出低 10 位标志位。
#define PDE_ADDR(pde)   PTE_ADDR(pde)

/* page directory and page table constants */
#define NPDEENTRY       512                    // page directory entries per page directory // 每页目录的条目数
#define NPTEENTRY       512                    // page table entries per page table每页表的条目数

#define PGSIZE          4096                    // bytes mapped by a page页面大小 (4KB)
#define PGSHIFT         12                      // log2(PGSIZE)//页面大小的对数 (log2(4096))
#define PTSIZE          (PGSIZE * NPTEENTRY)    // bytes mapped by a page directory entry//一个页目录条目映射的总字节数
#define PTSHIFT         21                      // log2(PTSIZE)页目录条目大小的对数 (log2(PTSIZE))

#define PTXSHIFT        12                      // offset of PTX in a linear address页表索引的位移
#define PDX0SHIFT       21                      // offset of PDX0 in a linear address二级页目录索引的位移
#define PDX1SHIFT       30                      // offset of PDX0 in a linear address一级页目录索引的位移
#define PTE_PPN_SHIFT   10                      // offset of PPN in a physical address页表条目中的物理页号偏移

// page table entry (PTE) fields
#define PTE_V     0x001 // Valid
#define PTE_R     0x002 // Read
#define PTE_W     0x004 // Write
#define PTE_X     0x008 // Execute
#define PTE_U     0x010 // User
#define PTE_G     0x020 // Global
#define PTE_A     0x040 // Accessed
#define PTE_D     0x080 // Dirty
#define PTE_SOFT  0x300 // Reserved for Software

#define PAGE_TABLE_DIR (PTE_V)
#define READ_ONLY (PTE_R | PTE_V)
#define READ_WRITE (PTE_R | PTE_W | PTE_V)//可读可写页面。
#define EXEC_ONLY (PTE_X | PTE_V)
#define READ_EXEC (PTE_R | PTE_X | PTE_V)
#define READ_WRITE_EXEC (PTE_R | PTE_W | PTE_X | PTE_V)

#define PTE_USER (PTE_R | PTE_W | PTE_X | PTE_U | PTE_V)//用户模式可读写执行页面。

#endif /* !__KERN_MM_MMU_H__ */
