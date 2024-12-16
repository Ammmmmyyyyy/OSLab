#include <unistd.h>
#include <proc.h>
#include <syscall.h>
#include <trap.h>
#include <stdio.h>
#include <pmm.h>
#include <assert.h>
//这里把系统调用进一步转发给proc.c的do_exit(), do_fork()等函数
static int
sys_exit(uint64_t arg[]) {
    // ucore从 arg[0] 获取退出码并转换为整型
    int error_code = (int)arg[0];
    
    // 调用 do_exit 处理进程退出，返回退出状态
    return do_exit(error_code);
}

static int
sys_fork(uint64_t arg[]) {
    // 获取当前进程的陷入帧（trapframe），其中包含当前进程的寄存器信息
    struct trapframe *tf = current->tf;
    
    // 获取当前进程的栈指针（sp），将其传递给 do_fork
    uintptr_t stack = tf->gpr.sp;
    
    // 调用 do_fork 创建一个新的子进程，传递栈指针和陷入帧
    return do_fork(0, stack, tf);
}

static int
sys_wait(uint64_t arg[]) {
    // 获取要等待的子进程 PID
    int pid = (int)arg[0];
    
    // 获取存储进程退出码的地址
    int *store = (int *)arg[1];
    
    // 调用 do_wait 等待子进程结束并获取退出状态
    return do_wait(pid, store);
}

static int
sys_exec(uint64_t arg[]) {
    // 从 arg 数组中获取程序名称、长度、二进制文件数据和大小
    const char *name = (const char *)arg[0];
    size_t len = (size_t)arg[1];
    unsigned char *binary = (unsigned char *)arg[2];
    size_t size = (size_t)arg[3];
    
    // 调用 do_execve 来执行指定的程序
    return do_execve(name, len, binary, size);
}

static int
sys_yield(uint64_t arg[]) {
    // 调用 do_yield 让出当前进程的 CPU 使用权
    return do_yield();
}

static int
sys_kill(uint64_t arg[]) {
    // 获取要终止的进程 PID
    int pid = (int)arg[0];
    
    // 调用 do_kill 来终止指定进程
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    // 返回当前进程的 PID
    return current->pid;
}

static int
sys_putc(uint64_t arg[]) {
    // 获取要输出的字符
    int c = (int)arg[0];
    
    // 调用 cputchar 函数输出字符
    cputchar(c);
    
    // 返回 0，表示成功
    return 0;
}

static int
sys_pgdir(uint64_t arg[]) {
    // 该系统调用暂时没有实现具体功能，但可以用来打印当前进程的页表信息
    // print_pgdir();
    
    // 返回 0，表示成功
    return 0;
}

static int (*syscalls[])(uint64_t arg[]) = {//这里定义了函数指针的数组syscalls, 把每个系统调用编号的下标上初始化为对应的函数指针
    [SYS_exit]              sys_exit,
    [SYS_fork]              sys_fork,
    [SYS_wait]              sys_wait,
    [SYS_exec]              sys_exec,
    [SYS_yield]             sys_yield,
    [SYS_kill]              sys_kill,
    [SYS_getpid]            sys_getpid,
    [SYS_putc]              sys_putc,
    [SYS_pgdir]             sys_pgdir,
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
    // 获取当前进程的陷入帧（trapframe），用于访问当前进程的寄存器状态
    struct trapframe *tf = current->tf;
    
    // 从 a0 寄存器获取系统调用编号
    uint64_t arg[5];  // 用于存储传递给系统调用的参数
    int num = tf->gpr.a0;  // a0 寄存器保存系统调用编号

    // 检查系统调用编号是否有效，防止越界访问 syscalls 数组
    if (num >= 0 && num < NUM_SYSCALLS) {
        // 如果系统调用编号合法且该编号对应的系统调用存在
        if (syscalls[num] != NULL) {
            // 从寄存器中提取出参数，并存入 arg 数组
            arg[0] = tf->gpr.a1;  // a1 寄存器保存第一个参数
            arg[1] = tf->gpr.a2;  // a2 寄存器保存第二个参数
            arg[2] = tf->gpr.a3;  // a3 寄存器保存第三个参数
            arg[3] = tf->gpr.a4;  // a4 寄存器保存第四个参数
            arg[4] = tf->gpr.a5;  // a5 寄存器保存第五个参数
            
            // 调用系统调用函数，并将返回值存储到 a0 寄存器
            tf->gpr.a0 = syscalls[num](arg);  //把寄存器里的参数取出来，转发给系统调用编号对应的函数进行处理
            
            return;  // 系统调用已完成，返回到调用者
        }
    }

    // 如果执行到这里，说明传入的系统调用编号无效或未实现
    // 打印当前陷入帧信息，帮助调试
    print_trapframe(tf);
    
    // 崩溃并打印错误信息，说明是一个未定义的系统调用
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}


