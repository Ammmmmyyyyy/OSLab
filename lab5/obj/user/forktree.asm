
obj/__user_forktree.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0c2000ef          	jal	8000e2 <umain>
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
  80002e:	092000ef          	jal	8000c0 <sys_putc>
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
  800068:	10e000ef          	jal	800176 <vprintfmt>
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

00000000008000b4 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  8000b4:	4509                	li	a0,2
  8000b6:	bf7d                	j	800074 <syscall>

00000000008000b8 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000b8:	4529                	li	a0,10
  8000ba:	bf6d                	j	800074 <syscall>

00000000008000bc <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000bc:	4549                	li	a0,18
  8000be:	bf5d                	j	800074 <syscall>

00000000008000c0 <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000c0:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000c2:	4579                	li	a0,30
  8000c4:	bf45                	j	800074 <syscall>

00000000008000c6 <exit>:
/*
为何不让进程本身完成所有的资源回收工作呢？这是因为进程要执行回收操作，就表明此进程还存在，还在执行指令，这就需要内核栈的空间不能释放，
且表示进程存在的进程控制块不能释放。所以需要父进程来帮忙释放子进程无法完成的这两个资源回收工作。
*/
void
exit(int error_code) {
  8000c6:	1141                	addi	sp,sp,-16
  8000c8:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000ca:	fe5ff0ef          	jal	8000ae <sys_exit>
    cprintf("BUG: exit failed.\n"); //执行完sys_exit后，按理说进程就结束了，后面的语句不应该再执行，
  8000ce:	00000517          	auipc	a0,0x0
  8000d2:	56a50513          	addi	a0,a0,1386 # 800638 <main+0x1c>
  8000d6:	f6bff0ef          	jal	800040 <cprintf>
    //所以执行到这里就说明exit失败了
    while (1);
  8000da:	a001                	j	8000da <exit+0x14>

00000000008000dc <fork>:
}

int
fork(void) {
    return sys_fork();
  8000dc:	bfe1                	j	8000b4 <sys_fork>

00000000008000de <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  8000de:	bfe9                	j	8000b8 <sys_yield>

00000000008000e0 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000e0:	bff1                	j	8000bc <sys_getpid>

00000000008000e2 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000e2:	1141                	addi	sp,sp,-16
  8000e4:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e6:	536000ef          	jal	80061c <main>
    exit(ret);
  8000ea:	fddff0ef          	jal	8000c6 <exit>

00000000008000ee <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000ee:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000f4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000fa:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000fe:	f022                	sd	s0,32(sp)
  800100:	ec26                	sd	s1,24(sp)
  800102:	e84a                	sd	s2,16(sp)
  800104:	f406                	sd	ra,40(sp)
  800106:	84aa                	mv	s1,a0
  800108:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80010a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80010e:	2a01                	sext.w	s4,s4
    if (num >= base) {
  800110:	05067063          	bgeu	a2,a6,800150 <printnum+0x62>
  800114:	e44e                	sd	s3,8(sp)
  800116:	89be                	mv	s3,a5
        while (-- width > 0)
  800118:	4785                	li	a5,1
  80011a:	00e7d763          	bge	a5,a4,800128 <printnum+0x3a>
            putch(padc, putdat);
  80011e:	85ca                	mv	a1,s2
  800120:	854e                	mv	a0,s3
        while (-- width > 0)
  800122:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800124:	9482                	jalr	s1
        while (-- width > 0)
  800126:	fc65                	bnez	s0,80011e <printnum+0x30>
  800128:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80012a:	1a02                	slli	s4,s4,0x20
  80012c:	020a5a13          	srli	s4,s4,0x20
  800130:	00000797          	auipc	a5,0x0
  800134:	52078793          	addi	a5,a5,1312 # 800650 <main+0x34>
  800138:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80013a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013c:	0007c503          	lbu	a0,0(a5)
}
  800140:	70a2                	ld	ra,40(sp)
  800142:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800144:	85ca                	mv	a1,s2
  800146:	87a6                	mv	a5,s1
}
  800148:	6942                	ld	s2,16(sp)
  80014a:	64e2                	ld	s1,24(sp)
  80014c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80014e:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800150:	03065633          	divu	a2,a2,a6
  800154:	8722                	mv	a4,s0
  800156:	f99ff0ef          	jal	8000ee <printnum>
  80015a:	bfc1                	j	80012a <printnum+0x3c>

000000000080015c <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
  80015c:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
  80015e:	6198                	ld	a4,0(a1)
  800160:	6594                	ld	a3,8(a1)
    b->cnt ++;
  800162:	2785                	addiw	a5,a5,1
  800164:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
  800166:	00d77763          	bgeu	a4,a3,800174 <sprintputch+0x18>
        *b->buf ++ = ch;
  80016a:	00170793          	addi	a5,a4,1
  80016e:	e19c                	sd	a5,0(a1)
  800170:	00a70023          	sb	a0,0(a4)
    }
}
  800174:	8082                	ret

0000000000800176 <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800176:	7119                	addi	sp,sp,-128
  800178:	f4a6                	sd	s1,104(sp)
  80017a:	f0ca                	sd	s2,96(sp)
  80017c:	ecce                	sd	s3,88(sp)
  80017e:	e8d2                	sd	s4,80(sp)
  800180:	e4d6                	sd	s5,72(sp)
  800182:	e0da                	sd	s6,64(sp)
  800184:	f862                	sd	s8,48(sp)
  800186:	fc86                	sd	ra,120(sp)
  800188:	f8a2                	sd	s0,112(sp)
  80018a:	fc5e                	sd	s7,56(sp)
  80018c:	f466                	sd	s9,40(sp)
  80018e:	f06a                	sd	s10,32(sp)
  800190:	ec6e                	sd	s11,24(sp)
  800192:	892a                	mv	s2,a0
  800194:	84ae                	mv	s1,a1
  800196:	8c32                	mv	s8,a2
  800198:	8a36                	mv	s4,a3
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80019a:	02500993          	li	s3,37
        switch (ch = *(unsigned char *)fmt ++) {
  80019e:	05500b13          	li	s6,85
  8001a2:	00000a97          	auipc	s5,0x0
  8001a6:	5c6a8a93          	addi	s5,s5,1478 # 800768 <main+0x14c>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001aa:	000c4503          	lbu	a0,0(s8)
  8001ae:	001c0413          	addi	s0,s8,1
  8001b2:	01350a63          	beq	a0,s3,8001c6 <vprintfmt+0x50>
            if (ch == '\0') {
  8001b6:	cd0d                	beqz	a0,8001f0 <vprintfmt+0x7a>
            putch(ch, putdat);
  8001b8:	85a6                	mv	a1,s1
  8001ba:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001bc:	00044503          	lbu	a0,0(s0)
  8001c0:	0405                	addi	s0,s0,1
  8001c2:	ff351ae3          	bne	a0,s3,8001b6 <vprintfmt+0x40>
        char padc = ' ';
  8001c6:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001ca:	4b81                	li	s7,0
  8001cc:	4601                	li	a2,0
        width = precision = -1;
  8001ce:	5d7d                	li	s10,-1
  8001d0:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001d2:	00044683          	lbu	a3,0(s0)
  8001d6:	00140c13          	addi	s8,s0,1
  8001da:	fdd6859b          	addiw	a1,a3,-35
  8001de:	0ff5f593          	zext.b	a1,a1
  8001e2:	02bb6663          	bltu	s6,a1,80020e <vprintfmt+0x98>
  8001e6:	058a                	slli	a1,a1,0x2
  8001e8:	95d6                	add	a1,a1,s5
  8001ea:	4198                	lw	a4,0(a1)
  8001ec:	9756                	add	a4,a4,s5
  8001ee:	8702                	jr	a4
}
  8001f0:	70e6                	ld	ra,120(sp)
  8001f2:	7446                	ld	s0,112(sp)
  8001f4:	74a6                	ld	s1,104(sp)
  8001f6:	7906                	ld	s2,96(sp)
  8001f8:	69e6                	ld	s3,88(sp)
  8001fa:	6a46                	ld	s4,80(sp)
  8001fc:	6aa6                	ld	s5,72(sp)
  8001fe:	6b06                	ld	s6,64(sp)
  800200:	7be2                	ld	s7,56(sp)
  800202:	7c42                	ld	s8,48(sp)
  800204:	7ca2                	ld	s9,40(sp)
  800206:	7d02                	ld	s10,32(sp)
  800208:	6de2                	ld	s11,24(sp)
  80020a:	6109                	addi	sp,sp,128
  80020c:	8082                	ret
            putch('%', putdat);
  80020e:	85a6                	mv	a1,s1
  800210:	02500513          	li	a0,37
  800214:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800216:	fff44703          	lbu	a4,-1(s0)
  80021a:	02500793          	li	a5,37
  80021e:	8c22                	mv	s8,s0
  800220:	f8f705e3          	beq	a4,a5,8001aa <vprintfmt+0x34>
  800224:	02500713          	li	a4,37
  800228:	ffec4783          	lbu	a5,-2(s8)
  80022c:	1c7d                	addi	s8,s8,-1
  80022e:	fee79de3          	bne	a5,a4,800228 <vprintfmt+0xb2>
  800232:	bfa5                	j	8001aa <vprintfmt+0x34>
                ch = *fmt;
  800234:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  800238:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
  80023a:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
  80023e:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
  800242:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
  800246:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
  800248:	02b76563          	bltu	a4,a1,800272 <vprintfmt+0xfc>
  80024c:	4525                	li	a0,9
                ch = *fmt;
  80024e:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
  800252:	002d171b          	slliw	a4,s10,0x2
  800256:	01a7073b          	addw	a4,a4,s10
  80025a:	0017171b          	slliw	a4,a4,0x1
  80025e:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
  800260:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
  800264:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800266:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
  80026a:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
  80026e:	feb570e3          	bgeu	a0,a1,80024e <vprintfmt+0xd8>
            if (width < 0)
  800272:	f60cd0e3          	bgez	s9,8001d2 <vprintfmt+0x5c>
                width = precision, precision = -1;
  800276:	8cea                	mv	s9,s10
  800278:	5d7d                	li	s10,-1
  80027a:	bfa1                	j	8001d2 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  80027c:	8db6                	mv	s11,a3
  80027e:	8462                	mv	s0,s8
  800280:	bf89                	j	8001d2 <vprintfmt+0x5c>
  800282:	8462                	mv	s0,s8
            altflag = 1;
  800284:	4b85                	li	s7,1
            goto reswitch;
  800286:	b7b1                	j	8001d2 <vprintfmt+0x5c>
    if (lflag >= 2) {
  800288:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80028a:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  80028e:	00c7c463          	blt	a5,a2,800296 <vprintfmt+0x120>
    else if (lflag) {
  800292:	1a060163          	beqz	a2,800434 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
  800296:	000a3603          	ld	a2,0(s4)
  80029a:	46c1                	li	a3,16
  80029c:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  80029e:	000d879b          	sext.w	a5,s11
  8002a2:	8766                	mv	a4,s9
  8002a4:	85a6                	mv	a1,s1
  8002a6:	854a                	mv	a0,s2
  8002a8:	e47ff0ef          	jal	8000ee <printnum>
            break;
  8002ac:	bdfd                	j	8001aa <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002ae:	000a2503          	lw	a0,0(s4)
  8002b2:	85a6                	mv	a1,s1
  8002b4:	0a21                	addi	s4,s4,8
  8002b6:	9902                	jalr	s2
            break;
  8002b8:	bdcd                	j	8001aa <vprintfmt+0x34>
    if (lflag >= 2) {
  8002ba:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002bc:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002c0:	00c7c463          	blt	a5,a2,8002c8 <vprintfmt+0x152>
    else if (lflag) {
  8002c4:	16060363          	beqz	a2,80042a <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
  8002c8:	000a3603          	ld	a2,0(s4)
  8002cc:	46a9                	li	a3,10
  8002ce:	8a3a                	mv	s4,a4
  8002d0:	b7f9                	j	80029e <vprintfmt+0x128>
            putch('0', putdat);
  8002d2:	85a6                	mv	a1,s1
  8002d4:	03000513          	li	a0,48
  8002d8:	9902                	jalr	s2
            putch('x', putdat);
  8002da:	85a6                	mv	a1,s1
  8002dc:	07800513          	li	a0,120
  8002e0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002e2:	000a3603          	ld	a2,0(s4)
            goto number;
  8002e6:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002e8:	0a21                	addi	s4,s4,8
            goto number;
  8002ea:	bf55                	j	80029e <vprintfmt+0x128>
            putch(ch, putdat);
  8002ec:	85a6                	mv	a1,s1
  8002ee:	02500513          	li	a0,37
  8002f2:	9902                	jalr	s2
            break;
  8002f4:	bd5d                	j	8001aa <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002f6:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002fa:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002fc:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002fe:	bf95                	j	800272 <vprintfmt+0xfc>
    if (lflag >= 2) {
  800300:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800302:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800306:	00c7c463          	blt	a5,a2,80030e <vprintfmt+0x198>
    else if (lflag) {
  80030a:	10060b63          	beqz	a2,800420 <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
  80030e:	000a3603          	ld	a2,0(s4)
  800312:	46a1                	li	a3,8
  800314:	8a3a                	mv	s4,a4
  800316:	b761                	j	80029e <vprintfmt+0x128>
            if (width < 0)
  800318:	fffcc793          	not	a5,s9
  80031c:	97fd                	srai	a5,a5,0x3f
  80031e:	00fcf7b3          	and	a5,s9,a5
  800322:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
  800326:	8462                	mv	s0,s8
            goto reswitch;
  800328:	b56d                	j	8001d2 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  80032a:	000a3403          	ld	s0,0(s4)
  80032e:	008a0793          	addi	a5,s4,8
  800332:	e43e                	sd	a5,8(sp)
  800334:	12040063          	beqz	s0,800454 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800338:	0d905963          	blez	s9,80040a <vprintfmt+0x294>
  80033c:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800340:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
  800344:	12fd9763          	bne	s11,a5,800472 <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800348:	00044783          	lbu	a5,0(s0)
  80034c:	0007851b          	sext.w	a0,a5
  800350:	cb9d                	beqz	a5,800386 <vprintfmt+0x210>
  800352:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800354:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800358:	000d4563          	bltz	s10,800362 <vprintfmt+0x1ec>
  80035c:	3d7d                	addiw	s10,s10,-1
  80035e:	028d0263          	beq	s10,s0,800382 <vprintfmt+0x20c>
                    putch('?', putdat);
  800362:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800364:	0c0b8d63          	beqz	s7,80043e <vprintfmt+0x2c8>
  800368:	3781                	addiw	a5,a5,-32
  80036a:	0cfdfa63          	bgeu	s11,a5,80043e <vprintfmt+0x2c8>
                    putch('?', putdat);
  80036e:	03f00513          	li	a0,63
  800372:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800374:	000a4783          	lbu	a5,0(s4)
  800378:	3cfd                	addiw	s9,s9,-1
  80037a:	0a05                	addi	s4,s4,1
  80037c:	0007851b          	sext.w	a0,a5
  800380:	ffe1                	bnez	a5,800358 <vprintfmt+0x1e2>
            for (; width > 0; width --) {
  800382:	01905963          	blez	s9,800394 <vprintfmt+0x21e>
                putch(' ', putdat);
  800386:	85a6                	mv	a1,s1
  800388:	02000513          	li	a0,32
            for (; width > 0; width --) {
  80038c:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
  80038e:	9902                	jalr	s2
            for (; width > 0; width --) {
  800390:	fe0c9be3          	bnez	s9,800386 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
  800394:	6a22                	ld	s4,8(sp)
  800396:	bd11                	j	8001aa <vprintfmt+0x34>
    if (lflag >= 2) {
  800398:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80039a:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  80039e:	00c7c363          	blt	a5,a2,8003a4 <vprintfmt+0x22e>
    else if (lflag) {
  8003a2:	ce25                	beqz	a2,80041a <vprintfmt+0x2a4>
        return va_arg(*ap, long);
  8003a4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003a8:	08044d63          	bltz	s0,800442 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  8003ac:	8622                	mv	a2,s0
  8003ae:	8a5e                	mv	s4,s7
  8003b0:	46a9                	li	a3,10
  8003b2:	b5f5                	j	80029e <vprintfmt+0x128>
            if (err < 0) {
  8003b4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003b8:	4661                	li	a2,24
            if (err < 0) {
  8003ba:	41f7d71b          	sraiw	a4,a5,0x1f
  8003be:	8fb9                	xor	a5,a5,a4
  8003c0:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003c4:	02d64663          	blt	a2,a3,8003f0 <vprintfmt+0x27a>
  8003c8:	00369713          	slli	a4,a3,0x3
  8003cc:	00000797          	auipc	a5,0x0
  8003d0:	4f478793          	addi	a5,a5,1268 # 8008c0 <error_string>
  8003d4:	97ba                	add	a5,a5,a4
  8003d6:	639c                	ld	a5,0(a5)
  8003d8:	cf81                	beqz	a5,8003f0 <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
  8003da:	86be                	mv	a3,a5
  8003dc:	00000617          	auipc	a2,0x0
  8003e0:	2a460613          	addi	a2,a2,676 # 800680 <main+0x64>
  8003e4:	85a6                	mv	a1,s1
  8003e6:	854a                	mv	a0,s2
  8003e8:	0e8000ef          	jal	8004d0 <printfmt>
            err = va_arg(ap, int);
  8003ec:	0a21                	addi	s4,s4,8
  8003ee:	bb75                	j	8001aa <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003f0:	00000617          	auipc	a2,0x0
  8003f4:	28060613          	addi	a2,a2,640 # 800670 <main+0x54>
  8003f8:	85a6                	mv	a1,s1
  8003fa:	854a                	mv	a0,s2
  8003fc:	0d4000ef          	jal	8004d0 <printfmt>
            err = va_arg(ap, int);
  800400:	0a21                	addi	s4,s4,8
  800402:	b365                	j	8001aa <vprintfmt+0x34>
            lflag ++;
  800404:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  800406:	8462                	mv	s0,s8
            goto reswitch;
  800408:	b3e9                	j	8001d2 <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80040a:	00044783          	lbu	a5,0(s0)
  80040e:	0007851b          	sext.w	a0,a5
  800412:	d3c9                	beqz	a5,800394 <vprintfmt+0x21e>
  800414:	00140a13          	addi	s4,s0,1
  800418:	bf2d                	j	800352 <vprintfmt+0x1dc>
        return va_arg(*ap, int);
  80041a:	000a2403          	lw	s0,0(s4)
  80041e:	b769                	j	8003a8 <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
  800420:	000a6603          	lwu	a2,0(s4)
  800424:	46a1                	li	a3,8
  800426:	8a3a                	mv	s4,a4
  800428:	bd9d                	j	80029e <vprintfmt+0x128>
  80042a:	000a6603          	lwu	a2,0(s4)
  80042e:	46a9                	li	a3,10
  800430:	8a3a                	mv	s4,a4
  800432:	b5b5                	j	80029e <vprintfmt+0x128>
  800434:	000a6603          	lwu	a2,0(s4)
  800438:	46c1                	li	a3,16
  80043a:	8a3a                	mv	s4,a4
  80043c:	b58d                	j	80029e <vprintfmt+0x128>
                    putch(ch, putdat);
  80043e:	9902                	jalr	s2
  800440:	bf15                	j	800374 <vprintfmt+0x1fe>
                putch('-', putdat);
  800442:	85a6                	mv	a1,s1
  800444:	02d00513          	li	a0,45
  800448:	9902                	jalr	s2
                num = -(long long)num;
  80044a:	40800633          	neg	a2,s0
  80044e:	8a5e                	mv	s4,s7
  800450:	46a9                	li	a3,10
  800452:	b5b1                	j	80029e <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
  800454:	01905663          	blez	s9,800460 <vprintfmt+0x2ea>
  800458:	02d00793          	li	a5,45
  80045c:	04fd9263          	bne	s11,a5,8004a0 <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800460:	02800793          	li	a5,40
  800464:	00000a17          	auipc	s4,0x0
  800468:	205a0a13          	addi	s4,s4,517 # 800669 <main+0x4d>
  80046c:	02800513          	li	a0,40
  800470:	b5cd                	j	800352 <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800472:	85ea                	mv	a1,s10
  800474:	8522                	mv	a0,s0
  800476:	0da000ef          	jal	800550 <strnlen>
  80047a:	40ac8cbb          	subw	s9,s9,a0
  80047e:	01905963          	blez	s9,800490 <vprintfmt+0x31a>
                    putch(padc, putdat);
  800482:	2d81                	sext.w	s11,s11
  800484:	85a6                	mv	a1,s1
  800486:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
  800488:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
  80048a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80048c:	fe0c9ce3          	bnez	s9,800484 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800490:	00044783          	lbu	a5,0(s0)
  800494:	0007851b          	sext.w	a0,a5
  800498:	ea079de3          	bnez	a5,800352 <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
  80049c:	6a22                	ld	s4,8(sp)
  80049e:	b331                	j	8001aa <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a0:	85ea                	mv	a1,s10
  8004a2:	00000517          	auipc	a0,0x0
  8004a6:	1c650513          	addi	a0,a0,454 # 800668 <main+0x4c>
  8004aa:	0a6000ef          	jal	800550 <strnlen>
  8004ae:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
  8004b2:	00000417          	auipc	s0,0x0
  8004b6:	1b640413          	addi	s0,s0,438 # 800668 <main+0x4c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ba:	00000a17          	auipc	s4,0x0
  8004be:	1afa0a13          	addi	s4,s4,431 # 800669 <main+0x4d>
  8004c2:	02800793          	li	a5,40
  8004c6:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ca:	fb904ce3          	bgtz	s9,800482 <vprintfmt+0x30c>
  8004ce:	b551                	j	800352 <vprintfmt+0x1dc>

00000000008004d0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004d0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004d2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004d6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004d8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004da:	ec06                	sd	ra,24(sp)
  8004dc:	f83a                	sd	a4,48(sp)
  8004de:	fc3e                	sd	a5,56(sp)
  8004e0:	e0c2                	sd	a6,64(sp)
  8004e2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004e4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004e6:	c91ff0ef          	jal	800176 <vprintfmt>
}
  8004ea:	60e2                	ld	ra,24(sp)
  8004ec:	6161                	addi	sp,sp,80
  8004ee:	8082                	ret

00000000008004f0 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  8004f0:	711d                	addi	sp,sp,-96
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
  8004f2:	15fd                	addi	a1,a1,-1
    va_start(ap, fmt);
  8004f4:	03810313          	addi	t1,sp,56
    struct sprintbuf b = {str, str + size - 1, 0};
  8004f8:	95aa                	add	a1,a1,a0
snprintf(char *str, size_t size, const char *fmt, ...) {
  8004fa:	f406                	sd	ra,40(sp)
  8004fc:	fc36                	sd	a3,56(sp)
  8004fe:	e0ba                	sd	a4,64(sp)
  800500:	e4be                	sd	a5,72(sp)
  800502:	e8c2                	sd	a6,80(sp)
  800504:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800506:	e01a                	sd	t1,0(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  800508:	e42a                	sd	a0,8(sp)
  80050a:	e82e                	sd	a1,16(sp)
  80050c:	cc02                	sw	zero,24(sp)
    if (str == NULL || b.buf > b.ebuf) {
  80050e:	c115                	beqz	a0,800532 <snprintf+0x42>
  800510:	02a5e163          	bltu	a1,a0,800532 <snprintf+0x42>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800514:	00000517          	auipc	a0,0x0
  800518:	c4850513          	addi	a0,a0,-952 # 80015c <sprintputch>
  80051c:	869a                	mv	a3,t1
  80051e:	002c                	addi	a1,sp,8
  800520:	c57ff0ef          	jal	800176 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800524:	67a2                	ld	a5,8(sp)
  800526:	00078023          	sb	zero,0(a5)
    return b.cnt;
  80052a:	4562                	lw	a0,24(sp)
}
  80052c:	70a2                	ld	ra,40(sp)
  80052e:	6125                	addi	sp,sp,96
  800530:	8082                	ret
        return -E_INVAL;
  800532:	5575                	li	a0,-3
  800534:	bfe5                	j	80052c <snprintf+0x3c>

0000000000800536 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  800536:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
  80053a:	872a                	mv	a4,a0
    size_t cnt = 0;
  80053c:	4501                	li	a0,0
    while (*s ++ != '\0') {
  80053e:	cb81                	beqz	a5,80054e <strlen+0x18>
        cnt ++;
  800540:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
  800542:	00a707b3          	add	a5,a4,a0
  800546:	0007c783          	lbu	a5,0(a5)
  80054a:	fbfd                	bnez	a5,800540 <strlen+0xa>
  80054c:	8082                	ret
    }
    return cnt;
}
  80054e:	8082                	ret

0000000000800550 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800550:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800552:	e589                	bnez	a1,80055c <strnlen+0xc>
  800554:	a811                	j	800568 <strnlen+0x18>
        cnt ++;
  800556:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800558:	00f58863          	beq	a1,a5,800568 <strnlen+0x18>
  80055c:	00f50733          	add	a4,a0,a5
  800560:	00074703          	lbu	a4,0(a4)
  800564:	fb6d                	bnez	a4,800556 <strnlen+0x6>
  800566:	85be                	mv	a1,a5
    }
    return cnt;
}
  800568:	852e                	mv	a0,a1
  80056a:	8082                	ret

000000000080056c <forktree>:
        exit(0);
    }
}

void
forktree(const char *cur) {
  80056c:	1101                	addi	sp,sp,-32
  80056e:	ec06                	sd	ra,24(sp)
  800570:	e822                	sd	s0,16(sp)
  800572:	842a                	mv	s0,a0
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  800574:	b6dff0ef          	jal	8000e0 <getpid>
  800578:	85aa                	mv	a1,a0
  80057a:	8622                	mv	a2,s0
  80057c:	00000517          	auipc	a0,0x0
  800580:	1cc50513          	addi	a0,a0,460 # 800748 <main+0x12c>
  800584:	abdff0ef          	jal	800040 <cprintf>

    forkchild(cur, '0');
  800588:	03000593          	li	a1,48
  80058c:	8522                	mv	a0,s0
  80058e:	044000ef          	jal	8005d2 <forkchild>
    if (strlen(cur) >= DEPTH)
  800592:	8522                	mv	a0,s0
  800594:	fa3ff0ef          	jal	800536 <strlen>
  800598:	478d                	li	a5,3
  80059a:	00a7f663          	bgeu	a5,a0,8005a6 <forktree+0x3a>
    forkchild(cur, '1');
}
  80059e:	60e2                	ld	ra,24(sp)
  8005a0:	6442                	ld	s0,16(sp)
  8005a2:	6105                	addi	sp,sp,32
  8005a4:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005a6:	03100713          	li	a4,49
  8005aa:	86a2                	mv	a3,s0
  8005ac:	00000617          	auipc	a2,0x0
  8005b0:	1b460613          	addi	a2,a2,436 # 800760 <main+0x144>
  8005b4:	4595                	li	a1,5
  8005b6:	0028                	addi	a0,sp,8
  8005b8:	f39ff0ef          	jal	8004f0 <snprintf>
    if (fork() == 0) {
  8005bc:	b21ff0ef          	jal	8000dc <fork>
  8005c0:	fd79                	bnez	a0,80059e <forktree+0x32>
        forktree(nxt);
  8005c2:	0028                	addi	a0,sp,8
  8005c4:	fa9ff0ef          	jal	80056c <forktree>
        yield();
  8005c8:	b17ff0ef          	jal	8000de <yield>
        exit(0);
  8005cc:	4501                	li	a0,0
  8005ce:	af9ff0ef          	jal	8000c6 <exit>

00000000008005d2 <forkchild>:
forkchild(const char *cur, char branch) {
  8005d2:	7179                	addi	sp,sp,-48
  8005d4:	f022                	sd	s0,32(sp)
  8005d6:	ec26                	sd	s1,24(sp)
  8005d8:	f406                	sd	ra,40(sp)
  8005da:	842a                	mv	s0,a0
  8005dc:	84ae                	mv	s1,a1
    if (strlen(cur) >= DEPTH)
  8005de:	f59ff0ef          	jal	800536 <strlen>
  8005e2:	478d                	li	a5,3
  8005e4:	00a7f763          	bgeu	a5,a0,8005f2 <forkchild+0x20>
}
  8005e8:	70a2                	ld	ra,40(sp)
  8005ea:	7402                	ld	s0,32(sp)
  8005ec:	64e2                	ld	s1,24(sp)
  8005ee:	6145                	addi	sp,sp,48
  8005f0:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005f2:	8726                	mv	a4,s1
  8005f4:	86a2                	mv	a3,s0
  8005f6:	00000617          	auipc	a2,0x0
  8005fa:	16a60613          	addi	a2,a2,362 # 800760 <main+0x144>
  8005fe:	4595                	li	a1,5
  800600:	0028                	addi	a0,sp,8
  800602:	eefff0ef          	jal	8004f0 <snprintf>
    if (fork() == 0) {
  800606:	ad7ff0ef          	jal	8000dc <fork>
  80060a:	fd79                	bnez	a0,8005e8 <forkchild+0x16>
        forktree(nxt);
  80060c:	0028                	addi	a0,sp,8
  80060e:	f5fff0ef          	jal	80056c <forktree>
        yield();
  800612:	acdff0ef          	jal	8000de <yield>
        exit(0);
  800616:	4501                	li	a0,0
  800618:	aafff0ef          	jal	8000c6 <exit>

000000000080061c <main>:

int
main(void) {
  80061c:	1141                	addi	sp,sp,-16
    forktree("");
  80061e:	00000517          	auipc	a0,0x0
  800622:	13a50513          	addi	a0,a0,314 # 800758 <main+0x13c>
main(void) {
  800626:	e406                	sd	ra,8(sp)
    forktree("");
  800628:	f45ff0ef          	jal	80056c <forktree>
    return 0;
}
  80062c:	60a2                	ld	ra,8(sp)
  80062e:	4501                	li	a0,0
  800630:	0141                	addi	sp,sp,16
  800632:	8082                	ret
