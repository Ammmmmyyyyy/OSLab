#ifndef __KERN_MM_SWAP_H__
#define __KERN_MM_SWAP_H__

#include <defs.h>
#include <memlayout.h>
#include <pmm.h>
#include <vmm.h>
/*
Offset（24 位）：交换空间的偏移量，用于标识页在交换文件中的位置。
Reserved（7 位）：保留位，未来扩展使用。
0 bit：固定为 0。
*/

/* *
 * swap_entry_t
 * --------------------------------------------
 * |         offset        |   reserved   | 0 |
 * --------------------------------------------
 *           24 bits            7 bits    1 bit
 * */

#define MAX_SWAP_OFFSET_LIMIT                   (1 << 24)

extern size_t max_swap_offset;

/* *
 * swap_offset - takes a swap_entry (saved in pte), and returns
 * the corresponding offset in swap mem_map.
 * */
 //entry >> 8 将条目右移 8 位以获取偏移量。
 ////如果偏移量无效，则触发 panic 错误。
 #define swap_offset(entry) ({                                       \
               size_t __offset = (entry >> 8);                        \
               if (!(__offset > 0 && __offset < max_swap_offset)) {    \
                    panic("invalid swap_entry_t = %08x.\n", entry);    \
               }                                                    \
               __offset;                                            \
          })

struct swap_manager
{
     const char *name; //
     /* Global initialization for the swap manager */
     int (*init)            (void); //全局初始化函数，初始化交换管理器。
     /* Initialize the priv data inside mm_struct */
     int (*init_mm)         (struct mm_struct *mm); //为具体的内存管理结构（mm_struct）初始化私有数据。
     /* Called when tick interrupt occured */
     int (*tick_event)      (struct mm_struct *mm); //处理定时器事件（如定期触发的页面统计或回收逻辑）。
     /* Called when map a swappable page into the mm_struct */
     int (*map_swappable)   (struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in);//指向一个函数的指针，该函数在将一个可交换页面映射到 mm_struct 中时被调用。参数 swap_in 指示是否正在进行页面交换操作（从磁盘加载页面）。
     /* When a page is marked as shared, this routine is called to
      * delete the addr entry from the swap manager */
     int (*set_unswappable) (struct mm_struct *mm, uintptr_t addr);//指向一个函数的指针，该函数在标记一个页面为不可交换时被调用。这通常在页面被共享时使用，目的是从交换管理器中删除该页面的条目。
     /* Try to swap out a page, return then victim */
     int (*swap_out_victim) (struct mm_struct *mm, struct Page **ptr_page, int in_tick);//指向一个函数的指针，该函数尝试选择一个页面进行交换并返回受害者页面（被交换出去的页面）
     /* check the page relpacement algorithm */
     int (*check_swap)(void);     //指向一个函数的指针，该函数检查页面置换算法的状态。可以用来评估当前的交换策略或算法是否需要调整。
};

extern volatile int swap_init_ok;
int swap_init(void);
int swap_init_mm(struct mm_struct *mm);
int swap_tick_event(struct mm_struct *mm);
int swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in);
int swap_set_unswappable(struct mm_struct *mm, uintptr_t addr);
int swap_out(struct mm_struct *mm, int n, int in_tick);
int swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result);

//#define MEMBER_OFFSET(m,t) ((int)(&((t *)0)->m))
//#define FROM_MEMBER(m,t,a) ((t *)((char *)(a) - MEMBER_OFFSET(m,t)))

#endif
