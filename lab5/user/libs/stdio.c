#include <defs.h>
#include <stdio.h>
#include <syscall.h>

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
    sys_putc(c);//系统调用
    //在用户程序里使用的cprintf()也是在user/libs/stdio.c重新实现的，和之前比最大的区别是，打印字符的时候需要经过系统调用sys_putc()，
    //而不能直接调用sbi_console_putchar()。这是自然的，因为只有在Supervisor Mode才能通过ecall调用Machine Mode的OpenSBI接口，
    //而在用户态(U Mode)就不能直接使用M mode的接口，而是要通过系统调用。
    (*cnt) ++;
}

/* *
 * vcprintf - format a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);//注意这里复用了vprintfmt, 但是传入了cputch函数指针。具体来说，vcprintf 函数复用了 vprintfmt 函数，而不需要重新编写输出格式化和打印的代码。
    return cnt;
}

/* *
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
    va_list ap;

    va_start(ap, fmt);
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}

/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}

