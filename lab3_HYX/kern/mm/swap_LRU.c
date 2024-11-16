#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_clock.h>
#include <list.h>

/* [wikipedia]The simplest Page Replacement Algorithm(PRA) is a FIFO algorithm. The first-in, first-out
 * page replacement algorithm is a low-overhead algorithm that requires little book-keeping on
 * the part of the operating system. The idea is obvious from the name - the operating system
 * keeps track of all the pages in memory in a queue, with the most recent arrival at the back,
 * and the earliest arrival in front. When a page needs to be replaced, the page at the front
 * of the queue (the oldest page) is selected. While FIFO is cheap and intuitive, it performs
 * poorly in practical application. Thus, it is rarely used in its unmodified form. This
 * algorithm experiences Belady's anomaly.
 *
 * Details of FIFO PRA
 * (1) Prepare: In order to implement FIFO PRA, we should manage all swappable pages, so we can
 *              link these pages into pra_list_head according the time order. At first you should
 *              be familiar to the struct list in list.h. struct list is a simple doubly linked list
 *              implementation. You should know howto USE: list_init, list_add(list_add_after),
 *              list_add_before, list_del, list_next, list_prev. Another tricky method is to transform
 *              a general list struct to a special struct (such as struct page). You can find some MACRO:
 *              le2page (in memlayout.h), (in future labs: le2vma (in vmm.h), le2proc (in proc.h),etc.
 */

list_entry_t pra_list_headlru;
/*
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_lru_init_mm(struct mm_struct *mm)
{     
     /*LAB3 EXERCISE 4: YOUR CODE*/ 
     // 初始化pra_list_head为空链表
     list_init(&pra_list_headlru);
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     mm->sm_priv=&pra_list_headlru;
     //cprintf(" mm->sm_priv %x in lru_init_mm\n",mm->sm_priv);
     return 0;
}
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
 //LRU就是将最久为使用的页面换出，最近使用的在链表前面，越久未使用就越是在后面。
static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;//链表
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 4: YOUR CODE*/ 
    // link the most recent arrival page at the back of the pra_list_head qeueue.
    // 将页面page插入到页面链表pra_list_head的末尾
    //list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *curr=list_next(head);
    list_add(head,entry);//
    
    //删除重复的页
    while(curr!=head){
    if(curr==entry){
    list_del(curr);
    break;
    }
    curr=list_next(curr);
    }
    return 0;
}

/*
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then set the addr of addr of this page to ptr_page.
 */
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     
     list_entry_t *entry=list_prev(head);//换出为列表最后一个
        // 获取当前页面对应的Page结构指针
       struct Page* currPage=le2page(entry,pra_page_link);
        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面
        if(entry!=head){
        entry = list_next(entry);
        list_del(list_prev(entry));
        *ptr_page=currPage;
        return 0;
        }
        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
        else{
        *ptr_page=NULL;
        }
    return 0;
}


static int
_lru_check_swap(void) {
    //初始状态d1 c1 b1 a1，缺页次数：4 看函数check_content_set(void)
    
    
    swap_tick_event(check_mm_struct);
    //a0,b0,c0,d0;
    
    cprintf("write Virt Page c in lru_check_swap\n");
    pte_t *ptep = get_pte(check_mm_struct->pgdir, 0x3000, 0);
    *ptep |= PTE_A;
    assert(pgfault_num==4);
    //状态a0,b0,c1,d0;
    
    
     cprintf("write Virt Page e in lru_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    // e1 a0 b0 c1
    
    swap_tick_event(check_mm_struct);
    //c0,e0,a0,b0;
    

    cprintf("write Virt Page a in lru_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==6);
    // d1 c0 e0 a0
    
    
    cprintf("write Virt Page b in lru_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==7);
    // b1 d1 c0 e0 
    
    return 0;
}


static int
_lru_init(void)
{
    return 0;
}

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm)
{ 
list_entry_t* head = (list_entry_t*)mm->sm_priv;
 assert(head != NULL);
list_entry_t* cur = list_next(head);
while(cur!=head){
struct Page* page = le2page(cur, pra_page_link);
pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
//ptep声明一个指向页表项的指针
 if (*ptep & PTE_A){      //页面在一段时间内被访问了，拿到最前，置零
    list_entry_t* temp = list_prev(cur);
    list_del(cur);
    list_add(head,cur);
     *ptep &= ~PTE_A;//渠反置0；
     cur = temp;
 }
 cur=list_next(cur);
// cprintf("here in lru_tick_event\n");
}


return 0; 
}


struct swap_manager swap_manager_lru =
{
     .name            = "lru swap manager",
     .init            = &_lru_init,
     .init_mm         = &_lru_init_mm,
     .tick_event      = &_lru_tick_event,
     .map_swappable   = &_lru_map_swappable,
     .set_unswappable = &_lru_set_unswappable,
     .swap_out_victim = &_lru_swap_out_victim,
     .check_swap      = &_lru_check_swap,
     };
