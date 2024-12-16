#include <defs.h>
#include <unistd.h>
#include <stdarg.h>
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {//va_list, va_start, va_arg都是C语言处理参数个数不定的函数的宏
    //在stdarg.h里定义
    va_list ap;//ap: 参数列表(此时未初始化)
    va_start(ap, num);//初始化参数列表, 从num开始
    //首先，va_start 初始化可变参数列表为 va_list 类型
    uint64_t a[MAX_ARGS];// 存储传入的可变参数
    int i, ret;// i 用于循环，ret 存储系统调用的返回值
    for (i = 0; i < MAX_ARGS; i ++) {//把参数依次取出，将它们从参数列表中取出并存储到数组 `a` 中
        a[i] = va_arg(ap, uint64_t);/* 随后的 va_arg 执行将按传递给函数的顺序，依次返回额外参数的值。 */
    }
    va_end(ap);//最后，在函数返回之前，必须执行 va_end

    asm volatile (
        "ld a0, %1\n"  // 将 syscall 编号 (num) 加载到 a0 寄存器
        "ld a1, %2\n"  // 将第一个参数 a[0] 加载到 a1 寄存器
        "ld a2, %3\n"  // 将第二个参数 a[1] 加载到 a2 寄存器
        "ld a3, %4\n"  // 将第三个参数 a[2] 加载到 a3 寄存器
        "ld a4, %5\n"  // 将第四个参数 a[3] 加载到 a4 寄存器
        "ld a5, %6\n"  // 将第五个参数 a[4] 加载到 a5 寄存器
        "ecall\n"      // 触发系统调用，执行内核中的相应操作
        "sd a0, %0"    // 将系统调用的返回值（保存在 a0 寄存器中）存储到变量 `ret` 中
        : "=m" (ret)   // 输出操作，将 `ret` 存储到内存中
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])  // 输入操作，传递 num 和参数数组 a 的内容
        : "memory"     // 告诉编译器可能会修改内存，避免优化掉此部分
    );
        //num存到a0寄存器， a[0]存到a1寄存器
    //ecall的返回值存到ret
    return ret;
}

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
}

int
sys_fork(void) {
    return syscall(SYS_fork);
}

int
sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
}

int
sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
}

int
sys_pgdir(void) {
    return syscall(SYS_pgdir);
}

