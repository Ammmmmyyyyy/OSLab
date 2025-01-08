# 操作系统Lab3实验报告

学号：2210620     姓名：何畅

学号：2212117     姓名：胡雨欣

# 实验目的

- 了解虚拟内存的Page Fault异常处理实现
- 了解页替换算法在操作系统中的实现
- 学会如何使用多级页表，处理缺页异常（Page Fault），实现页面置换算法。

# 实验内容

## 1.理解基于FIFO的页面替换算法

描述FIFO页面置换算法下，一个页面从被换入到被换出的过程中，会经过代码里哪些函数/宏的处理（或者说，需要调用哪些函数/宏），并用简单的一两句话描述每个函数在过程中做了什么？

- 至少正确指出10个不同的函数分别做了什么？我们认为只要函数原型不同，就算两个不同的函数。要求指出对执行过程有实际影响,删去后会导致输出结果不同的函数（例如assert）而不是cprintf这样的函数。

1. `swap_in`：页面换入时，需要先调用`swap.c`的`swap_in`函数。首先申请一个新的页面（`alloc_page`），然后找到对应的页表项（`get_pte`），最后将数据从磁盘写入内存（`swapfs_read`）。
2. `alloc_page`：用于申请一个页面，即一块连续的内存空间，在申请时，需要使用`assert(result!=NULL)`来判断是否成功申请页面。
3. `assert(result!=NULL)`：这个`assert`不能删除，否则申请到的页面实际上是`NULL`会影响后续的页面换入。
4. `get_pte`：用于获得与输入的虚拟地址对应的页表项（也有可能是新建的）。
5. `swapfs_read`：从 `swap` 设备的指定扇区读取数据，写入页面。
6. `swap_out`：用于将指定数量的页面（`n`）从内存换出到交换空间。使用一个 `for` 循环遍历 `n`，每次循环试图选择并换出一页。调用 `_fifo_swap_out_victim` 函数选择一个待换出的页面，结果存储在 `page` 指针中。如果失败（`r != 0`），则输出错误信息并退出循环。获取选中的页面的虚拟地址`v`。根据虚拟地址 `v` 获取相应的页表项指针 `ptep`。将页面的数据写入交换空间（`swapfs_write`）。如果写入失败，调用`_fifo_map_swappable`更新`FIFO`队列；如果写入成功，更新页表项 `*ptep` 为新写入的交换条目，并释放该页面。最后刷新`TLB`，失效 `TLB` 中对应的条目。
7. `_fifo_swap_out_victim`：在队列中选择最早到达的页面，即队尾的页面，作为需要释放的页面。
8. `swapfs_write`：把页面中的数据写入指定的扇区，因为如果页面中的数据被修改过，与磁盘不一致，就要写回磁盘。
9. `_fifo_map_swappable`：把一个页面放入到队头。在`swap_out`中调用是用于将队尾的页面移动到队头，防止下一次换出失败。
10. `free_page`：释放页面，即让这一块连续的内存空间变成`free`状态，用于下一次页面分配。
11. `tlb_invalidate`：调用`flush_tlb()`来刷新`TLB`。
12. `flush_tlb`：使用 `sfence.vma` 指令刷新 `TLB`。

## 2.深入理解不同分页模式的工作原理

get_pte()函数（位于`kern/mm/pmm.c`）用于在页表中查找或创建页表项，从而实现对指定线性地址对应的物理页的访问和映射操作。这在操作系统中的分页机制下，是实现虚拟内存与物理内存之间映射关系非常重要的内容。

- get_pte()函数中有两段形式类似的代码， 结合sv32，sv39，sv48的异同，解释这两段代码为什么如此相像。

**SV32**：使用 2 层页表（页目录和页表），支持 32 位虚拟地址。页目录和页表项各占 4 字节，能管理 4GB 的地址空间。

**SV39**：使用 3 层页表（页目录、页中间表和页表），支持 39 位虚拟地址。页目录和页表项各占 8 字节，能管理512GB的地址空间。

**SV48**：使用 4 层页表（页目录、页中间表、页中间表和页表），支持 48 位虚拟地址。页目录和页表项各占 8 字节，能管理256TB的地址空间。

在`get_pte()`函数中，第一段找到对应的`Giga Page`中的指向下一级页表的页目录项，如果不存在，则分配一个新的页和页表项。第二段找到对应的`Mega Page`中的指向下一级页表的页目录项，如果不存在，则分配一个新的页和页表项。二者逻辑完全一致，不同的只有页表的地址和偏移。

因此，无论是 `SV32`、`SV39` 还是 `SV48`，它们都遵循相同的逻辑：每一级页表都可能需要分配新的页面。如果页表项无效，就分配页面并初始化。这个过程在不同层级的页表中是相似的。

- 目前get_pte()函数将页表项的查找和页表项的分配合并在一个函数里，你认为这种写法好吗？有没有必要把两个功能拆开？

我认为好。因为在查找不到时一定会进行分配，所以将查找和分配合并在一个函数中，可以减少调用次数，简化用户代码。调用者只需调用一个函数即可完成页表项的查找和必要的分配。

## 3.给未被映射的地址映射上物理页

补充完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制 结构所指定的页表，而不是内核的页表。

请在实验报告中简要说明你的设计实现过程。
具体过程已在注释中说明。

```c
else {
        /*LAB3 EXERCISE 3: YOUR CODE
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
            swap_in(mm,addr,&page);//将该页面从磁盘加载到内存
                
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            page_insert(mm->pgdir,page,addr,perm);//建立页面的物理地址和虚拟地址的映射关系
                
            //(3) make the page swappable.
            swap_map_swappable(mm,addr,page,1);//将页面标记为可交换，使得页面管理系统可以将其再次换出到磁盘
            page->pra_vaddr = addr;// 更新页面的 pra_vaddr 为当前的 addr 地址，记录该页面被访问的线性地址
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }
```

请回答如下问题：

- 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。

页目录项和页表项的`V`表示这个页表项是否合法。另外一些权限位，比如`D`，指示页面是否经过修改，在换出时是否要写回磁盘。`R`、`W`、`X`位指示可读、可写、可执行，来保障换入换出后的读写权限正确。

- 如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

首先保存当前异常原因，根据`stvec`的地址跳转到中断处理程序，即`trap.c`文件中的`trap`函数。接着跳转到`exception_handler`中的`CAUSE_LOAD_ACCESS`或`CAUSE_STORE_ACCESS`处理缺页异常，即调用`pgfault_handler`，打印异常信息后，调用`do_pgfault`具体处理缺页异常。如果处理成功，则返回到发生缺页异常处重新执行指令。否则输出`unhandled page fault`。

- 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

有对应关系。系统中的每个物理页帧都有一个 `Page` 实例与之对应，`Page` 数组是对所有物理页帧的抽象管理结构。页表项则是虚拟内存管理的核心结构，用于将虚拟地址映射到物理地址。一个页表项会指向一个物理页帧，而该物理页帧由 `Page` 描述。因此，通过页表项的物理地址可以定位到 `Page` 数组中的相应条目。

## 4.补充完成Clock页替换算法

通过之前的练习，相信大家对FIFO的页面替换算法有了更深入的了解，现在请在我们给出的框架上，填写代码，实现 Clock页替换算法（mm/swap_clock.c）。(提示:要输出curr_ptr的值才能通过make grade)

请在实验报告中简要说明你的设计实现过程。

具体过程已在注释中说明。

```c++
static int
_clock_init_mm(struct mm_struct *mm)
{     
     /*LAB3 EXERCISE 4: YOUR CODE*/ 
     // 初始化pra_list_head为空链表
     list_init(&pra_list_headclock);
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     curr_ptr=&pra_list_headclock;
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作
     mm->sm_priv=&pra_list_headclock;
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && curr_ptr != NULL);
    //record the page access situlation
    /*LAB3 EXERCISE 4: YOUR CODE*/ 
    // link the most recent arrival page at the back of the pra_list_head qeueue.
    // 将页面page插入到页面链表pra_list_head的末尾
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_add_before(head,entry);
    // 将页面的visited标志置为1，表示该页面已被访问
    page->visited=1;
    return 0;
}
/*
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then set the addr of addr of this page to ptr_page.
 */
static int
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
         assert(head != NULL);
     assert(in_tick==0);
     /* Select the victim */
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     //(2)  set the addr of addr of this page to ptr_page
    while (1) {
        /*LAB3 EXERCISE 4: YOUR CODE*/ 
        // 编写代码
        // 遍历页面链表pra_list_head，查找最早未被访问的页面，如果curr_ptr的下一个节点还是head，说明是空表，应该直接跳出
        if(curr_ptr == head){
            curr_ptr = list_next(curr_ptr);
            if(curr_ptr == head) {
                *ptr_page = NULL;
                break;
            }
        }
        // 获取当前页面对应的Page结构指针
        struct Page* currPage=le2page(curr_ptr,pra_page_link);
        // 如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面，同时curr_ptr指向下一个节点，为下一次换出做准备
        if(!currPage->visited){
        //要输出curr_ptr的值才能通过make grade
        //cprintf("the value of cutt_ptr is %p\n", curr_ptr);
        cprintf("curr_ptr 0xffffffff%x\n",curr_ptr);
        curr_ptr = list_next(curr_ptr);
        list_del(list_prev(curr_ptr));
        *ptr_page=currPage;
        break;
        }
        // 如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问
        else{
        currPage->visited=0;
        curr_ptr = list_next(curr_ptr);
        }
    }
    return 0;
}
```

请回答如下问题：

- 比较Clock页替换算法和FIFO算法的不同。

**FIFO算法**：简单地按页进入的顺序替换。最早进入的页面会在需要替换时首先移出内存。算法实现相对简单，只需一个队列记录页面进入的顺序。

**Clock算法**：采用类似“时钟”的思想，为每个页面增加一个“访问位”作为标记。页面访问时将访问位设置为1。当需要替换时，算法会检查当前页面的访问位，如果为0则替换该页；如果为1则将其置0并继续检查下一个页面，直到找到访问位为0的页面进行替换。

## 5.阅读代码和实现手册，理解页表映射方式相关知识

如果我们采用”一个大页“ 的页表映射方式，相比分级页表，有什么好处、优势，有什么坏处、风险？

### 优点/优势

1. **减少页表开销**：
   - 使用“一大页”可以减少页表的层级结构，从而显著减少页表项的数量。
   - 对于一个大页来说，只需要一个页表项来表示整个大页的映射，因此页表的开销大大降低，尤其是在需要映射大块连续地址空间的情况下。
2. **提高 TLB 命中率**：
   - 大页映射可以减少 TLB（Translation Lookaside Buffer）中存储的页表项数量，因为每个页表项映射的地址空间更大。
   - 这意味着可以在 TLB 中存储更多的有效映射，提高 TLB 的命中率，减少内存访问的开销。
3. **减少页表查找的层级**：
   - 分级页表需要逐级查找，在 2 级或 3 级页表的情况下，需要多次访问内存才能找到最终的物理地址。
   - 使用大页时，可以直接找到目标页表项，减少了页表查找的层级，从而提高访问速度。
4. **适合大内存块的应用**：
   - 在某些场景下（例如大型数据库、内存映射文件、大型数组等），应用程序需要访问连续的大内存块。大页映射可以更高效地管理和映射这些大块内存，减少页表管理的开销。

### 缺点/风险

1. **内存浪费**：
   - 使用大页时，如果分配的内存块没有完全用到，会造成大量的内存浪费，特别是在分配的内存地址不连续或者需求不均匀的情况下。
   - 例如，如果只需要 4 KB 数据，但使用了一个 2 MB 的大页，那么会浪费大部分内存空间。
2. **碎片化问题**：
   - 大页映射会导致内存碎片化的问题，尤其是在系统内存压力较大的情况下。
   - 随着内存分配和释放的进行，很难找到足够大的连续物理内存区域来分配给大页，从而影响系统性能和内存利用率。
3. **细粒度控制缺失**：
   - 大页的大小较大，导致操作系统对内存的管理较粗粒度。大页的映射方式缺乏对小范围内存的精确控制。
   - 例如，在内存权限管理方面，无法对大页内的每一小块单独设置访问权限，这可能会带来安全性风险。
4. **页面置换开销增加**：
   - 当需要换出或换入页面时，大页映射会导致更大的数据量被换入或换出。
   - 换出时，整个大页都需要被写入到交换空间，这会增加 I/O 开销，影响性能。
5. **不适合小内存块的应用**：
   - 对于那些频繁访问小块内存的应用程序来说，大页映射并不合适，因为这些应用通常不需要大块的连续物理内存。
   - 如果强制使用大页映射，可能会导致大量的内存浪费和资源不必要的消耗。

## 6.实现不考虑实现开销和效率的LRU页替换算法

代码如下，具体过程已在注释中说明：

```c++
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
 //LRU就是将最久未使用的页面换出，最近使用的在链表前面，越久未使用就越是在后面。
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
        if(entry!=head){
        entry = list_next(entry);
        list_del(list_prev(entry));
        *ptr_page=currPage;
        return 0;
        }
        else{
        *ptr_page=NULL;
        }
    return 0;
}

static int
_lru_tick_event(struct mm_struct *mm)//页面访问更新机制
{ 
list_entry_t* head = (list_entry_t*)mm->sm_priv;
 assert(head != NULL);
list_entry_t* cur = list_next(head);
while(cur!=head){
struct Page* page = le2page(cur, pra_page_link);
pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
//ptep声明一个指向页表项的指针
 if (*ptep & PTE_A){      //页面在一段时间内被访问了，拿到最前，置0
    list_entry_t* temp = list_prev(cur);
    list_del(cur);
    list_add(head,cur);
     *ptep &= ~PTE_A;//取反置0；
     cur = temp;
 }
 cur=list_next(cur);
// cprintf("here in lru_tick_event\n");
}
```

# 重要的知识点

### 1. FIFO（First-In, First-Out）页面替换算法

**原理**：

- FIFO 算法按页面进入内存的顺序进行替换，最早进入内存的页面在内存满时最先被替换出去。

**步骤**：

1. 维护一个队列，按页面进入内存的顺序将页面加入队列头部。
2. 当需要替换页面时，从队列尾部移出最早进入的页面。
3. 将新页面加入队列头部。

**优缺点**：

- **优点**：实现简单，开销较小。
- **缺点**：无法考虑页面访问的频率和时间局部性，可能导致"Belady’s Anomaly"（增加页面数反而导致缺页率升高的现象）。

### 2. Clock（时钟）页面替换算法

**原理**：

- Clock 算法是 FIFO 的一种改进，用一个指针模拟“时钟”，并引入“访问位”来记录页面是否被访问。
- 该算法维护一个循环队列，每个页面有一个访问位，记录页面是否被访问过。

**步骤**：

1. 每个页面在被访问时，其访问位设为 1。
2. 当内存已满且需要替换页面时，时钟指针开始检查各页面的访问位：
   - 如果访问位为 0，表示该页面较少使用，将该页面替换。
   - 如果访问位为 1，将其设为 0，时钟指针移动到下一个页面，直到找到访问位为 0 的页面并替换之。
3. 将新页面插入替换位置，并将访问位设为 1。

**优缺点**：

- **优点**：考虑了页面的访问频率，避免了FIFO算法的缺点。
- **缺点**：虽然性能提升，但还未完全实现 LRU。

### 3. LRU（Least Recently Used）页面替换算法

**原理**：

- LRU 算法替换最近最少使用的页面，即最久未被访问的页面。
- 利用“时间局部性”原理，认为较久未使用的页面近期也不太会被使用。

**步骤**：

1. 维护一个队列，按页面进入内存的顺序将页面加入队列头部。
2. 当需要替换页面时，从队列尾部移出最久未被访问的页面。
3. 将新页面加入队列头部。
4. 定期将被访问过的页面移动到队列头部。

**优缺点**：

- **优点**：较符合实际应用中的访问规律，缺页率低。
- **缺点**：硬件实现较复杂，维护时间戳或链表开销较大。

### 4.当程序运行中访问内存产生page fault异常时，如何判定这个引起异常的虚拟地址内存访问是越界、写只读页的“非法地址”访问还是由于数据被临时换出到磁盘上或还没有分配内存的“合法地址”访问？

#### 1. **检查访问的虚拟地址是否在当前进程的虚拟地址空间范围内**

- 操作系统为每个进程维护虚拟地址空间的布局，包括：
  - 已分配的堆栈、堆和代码段等区域；
  - 已映射的内存区域（如通过 `mmap` 映射的区域）。
- 通过页表或类似结构可以检查该虚拟地址是否属于有效的分配区域：
  - 如果访问地址超出了分配的范围（未映射到页表中），则判定为 **越界访问（非法访问）**。
  - 若访问的虚拟地址是完全非法的（不在该进程的地址空间中），通常会直接触发操作系统抛出 **Segmentation Fault（段错误）**。

#### 2. **检查访问权限**

- 如果地址有效，但程序试图执行不被允许的操作（如对只读页执行写操作），系统将产生 

  访问权限错误（Protection Fault）

  。

  - 页表中包含关于页的权限信息，例如：
    - 是否为只读页；
    - 是否允许执行；
    - 是否允许用户模式访问。
  - 若访问方式不符合权限规定，则会触发 **非法访问错误**。

#### 3. **检查页面状态**

- 如果虚拟地址在页表中有效，且权限允许，但对应的页状态为以下之一：
  - 未分配实际物理内存：
    - 页面可能尚未分配（例如延迟分配时写时分配机制）。
  - 被换出（Swapped Out）：
    - 页面可能被操作系统换出到磁盘上。
  - 在这些情况下，操作系统会尝试通过页缺失中断处理程序（Page Fault Handler）恢复页面：
    - **如果恢复成功，则访问是合法的。**
    - 如果无法恢复页面（如访问了未初始化的匿名页），可能会触发程序错误。

### 5.何时进行请求调页/页换入换出处理

#### **1. 什么时候进行请求调页（Page Fetching）？**

请求调页是指当一个进程访问的虚拟地址没有映射到物理内存时，操作系统需要加载相应的页到内存中。

#### **触发条件：页缺失（Page Fault）**

- 未分配物理页（Copy-On-Write 或 延迟分配）：
  - 当进程第一次访问某个虚拟地址时，可能尚未为其分配实际物理页。
  - 系统会触发一个页缺失中断（Page Fault），然后分配一个新的物理页并初始化它（例如填充为零或从磁盘读取内容）。
- 内存映射文件（Memory-Mapped Files）：
  - 若一个虚拟地址映射到磁盘文件的一部分，但相应的页尚未加载到内存，访问时会触发页缺失。
  - 操作系统从磁盘加载所需的内容到物理内存。
- 换出的页被重新访问：
  - 如果一个页之前被换出到磁盘（Swapped Out），当进程再次访问该页时，系统需要将页从磁盘换回内存。

#### **请求调页时机：**

- 按需调页（Demand Paging）：
  - 系统默认延迟加载页面，只有当进程实际访问到页面时才加载。这种方式提高了内存利用率。
- 预取（Prefetching）：
  - 在某些情况下，操作系统可能预测到即将需要的页面，并提前加载，减少未来的页缺失中断。
  - 例如，在顺序文件读取场景中。

#### **2. 什么时候进行页换出（Page Swapping）？**

页换出是指当系统的物理内存不足时，操作系统需要将某些页面移出内存，以腾出空间给其他页面使用。

#### **触发条件：内存压力**

- 当系统物理内存接近耗尽，且当前活动进程需要更多的内存时，操作系统触发页换出。
- 页换出的选择依据页面置换算法（如 LRU、FIFO 等）决定哪些页面被移出。

#### **页换出的常见情景：**

- 长时间未使用的页面：
  - 如果一个页面很久没有被访问，操作系统可能认为它不再是“活跃的”，从而将其换出到磁盘。
- 后台进程或低优先级进程：
  - 如果某些进程处于后台运行，操作系统可能优先换出其页面。
- 临时文件映射：
  - 与磁盘文件相关联的页面可能更容易被换出，因为它们可以随时从磁盘重新加载。

#### **页换出时机：**

- 主动换出（Proactive Swapping）：
  - 操作系统在检测到内存即将不足时，提前开始换出页面以避免紧急情况。
- 被动换出（Reactive Swapping）：
  - 只有当新的页面分配请求无法满足时，操作系统才换出页面。
