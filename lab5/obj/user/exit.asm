
obj/__user_exit.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	12c000ef          	jal	80014c <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800026:	715d                	addi	sp,sp,-80
  800028:	e822                	sd	s0,16(sp)
  80002a:	fc3e                	sd	a5,56(sp)
  80002c:	8432                	mv	s0,a2
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  80002e:	103c                	addi	a5,sp,40
    cprintf("user panic at %s:%d:\n    ", file, line);
  800030:	862e                	mv	a2,a1
  800032:	85aa                	mv	a1,a0
  800034:	00000517          	auipc	a0,0x0
  800038:	63c50513          	addi	a0,a0,1596 # 800670 <main+0x114>
__panic(const char *file, int line, const char *fmt, ...) {
  80003c:	ec06                	sd	ra,24(sp)
  80003e:	f436                	sd	a3,40(sp)
  800040:	f83a                	sd	a4,48(sp)
  800042:	e0c2                	sd	a6,64(sp)
  800044:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800046:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800048:	058000ef          	jal	8000a0 <cprintf>
    vcprintf(fmt, ap);
  80004c:	65a2                	ld	a1,8(sp)
  80004e:	8522                	mv	a0,s0
  800050:	030000ef          	jal	800080 <vcprintf>
    cprintf("\n");
  800054:	00000517          	auipc	a0,0x0
  800058:	63c50513          	addi	a0,a0,1596 # 800690 <main+0x134>
  80005c:	044000ef          	jal	8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0c8000ef          	jal	80012a <exit>

0000000000800066 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800066:	1141                	addi	sp,sp,-16
  800068:	e022                	sd	s0,0(sp)
  80006a:	e406                	sd	ra,8(sp)
  80006c:	842e                	mv	s0,a1
    sys_putc(c);//系统调用
  80006e:	0b6000ef          	jal	800124 <sys_putc>
    //在用户程序里使用的cprintf()也是在user/libs/stdio.c重新实现的，和之前比最大的区别是，打印字符的时候需要经过系统调用sys_putc()，
    //而不能直接调用sbi_console_putchar()。这是自然的，因为只有在Supervisor Mode才能通过ecall调用Machine Mode的OpenSBI接口，
    //而在用户态(U Mode)就不能直接使用M mode的接口，而是要通过系统调用。
    (*cnt) ++;
  800072:	401c                	lw	a5,0(s0)
}
  800074:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800076:	2785                	addiw	a5,a5,1
  800078:	c01c                	sw	a5,0(s0)
}
  80007a:	6402                	ld	s0,0(sp)
  80007c:	0141                	addi	sp,sp,16
  80007e:	8082                	ret

0000000000800080 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800080:	1101                	addi	sp,sp,-32
  800082:	862a                	mv	a2,a0
  800084:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);//注意这里复用了vprintfmt, 但是传入了cputch函数指针。具体来说，vcprintf 函数复用了 vprintfmt 函数，而不需要重新编写输出格式化和打印的代码。
  800086:	00000517          	auipc	a0,0x0
  80008a:	fe050513          	addi	a0,a0,-32 # 800066 <cputch>
  80008e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800090:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800092:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);//注意这里复用了vprintfmt, 但是传入了cputch函数指针。具体来说，vcprintf 函数复用了 vprintfmt 函数，而不需要重新编写输出格式化和打印的代码。
  800094:	132000ef          	jal	8001c6 <vprintfmt>
    return cnt;
}
  800098:	60e2                	ld	ra,24(sp)
  80009a:	4532                	lw	a0,12(sp)
  80009c:	6105                	addi	sp,sp,32
  80009e:	8082                	ret

00000000008000a0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a0:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000a2:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000a6:	f42e                	sd	a1,40(sp)
  8000a8:	f832                	sd	a2,48(sp)
  8000aa:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);//注意这里复用了vprintfmt, 但是传入了cputch函数指针。具体来说，vcprintf 函数复用了 vprintfmt 函数，而不需要重新编写输出格式化和打印的代码。
  8000ac:	862a                	mv	a2,a0
  8000ae:	004c                	addi	a1,sp,4
  8000b0:	00000517          	auipc	a0,0x0
  8000b4:	fb650513          	addi	a0,a0,-74 # 800066 <cputch>
  8000b8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000ba:	ec06                	sd	ra,24(sp)
  8000bc:	e0ba                	sd	a4,64(sp)
  8000be:	e4be                	sd	a5,72(sp)
  8000c0:	e8c2                	sd	a6,80(sp)
  8000c2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000c4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000c6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);//注意这里复用了vprintfmt, 但是传入了cputch函数指针。具体来说，vcprintf 函数复用了 vprintfmt 函数，而不需要重新编写输出格式化和打印的代码。
  8000c8:	0fe000ef          	jal	8001c6 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000cc:	60e2                	ld	ra,24(sp)
  8000ce:	4512                	lw	a0,4(sp)
  8000d0:	6125                	addi	sp,sp,96
  8000d2:	8082                	ret

00000000008000d4 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {//va_list, va_start, va_arg都是C语言处理参数个数不定的函数的宏
  8000d4:	7175                	addi	sp,sp,-144
  8000d6:	e42a                	sd	a0,8(sp)
    va_start(ap, num);//初始化参数列表, 从num开始
    //首先，va_start 初始化可变参数列表为 va_list 类型
    uint64_t a[MAX_ARGS];// 存储传入的可变参数
    int i, ret;// i 用于循环，ret 存储系统调用的返回值
    for (i = 0; i < MAX_ARGS; i ++) {//把参数依次取出，将它们从参数列表中取出并存储到数组 `a` 中
        a[i] = va_arg(ap, uint64_t);/* 随后的 va_arg 执行将按传递给函数的顺序，依次返回额外参数的值。 */
  8000d8:	0108                	addi	a0,sp,128
syscall(int64_t num, ...) {//va_list, va_start, va_arg都是C语言处理参数个数不定的函数的宏
  8000da:	ecae                	sd	a1,88(sp)
  8000dc:	f0b2                	sd	a2,96(sp)
  8000de:	f4b6                	sd	a3,104(sp)
  8000e0:	f8ba                	sd	a4,112(sp)
  8000e2:	fcbe                	sd	a5,120(sp)
  8000e4:	e142                	sd	a6,128(sp)
  8000e6:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);/* 随后的 va_arg 执行将按传递给函数的顺序，依次返回额外参数的值。 */
  8000e8:	f02a                	sd	a0,32(sp)
  8000ea:	f42e                	sd	a1,40(sp)
  8000ec:	f832                	sd	a2,48(sp)
  8000ee:	fc36                	sd	a3,56(sp)
  8000f0:	e0ba                	sd	a4,64(sp)
  8000f2:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);//最后，在函数返回之前，必须执行 va_end

    asm volatile (
  8000f4:	6522                	ld	a0,8(sp)
  8000f6:	75a2                	ld	a1,40(sp)
  8000f8:	7642                	ld	a2,48(sp)
  8000fa:	76e2                	ld	a3,56(sp)
  8000fc:	6706                	ld	a4,64(sp)
  8000fe:	67a6                	ld	a5,72(sp)
  800100:	00000073          	ecall
  800104:	00a13e23          	sd	a0,28(sp)
        : "memory"     // 告诉编译器可能会修改内存，避免优化掉此部分
    );
        //num存到a0寄存器， a[0]存到a1寄存器
    //ecall的返回值存到ret
    return ret;
}
  800108:	4572                	lw	a0,28(sp)
  80010a:	6149                	addi	sp,sp,144
  80010c:	8082                	ret

000000000080010e <sys_exit>:

int
sys_exit(int64_t error_code) {
  80010e:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  800110:	4505                	li	a0,1
  800112:	b7c9                	j	8000d4 <syscall>

0000000000800114 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  800114:	4509                	li	a0,2
  800116:	bf7d                	j	8000d4 <syscall>

0000000000800118 <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
  800118:	862e                	mv	a2,a1
    return syscall(SYS_wait, pid, store);
  80011a:	85aa                	mv	a1,a0
  80011c:	450d                	li	a0,3
  80011e:	bf5d                	j	8000d4 <syscall>

0000000000800120 <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800120:	4529                	li	a0,10
  800122:	bf4d                	j	8000d4 <syscall>

0000000000800124 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  800124:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800126:	4579                	li	a0,30
  800128:	b775                	j	8000d4 <syscall>

000000000080012a <exit>:
/*
为何不让进程本身完成所有的资源回收工作呢？这是因为进程要执行回收操作，就表明此进程还存在，还在执行指令，这就需要内核栈的空间不能释放，
且表示进程存在的进程控制块不能释放。所以需要父进程来帮忙释放子进程无法完成的这两个资源回收工作。
*/
void
exit(int error_code) {
  80012a:	1141                	addi	sp,sp,-16
  80012c:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80012e:	fe1ff0ef          	jal	80010e <sys_exit>
    cprintf("BUG: exit failed.\n"); //执行完sys_exit后，按理说进程就结束了，后面的语句不应该再执行，
  800132:	00000517          	auipc	a0,0x0
  800136:	56650513          	addi	a0,a0,1382 # 800698 <main+0x13c>
  80013a:	f67ff0ef          	jal	8000a0 <cprintf>
    //所以执行到这里就说明exit失败了
    while (1);
  80013e:	a001                	j	80013e <exit+0x14>

0000000000800140 <fork>:
}

int
fork(void) {
    return sys_fork();
  800140:	bfd1                	j	800114 <sys_fork>

0000000000800142 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  800142:	4581                	li	a1,0
  800144:	4501                	li	a0,0
  800146:	bfc9                	j	800118 <sys_wait>

0000000000800148 <waitpid>:
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  800148:	bfc1                	j	800118 <sys_wait>

000000000080014a <yield>:
}

void
yield(void) {
    sys_yield();
  80014a:	bfd9                	j	800120 <sys_yield>

000000000080014c <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80014c:	1141                	addi	sp,sp,-16
  80014e:	e406                	sd	ra,8(sp)
    int ret = main();
  800150:	40c000ef          	jal	80055c <main>
    exit(ret);
  800154:	fd7ff0ef          	jal	80012a <exit>

0000000000800158 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800158:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80015c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80015e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800162:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800164:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800168:	f022                	sd	s0,32(sp)
  80016a:	ec26                	sd	s1,24(sp)
  80016c:	e84a                	sd	s2,16(sp)
  80016e:	f406                	sd	ra,40(sp)
  800170:	84aa                	mv	s1,a0
  800172:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800174:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800178:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80017a:	05067063          	bgeu	a2,a6,8001ba <printnum+0x62>
  80017e:	e44e                	sd	s3,8(sp)
  800180:	89be                	mv	s3,a5
        while (-- width > 0)
  800182:	4785                	li	a5,1
  800184:	00e7d763          	bge	a5,a4,800192 <printnum+0x3a>
            putch(padc, putdat);
  800188:	85ca                	mv	a1,s2
  80018a:	854e                	mv	a0,s3
        while (-- width > 0)
  80018c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80018e:	9482                	jalr	s1
        while (-- width > 0)
  800190:	fc65                	bnez	s0,800188 <printnum+0x30>
  800192:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800194:	1a02                	slli	s4,s4,0x20
  800196:	020a5a13          	srli	s4,s4,0x20
  80019a:	00000797          	auipc	a5,0x0
  80019e:	51678793          	addi	a5,a5,1302 # 8006b0 <main+0x154>
  8001a2:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001a4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a6:	0007c503          	lbu	a0,0(a5)
}
  8001aa:	70a2                	ld	ra,40(sp)
  8001ac:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ae:	85ca                	mv	a1,s2
  8001b0:	87a6                	mv	a5,s1
}
  8001b2:	6942                	ld	s2,16(sp)
  8001b4:	64e2                	ld	s1,24(sp)
  8001b6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001b8:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001ba:	03065633          	divu	a2,a2,a6
  8001be:	8722                	mv	a4,s0
  8001c0:	f99ff0ef          	jal	800158 <printnum>
  8001c4:	bfc1                	j	800194 <printnum+0x3c>

00000000008001c6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c6:	7119                	addi	sp,sp,-128
  8001c8:	f4a6                	sd	s1,104(sp)
  8001ca:	f0ca                	sd	s2,96(sp)
  8001cc:	ecce                	sd	s3,88(sp)
  8001ce:	e8d2                	sd	s4,80(sp)
  8001d0:	e4d6                	sd	s5,72(sp)
  8001d2:	e0da                	sd	s6,64(sp)
  8001d4:	f862                	sd	s8,48(sp)
  8001d6:	fc86                	sd	ra,120(sp)
  8001d8:	f8a2                	sd	s0,112(sp)
  8001da:	fc5e                	sd	s7,56(sp)
  8001dc:	f466                	sd	s9,40(sp)
  8001de:	f06a                	sd	s10,32(sp)
  8001e0:	ec6e                	sd	s11,24(sp)
  8001e2:	892a                	mv	s2,a0
  8001e4:	84ae                	mv	s1,a1
  8001e6:	8c32                	mv	s8,a2
  8001e8:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ea:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001ee:	05500b13          	li	s6,85
  8001f2:	00000a97          	auipc	s5,0x0
  8001f6:	6e2a8a93          	addi	s5,s5,1762 # 8008d4 <main+0x378>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001fa:	000c4503          	lbu	a0,0(s8)
  8001fe:	001c0413          	addi	s0,s8,1
  800202:	01350a63          	beq	a0,s3,800216 <vprintfmt+0x50>
            if (ch == '\0') {
  800206:	cd0d                	beqz	a0,800240 <vprintfmt+0x7a>
            putch(ch, putdat);
  800208:	85a6                	mv	a1,s1
  80020a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020c:	00044503          	lbu	a0,0(s0)
  800210:	0405                	addi	s0,s0,1
  800212:	ff351ae3          	bne	a0,s3,800206 <vprintfmt+0x40>
        char padc = ' ';
  800216:	02000d93          	li	s11,32
        lflag = altflag = 0;
  80021a:	4b81                	li	s7,0
  80021c:	4601                	li	a2,0
        width = precision = -1;
  80021e:	5d7d                	li	s10,-1
  800220:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800222:	00044683          	lbu	a3,0(s0)
  800226:	00140c13          	addi	s8,s0,1
  80022a:	fdd6859b          	addiw	a1,a3,-35
  80022e:	0ff5f593          	zext.b	a1,a1
  800232:	02bb6663          	bltu	s6,a1,80025e <vprintfmt+0x98>
  800236:	058a                	slli	a1,a1,0x2
  800238:	95d6                	add	a1,a1,s5
  80023a:	4198                	lw	a4,0(a1)
  80023c:	9756                	add	a4,a4,s5
  80023e:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800240:	70e6                	ld	ra,120(sp)
  800242:	7446                	ld	s0,112(sp)
  800244:	74a6                	ld	s1,104(sp)
  800246:	7906                	ld	s2,96(sp)
  800248:	69e6                	ld	s3,88(sp)
  80024a:	6a46                	ld	s4,80(sp)
  80024c:	6aa6                	ld	s5,72(sp)
  80024e:	6b06                	ld	s6,64(sp)
  800250:	7be2                	ld	s7,56(sp)
  800252:	7c42                	ld	s8,48(sp)
  800254:	7ca2                	ld	s9,40(sp)
  800256:	7d02                	ld	s10,32(sp)
  800258:	6de2                	ld	s11,24(sp)
  80025a:	6109                	addi	sp,sp,128
  80025c:	8082                	ret
            putch('%', putdat);
  80025e:	85a6                	mv	a1,s1
  800260:	02500513          	li	a0,37
  800264:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800266:	fff44703          	lbu	a4,-1(s0)
  80026a:	02500793          	li	a5,37
  80026e:	8c22                	mv	s8,s0
  800270:	f8f705e3          	beq	a4,a5,8001fa <vprintfmt+0x34>
  800274:	02500713          	li	a4,37
  800278:	ffec4783          	lbu	a5,-2(s8)
  80027c:	1c7d                	addi	s8,s8,-1
  80027e:	fee79de3          	bne	a5,a4,800278 <vprintfmt+0xb2>
  800282:	bfa5                	j	8001fa <vprintfmt+0x34>
                ch = *fmt;
  800284:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  800288:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
  80028a:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
  80028e:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
  800292:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
  800296:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
  800298:	02b76563          	bltu	a4,a1,8002c2 <vprintfmt+0xfc>
  80029c:	4525                	li	a0,9
                ch = *fmt;
  80029e:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
  8002a2:	002d171b          	slliw	a4,s10,0x2
  8002a6:	01a7073b          	addw	a4,a4,s10
  8002aa:	0017171b          	slliw	a4,a4,0x1
  8002ae:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
  8002b0:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
  8002b4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002b6:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
  8002ba:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
  8002be:	feb570e3          	bgeu	a0,a1,80029e <vprintfmt+0xd8>
            if (width < 0)
  8002c2:	f60cd0e3          	bgez	s9,800222 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002c6:	8cea                	mv	s9,s10
  8002c8:	5d7d                	li	s10,-1
  8002ca:	bfa1                	j	800222 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002cc:	8db6                	mv	s11,a3
  8002ce:	8462                	mv	s0,s8
  8002d0:	bf89                	j	800222 <vprintfmt+0x5c>
  8002d2:	8462                	mv	s0,s8
            altflag = 1;
  8002d4:	4b85                	li	s7,1
            goto reswitch;
  8002d6:	b7b1                	j	800222 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002d8:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002da:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002de:	00c7c463          	blt	a5,a2,8002e6 <vprintfmt+0x120>
    else if (lflag) {
  8002e2:	1a060163          	beqz	a2,800484 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
  8002e6:	000a3603          	ld	a2,0(s4)
  8002ea:	46c1                	li	a3,16
  8002ec:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  8002ee:	000d879b          	sext.w	a5,s11
  8002f2:	8766                	mv	a4,s9
  8002f4:	85a6                	mv	a1,s1
  8002f6:	854a                	mv	a0,s2
  8002f8:	e61ff0ef          	jal	800158 <printnum>
            break;
  8002fc:	bdfd                	j	8001fa <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002fe:	000a2503          	lw	a0,0(s4)
  800302:	85a6                	mv	a1,s1
  800304:	0a21                	addi	s4,s4,8
  800306:	9902                	jalr	s2
            break;
  800308:	bdcd                	j	8001fa <vprintfmt+0x34>
    if (lflag >= 2) {
  80030a:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80030c:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800310:	00c7c463          	blt	a5,a2,800318 <vprintfmt+0x152>
    else if (lflag) {
  800314:	16060363          	beqz	a2,80047a <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
  800318:	000a3603          	ld	a2,0(s4)
  80031c:	46a9                	li	a3,10
  80031e:	8a3a                	mv	s4,a4
  800320:	b7f9                	j	8002ee <vprintfmt+0x128>
            putch('0', putdat);
  800322:	85a6                	mv	a1,s1
  800324:	03000513          	li	a0,48
  800328:	9902                	jalr	s2
            putch('x', putdat);
  80032a:	85a6                	mv	a1,s1
  80032c:	07800513          	li	a0,120
  800330:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800332:	000a3603          	ld	a2,0(s4)
            goto number;
  800336:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800338:	0a21                	addi	s4,s4,8
            goto number;
  80033a:	bf55                	j	8002ee <vprintfmt+0x128>
            putch(ch, putdat);
  80033c:	85a6                	mv	a1,s1
  80033e:	02500513          	li	a0,37
  800342:	9902                	jalr	s2
            break;
  800344:	bd5d                	j	8001fa <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800346:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80034a:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  80034c:	0a21                	addi	s4,s4,8
            goto process_precision;
  80034e:	bf95                	j	8002c2 <vprintfmt+0xfc>
    if (lflag >= 2) {
  800350:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800352:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800356:	00c7c463          	blt	a5,a2,80035e <vprintfmt+0x198>
    else if (lflag) {
  80035a:	10060b63          	beqz	a2,800470 <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
  80035e:	000a3603          	ld	a2,0(s4)
  800362:	46a1                	li	a3,8
  800364:	8a3a                	mv	s4,a4
  800366:	b761                	j	8002ee <vprintfmt+0x128>
            if (width < 0)
  800368:	fffcc793          	not	a5,s9
  80036c:	97fd                	srai	a5,a5,0x3f
  80036e:	00fcf7b3          	and	a5,s9,a5
  800372:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
  800376:	8462                	mv	s0,s8
            goto reswitch;
  800378:	b56d                	j	800222 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  80037a:	000a3403          	ld	s0,0(s4)
  80037e:	008a0793          	addi	a5,s4,8
  800382:	e43e                	sd	a5,8(sp)
  800384:	12040063          	beqz	s0,8004a4 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800388:	0d905963          	blez	s9,80045a <vprintfmt+0x294>
  80038c:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800390:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
  800394:	12fd9763          	bne	s11,a5,8004c2 <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800398:	00044783          	lbu	a5,0(s0)
  80039c:	0007851b          	sext.w	a0,a5
  8003a0:	cb9d                	beqz	a5,8003d6 <vprintfmt+0x210>
  8003a2:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003a4:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a8:	000d4563          	bltz	s10,8003b2 <vprintfmt+0x1ec>
  8003ac:	3d7d                	addiw	s10,s10,-1
  8003ae:	028d0263          	beq	s10,s0,8003d2 <vprintfmt+0x20c>
                    putch('?', putdat);
  8003b2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003b4:	0c0b8d63          	beqz	s7,80048e <vprintfmt+0x2c8>
  8003b8:	3781                	addiw	a5,a5,-32
  8003ba:	0cfdfa63          	bgeu	s11,a5,80048e <vprintfmt+0x2c8>
                    putch('?', putdat);
  8003be:	03f00513          	li	a0,63
  8003c2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c4:	000a4783          	lbu	a5,0(s4)
  8003c8:	3cfd                	addiw	s9,s9,-1
  8003ca:	0a05                	addi	s4,s4,1
  8003cc:	0007851b          	sext.w	a0,a5
  8003d0:	ffe1                	bnez	a5,8003a8 <vprintfmt+0x1e2>
            for (; width > 0; width --) {
  8003d2:	01905963          	blez	s9,8003e4 <vprintfmt+0x21e>
                putch(' ', putdat);
  8003d6:	85a6                	mv	a1,s1
  8003d8:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003dc:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
  8003de:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003e0:	fe0c9be3          	bnez	s9,8003d6 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003e4:	6a22                	ld	s4,8(sp)
  8003e6:	bd11                	j	8001fa <vprintfmt+0x34>
    if (lflag >= 2) {
  8003e8:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8003ea:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003ee:	00c7c363          	blt	a5,a2,8003f4 <vprintfmt+0x22e>
    else if (lflag) {
  8003f2:	ce25                	beqz	a2,80046a <vprintfmt+0x2a4>
        return va_arg(*ap, long);
  8003f4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003f8:	08044d63          	bltz	s0,800492 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  8003fc:	8622                	mv	a2,s0
  8003fe:	8a5e                	mv	s4,s7
  800400:	46a9                	li	a3,10
  800402:	b5f5                	j	8002ee <vprintfmt+0x128>
            if (err < 0) {
  800404:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800408:	4661                	li	a2,24
            if (err < 0) {
  80040a:	41f7d71b          	sraiw	a4,a5,0x1f
  80040e:	8fb9                	xor	a5,a5,a4
  800410:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800414:	02d64663          	blt	a2,a3,800440 <vprintfmt+0x27a>
  800418:	00369713          	slli	a4,a3,0x3
  80041c:	00000797          	auipc	a5,0x0
  800420:	61478793          	addi	a5,a5,1556 # 800a30 <error_string>
  800424:	97ba                	add	a5,a5,a4
  800426:	639c                	ld	a5,0(a5)
  800428:	cf81                	beqz	a5,800440 <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
  80042a:	86be                	mv	a3,a5
  80042c:	00000617          	auipc	a2,0x0
  800430:	2b460613          	addi	a2,a2,692 # 8006e0 <main+0x184>
  800434:	85a6                	mv	a1,s1
  800436:	854a                	mv	a0,s2
  800438:	0e8000ef          	jal	800520 <printfmt>
            err = va_arg(ap, int);
  80043c:	0a21                	addi	s4,s4,8
  80043e:	bb75                	j	8001fa <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800440:	00000617          	auipc	a2,0x0
  800444:	29060613          	addi	a2,a2,656 # 8006d0 <main+0x174>
  800448:	85a6                	mv	a1,s1
  80044a:	854a                	mv	a0,s2
  80044c:	0d4000ef          	jal	800520 <printfmt>
            err = va_arg(ap, int);
  800450:	0a21                	addi	s4,s4,8
  800452:	b365                	j	8001fa <vprintfmt+0x34>
            lflag ++;
  800454:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  800456:	8462                	mv	s0,s8
            goto reswitch;
  800458:	b3e9                	j	800222 <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80045a:	00044783          	lbu	a5,0(s0)
  80045e:	0007851b          	sext.w	a0,a5
  800462:	d3c9                	beqz	a5,8003e4 <vprintfmt+0x21e>
  800464:	00140a13          	addi	s4,s0,1
  800468:	bf2d                	j	8003a2 <vprintfmt+0x1dc>
        return va_arg(*ap, int);
  80046a:	000a2403          	lw	s0,0(s4)
  80046e:	b769                	j	8003f8 <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
  800470:	000a6603          	lwu	a2,0(s4)
  800474:	46a1                	li	a3,8
  800476:	8a3a                	mv	s4,a4
  800478:	bd9d                	j	8002ee <vprintfmt+0x128>
  80047a:	000a6603          	lwu	a2,0(s4)
  80047e:	46a9                	li	a3,10
  800480:	8a3a                	mv	s4,a4
  800482:	b5b5                	j	8002ee <vprintfmt+0x128>
  800484:	000a6603          	lwu	a2,0(s4)
  800488:	46c1                	li	a3,16
  80048a:	8a3a                	mv	s4,a4
  80048c:	b58d                	j	8002ee <vprintfmt+0x128>
                    putch(ch, putdat);
  80048e:	9902                	jalr	s2
  800490:	bf15                	j	8003c4 <vprintfmt+0x1fe>
                putch('-', putdat);
  800492:	85a6                	mv	a1,s1
  800494:	02d00513          	li	a0,45
  800498:	9902                	jalr	s2
                num = -(long long)num;
  80049a:	40800633          	neg	a2,s0
  80049e:	8a5e                	mv	s4,s7
  8004a0:	46a9                	li	a3,10
  8004a2:	b5b1                	j	8002ee <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
  8004a4:	01905663          	blez	s9,8004b0 <vprintfmt+0x2ea>
  8004a8:	02d00793          	li	a5,45
  8004ac:	04fd9263          	bne	s11,a5,8004f0 <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b0:	02800793          	li	a5,40
  8004b4:	00000a17          	auipc	s4,0x0
  8004b8:	215a0a13          	addi	s4,s4,533 # 8006c9 <main+0x16d>
  8004bc:	02800513          	li	a0,40
  8004c0:	b5cd                	j	8003a2 <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c2:	85ea                	mv	a1,s10
  8004c4:	8522                	mv	a0,s0
  8004c6:	07a000ef          	jal	800540 <strnlen>
  8004ca:	40ac8cbb          	subw	s9,s9,a0
  8004ce:	01905963          	blez	s9,8004e0 <vprintfmt+0x31a>
                    putch(padc, putdat);
  8004d2:	2d81                	sext.w	s11,s11
  8004d4:	85a6                	mv	a1,s1
  8004d6:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d8:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
  8004da:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004dc:	fe0c9ce3          	bnez	s9,8004d4 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e0:	00044783          	lbu	a5,0(s0)
  8004e4:	0007851b          	sext.w	a0,a5
  8004e8:	ea079de3          	bnez	a5,8003a2 <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004ec:	6a22                	ld	s4,8(sp)
  8004ee:	b331                	j	8001fa <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004f0:	85ea                	mv	a1,s10
  8004f2:	00000517          	auipc	a0,0x0
  8004f6:	1d650513          	addi	a0,a0,470 # 8006c8 <main+0x16c>
  8004fa:	046000ef          	jal	800540 <strnlen>
  8004fe:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
  800502:	00000417          	auipc	s0,0x0
  800506:	1c640413          	addi	s0,s0,454 # 8006c8 <main+0x16c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80050a:	00000a17          	auipc	s4,0x0
  80050e:	1bfa0a13          	addi	s4,s4,447 # 8006c9 <main+0x16d>
  800512:	02800793          	li	a5,40
  800516:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
  80051a:	fb904ce3          	bgtz	s9,8004d2 <vprintfmt+0x30c>
  80051e:	b551                	j	8003a2 <vprintfmt+0x1dc>

0000000000800520 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800520:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800522:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800526:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800528:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052a:	ec06                	sd	ra,24(sp)
  80052c:	f83a                	sd	a4,48(sp)
  80052e:	fc3e                	sd	a5,56(sp)
  800530:	e0c2                	sd	a6,64(sp)
  800532:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800534:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800536:	c91ff0ef          	jal	8001c6 <vprintfmt>
}
  80053a:	60e2                	ld	ra,24(sp)
  80053c:	6161                	addi	sp,sp,80
  80053e:	8082                	ret

0000000000800540 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800540:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800542:	e589                	bnez	a1,80054c <strnlen+0xc>
  800544:	a811                	j	800558 <strnlen+0x18>
        cnt ++;
  800546:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800548:	00f58863          	beq	a1,a5,800558 <strnlen+0x18>
  80054c:	00f50733          	add	a4,a0,a5
  800550:	00074703          	lbu	a4,0(a4)
  800554:	fb6d                	bnez	a4,800546 <strnlen+0x6>
  800556:	85be                	mv	a1,a5
    }
    return cnt;
}
  800558:	852e                	mv	a0,a1
  80055a:	8082                	ret

000000000080055c <main>:
#include <ulib.h>

int magic = -0x10384;

int
main(void) {//这个用户程序exit里我们测试了fork() wait()这些函数。这些函数都是user/libs/ulib.h对系统调用的封装
  80055c:	1101                	addi	sp,sp,-32
    int pid, code;
    cprintf("I am the parent. Forking the child...\n");// 父进程输出信息，表示将要创建子进程
  80055e:	00000517          	auipc	a0,0x0
  800562:	24a50513          	addi	a0,a0,586 # 8007a8 <main+0x24c>
main(void) {//这个用户程序exit里我们测试了fork() wait()这些函数。这些函数都是user/libs/ulib.h对系统调用的封装
  800566:	ec06                	sd	ra,24(sp)
  800568:	e822                	sd	s0,16(sp)
    cprintf("I am the parent. Forking the child...\n");// 父进程输出信息，表示将要创建子进程
  80056a:	b37ff0ef          	jal	8000a0 <cprintf>
    if ((pid = fork()) == 0) {// 创建子进程，fork() 返回子进程的 PID给父进程，子进程返回0s
  80056e:	bd3ff0ef          	jal	800140 <fork>
  800572:	c561                	beqz	a0,80063a <main+0xde>
  800574:	842a                	mv	s0,a0
        yield();
        yield();
        exit(magic);// 子进程完成后，调用 exit() 退出，传递 magic 作为退出码
    }
    else {
        cprintf("I am parent, fork a child pid %d\n",pid);// 父进程的代码块
  800576:	85aa                	mv	a1,a0
  800578:	00000517          	auipc	a0,0x0
  80057c:	27050513          	addi	a0,a0,624 # 8007e8 <main+0x28c>
  800580:	b21ff0ef          	jal	8000a0 <cprintf>
    }
    assert(pid > 0);// 确保父进程的 pid 大于0
  800584:	08805c63          	blez	s0,80061c <main+0xc0>
    cprintf("I am the parent, waiting now..\n");// 父进程输出等待子进程结束的信息
  800588:	00000517          	auipc	a0,0x0
  80058c:	2b850513          	addi	a0,a0,696 # 800840 <main+0x2e4>
  800590:	b11ff0ef          	jal	8000a0 <cprintf>

    assert(waitpid(pid, &code) == 0 && code == magic);// 父进程等待子进程的退出，验证退出码为 magic
  800594:	006c                	addi	a1,sp,12
  800596:	8522                	mv	a0,s0
  800598:	bb1ff0ef          	jal	800148 <waitpid>
  80059c:	e131                	bnez	a0,8005e0 <main+0x84>
  80059e:	4732                	lw	a4,12(sp)
  8005a0:	00001797          	auipc	a5,0x1
  8005a4:	a607a783          	lw	a5,-1440(a5) # 801000 <magic>
  8005a8:	02f71c63          	bne	a4,a5,8005e0 <main+0x84>
    assert(waitpid(pid, &code) != 0 && wait() != 0);// 父进程再次尝试等待子进程，应该失败
  8005ac:	006c                	addi	a1,sp,12
  8005ae:	8522                	mv	a0,s0
  8005b0:	b99ff0ef          	jal	800148 <waitpid>
  8005b4:	c529                	beqz	a0,8005fe <main+0xa2>
  8005b6:	b8dff0ef          	jal	800142 <wait>
  8005ba:	c131                	beqz	a0,8005fe <main+0xa2>
    cprintf("waitpid %d ok.\n", pid);// 输出等待操作成功的调试信息
  8005bc:	85a2                	mv	a1,s0
  8005be:	00000517          	auipc	a0,0x0
  8005c2:	2fa50513          	addi	a0,a0,762 # 8008b8 <main+0x35c>
  8005c6:	adbff0ef          	jal	8000a0 <cprintf>

    cprintf("exit pass.\n");// 父进程退出信息
  8005ca:	00000517          	auipc	a0,0x0
  8005ce:	2fe50513          	addi	a0,a0,766 # 8008c8 <main+0x36c>
  8005d2:	acfff0ef          	jal	8000a0 <cprintf>
    return 0;
}
  8005d6:	60e2                	ld	ra,24(sp)
  8005d8:	6442                	ld	s0,16(sp)
  8005da:	4501                	li	a0,0
  8005dc:	6105                	addi	sp,sp,32
  8005de:	8082                	ret
    assert(waitpid(pid, &code) == 0 && code == magic);// 父进程等待子进程的退出，验证退出码为 magic
  8005e0:	00000697          	auipc	a3,0x0
  8005e4:	28068693          	addi	a3,a3,640 # 800860 <main+0x304>
  8005e8:	00000617          	auipc	a2,0x0
  8005ec:	23060613          	addi	a2,a2,560 # 800818 <main+0x2bc>
  8005f0:	45ed                	li	a1,27
  8005f2:	00000517          	auipc	a0,0x0
  8005f6:	23e50513          	addi	a0,a0,574 # 800830 <main+0x2d4>
  8005fa:	a2dff0ef          	jal	800026 <__panic>
    assert(waitpid(pid, &code) != 0 && wait() != 0);// 父进程再次尝试等待子进程，应该失败
  8005fe:	00000697          	auipc	a3,0x0
  800602:	29268693          	addi	a3,a3,658 # 800890 <main+0x334>
  800606:	00000617          	auipc	a2,0x0
  80060a:	21260613          	addi	a2,a2,530 # 800818 <main+0x2bc>
  80060e:	45f1                	li	a1,28
  800610:	00000517          	auipc	a0,0x0
  800614:	22050513          	addi	a0,a0,544 # 800830 <main+0x2d4>
  800618:	a0fff0ef          	jal	800026 <__panic>
    assert(pid > 0);// 确保父进程的 pid 大于0
  80061c:	00000697          	auipc	a3,0x0
  800620:	1f468693          	addi	a3,a3,500 # 800810 <main+0x2b4>
  800624:	00000617          	auipc	a2,0x0
  800628:	1f460613          	addi	a2,a2,500 # 800818 <main+0x2bc>
  80062c:	45e1                	li	a1,24
  80062e:	00000517          	auipc	a0,0x0
  800632:	20250513          	addi	a0,a0,514 # 800830 <main+0x2d4>
  800636:	9f1ff0ef          	jal	800026 <__panic>
        cprintf("I am the child.\n");// 子进程的代码块
  80063a:	00000517          	auipc	a0,0x0
  80063e:	19650513          	addi	a0,a0,406 # 8007d0 <main+0x274>
  800642:	a5fff0ef          	jal	8000a0 <cprintf>
        yield();
  800646:	b05ff0ef          	jal	80014a <yield>
        yield();
  80064a:	b01ff0ef          	jal	80014a <yield>
        yield();
  80064e:	afdff0ef          	jal	80014a <yield>
        yield();
  800652:	af9ff0ef          	jal	80014a <yield>
        yield();
  800656:	af5ff0ef          	jal	80014a <yield>
        yield();
  80065a:	af1ff0ef          	jal	80014a <yield>
        yield();
  80065e:	aedff0ef          	jal	80014a <yield>
        exit(magic);// 子进程完成后，调用 exit() 退出，传递 magic 作为退出码
  800662:	00001517          	auipc	a0,0x1
  800666:	99e52503          	lw	a0,-1634(a0) # 801000 <magic>
  80066a:	ac1ff0ef          	jal	80012a <exit>
