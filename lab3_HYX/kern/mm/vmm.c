#include <vmm.h>
#include <sync.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <error.h>
#include <pmm.h>
#include <riscv.h>
#include <swap.h>

/* 
  vmm design include two parts: mm_struct (mm) & vma_struct (vma)
  mm is the memory manager for the set of continuous virtual memory  
  area which have the same PDT. vma is a continuous virtual memory area.
  There a linear link list for vma & a redblack link list for vma in mm.
---------------
  mm related functions:
   golbal functions
     struct mm_struct * mm_create(void)
     void mm_destroy(struct mm_struct *mm)
     int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
--------------
  vma related functions:
   global functions
     struct vma_struct * vma_create (uintptr_t vm_start, uintptr_t vm_end,...)
     void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
     struct vma_struct * find_vma(struct mm_struct *mm, uintptr_t addr)
   local functions
     inline void check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
---------------
   check correctness functions
     void check_vmm(void);
     void check_vma_struct(void);
     void check_pgfault(void);
*/

//vma 是“虚拟内存区域”（Virtual Memory Area）的缩写，通常在操作系统和内存管理的上下文中使用。每个进程在其虚拟地址空间中可能有多个 VMA，每个 VMA 代表一块连续的虚拟内存，具有特定的属性和状态。
//内存管理结构 (vm_mm): 指向该 VMA 所属的内存管理结构体（通常是 mm_struct），该结构体包含了该进程的内存信息。
// szx func : print_vma and print_mm
void print_vma(char *name, struct vma_struct *vma){//作用是打印出一个 vma_struct 结构体的各个属性
	cprintf("-- %s print_vma --\n", name);
	cprintf("   mm_struct: %p\n",vma->vm_mm);
	cprintf("   vm_start,vm_end: %x,%x\n",vma->vm_start,vma->vm_end);
	cprintf("   vm_flags: %x\n",vma->vm_flags);
	cprintf("   list_entry_t: %p\n",&vma->list_link);
}

void print_mm(char *name, struct mm_struct *mm){
	cprintf("-- %s print_mm --\n",name);
	cprintf("   mmap_list: %p\n",&mm->mmap_list);
	cprintf("   map_count: %d\n",mm->map_count);
	list_entry_t *list = &mm->mmap_list;
	for(int i=0;i<mm->map_count;i++){
		list = list_next(list);
		print_vma(name, le2vma(list,list_link));
	}
}

static void check_vmm(void);
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) { //目的是为进程分配一个新的内存管理结构体 mm_struct 并进行初始化
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));

    if (mm != NULL) {
        list_init(&(mm->mmap_list));//list_init(list_entry_t *elm) {elm->prev = elm->next = elm;}
        mm->mmap_cache = NULL;
        mm->pgdir = NULL;
        mm->map_count = 0;

        if (swap_init_ok) swap_init_mm(mm);//如果交换管理（swap management）初始化成功 (swap_init_ok 为真)，则调用 swap_init_mm(mm) 对新的内存管理结构体进行交换管理相关的初始化。
        else mm->sm_priv = NULL;//如果交换管理未成功，sm_priv 字段被设置为 NULL。
    }
    return mm;
}

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {//分配并初始化一个新的 VMA 结构体。
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));

    if (vma != NULL) {
        vma->vm_start = vm_start;
        vma->vm_end = vm_end;
        vma->vm_flags = vm_flags;
    }
    return vma;
}


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {//用于在给定的内存管理结构体 mm_struct 中查找与特定地址 addr 相关的虚拟内存区域（VMA）
    struct vma_struct *vma = NULL;
    if (mm != NULL) {
        vma = mm->mmap_cache;//从内存管理结构体中提取 mmap_cache 缓存的 VMA。mmap_cache缓存了最近一次访问的 VMA
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {//尝试使用 mmap_cache 中缓存的 VMA。如果缓存中的 VMA 不存在或不包含地址 addr，则继续查找。
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
                    vma = le2vma(le, list_link);
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
                    vma = NULL;
                }
        }
        if (vma != NULL) {
            mm->mmap_cache = vma;
        }
    }
    return vma;
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {//用于检查两个虚拟内存区域（VMA）是否存在 重叠
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
}


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {//循环继续直到找到一个起始地址大于新 VMA 的位置
                break;
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
    }
    if (le_next != list) {
        check_vma_overlap(vma, le2vma(le_next, list_link));
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
}

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
    mm=NULL;
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
    check_vmm();
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();//调用 nr_free_pages() 函数获取当前系统中空闲页面的数量，并将其存储在变量 nr_free_pages_store 中。
    check_vma_struct(); //用于验证虚拟内存区域（VMA）的结构和状态。
    check_pgfault();

    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作 这是因为在使用 Sv39 三级页表时，会占用一个额外的内存页。
    assert(nr_free_pages_store == nr_free_pages());//使用 assert 检查当前的空闲页面数量是否与 nr_free_pages_store 相等.如果不相等，则说明在执行检查的过程中出现了问题，这将导致程序终止（在调试模式下）。

    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {//用于检查和验证虚拟内存区域（VMA）结构及其操作的正确性。
    size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
        assert(le != &(mm->mmap_list));//保证mm中有 vma
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
        struct vma_struct *vma1 = find_vma(mm, i);
        assert(vma1 != NULL);
        struct vma_struct *vma2 = find_vma(mm, i+1);
        assert(vma2 != NULL);
        struct vma_struct *vma3 = find_vma(mm, i+2);
        assert(vma3 == NULL);
        struct vma_struct *vma4 = find_vma(mm, i+3);
        assert(vma4 == NULL);
        struct vma_struct *vma5 = find_vma(mm, i+4);
        assert(vma5 == NULL);

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
        struct vma_struct *vma_below_5= find_vma(mm,i);
        if (vma_below_5 != NULL ) {
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);

    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_vma_struct() succeeded!\n");
}

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) { //用于检查页面故障处理程序的正确性
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();

    check_mm_struct = mm_create();

    assert(check_mm_struct != NULL);
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;//将全局页目录 boot_pgdir 赋给 mm->pgdir，作为该内存管理结构的页表。
    assert(pgdir[0] == 0);//确保页目录的第一个条目为空，表示当前还没有分配任何页面。

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {//循环写入数据到 addr 开始的 100 字节，并计算其总和
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);//验证页面故障处理程序是否正确分配了页面并允许读写操作。
//移除与 addr 对应的物理页面。调用 free_page 释放与页目录中第一个条目对应的页面，并将该条目置为零。
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));

    free_page(pde2page(pgdir[0]));

    pgdir[0] = 0;

    mm->pgdir = NULL;
    mm_destroy(mm);

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作

    assert(nr_free_pages_store == nr_free_pages());

    cprintf("check_pgfault() succeeded!\n");
}
//page fault number
volatile unsigned int pgfault_num=0;

/* do_pgfault - interrupt handler to process the page fault execption
 * @mm         : the control struct for a set of vma using the same PDT
 * @error_code : the error code recorded in trapframe->tf_err which is setted by x86 hardware
 * @addr       : the addr which causes a memory access exception, (the contents of the CR2 register)
 *
 * CALL GRAPH: trap--> trap_dispatch-->pgfault_handler-->do_pgfault
 * The processor provides ucore's do_pgfault function with two items of information to aid in diagnosing
 * the exception and recovering from it.
 *   (1) The contents of the CR2 register. The processor loads the CR2 register with the
 *       32-bit linear address that generated the exception. The do_pgfault fun can
 *       use this address to locate the corresponding page directory and page-table
 *       entries.
 *   (2) An error code on the kernel stack. The error code for a page fault has a format different from
 *       that for other exceptions. The error code tells the exception handler three things:
 *         -- The P flag   (bit 0) indicates whether the exception was due to a not-present page (0)
 *            or to either an access rights violation or the use of a reserved bit (1).
 *         -- The W/R flag (bit 1) indicates whether the memory access that caused the exception
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {//: 当程序访问的虚拟地址未映射到物理内存时，调用此函数来加载相应的页面，并更新页表。
    int ret = -E_INVAL;//ret 初始设为 -E_INVAL，表示一个无效的地址错误。
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);

    pgfault_num++;
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }

    /* IF (write an existed addr ) OR
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;//初始化 perm 为 PTE_U（用户可访问）。
    if (vma->vm_flags & VM_WRITE) {//果 VMA 是可写的（VM_WRITE），则添加可读和可写权限。
        perm |= (PTE_R | PTE_W);//则可读和可写权限。
    }
    addr = ROUNDDOWN(addr, PGSIZE);//将 addr 向下对齐到页面大小，确保处理的是完整的页面。

    ret = -E_NO_MEM;//设置返回值为 -E_NO_MEM，用于表示内存不足的情况。

    pte_t *ptep=NULL;//声明一个指向页表项的指针，初始值为 NULL。
    /*
    * Maybe you want help comment, BELOW comments can help you finish the code
    *
    * Some Useful MACROs and DEFINEs, you can use them in below implementation.
    * MACROs or Functions:
    *   get_pte : get an pte and return the kernel virtual address of this pte for la
    *             if the PT contians this pte didn't exist, alloc a page for PT (notice the 3th parameter '1')
    *   pgdir_alloc_page : call alloc_page & page_insert functions to allocate a page size memory & setup
    *             an addr map pa<--->la with linear address la and the PDT pgdir
    * DEFINES:
    *   VM_WRITE  : If vma->vm_flags & VM_WRITE == 1/0, then the vma is writable/non writable
    *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
    *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
    * VARIABLES:
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } else {
        /*LAB3 EXERCISE 3: 2212117
        * 请你根据以下信息提示，补充函数
        * 现在我们认为pte是一个交换条目，那我们应该从磁盘加载数据并放到带有phy addr的页面，
        * 并将phy addr与逻辑addr映射，触发交换管理器记录该页面的访问情况
        *
        *  一些有用的宏和定义，可能会对你接下来代码的编写产生帮助(显然是有帮助的)
        *  宏或函数:
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
            struct Page *page = NULL;
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
            swap_in(mm,addr,&page);
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir,page,addr,perm);
            //(3) make the page swappable.
            swap_map_swappable(mm,page,addr,1);
            page->pra_vaddr = addr;//通常用于记录页面对应的虚拟地址
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
failed:
    return ret;
}

