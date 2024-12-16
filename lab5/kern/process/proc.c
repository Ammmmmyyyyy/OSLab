#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <cow.h>

/* ------------- process/thread mechanism design&implementation -------------
(an simplified Linux process/thread mechanism )
introduction:
  ucore implements a simple process/thread mechanism. process contains the independent memory sapce, at least one threads
for execution, the kernel data(for management), processor state (for context switch), files(in lab6), etc. ucore needs to
manage all these details efficiently. In ucore, a thread is just a special kind of process(share process's memory).
------------------------------
process state       :     meaning               -- reason
    PROC_UNINIT     :   uninitialized           -- alloc_proc
    PROC_SLEEPING   :   sleeping                -- try_free_pages, do_wait, do_sleep
    PROC_RUNNABLE   :   runnable(maybe running) -- proc_init, wakeup_proc, 
    PROC_ZOMBIE     :   almost dead             -- do_exit

-----------------------------
process state changing:
                                            
  alloc_proc                                 RUNNING
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+ 
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  + 
                                           -----------------------wakeup_proc----------------------------------
-----------------------------
process relations
parent:           proc->parent  (proc is children)
children:         proc->cptr    (proc is parent)
older sibling:    proc->optr    (proc is younger sibling)
younger sibling:  proc->yptr    (proc is older sibling)
-----------------------------
related syscall for process:
SYS_exit        : process exit,                           -->do_exit
SYS_fork        : create child process, dup mm            -->do_fork-->wakeup_proc
SYS_wait        : wait process                            -->do_wait
SYS_exec        : after fork, process execute a program   -->load a program and refresh the mm
SYS_clone       : create child thread                     -->do_fork-->wakeup_proc
SYS_yield       : process flag itself need resecheduling, -- proc->need_sched=1, then scheduler will rescheule this process
SYS_sleep       : process sleep                           -->do_sleep 
SYS_kill        : kill process                            -->do_kill-->proc->flags |= PF_EXITING
                                                                 -->wakeup_proc-->do_wait-->do_exit   
SYS_getpid      : get the process's pid

*/

// the process set's list
list_entry_t proc_list;

#define HASH_SHIFT          10
#define HASH_LIST_SIZE      (1 << HASH_SHIFT)
#define pid_hashfn(x)       (hash32(x, HASH_SHIFT))

// has list for process set based on pid
static list_entry_t hash_list[HASH_LIST_SIZE];

// idle proc
struct proc_struct *idleproc = NULL;
// init proc
struct proc_struct *initproc = NULL;
// current proc
struct proc_struct *current = NULL;

static int nr_process = 0;

void kernel_thread_entry(void);
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
    //LAB4:EXERCISE1 YOUR CODE
    /*
     * below fields in proc_struct need to be initialized
     *       enum proc_state state;                      // Process state
     *       int pid;                                    // Process ID
     *       int runs;                                   // the running times of Proces
     *       uintptr_t kstack;                           // Process kernel stack
     *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
     *       struct proc_struct *parent;                 // the parent process
     *       struct mm_struct *mm;                       // Process's memory management field
     *       struct context context;                     // Switch here to run process
     *       struct trapframe *tf;                       // Trap frame for current interrupt
     *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
     *       uint32_t flags;                             // Process flag
     *       char name[PROC_NAME_LEN + 1];               // Process name
     */
    	proc->state=PROC_UNINIT;//给进程设置为未初始化状态
    	proc->pid=-1;//为初始化进程为-1
    	proc->runs=0;
    	proc->kstack=0;//初始化内核栈地址为 0，稍后会在创建栈时赋值。
    	proc->need_resched=0;//默认不需要调度
    	proc->parent=NULL;//父进程为空
    	proc->mm=NULL;//初始化内存管理结构为 NULL，稍后需要分配具体的内存管理结构。
    	memset(&(proc->context),0,sizeof(struct context));//初始化上下文
    	proc->tf=NULL;//初始化陷阱帧为 NULL，稍后需要分配具体的陷阱帧结构。    	
        proc->cr3 = boot_cr3;      // 使用内核页目录表的基址
        proc->flags=0;//无特殊标志位
        memset(&(proc->name),0,PROC_NAME_LEN + 1); // 初始化进程名为空字符串
    	
     

     //LAB5 YOUR CODE : (update LAB4 steps)
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
    proc->wait_state = 0;
    /*
    cptr：子进程指针。
    optr：兄弟进程指针（older sibling）。
    yptr：兄弟进程指针（younger sibling）。
    三者初始化为 NULL，稍后可以根据进程关系进行赋值。
    */
    proc->cptr = NULL;
    proc->optr = NULL;
    proc->yptr = NULL;  
    }
    return proc;
}

// set_proc_name - set the name of proc
char *
set_proc_name(struct proc_struct *proc, const char *name) {
    memset(proc->name, 0, sizeof(proc->name));
    return memcpy(proc->name, name, PROC_NAME_LEN);
}

// get_proc_name - get the name of proc
char *
get_proc_name(struct proc_struct *proc) {
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

// set_links - set the relation links of process
static void
set_links(struct proc_struct *proc) {
    list_add(&proc_list, &(proc->list_link));
    proc->yptr = NULL;
    if ((proc->optr = proc->parent->cptr) != NULL) {
        proc->optr->yptr = proc;
    }
    proc->parent->cptr = proc;
    nr_process ++;
}

// remove_links - clean the relation links of process
static void
remove_links(struct proc_struct *proc) {
    list_del(&(proc->list_link));
    if (proc->optr != NULL) {
        proc->optr->yptr = proc->yptr;
    }
    if (proc->yptr != NULL) {
        proc->yptr->optr = proc->optr;
    }
    else {
       proc->parent->cptr = proc->optr;
    }
    nr_process --;
}

// get_pid - alloc a unique pid for process
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS);
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) {
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le)) != list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) {
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat;
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid;
            }
        }
    }
    return last_pid;
}

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
    if (proc != current) {
        // LAB4:EXERCISE3 YOUR CODE
        /*
        * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
        * MACROs or Functions:
        *   local_intr_save():        Disable interrupts
        *   local_intr_restore():     Enable Interrupts
        *   lcr3():                   Modify the value of CR3 register
        *   switch_to():              Context switching between two processes
        */
        /*
        #define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
#define local_intr_restore(x) __intr_restore(x);

        */
        bool x;
        struct proc_struct *prev=current;
        local_intr_save(x);//将当前中断状态保存到 x 并禁用中断。
        {
            current=proc;
            /*
            static inline void
lcr3(unsigned int cr3) {
    write_csr(sptbr, SATP32_MODE | (cr3 >> RISCV_PGSHIFT));
}
            */
            lcr3(proc->cr3);//切换页表，将当前进程的地址空间切换为目标进程的地址空间。proc->cr3 是目标进程的页目录基地址。
            //switch_to 函数会保存当前进程（prev）的上下文并恢复目标进程（proc）的上下文，从而实现进程切换。prev->context 是当前进程的上下文（包括寄存器等信息），proc->context 是目标进程的上下文。
             switch_to(&(prev->context), &(proc->context));//切换上下文
        }
        local_intr_restore(x);
       
    }
}


// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
}

// hash_proc - add proc into proc hash_list
static void
hash_proc(struct proc_struct *proc) {
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

// unhash_proc - delete proc from proc hash_list
static void
unhash_proc(struct proc_struct *proc) {
    list_del(&(proc->hash_link));
}

// find_proc - find proc frome proc hash_list according to pid
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le)) != list) {
            struct proc_struct *proc = le2proc(le, hash_link);
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
}

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    tf.gpr.s0 = (uintptr_t)fn;
    tf.gpr.s1 = (uintptr_t)arg;
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
    tf.epc = (uintptr_t)kernel_thread_entry;
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
static int
setup_kstack(struct proc_struct *proc) {
    struct Page *page = alloc_pages(KSTACKPAGE);
    if (page != NULL) {
        proc->kstack = (uintptr_t)page2kva(page);
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - free the memory space of process kernel stack
static void
put_kstack(struct proc_struct *proc) {
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
}

// setup_pgdir - alloc one page as PDT
static int
setup_pgdir(struct mm_struct *mm) {
    struct Page *page;
    if ((page = alloc_page()) == NULL) {
        return -E_NO_MEM;
    }
    pde_t *pgdir = page2kva(page);
    memcpy(pgdir, boot_pgdir, PGSIZE);

    mm->pgdir = pgdir;
    return 0;
}

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm) {
    free_page(kva2page(mm->pgdir));
}

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    struct mm_struct *mm, *oldmm = current->mm;

    /* current is a kernel thread */
    if (oldmm == NULL) {
        return 0;
    }
    if (clone_flags & CLONE_VM) {
        mm = oldmm;
        goto good_mm;
    }
    int ret = -E_NO_MEM;
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    if (setup_pgdir(mm) != 0) {
        goto bad_pgdir_cleanup_mm;
    }
    lock_mm(oldmm);
    {
        ret = dup_mmap(mm, oldmm);
    }
    unlock_mm(oldmm);

    if (ret != 0) {
        goto bad_dup_cleanup_mmap;
    }

good_mm:
    mm_count_inc(mm);
    proc->mm = mm;
    proc->cr3 = PADDR(mm->pgdir);
    return 0;
bad_dup_cleanup_mmap:
    exit_mmap(mm);
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    return ret;
}

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
    *(proc->tf) = *tf;

    // Set a0 to 0 so a child process knows it's just forked
    proc->tf->gpr.a0 = 0;
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;

    proc->context.ra = (uintptr_t)forkret;
    proc->context.sp = (uintptr_t)(proc->tf);
}

/* do_fork -     parent process for a new child process
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
 /*
 clone_flags：表示子进程的内存共享方式（如 CLONE_VM 表示内存共享）。
stack：子进程的用户态栈顶地址。
tf：陷阱帧，用于保存当前进程的运行状态。
 */
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {//创建一个新的子进程，复制当前进程的内核栈、内存管理结构和运行状态。
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //LAB4:EXERCISE2 YOUR CODE
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakeup_proc:  set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. call alloc_proc to allocate a proc_struct
    //    2. call setup_kstack to allocate a kernel stack for child process
    //    3. call copy_mm to dup OR share mm according clone_flag
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid
    proc=alloc_proc();
    if(proc==NULL){
    goto fork_out;
    }
    proc->parent = current;//将子进程的父节点设置为当前进程
    assert(current->wait_state == 0);
    if(setup_kstack(proc)!=0){
    goto bad_fork_cleanup_proc;  // 释放刚刚alloc的proc_struct
    }
    
    // if(copy_mm(clone_flags,proc)!=0){
    // goto bad_fork_cleanup_kstack;  // 释放刚刚alloc的proc_struct
    // }
    if(cow_copy_mm(proc) != 0) {
        goto bad_fork_cleanup_kstack;
    }
    copy_thread(proc,stack,tf);// 复制trapframe，设置context
    
    proc->pid=get_pid();//获取当前进程PID
    hash_proc(proc);
    //list_add(&proc_list,&(proc->list_link));
    set_links(proc);
    //nr_process++;////进程数加一
    wakeup_proc(proc);
    return proc->pid;
            

    //LAB5 YOUR CODE : (update LAB4 steps)
    //TIPS: you should modify your written code in lab4(step1 and step5), not add more code.
   /* Some Functions
    *    set_links:  set the relation links of process.  ALSO SEE: remove_links:  lean the relation links of process 
    *    -------------------
    *    update step 1: set child proc's parent to current process, make sure current process's wait_state is 0
    *    update step 5: insert proc_struct into hash_list && proc_list, set the relation links of process
    */


 
fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}

// do_exit - 由 sys_exit 调用，处理进程退出的操作
// 1. 调用 exit_mmap、put_pgdir 和 mm_destroy 释放进程占用的几乎所有内存空间
// 2. 设置进程状态为 PROC_ZOMBIE，之后调用 wakeup_proc 让父进程回收该进程
// 3. 调用 scheduler 切换到其他进程
int
do_exit(int error_code) {
    // 如果是空闲进程退出，报错并终止
    if (current == idleproc) {
        panic("idleproc exit.\n");
    }

    // 如果是初始化进程退出，报错并终止
    if (current == initproc) {
        panic("initproc exit.\n");
    }

    // 获取当前进程的内存管理结构
    struct mm_struct *mm = current->mm;

    // 如果当前进程有内存管理结构（即已分配了内存），说明是用户进程
    if (mm != NULL) {
        lcr3(boot_cr3);  // 切换到内核页表，确保接下来的操作在内核空间执行
        
        // 如果 mm 引用计数减为 0，意味着没有其他进程共享此mm
        if (mm_count_dec(mm) == 0) {
            // 释放内存映射、页目录等资源
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        // 清空当前进程的内存管理结构，表示资源已经释放
        current->mm = NULL;
    }

    // 设置当前进程的状态为 "僵尸"（表示进程已退出，等待父进程回收）
    current->state = PROC_ZOMBIE;
    current->exit_code = error_code;  // 保存退出码

    bool intr_flag;
    struct proc_struct *proc;

    // 保存当前中断状态，并在关键代码区域禁止中断
    local_intr_save(intr_flag);
    {
        // 获取当前进程的父进程
        proc = current->parent;
        
        // 如果父进程处于等待子进程状态，唤醒父进程
        if (proc->wait_state == WT_CHILD) {
            wakeup_proc(proc);
        }

        // 清理当前进程的子进程（将子进程转移到 initproc 下）
        while (current->cptr != NULL) {
            proc = current->cptr;  // 获取当前进程的第一个子进程
            current->cptr = proc->optr;  // 将子进程从当前进程的子进程链表中移除

            // 设置子进程的父进程为空
            proc->yptr = NULL;
            
            // 将子进程移动到 initproc 下
            if ((proc->optr = initproc->cptr) != NULL) {
                initproc->cptr->yptr = proc;  // 将 initproc 的第一个子进程指向新父进程proc
            }
            proc->parent = initproc;  // 设置新父进程为 initproc
            initproc->cptr = proc;  // 将当前子进程加入 initproc 的子进程链表

            // 如果该子进程是僵尸进程，且 initproc 正在等待子进程，则唤醒 initproc
            if (proc->state == PROC_ZOMBIE) {
                if (initproc->wait_state == WT_CHILD) {
                    wakeup_proc(initproc);
                }
            }
        }
    }
    // 恢复中断状态
    local_intr_restore(intr_flag);

    // 调用调度器，切换到其他进程
    schedule();

    // 如果调度器返回了，说明发生了错误，应该不会返回
    panic("do_exit will not return!! %d.\n", current->pid);
}

/*
注意我们需要让CPU进入U mode执行do_execve()加载的用户程序。进行系统调用sys_exec之后，我们在trap返回的时候调用了sret指令，
这时只要sstatus寄存器的SPP二进制位为0，就会切换到U mode，但SPP存储的是“进入trap之前来自什么特权级”，也就是说我们这里ebreak之后SPP的数值为1，
sret之后会回到S mode在内核态执行用户程序。
所以load_icode()函数在构造新进程的时候，会把SSTATUS_SPP设置为0，使得sret的时候能回到U mode。
*/
/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
static int
load_icode(unsigned char *binary, size_t size) {//函数 load_icode 用于加载用户态程序到内存。binary：指向 ELF 格式的二进制数据。size：二进制数据大小
    if (current->mm != NULL) {//检查当前进程的 mm（内存管理结构）是否为空。如果不是，说明当前进程已有内存空间，直接触发内核 panic。
        panic("load_icode: current->mm must be empty.\n");
    }

    int ret = -E_NO_MEM;
    struct mm_struct *mm;
    //(1) create a new mm for current process
    //调用 mm_create 创建一个新的内存管理结构 mm_struct。
    //如果创建失败，返回错误 -E_NO_MEM 并跳转到错误处理标签 bad_mm。
    if ((mm = mm_create()) == NULL) {
        goto bad_mm;
    }
    //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT 为当前进程创建新的页目录表
    if (setup_pgdir(mm) != 0) {//调用 setup_pgdir 分配页目录表（PDT）。mm->pgdir 指向内核中的页目录表的虚拟地址。
        goto bad_pgdir_cleanup_mm;
    }
    //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process 复制 ELF 文件的各个段到进程的内存空间
    struct Page *page;
    //(3.1) get the file header of the bianry program (ELF format)获取 ELF 文件的文件头
    struct elfhdr *elf = (struct elfhdr *)binary;
    //(3.2) get the entry of the program section headers of the bianry program (ELF format) 获取程序段头，指向 ELF 文件的程序头部
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
    //(3.3) This program is valid?
    //检查 ELF 文件的魔数（e_magic）是否正确。如果不匹配，说明文件格式非法，返回 -E_INVAL_ELF 错误。
    if (elf->e_magic != ELF_MAGIC) {//将二进制数据的开头解释为 ELF 文件头。
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_pgdir;
    }

    uint32_t vm_flags, perm;
    struct proghdr *ph_end = ph + elf->e_phnum;
    //跳过非 LOAD 类型的段（p_type != ELF_PT_LOAD）。LOAD 类型的段需要加载到内存
    for (; ph < ph_end; ph ++) {
    //(3.4) find every program section headers 遍历 ELF 文件中的每个程序段（Program Segment），加载符合条件的段到内存
        if (ph->p_type != ELF_PT_LOAD) {
            continue ;
        }
        //检查段的文件大小（p_filesz）是否超过段的内存大小（p_memsz）。如果超过，说明 ELF 文件有问题。
        if (ph->p_filesz > ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0) {
            // continue ;
        }
    //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz) 设置段的内存映射标志
    /*
    根据段标志（p_flags）设置虚拟内存标志（vm_flags）和页表权限（perm）。
ELF_PF_X：可执行。
ELF_PF_W：可写。
ELF_PF_R：可读
    */
        vm_flags = 0, perm = PTE_U | PTE_V;
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        // modify the perm bits here for RISC-V 根据不同的标志位设置权限
        if (vm_flags & VM_READ) perm |= PTE_R;
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
        if (vm_flags & VM_EXEC) perm |= PTE_X;
        //调用 mm_map 将段的虚拟地址范围（p_va 到 p_va + p_memsz）映射到进程的虚拟地址空间。
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
            goto bad_cleanup_mmap;
        }
        //拷贝段数据
        unsigned char *from = binary + ph->p_offset;
        size_t off, size;
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);

        ret = -E_NO_MEM;

     //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        //分配物理页，并将段内容从 ELF 文件复制到进程的内存空间
        end = ph->p_va + ph->p_filesz;
     //(3.6.1) copy TEXT/DATA section of bianry program
     
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) { // 分配物理页并复制数据
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memcpy(page2kva(page) + off, from, size);
            start += size, from += size;
        }

      //(3.6.2) build BSS section of binary program 为 BSS 段分配并清零内存
        end = ph->p_va + ph->p_memsz;
        if (start < la) {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }
        //段的未初始化部分（p_filesz 到 p_memsz）需要清零。
        while (start < end) {
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            memset(page2kva(page) + off, 0, size);
            start += size;
        }
    }
    //(4) build user stack memory 构建用户栈内存
    //调用 mm_map 映射用户栈空间（从 USTACKTOP - USTACKSIZE 到 USTACKTOP）。
    //调用 pgdir_alloc_page 为栈分配物理页。
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
        goto bad_cleanup_mmap;
    }
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
    
    //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory 设置当前进程的 mm 和 CR3 寄存器
    mm_count_inc(mm); // 增加 mm 引用计数并将其设置为当前进程的 mm
    current->mm = mm;
    current->cr3 = PADDR(mm->pgdir);
    lcr3(PADDR(mm->pgdir));

    //(6) setup trapframe for user environment 设置用户环境的 trapframe
    struct trapframe *tf = current->tf;
    // Keep sstatus
    uintptr_t sstatus = tf->status;
    memset(tf, 0, sizeof(struct trapframe));
    /* LAB5:EXERCISE1 YOUR CODE
     * should set tf->gpr.sp, tf->epc, tf->status
     * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
     *          tf->gpr.sp should be user stack top (the value of sp)
     *          tf->epc should be entry point of user program (the value of sepc)
     *          tf->status should be appropriate for user program (the value of sstatus)
     *          hint: check meaning of SPP, SPIE in SSTATUS, use them by SSTATUS_SPP, SSTATUS_SPIE(defined in risv.h)
     */
     /*、
     gpr.sp：设置栈顶指针。
epc：设置程序入口地址（e_entry）。
状态寄存器status：设置用户态的特权级别和中断使能。
     */
    tf->gpr.sp = USTACKTOP;
    tf->epc = elf->e_entry;
    tf->status = (read_csr(sstatus) & ~SSTATUS_SPP) | SSTATUS_SPIE;


    ret = 0;
out:
    return ret;
bad_cleanup_mmap:
    exit_mmap(mm);
bad_elf_cleanup_pgdir:
    put_pgdir(mm);
bad_pgdir_cleanup_mm:
    mm_destroy(mm);
bad_mm:
    goto out;
}

// do_execve - 调用 exit_mmap(mm) 和 put_pgdir(mm) 来回收当前进程的内存空间
//            - 调用 load_icode 来根据二进制程序设置新的内存空间
int
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
    // 获取当前进程的内存管理结构（mm_struct）
    struct mm_struct *mm = current->mm;

    // 检查程序名称内存区域的可访问性
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
        return -E_INVAL;  // 如果程序名的内存不可访问，返回无效错误
    }

    // 限制进程名的长度不能超过 PROC_NAME_LEN
    if (len > PROC_NAME_LEN) {
        len = PROC_NAME_LEN;  // 如果程序名太长，截取为最大长度
    }

    // 为本地存储的程序名分配缓冲区
    char local_name[PROC_NAME_LEN + 1];  
    memset(local_name, 0, sizeof(local_name));  // 清零内存
    memcpy(local_name, name, len);  // 复制程序名到 local_name

    // 如果进程有内存管理结构（mm），则清理当前进程的内存空间
    if (mm != NULL) {
        cputs("mm != NULL");  // 调试输出

        // 切换到内核页表，准备释放当前进程的内存
        lcr3(boot_cr3);

        // 减少 mm 的引用计数，如果为 0，则表示没有其他进程引用该内存结构
        if (mm_count_dec(mm) == 0) {
            // 释放当前进程的内存映射和页表
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);  // 销毁 mm 结构，释放所有内存
        }

        // 清空当前进程的内存管理结构指针，准备重新分配内存
        current->mm = NULL;
    }

    // 加载新的程序到当前进程的内存空间
    int ret;
    if ((ret = load_icode(binary, size)) != 0) {
        // 如果加载程序失败，跳转到 execve_exit 标签进行错误处理
        goto execve_exit;
    }

    // 设置当前进程的名称为 local_name（避免直接使用 name，因为可能存在其他访问问题）
    set_proc_name(current, local_name);

    // 如果一切顺利，返回 0，表示成功
    return 0;

execve_exit:
    // 如果加载程序失败，调用 do_exit 退出进程，并传递错误码
    do_exit(ret);

    // 此时程序应该已经退出，因此此行代码永远不会被执行到
    panic("already exit: %e.\n", ret);  // 崩溃，打印错误码
}

// do_yield - ask the scheduler to reschedule
int
do_yield(void) {
    current->need_resched = 1;
    return 0;
}

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int
do_wait(int pid, int *code_store) {
    struct mm_struct *mm = current->mm;
    if (code_store != NULL) {
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
            return -E_INVAL;
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    if (pid != 0) {
        proc = find_proc(pid);
        if (proc != NULL && proc->parent == current) {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    else {
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    if (haskid) {
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
        schedule();
        if (current->flags & PF_EXITING) {
            do_exit(-E_KILLED);
        }
        goto repeat;
    }
    return -E_BAD_PROC;

found:
    if (proc == idleproc || proc == initproc) {
        panic("wait idleproc or initproc.\n");
    }
    if (code_store != NULL) {
        *code_store = proc->exit_code;
    }
    local_intr_save(intr_flag);
    {
        unhash_proc(proc);
        remove_links(proc);
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int
do_kill(int pid) {
    struct proc_struct *proc;
    if ((proc = find_proc(pid)) != NULL) {
        if (!(proc->flags & PF_EXITING)) {
            proc->flags |= PF_EXITING;
            if (proc->wait_state & WT_INTERRUPTED) {
                wakeup_proc(proc);
            }
            return 0;
        }
        return -E_KILLED;
    }
    return -E_INVAL;
}
/*
很不幸。这么做行不通。do_execve() load_icode()里面只是构建了用户程序运行的上下文，但是并没有完成切换。
上下文切换实际上要借助中断处理的返回来完成。直接调用do_execve()是无法完成上下文切换的。如果是在用户态调用exec(), 
系统调用的ecall产生的中断返回时， 就可以完成上下文切换。

由于目前我们在S mode下，所以不能通过ecall来产生中断。我们这里采取一个取巧的办法，用ebreak产生断点中断进行处理，
通过设置a7寄存器的值为10说明这不是一个普通的断点中断，而是要转发到syscall(), 这样用一个不是特别优雅的方式，实现了在内核态使用系统调用。
*/
// kernel_execve - 调用 SYS_exec 系统调用来执行用户程序，由 user_main 内核线程调用
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
    // 初始化返回值 ret 和程序名长度 len
    int64_t ret = 0, len = strlen(name);

    // 使用内联汇编来发起系统调用 SYS_exec
    asm volatile(
        "li a0, %1\n"        // 将 SYS_exec 系统调用编号加载到 a0 寄存器
        "lw a1, %2\n"        // 将程序名地址加载到 a1 寄存器
        "lw a2, %3\n"        // 将程序名长度加载到 a2 寄存器
        "lw a3, %4\n"        // 将程序的二进制数据地址加载到 a3 寄存器
        "lw a4, %5\n"        // 将程序的大小加载到 a4 寄存器
        "li a7, 10\n"        // 将系统调用号（10，表示 exec）加载到 a7 寄存器
        "ebreak\n"           // 触发系统调用，执行 ebreak 指令
        "sw a0, %0\n"        // 将返回值（a0 寄存器的内容，即系统调用的返回值）存储到 ret
        : "=m"(ret)          // 输出操作：将 a0 寄存器的值存入 ret
        : "i"(SYS_exec),     // 输入操作：将 SYS_exec 编号传递给 a0
          "m"(name),         // 将程序名的地址传递给 a1
          "m"(len),          // 将程序名的长度传递给 a2
          "m"(binary),       // 将程序二进制数据的地址传递给 a3
          "m"(size)          // 将程序的大小传递给 a4
        : "memory");         // 声明内存被修改，以防止编译器进行优化

    // 打印系统调用返回值，便于调试
    cprintf("ret = %d\n", ret);

    // 返回系统调用的结果
    return ret;
}


#define __KERNEL_EXECVE(name, binary, size) ({                          \
            cprintf("kernel_execve: pid = %d, name = \"%s\".\n",        \
                    current->pid, name);                                \
            kernel_execve(name, binary, (size_t)(size));                \
        })// 打印正在执行的进程信息// 调用内核的 execve 函数加载程序

#define KERNEL_EXECVE(x) ({                                             \
            extern unsigned char _binary_obj___user_##x##_out_start[],  \
                _binary_obj___user_##x##_out_size[];                    \
            __KERNEL_EXECVE(#x, _binary_obj___user_##x##_out_start,     \
                            _binary_obj___user_##x##_out_size);         \
        })// 外部定义了程序的二进制数据起始位置和大小// 调用 __KERNEL_EXECVE 宏来执行程序
        //_binary_obj___user_##x##_out_start和_binary_obj___user_##x##_out_size都是编译的时候自动生成的符号。注意这里的##x##，按照C语言宏的语法，会直接把x的变量名代替进去。

#define __KERNEL_EXECVE2(x, xstart, xsize) ({                           \
            extern unsigned char xstart[], xsize[];                     \
            __KERNEL_EXECVE(#x, xstart, (size_t)xsize);                 \
        })// 外部定义了程序的二进制数据起始位置和大小// 调用 __KERNEL_EXECVE 宏来执行指定程序

#define KERNEL_EXECVE2(x, xstart, xsize)        __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {//于是，我们在user_main()所做的，就是执行了

//kern_execve("exit", _binary_obj___user_exit_out_start,_binary_obj___user_exit_out_size)

//这么一个函数。这时user_main就从内核进程变成了用户进程
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);// 如果定义了 TEST 宏，则执行指定的测试程序
    // KERNEL_EXECVE2 是一个宏，用于加载和执行 TEST 指定的程序
#else
    KERNEL_EXECVE(exit);// 否则，执行 exit 程序，通常是退出程序
#endif
    panic("user_main execve failed.\n");// 如果 execve 调用失败，触发 panic
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    size_t nr_free_pages_store = nr_free_pages();// 获取当前系统的空闲页面数量和已分配的内存量
    size_t kernel_allocated_store = kallocated();

    int pid = kernel_thread(user_main, NULL, 0);// 新建了一个内核进程，执行函数user_main(),这个内核进程里我们将要开始执行用户进程
    if (pid <= 0) {
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {// 等待子进程退出，也就是等待user_main()退出
        schedule();
    }

    cprintf("all user-mode processes have quit.\n");
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);// 检查 initproc 相关的指针是否为空，确保初始化过程中没有错误
    assert(nr_process == 2);// 确保进程数量为2，通常是 init 进程和 user_main 进程
    assert(list_next(&proc_list) == &(initproc->list_link));// 检查进程链表的前后链接，确认 initproc 依然在链表中
    assert(list_prev(&proc_list) == &(initproc->list_link));

    cprintf("init check memory pass.\n");
    return 0;
}

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
    set_proc_name(idleproc, "idle");
    nr_process ++;

    current = idleproc;

    int pid = kernel_thread(init_main, NULL, 0);
    if (pid <= 0) {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
    while (1) {
        if (current->need_resched) {
            schedule();
        }
    }
}

