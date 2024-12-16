#ifndef __KERN_PROCESS_PROC_H__
#define __KERN_PROCESS_PROC_H__

#include <defs.h>
#include <list.h>
#include <trap.h>
#include <memlayout.h>


// process's state in his life cycle
enum proc_state {
    PROC_UNINIT = 0,  // uninitialized
    PROC_SLEEPING,    // sleeping
    PROC_RUNNABLE,    // runnable(maybe running)
    PROC_ZOMBIE,      // almost dead, and wait parent proc to reclaim his resource
};

struct context {
    uintptr_t ra;
    uintptr_t sp;
    uintptr_t s0;
    uintptr_t s1;
    uintptr_t s2;
    uintptr_t s3;
    uintptr_t s4;
    uintptr_t s5;
    uintptr_t s6;
    uintptr_t s7;
    uintptr_t s8;
    uintptr_t s9;
    uintptr_t s10;
    uintptr_t s11;
};

#define PROC_NAME_LEN               15
#define MAX_PROCESS                 4096
#define MAX_PID                     (MAX_PROCESS * 2)

extern list_entry_t proc_list;

struct proc_struct {
    enum proc_state state;                      // Process state 进程状态，表示进程当前的状态
    int pid;                                    // Process ID
    int runs;                                   // the running times of Proces
    uintptr_t kstack;                           // Process kernel stack 进程的内核栈，存放进程的内核态栈数据
    volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU? 是否需要重新调度的标志
    struct proc_struct *parent;                 // the parent process 父进程指针
    struct mm_struct *mm;                       // Process's memory management field 进程的内存管理结构，表示进程的虚拟内存空间
    struct context context;                     // Switch here to run process 进程的上下文（即寄存器状态），用于进程切换时保存进程的寄存器值
    struct trapframe *tf;                       // Trap frame for current interrupt 当前进程的 Trap Frame，保存进程上下文中的中断信息（例如中断、系统调用的参数等）
    uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT) CR3 寄存器的值，即页目录表的基地址
    uint32_t flags;                             // Process flag 进程的标志位，存储进程的一些状态信息，如是否为内核线程等
    char name[PROC_NAME_LEN + 1];               // Process name 进程的名称，最大长度为 `PROC_NAME_LEN`，用于标识进程
    list_entry_t list_link;                     // Process link list 用于进程链表的连接（双向链表），该链表用于进程调度、进程管理等
    list_entry_t hash_link;                     // Process hash list 用于进程哈希表的连接
    int exit_code;                              // exit code (be sent to parent proc) 进程退出码
    uint32_t wait_state;                        // waiting state 进程的等待状态，指示进程当前是否在等待某些事件
    struct proc_struct *cptr, *yptr, *optr;     // relations between processes 当前进程的子进程（cptr）、父进程（yptr）和兄弟进程（optr）的链接关系
};

#define PF_EXITING                  0x00000001      // getting shutdown

#define WT_CHILD                    (0x00000001 | WT_INTERRUPTED)
#define WT_INTERRUPTED               0x80000000                    // the wait state could be interrupted


#define le2proc(le, member)         \
    to_struct((le), struct proc_struct, member)

extern struct proc_struct *idleproc, *initproc, *current;

void proc_init(void);
void proc_run(struct proc_struct *proc);
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);

char *set_proc_name(struct proc_struct *proc, const char *name);
char *get_proc_name(struct proc_struct *proc);
void cpu_idle(void) __attribute__((noreturn));

struct proc_struct *find_proc(int pid);
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
int do_exit(int error_code);
int do_yield(void);
int do_execve(const char *name, size_t len, unsigned char *binary, size_t size);
int do_wait(int pid, int *code_store);
int do_kill(int pid);
#endif /* !__KERN_PROCESS_PROC_H__ */

