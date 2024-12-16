#ifndef __LIBS_UNISTD_H__
#define __LIBS_UNISTD_H__

#define T_SYSCALL           0x80// 定义系统调用的中断号

/* syscall number */
#define SYS_exit            1       // 退出进程
#define SYS_fork            2       // 创建子进程
#define SYS_wait            3       // 等待进程结束
#define SYS_exec            4       // 执行程序
#define SYS_clone           5       // 创建进程（带有更多选项）
#define SYS_yield           10      // 主动放弃当前进程的 CPU 时间片
#define SYS_sleep           11      // 使当前进程睡眠指定时间
#define SYS_kill            12      // 发送信号终止进程
#define SYS_gettime         17      // 获取当前系统时间
#define SYS_getpid          18      // 获取当前进程的 PID
#define SYS_brk             19      // 修改进程的堆空间
#define SYS_mmap            20      // 映射文件或设备到内存
#define SYS_munmap          21      // 解除映射文件或设备
#define SYS_shmem           22      // 共享内存操作
#define SYS_putc            30      // 输出字符到控制台
#define SYS_pgdir           31      // 获取当前进程的页目录

/* SYS_fork flags */
#define CLONE_VM            0x00000100  // set if VM shared between processes 设置此标志时，子进程共享父进程的虚拟内存
#define CLONE_THREAD        0x00000200  // thread group 设置此标志时，子进程为线程组的一部分

#endif /* !__LIBS_UNISTD_H__ */

