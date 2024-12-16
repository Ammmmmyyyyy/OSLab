
obj/__user_hello.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0b6000ef          	jal	8000d6 <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800026:	1141                	addi	sp,sp,-16
  800028:	e022                	sd	s0,0(sp)
  80002a:	e406                	sd	ra,8(sp)
  80002c:	842e                	mv	s0,a1
    sys_putc(c);//系统调用
  80002e:	08a000ef          	jal	8000b8 <sys_putc>
    //在用户程序里使用的cprintf()也是在user/libs/stdio.c重新实现的，和之前比最大的区别是，打印字符的时候需要经过系统调用sys_putc()，
    //而不能直接调用sbi_console_putchar()。这是自然的，因为只有在Supervisor Mode才能通过ecall调用Machine Mode的OpenSBI接口，
    //而在用户态(U Mode)就不能直接使用M mode的接口，而是要通过系统调用。
    (*cnt) ++;
  800032:	401c                	lw	a5,0(s0)
}
  800034:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800036:	2785                	addiw	a5,a5,1
  800038:	c01c                	sw	a5,0(s0)
}
  80003a:	6402                	ld	s0,0(sp)
  80003c:	0141                	addi	sp,sp,16
  80003e:	8082                	ret

0000000000800040 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800040:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800042:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800046:	f42e                	sd	a1,40(sp)
  800048:	f832                	sd	a2,48(sp)
  80004a:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);//注意这里复用了vprintfmt, 但是传入了cputch函数指针。具体来说，vcprintf 函数复用了 vprintfmt 函数，而不需要重新编写输出格式化和打印的代码。
  80004c:	862a                	mv	a2,a0
  80004e:	004c                	addi	a1,sp,4
  800050:	00000517          	auipc	a0,0x0
  800054:	fd650513          	addi	a0,a0,-42 # 800026 <cputch>
  800058:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  80005a:	ec06                	sd	ra,24(sp)
  80005c:	e0ba                	sd	a4,64(sp)
  80005e:	e4be                	sd	a5,72(sp)
  800060:	e8c2                	sd	a6,80(sp)
  800062:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800064:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800066:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);//注意这里复用了vprintfmt, 但是传入了cputch函数指针。具体来说，vcprintf 函数复用了 vprintfmt 函数，而不需要重新编写输出格式化和打印的代码。
  800068:	0e8000ef          	jal	800150 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80006c:	60e2                	ld	ra,24(sp)
  80006e:	4512                	lw	a0,4(sp)
  800070:	6125                	addi	sp,sp,96
  800072:	8082                	ret

0000000000800074 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {//va_list, va_start, va_arg都是C语言处理参数个数不定的函数的宏
  800074:	7175                	addi	sp,sp,-144
  800076:	e42a                	sd	a0,8(sp)
    va_start(ap, num);//初始化参数列表, 从num开始
    //首先，va_start 初始化可变参数列表为 va_list 类型
    uint64_t a[MAX_ARGS];// 存储传入的可变参数
    int i, ret;// i 用于循环，ret 存储系统调用的返回值
    for (i = 0; i < MAX_ARGS; i ++) {//把参数依次取出，将它们从参数列表中取出并存储到数组 `a` 中
        a[i] = va_arg(ap, uint64_t);/* 随后的 va_arg 执行将按传递给函数的顺序，依次返回额外参数的值。 */
  800078:	0108                	addi	a0,sp,128
syscall(int64_t num, ...) {//va_list, va_start, va_arg都是C语言处理参数个数不定的函数的宏
  80007a:	ecae                	sd	a1,88(sp)
  80007c:	f0b2                	sd	a2,96(sp)
  80007e:	f4b6                	sd	a3,104(sp)
  800080:	f8ba                	sd	a4,112(sp)
  800082:	fcbe                	sd	a5,120(sp)
  800084:	e142                	sd	a6,128(sp)
  800086:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);/* 随后的 va_arg 执行将按传递给函数的顺序，依次返回额外参数的值。 */
  800088:	f02a                	sd	a0,32(sp)
  80008a:	f42e                	sd	a1,40(sp)
  80008c:	f832                	sd	a2,48(sp)
  80008e:	fc36                	sd	a3,56(sp)
  800090:	e0ba                	sd	a4,64(sp)
  800092:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);//最后，在函数返回之前，必须执行 va_end

    asm volatile (
  800094:	6522                	ld	a0,8(sp)
  800096:	75a2                	ld	a1,40(sp)
  800098:	7642                	ld	a2,48(sp)
  80009a:	76e2                	ld	a3,56(sp)
  80009c:	6706                	ld	a4,64(sp)
  80009e:	67a6                	ld	a5,72(sp)
  8000a0:	00000073          	ecall
  8000a4:	00a13e23          	sd	a0,28(sp)
        : "memory"     // 告诉编译器可能会修改内存，避免优化掉此部分
    );
        //num存到a0寄存器， a[0]存到a1寄存器
    //ecall的返回值存到ret
    return ret;
}
  8000a8:	4572                	lw	a0,28(sp)
  8000aa:	6149                	addi	sp,sp,144
  8000ac:	8082                	ret

00000000008000ae <sys_exit>:

int
sys_exit(int64_t error_code) {
  8000ae:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  8000b0:	4505                	li	a0,1
  8000b2:	b7c9                	j	800074 <syscall>

00000000008000b4 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000b4:	4549                	li	a0,18
  8000b6:	bf7d                	j	800074 <syscall>

00000000008000b8 <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000b8:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000ba:	4579                	li	a0,30
  8000bc:	bf65                	j	800074 <syscall>

00000000008000be <exit>:
/*
为何不让进程本身完成所有的资源回收工作呢？这是因为进程要执行回收操作，就表明此进程还存在，还在执行指令，这就需要内核栈的空间不能释放，
且表示进程存在的进程控制块不能释放。所以需要父进程来帮忙释放子进程无法完成的这两个资源回收工作。
*/
void
exit(int error_code) {
  8000be:	1141                	addi	sp,sp,-16
  8000c0:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c2:	fedff0ef          	jal	8000ae <sys_exit>
    cprintf("BUG: exit failed.\n"); //执行完sys_exit后，按理说进程就结束了，后面的语句不应该再执行，
  8000c6:	00000517          	auipc	a0,0x0
  8000ca:	45a50513          	addi	a0,a0,1114 # 800520 <main+0x3a>
  8000ce:	f73ff0ef          	jal	800040 <cprintf>
    //所以执行到这里就说明exit失败了
    while (1);
  8000d2:	a001                	j	8000d2 <exit+0x14>

00000000008000d4 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000d4:	b7c5                	j	8000b4 <sys_getpid>

00000000008000d6 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d6:	1141                	addi	sp,sp,-16
  8000d8:	e406                	sd	ra,8(sp)
    int ret = main();
  8000da:	40c000ef          	jal	8004e6 <main>
    exit(ret);
  8000de:	fe1ff0ef          	jal	8000be <exit>

00000000008000e2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000e2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000e8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000ec:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000ee:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000f2:	f022                	sd	s0,32(sp)
  8000f4:	ec26                	sd	s1,24(sp)
  8000f6:	e84a                	sd	s2,16(sp)
  8000f8:	f406                	sd	ra,40(sp)
  8000fa:	84aa                	mv	s1,a0
  8000fc:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8000fe:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800102:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800104:	05067063          	bgeu	a2,a6,800144 <printnum+0x62>
  800108:	e44e                	sd	s3,8(sp)
  80010a:	89be                	mv	s3,a5
        while (-- width > 0)
  80010c:	4785                	li	a5,1
  80010e:	00e7d763          	bge	a5,a4,80011c <printnum+0x3a>
            putch(padc, putdat);
  800112:	85ca                	mv	a1,s2
  800114:	854e                	mv	a0,s3
        while (-- width > 0)
  800116:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800118:	9482                	jalr	s1
        while (-- width > 0)
  80011a:	fc65                	bnez	s0,800112 <printnum+0x30>
  80011c:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80011e:	1a02                	slli	s4,s4,0x20
  800120:	020a5a13          	srli	s4,s4,0x20
  800124:	00000797          	auipc	a5,0x0
  800128:	41478793          	addi	a5,a5,1044 # 800538 <main+0x52>
  80012c:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80012e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800130:	0007c503          	lbu	a0,0(a5)
}
  800134:	70a2                	ld	ra,40(sp)
  800136:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800138:	85ca                	mv	a1,s2
  80013a:	87a6                	mv	a5,s1
}
  80013c:	6942                	ld	s2,16(sp)
  80013e:	64e2                	ld	s1,24(sp)
  800140:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800142:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800144:	03065633          	divu	a2,a2,a6
  800148:	8722                	mv	a4,s0
  80014a:	f99ff0ef          	jal	8000e2 <printnum>
  80014e:	bfc1                	j	80011e <printnum+0x3c>

0000000000800150 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800150:	7119                	addi	sp,sp,-128
  800152:	f4a6                	sd	s1,104(sp)
  800154:	f0ca                	sd	s2,96(sp)
  800156:	ecce                	sd	s3,88(sp)
  800158:	e8d2                	sd	s4,80(sp)
  80015a:	e4d6                	sd	s5,72(sp)
  80015c:	e0da                	sd	s6,64(sp)
  80015e:	f862                	sd	s8,48(sp)
  800160:	fc86                	sd	ra,120(sp)
  800162:	f8a2                	sd	s0,112(sp)
  800164:	fc5e                	sd	s7,56(sp)
  800166:	f466                	sd	s9,40(sp)
  800168:	f06a                	sd	s10,32(sp)
  80016a:	ec6e                	sd	s11,24(sp)
  80016c:	892a                	mv	s2,a0
  80016e:	84ae                	mv	s1,a1
  800170:	8c32                	mv	s8,a2
  800172:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800174:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800178:	05500b13          	li	s6,85
  80017c:	00000a97          	auipc	s5,0x0
  800180:	4f4a8a93          	addi	s5,s5,1268 # 800670 <main+0x18a>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800184:	000c4503          	lbu	a0,0(s8)
  800188:	001c0413          	addi	s0,s8,1
  80018c:	01350a63          	beq	a0,s3,8001a0 <vprintfmt+0x50>
            if (ch == '\0') {
  800190:	cd0d                	beqz	a0,8001ca <vprintfmt+0x7a>
            putch(ch, putdat);
  800192:	85a6                	mv	a1,s1
  800194:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800196:	00044503          	lbu	a0,0(s0)
  80019a:	0405                	addi	s0,s0,1
  80019c:	ff351ae3          	bne	a0,s3,800190 <vprintfmt+0x40>
        char padc = ' ';
  8001a0:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001a4:	4b81                	li	s7,0
  8001a6:	4601                	li	a2,0
        width = precision = -1;
  8001a8:	5d7d                	li	s10,-1
  8001aa:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001ac:	00044683          	lbu	a3,0(s0)
  8001b0:	00140c13          	addi	s8,s0,1
  8001b4:	fdd6859b          	addiw	a1,a3,-35
  8001b8:	0ff5f593          	zext.b	a1,a1
  8001bc:	02bb6663          	bltu	s6,a1,8001e8 <vprintfmt+0x98>
  8001c0:	058a                	slli	a1,a1,0x2
  8001c2:	95d6                	add	a1,a1,s5
  8001c4:	4198                	lw	a4,0(a1)
  8001c6:	9756                	add	a4,a4,s5
  8001c8:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001ca:	70e6                	ld	ra,120(sp)
  8001cc:	7446                	ld	s0,112(sp)
  8001ce:	74a6                	ld	s1,104(sp)
  8001d0:	7906                	ld	s2,96(sp)
  8001d2:	69e6                	ld	s3,88(sp)
  8001d4:	6a46                	ld	s4,80(sp)
  8001d6:	6aa6                	ld	s5,72(sp)
  8001d8:	6b06                	ld	s6,64(sp)
  8001da:	7be2                	ld	s7,56(sp)
  8001dc:	7c42                	ld	s8,48(sp)
  8001de:	7ca2                	ld	s9,40(sp)
  8001e0:	7d02                	ld	s10,32(sp)
  8001e2:	6de2                	ld	s11,24(sp)
  8001e4:	6109                	addi	sp,sp,128
  8001e6:	8082                	ret
            putch('%', putdat);
  8001e8:	85a6                	mv	a1,s1
  8001ea:	02500513          	li	a0,37
  8001ee:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8001f0:	fff44703          	lbu	a4,-1(s0)
  8001f4:	02500793          	li	a5,37
  8001f8:	8c22                	mv	s8,s0
  8001fa:	f8f705e3          	beq	a4,a5,800184 <vprintfmt+0x34>
  8001fe:	02500713          	li	a4,37
  800202:	ffec4783          	lbu	a5,-2(s8)
  800206:	1c7d                	addi	s8,s8,-1
  800208:	fee79de3          	bne	a5,a4,800202 <vprintfmt+0xb2>
  80020c:	bfa5                	j	800184 <vprintfmt+0x34>
                ch = *fmt;
  80020e:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  800212:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
  800214:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
  800218:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
  80021c:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
  800220:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
  800222:	02b76563          	bltu	a4,a1,80024c <vprintfmt+0xfc>
  800226:	4525                	li	a0,9
                ch = *fmt;
  800228:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
  80022c:	002d171b          	slliw	a4,s10,0x2
  800230:	01a7073b          	addw	a4,a4,s10
  800234:	0017171b          	slliw	a4,a4,0x1
  800238:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
  80023a:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
  80023e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800240:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
  800244:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
  800248:	feb570e3          	bgeu	a0,a1,800228 <vprintfmt+0xd8>
            if (width < 0)
  80024c:	f60cd0e3          	bgez	s9,8001ac <vprintfmt+0x5c>
                width = precision, precision = -1;
  800250:	8cea                	mv	s9,s10
  800252:	5d7d                	li	s10,-1
  800254:	bfa1                	j	8001ac <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  800256:	8db6                	mv	s11,a3
  800258:	8462                	mv	s0,s8
  80025a:	bf89                	j	8001ac <vprintfmt+0x5c>
  80025c:	8462                	mv	s0,s8
            altflag = 1;
  80025e:	4b85                	li	s7,1
            goto reswitch;
  800260:	b7b1                	j	8001ac <vprintfmt+0x5c>
    if (lflag >= 2) {
  800262:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800264:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800268:	00c7c463          	blt	a5,a2,800270 <vprintfmt+0x120>
    else if (lflag) {
  80026c:	1a060163          	beqz	a2,80040e <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
  800270:	000a3603          	ld	a2,0(s4)
  800274:	46c1                	li	a3,16
  800276:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  800278:	000d879b          	sext.w	a5,s11
  80027c:	8766                	mv	a4,s9
  80027e:	85a6                	mv	a1,s1
  800280:	854a                	mv	a0,s2
  800282:	e61ff0ef          	jal	8000e2 <printnum>
            break;
  800286:	bdfd                	j	800184 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800288:	000a2503          	lw	a0,0(s4)
  80028c:	85a6                	mv	a1,s1
  80028e:	0a21                	addi	s4,s4,8
  800290:	9902                	jalr	s2
            break;
  800292:	bdcd                	j	800184 <vprintfmt+0x34>
    if (lflag >= 2) {
  800294:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800296:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  80029a:	00c7c463          	blt	a5,a2,8002a2 <vprintfmt+0x152>
    else if (lflag) {
  80029e:	16060363          	beqz	a2,800404 <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
  8002a2:	000a3603          	ld	a2,0(s4)
  8002a6:	46a9                	li	a3,10
  8002a8:	8a3a                	mv	s4,a4
  8002aa:	b7f9                	j	800278 <vprintfmt+0x128>
            putch('0', putdat);
  8002ac:	85a6                	mv	a1,s1
  8002ae:	03000513          	li	a0,48
  8002b2:	9902                	jalr	s2
            putch('x', putdat);
  8002b4:	85a6                	mv	a1,s1
  8002b6:	07800513          	li	a0,120
  8002ba:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002bc:	000a3603          	ld	a2,0(s4)
            goto number;
  8002c0:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002c2:	0a21                	addi	s4,s4,8
            goto number;
  8002c4:	bf55                	j	800278 <vprintfmt+0x128>
            putch(ch, putdat);
  8002c6:	85a6                	mv	a1,s1
  8002c8:	02500513          	li	a0,37
  8002cc:	9902                	jalr	s2
            break;
  8002ce:	bd5d                	j	800184 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002d0:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002d4:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002d6:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002d8:	bf95                	j	80024c <vprintfmt+0xfc>
    if (lflag >= 2) {
  8002da:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002dc:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002e0:	00c7c463          	blt	a5,a2,8002e8 <vprintfmt+0x198>
    else if (lflag) {
  8002e4:	10060b63          	beqz	a2,8003fa <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
  8002e8:	000a3603          	ld	a2,0(s4)
  8002ec:	46a1                	li	a3,8
  8002ee:	8a3a                	mv	s4,a4
  8002f0:	b761                	j	800278 <vprintfmt+0x128>
            if (width < 0)
  8002f2:	fffcc793          	not	a5,s9
  8002f6:	97fd                	srai	a5,a5,0x3f
  8002f8:	00fcf7b3          	and	a5,s9,a5
  8002fc:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
  800300:	8462                	mv	s0,s8
            goto reswitch;
  800302:	b56d                	j	8001ac <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  800304:	000a3403          	ld	s0,0(s4)
  800308:	008a0793          	addi	a5,s4,8
  80030c:	e43e                	sd	a5,8(sp)
  80030e:	12040063          	beqz	s0,80042e <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800312:	0d905963          	blez	s9,8003e4 <vprintfmt+0x294>
  800316:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80031a:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
  80031e:	12fd9763          	bne	s11,a5,80044c <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800322:	00044783          	lbu	a5,0(s0)
  800326:	0007851b          	sext.w	a0,a5
  80032a:	cb9d                	beqz	a5,800360 <vprintfmt+0x210>
  80032c:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  80032e:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800332:	000d4563          	bltz	s10,80033c <vprintfmt+0x1ec>
  800336:	3d7d                	addiw	s10,s10,-1
  800338:	028d0263          	beq	s10,s0,80035c <vprintfmt+0x20c>
                    putch('?', putdat);
  80033c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80033e:	0c0b8d63          	beqz	s7,800418 <vprintfmt+0x2c8>
  800342:	3781                	addiw	a5,a5,-32
  800344:	0cfdfa63          	bgeu	s11,a5,800418 <vprintfmt+0x2c8>
                    putch('?', putdat);
  800348:	03f00513          	li	a0,63
  80034c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80034e:	000a4783          	lbu	a5,0(s4)
  800352:	3cfd                	addiw	s9,s9,-1
  800354:	0a05                	addi	s4,s4,1
  800356:	0007851b          	sext.w	a0,a5
  80035a:	ffe1                	bnez	a5,800332 <vprintfmt+0x1e2>
            for (; width > 0; width --) {
  80035c:	01905963          	blez	s9,80036e <vprintfmt+0x21e>
                putch(' ', putdat);
  800360:	85a6                	mv	a1,s1
  800362:	02000513          	li	a0,32
            for (; width > 0; width --) {
  800366:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
  800368:	9902                	jalr	s2
            for (; width > 0; width --) {
  80036a:	fe0c9be3          	bnez	s9,800360 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
  80036e:	6a22                	ld	s4,8(sp)
  800370:	bd11                	j	800184 <vprintfmt+0x34>
    if (lflag >= 2) {
  800372:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800374:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800378:	00c7c363          	blt	a5,a2,80037e <vprintfmt+0x22e>
    else if (lflag) {
  80037c:	ce25                	beqz	a2,8003f4 <vprintfmt+0x2a4>
        return va_arg(*ap, long);
  80037e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800382:	08044d63          	bltz	s0,80041c <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800386:	8622                	mv	a2,s0
  800388:	8a5e                	mv	s4,s7
  80038a:	46a9                	li	a3,10
  80038c:	b5f5                	j	800278 <vprintfmt+0x128>
            if (err < 0) {
  80038e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800392:	4661                	li	a2,24
            if (err < 0) {
  800394:	41f7d71b          	sraiw	a4,a5,0x1f
  800398:	8fb9                	xor	a5,a5,a4
  80039a:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80039e:	02d64663          	blt	a2,a3,8003ca <vprintfmt+0x27a>
  8003a2:	00369713          	slli	a4,a3,0x3
  8003a6:	00000797          	auipc	a5,0x0
  8003aa:	42278793          	addi	a5,a5,1058 # 8007c8 <error_string>
  8003ae:	97ba                	add	a5,a5,a4
  8003b0:	639c                	ld	a5,0(a5)
  8003b2:	cf81                	beqz	a5,8003ca <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
  8003b4:	86be                	mv	a3,a5
  8003b6:	00000617          	auipc	a2,0x0
  8003ba:	1ba60613          	addi	a2,a2,442 # 800570 <main+0x8a>
  8003be:	85a6                	mv	a1,s1
  8003c0:	854a                	mv	a0,s2
  8003c2:	0e8000ef          	jal	8004aa <printfmt>
            err = va_arg(ap, int);
  8003c6:	0a21                	addi	s4,s4,8
  8003c8:	bb75                	j	800184 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003ca:	00000617          	auipc	a2,0x0
  8003ce:	19660613          	addi	a2,a2,406 # 800560 <main+0x7a>
  8003d2:	85a6                	mv	a1,s1
  8003d4:	854a                	mv	a0,s2
  8003d6:	0d4000ef          	jal	8004aa <printfmt>
            err = va_arg(ap, int);
  8003da:	0a21                	addi	s4,s4,8
  8003dc:	b365                	j	800184 <vprintfmt+0x34>
            lflag ++;
  8003de:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003e0:	8462                	mv	s0,s8
            goto reswitch;
  8003e2:	b3e9                	j	8001ac <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e4:	00044783          	lbu	a5,0(s0)
  8003e8:	0007851b          	sext.w	a0,a5
  8003ec:	d3c9                	beqz	a5,80036e <vprintfmt+0x21e>
  8003ee:	00140a13          	addi	s4,s0,1
  8003f2:	bf2d                	j	80032c <vprintfmt+0x1dc>
        return va_arg(*ap, int);
  8003f4:	000a2403          	lw	s0,0(s4)
  8003f8:	b769                	j	800382 <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
  8003fa:	000a6603          	lwu	a2,0(s4)
  8003fe:	46a1                	li	a3,8
  800400:	8a3a                	mv	s4,a4
  800402:	bd9d                	j	800278 <vprintfmt+0x128>
  800404:	000a6603          	lwu	a2,0(s4)
  800408:	46a9                	li	a3,10
  80040a:	8a3a                	mv	s4,a4
  80040c:	b5b5                	j	800278 <vprintfmt+0x128>
  80040e:	000a6603          	lwu	a2,0(s4)
  800412:	46c1                	li	a3,16
  800414:	8a3a                	mv	s4,a4
  800416:	b58d                	j	800278 <vprintfmt+0x128>
                    putch(ch, putdat);
  800418:	9902                	jalr	s2
  80041a:	bf15                	j	80034e <vprintfmt+0x1fe>
                putch('-', putdat);
  80041c:	85a6                	mv	a1,s1
  80041e:	02d00513          	li	a0,45
  800422:	9902                	jalr	s2
                num = -(long long)num;
  800424:	40800633          	neg	a2,s0
  800428:	8a5e                	mv	s4,s7
  80042a:	46a9                	li	a3,10
  80042c:	b5b1                	j	800278 <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
  80042e:	01905663          	blez	s9,80043a <vprintfmt+0x2ea>
  800432:	02d00793          	li	a5,45
  800436:	04fd9263          	bne	s11,a5,80047a <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80043a:	02800793          	li	a5,40
  80043e:	00000a17          	auipc	s4,0x0
  800442:	113a0a13          	addi	s4,s4,275 # 800551 <main+0x6b>
  800446:	02800513          	li	a0,40
  80044a:	b5cd                	j	80032c <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80044c:	85ea                	mv	a1,s10
  80044e:	8522                	mv	a0,s0
  800450:	07a000ef          	jal	8004ca <strnlen>
  800454:	40ac8cbb          	subw	s9,s9,a0
  800458:	01905963          	blez	s9,80046a <vprintfmt+0x31a>
                    putch(padc, putdat);
  80045c:	2d81                	sext.w	s11,s11
  80045e:	85a6                	mv	a1,s1
  800460:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
  800462:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
  800464:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800466:	fe0c9ce3          	bnez	s9,80045e <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80046a:	00044783          	lbu	a5,0(s0)
  80046e:	0007851b          	sext.w	a0,a5
  800472:	ea079de3          	bnez	a5,80032c <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
  800476:	6a22                	ld	s4,8(sp)
  800478:	b331                	j	800184 <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80047a:	85ea                	mv	a1,s10
  80047c:	00000517          	auipc	a0,0x0
  800480:	0d450513          	addi	a0,a0,212 # 800550 <main+0x6a>
  800484:	046000ef          	jal	8004ca <strnlen>
  800488:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
  80048c:	00000417          	auipc	s0,0x0
  800490:	0c440413          	addi	s0,s0,196 # 800550 <main+0x6a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800494:	00000a17          	auipc	s4,0x0
  800498:	0bda0a13          	addi	s4,s4,189 # 800551 <main+0x6b>
  80049c:	02800793          	li	a5,40
  8004a0:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a4:	fb904ce3          	bgtz	s9,80045c <vprintfmt+0x30c>
  8004a8:	b551                	j	80032c <vprintfmt+0x1dc>

00000000008004aa <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004aa:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004ac:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004b2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b4:	ec06                	sd	ra,24(sp)
  8004b6:	f83a                	sd	a4,48(sp)
  8004b8:	fc3e                	sd	a5,56(sp)
  8004ba:	e0c2                	sd	a6,64(sp)
  8004bc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004be:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004c0:	c91ff0ef          	jal	800150 <vprintfmt>
}
  8004c4:	60e2                	ld	ra,24(sp)
  8004c6:	6161                	addi	sp,sp,80
  8004c8:	8082                	ret

00000000008004ca <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8004ca:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8004cc:	e589                	bnez	a1,8004d6 <strnlen+0xc>
  8004ce:	a811                	j	8004e2 <strnlen+0x18>
        cnt ++;
  8004d0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004d2:	00f58863          	beq	a1,a5,8004e2 <strnlen+0x18>
  8004d6:	00f50733          	add	a4,a0,a5
  8004da:	00074703          	lbu	a4,0(a4)
  8004de:	fb6d                	bnez	a4,8004d0 <strnlen+0x6>
  8004e0:	85be                	mv	a1,a5
    }
    return cnt;
}
  8004e2:	852e                	mv	a0,a1
  8004e4:	8082                	ret

00000000008004e6 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8004e6:	1141                	addi	sp,sp,-16
    cprintf("Hello world!!.\n");
  8004e8:	00000517          	auipc	a0,0x0
  8004ec:	15050513          	addi	a0,a0,336 # 800638 <main+0x152>
main(void) {
  8004f0:	e406                	sd	ra,8(sp)
    cprintf("Hello world!!.\n");
  8004f2:	b4fff0ef          	jal	800040 <cprintf>
    cprintf("I am process %d.\n", getpid());
  8004f6:	bdfff0ef          	jal	8000d4 <getpid>
  8004fa:	85aa                	mv	a1,a0
  8004fc:	00000517          	auipc	a0,0x0
  800500:	14c50513          	addi	a0,a0,332 # 800648 <main+0x162>
  800504:	b3dff0ef          	jal	800040 <cprintf>
    cprintf("hello pass.\n");
  800508:	00000517          	auipc	a0,0x0
  80050c:	15850513          	addi	a0,a0,344 # 800660 <main+0x17a>
  800510:	b31ff0ef          	jal	800040 <cprintf>
    return 0;
}
  800514:	60a2                	ld	ra,8(sp)
  800516:	4501                	li	a0,0
  800518:	0141                	addi	sp,sp,16
  80051a:	8082                	ret
