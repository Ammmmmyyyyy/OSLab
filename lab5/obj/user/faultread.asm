
obj/__user_faultread.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0b0000ef          	jal	8000d0 <umain>
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
  80002e:	086000ef          	jal	8000b4 <sys_putc>
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
  800068:	0e2000ef          	jal	80014a <vprintfmt>
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

00000000008000b4 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  8000b4:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000b6:	4579                	li	a0,30
  8000b8:	bf75                	j	800074 <syscall>

00000000008000ba <exit>:
/*
为何不让进程本身完成所有的资源回收工作呢？这是因为进程要执行回收操作，就表明此进程还存在，还在执行指令，这就需要内核栈的空间不能释放，
且表示进程存在的进程控制块不能释放。所以需要父进程来帮忙释放子进程无法完成的这两个资源回收工作。
*/
void
exit(int error_code) {
  8000ba:	1141                	addi	sp,sp,-16
  8000bc:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000be:	ff1ff0ef          	jal	8000ae <sys_exit>
    cprintf("BUG: exit failed.\n"); //执行完sys_exit后，按理说进程就结束了，后面的语句不应该再执行，
  8000c2:	00000517          	auipc	a0,0x0
  8000c6:	42650513          	addi	a0,a0,1062 # 8004e8 <main+0x8>
  8000ca:	f77ff0ef          	jal	800040 <cprintf>
    //所以执行到这里就说明exit失败了
    while (1);
  8000ce:	a001                	j	8000ce <exit+0x14>

00000000008000d0 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d0:	1141                	addi	sp,sp,-16
  8000d2:	e406                	sd	ra,8(sp)
    int ret = main();
  8000d4:	40c000ef          	jal	8004e0 <main>
    exit(ret);
  8000d8:	fe3ff0ef          	jal	8000ba <exit>

00000000008000dc <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000dc:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000e2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000e8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000ec:	f022                	sd	s0,32(sp)
  8000ee:	ec26                	sd	s1,24(sp)
  8000f0:	e84a                	sd	s2,16(sp)
  8000f2:	f406                	sd	ra,40(sp)
  8000f4:	84aa                	mv	s1,a0
  8000f6:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8000f8:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8000fc:	2a01                	sext.w	s4,s4
    if (num >= base) {
  8000fe:	05067063          	bgeu	a2,a6,80013e <printnum+0x62>
  800102:	e44e                	sd	s3,8(sp)
  800104:	89be                	mv	s3,a5
        while (-- width > 0)
  800106:	4785                	li	a5,1
  800108:	00e7d763          	bge	a5,a4,800116 <printnum+0x3a>
            putch(padc, putdat);
  80010c:	85ca                	mv	a1,s2
  80010e:	854e                	mv	a0,s3
        while (-- width > 0)
  800110:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800112:	9482                	jalr	s1
        while (-- width > 0)
  800114:	fc65                	bnez	s0,80010c <printnum+0x30>
  800116:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800118:	1a02                	slli	s4,s4,0x20
  80011a:	020a5a13          	srli	s4,s4,0x20
  80011e:	00000797          	auipc	a5,0x0
  800122:	3e278793          	addi	a5,a5,994 # 800500 <main+0x20>
  800126:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800128:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80012a:	0007c503          	lbu	a0,0(a5)
}
  80012e:	70a2                	ld	ra,40(sp)
  800130:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800132:	85ca                	mv	a1,s2
  800134:	87a6                	mv	a5,s1
}
  800136:	6942                	ld	s2,16(sp)
  800138:	64e2                	ld	s1,24(sp)
  80013a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80013c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80013e:	03065633          	divu	a2,a2,a6
  800142:	8722                	mv	a4,s0
  800144:	f99ff0ef          	jal	8000dc <printnum>
  800148:	bfc1                	j	800118 <printnum+0x3c>

000000000080014a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80014a:	7119                	addi	sp,sp,-128
  80014c:	f4a6                	sd	s1,104(sp)
  80014e:	f0ca                	sd	s2,96(sp)
  800150:	ecce                	sd	s3,88(sp)
  800152:	e8d2                	sd	s4,80(sp)
  800154:	e4d6                	sd	s5,72(sp)
  800156:	e0da                	sd	s6,64(sp)
  800158:	f862                	sd	s8,48(sp)
  80015a:	fc86                	sd	ra,120(sp)
  80015c:	f8a2                	sd	s0,112(sp)
  80015e:	fc5e                	sd	s7,56(sp)
  800160:	f466                	sd	s9,40(sp)
  800162:	f06a                	sd	s10,32(sp)
  800164:	ec6e                	sd	s11,24(sp)
  800166:	892a                	mv	s2,a0
  800168:	84ae                	mv	s1,a1
  80016a:	8c32                	mv	s8,a2
  80016c:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80016e:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800172:	05500b13          	li	s6,85
  800176:	00000a97          	auipc	s5,0x0
  80017a:	48aa8a93          	addi	s5,s5,1162 # 800600 <main+0x120>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80017e:	000c4503          	lbu	a0,0(s8)
  800182:	001c0413          	addi	s0,s8,1
  800186:	01350a63          	beq	a0,s3,80019a <vprintfmt+0x50>
            if (ch == '\0') {
  80018a:	cd0d                	beqz	a0,8001c4 <vprintfmt+0x7a>
            putch(ch, putdat);
  80018c:	85a6                	mv	a1,s1
  80018e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800190:	00044503          	lbu	a0,0(s0)
  800194:	0405                	addi	s0,s0,1
  800196:	ff351ae3          	bne	a0,s3,80018a <vprintfmt+0x40>
        char padc = ' ';
  80019a:	02000d93          	li	s11,32
        lflag = altflag = 0;
  80019e:	4b81                	li	s7,0
  8001a0:	4601                	li	a2,0
        width = precision = -1;
  8001a2:	5d7d                	li	s10,-1
  8001a4:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001a6:	00044683          	lbu	a3,0(s0)
  8001aa:	00140c13          	addi	s8,s0,1
  8001ae:	fdd6859b          	addiw	a1,a3,-35
  8001b2:	0ff5f593          	zext.b	a1,a1
  8001b6:	02bb6663          	bltu	s6,a1,8001e2 <vprintfmt+0x98>
  8001ba:	058a                	slli	a1,a1,0x2
  8001bc:	95d6                	add	a1,a1,s5
  8001be:	4198                	lw	a4,0(a1)
  8001c0:	9756                	add	a4,a4,s5
  8001c2:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001c4:	70e6                	ld	ra,120(sp)
  8001c6:	7446                	ld	s0,112(sp)
  8001c8:	74a6                	ld	s1,104(sp)
  8001ca:	7906                	ld	s2,96(sp)
  8001cc:	69e6                	ld	s3,88(sp)
  8001ce:	6a46                	ld	s4,80(sp)
  8001d0:	6aa6                	ld	s5,72(sp)
  8001d2:	6b06                	ld	s6,64(sp)
  8001d4:	7be2                	ld	s7,56(sp)
  8001d6:	7c42                	ld	s8,48(sp)
  8001d8:	7ca2                	ld	s9,40(sp)
  8001da:	7d02                	ld	s10,32(sp)
  8001dc:	6de2                	ld	s11,24(sp)
  8001de:	6109                	addi	sp,sp,128
  8001e0:	8082                	ret
            putch('%', putdat);
  8001e2:	85a6                	mv	a1,s1
  8001e4:	02500513          	li	a0,37
  8001e8:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8001ea:	fff44703          	lbu	a4,-1(s0)
  8001ee:	02500793          	li	a5,37
  8001f2:	8c22                	mv	s8,s0
  8001f4:	f8f705e3          	beq	a4,a5,80017e <vprintfmt+0x34>
  8001f8:	02500713          	li	a4,37
  8001fc:	ffec4783          	lbu	a5,-2(s8)
  800200:	1c7d                	addi	s8,s8,-1
  800202:	fee79de3          	bne	a5,a4,8001fc <vprintfmt+0xb2>
  800206:	bfa5                	j	80017e <vprintfmt+0x34>
                ch = *fmt;
  800208:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  80020c:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
  80020e:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
  800212:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
  800216:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
  80021a:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
  80021c:	02b76563          	bltu	a4,a1,800246 <vprintfmt+0xfc>
  800220:	4525                	li	a0,9
                ch = *fmt;
  800222:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
  800226:	002d171b          	slliw	a4,s10,0x2
  80022a:	01a7073b          	addw	a4,a4,s10
  80022e:	0017171b          	slliw	a4,a4,0x1
  800232:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
  800234:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
  800238:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80023a:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
  80023e:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
  800242:	feb570e3          	bgeu	a0,a1,800222 <vprintfmt+0xd8>
            if (width < 0)
  800246:	f60cd0e3          	bgez	s9,8001a6 <vprintfmt+0x5c>
                width = precision, precision = -1;
  80024a:	8cea                	mv	s9,s10
  80024c:	5d7d                	li	s10,-1
  80024e:	bfa1                	j	8001a6 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  800250:	8db6                	mv	s11,a3
  800252:	8462                	mv	s0,s8
  800254:	bf89                	j	8001a6 <vprintfmt+0x5c>
  800256:	8462                	mv	s0,s8
            altflag = 1;
  800258:	4b85                	li	s7,1
            goto reswitch;
  80025a:	b7b1                	j	8001a6 <vprintfmt+0x5c>
    if (lflag >= 2) {
  80025c:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80025e:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800262:	00c7c463          	blt	a5,a2,80026a <vprintfmt+0x120>
    else if (lflag) {
  800266:	1a060163          	beqz	a2,800408 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
  80026a:	000a3603          	ld	a2,0(s4)
  80026e:	46c1                	li	a3,16
  800270:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  800272:	000d879b          	sext.w	a5,s11
  800276:	8766                	mv	a4,s9
  800278:	85a6                	mv	a1,s1
  80027a:	854a                	mv	a0,s2
  80027c:	e61ff0ef          	jal	8000dc <printnum>
            break;
  800280:	bdfd                	j	80017e <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800282:	000a2503          	lw	a0,0(s4)
  800286:	85a6                	mv	a1,s1
  800288:	0a21                	addi	s4,s4,8
  80028a:	9902                	jalr	s2
            break;
  80028c:	bdcd                	j	80017e <vprintfmt+0x34>
    if (lflag >= 2) {
  80028e:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800290:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  800294:	00c7c463          	blt	a5,a2,80029c <vprintfmt+0x152>
    else if (lflag) {
  800298:	16060363          	beqz	a2,8003fe <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
  80029c:	000a3603          	ld	a2,0(s4)
  8002a0:	46a9                	li	a3,10
  8002a2:	8a3a                	mv	s4,a4
  8002a4:	b7f9                	j	800272 <vprintfmt+0x128>
            putch('0', putdat);
  8002a6:	85a6                	mv	a1,s1
  8002a8:	03000513          	li	a0,48
  8002ac:	9902                	jalr	s2
            putch('x', putdat);
  8002ae:	85a6                	mv	a1,s1
  8002b0:	07800513          	li	a0,120
  8002b4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002b6:	000a3603          	ld	a2,0(s4)
            goto number;
  8002ba:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002bc:	0a21                	addi	s4,s4,8
            goto number;
  8002be:	bf55                	j	800272 <vprintfmt+0x128>
            putch(ch, putdat);
  8002c0:	85a6                	mv	a1,s1
  8002c2:	02500513          	li	a0,37
  8002c6:	9902                	jalr	s2
            break;
  8002c8:	bd5d                	j	80017e <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002ca:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002ce:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002d0:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002d2:	bf95                	j	800246 <vprintfmt+0xfc>
    if (lflag >= 2) {
  8002d4:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002d6:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002da:	00c7c463          	blt	a5,a2,8002e2 <vprintfmt+0x198>
    else if (lflag) {
  8002de:	10060b63          	beqz	a2,8003f4 <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
  8002e2:	000a3603          	ld	a2,0(s4)
  8002e6:	46a1                	li	a3,8
  8002e8:	8a3a                	mv	s4,a4
  8002ea:	b761                	j	800272 <vprintfmt+0x128>
            if (width < 0)
  8002ec:	fffcc793          	not	a5,s9
  8002f0:	97fd                	srai	a5,a5,0x3f
  8002f2:	00fcf7b3          	and	a5,s9,a5
  8002f6:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
  8002fa:	8462                	mv	s0,s8
            goto reswitch;
  8002fc:	b56d                	j	8001a6 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002fe:	000a3403          	ld	s0,0(s4)
  800302:	008a0793          	addi	a5,s4,8
  800306:	e43e                	sd	a5,8(sp)
  800308:	12040063          	beqz	s0,800428 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  80030c:	0d905963          	blez	s9,8003de <vprintfmt+0x294>
  800310:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800314:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
  800318:	12fd9763          	bne	s11,a5,800446 <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80031c:	00044783          	lbu	a5,0(s0)
  800320:	0007851b          	sext.w	a0,a5
  800324:	cb9d                	beqz	a5,80035a <vprintfmt+0x210>
  800326:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800328:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80032c:	000d4563          	bltz	s10,800336 <vprintfmt+0x1ec>
  800330:	3d7d                	addiw	s10,s10,-1
  800332:	028d0263          	beq	s10,s0,800356 <vprintfmt+0x20c>
                    putch('?', putdat);
  800336:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800338:	0c0b8d63          	beqz	s7,800412 <vprintfmt+0x2c8>
  80033c:	3781                	addiw	a5,a5,-32
  80033e:	0cfdfa63          	bgeu	s11,a5,800412 <vprintfmt+0x2c8>
                    putch('?', putdat);
  800342:	03f00513          	li	a0,63
  800346:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800348:	000a4783          	lbu	a5,0(s4)
  80034c:	3cfd                	addiw	s9,s9,-1
  80034e:	0a05                	addi	s4,s4,1
  800350:	0007851b          	sext.w	a0,a5
  800354:	ffe1                	bnez	a5,80032c <vprintfmt+0x1e2>
            for (; width > 0; width --) {
  800356:	01905963          	blez	s9,800368 <vprintfmt+0x21e>
                putch(' ', putdat);
  80035a:	85a6                	mv	a1,s1
  80035c:	02000513          	li	a0,32
            for (; width > 0; width --) {
  800360:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
  800362:	9902                	jalr	s2
            for (; width > 0; width --) {
  800364:	fe0c9be3          	bnez	s9,80035a <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
  800368:	6a22                	ld	s4,8(sp)
  80036a:	bd11                	j	80017e <vprintfmt+0x34>
    if (lflag >= 2) {
  80036c:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80036e:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800372:	00c7c363          	blt	a5,a2,800378 <vprintfmt+0x22e>
    else if (lflag) {
  800376:	ce25                	beqz	a2,8003ee <vprintfmt+0x2a4>
        return va_arg(*ap, long);
  800378:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80037c:	08044d63          	bltz	s0,800416 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800380:	8622                	mv	a2,s0
  800382:	8a5e                	mv	s4,s7
  800384:	46a9                	li	a3,10
  800386:	b5f5                	j	800272 <vprintfmt+0x128>
            if (err < 0) {
  800388:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80038c:	4661                	li	a2,24
            if (err < 0) {
  80038e:	41f7d71b          	sraiw	a4,a5,0x1f
  800392:	8fb9                	xor	a5,a5,a4
  800394:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800398:	02d64663          	blt	a2,a3,8003c4 <vprintfmt+0x27a>
  80039c:	00369713          	slli	a4,a3,0x3
  8003a0:	00000797          	auipc	a5,0x0
  8003a4:	3b878793          	addi	a5,a5,952 # 800758 <error_string>
  8003a8:	97ba                	add	a5,a5,a4
  8003aa:	639c                	ld	a5,0(a5)
  8003ac:	cf81                	beqz	a5,8003c4 <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
  8003ae:	86be                	mv	a3,a5
  8003b0:	00000617          	auipc	a2,0x0
  8003b4:	18860613          	addi	a2,a2,392 # 800538 <main+0x58>
  8003b8:	85a6                	mv	a1,s1
  8003ba:	854a                	mv	a0,s2
  8003bc:	0e8000ef          	jal	8004a4 <printfmt>
            err = va_arg(ap, int);
  8003c0:	0a21                	addi	s4,s4,8
  8003c2:	bb75                	j	80017e <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003c4:	00000617          	auipc	a2,0x0
  8003c8:	16460613          	addi	a2,a2,356 # 800528 <main+0x48>
  8003cc:	85a6                	mv	a1,s1
  8003ce:	854a                	mv	a0,s2
  8003d0:	0d4000ef          	jal	8004a4 <printfmt>
            err = va_arg(ap, int);
  8003d4:	0a21                	addi	s4,s4,8
  8003d6:	b365                	j	80017e <vprintfmt+0x34>
            lflag ++;
  8003d8:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003da:	8462                	mv	s0,s8
            goto reswitch;
  8003dc:	b3e9                	j	8001a6 <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003de:	00044783          	lbu	a5,0(s0)
  8003e2:	0007851b          	sext.w	a0,a5
  8003e6:	d3c9                	beqz	a5,800368 <vprintfmt+0x21e>
  8003e8:	00140a13          	addi	s4,s0,1
  8003ec:	bf2d                	j	800326 <vprintfmt+0x1dc>
        return va_arg(*ap, int);
  8003ee:	000a2403          	lw	s0,0(s4)
  8003f2:	b769                	j	80037c <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
  8003f4:	000a6603          	lwu	a2,0(s4)
  8003f8:	46a1                	li	a3,8
  8003fa:	8a3a                	mv	s4,a4
  8003fc:	bd9d                	j	800272 <vprintfmt+0x128>
  8003fe:	000a6603          	lwu	a2,0(s4)
  800402:	46a9                	li	a3,10
  800404:	8a3a                	mv	s4,a4
  800406:	b5b5                	j	800272 <vprintfmt+0x128>
  800408:	000a6603          	lwu	a2,0(s4)
  80040c:	46c1                	li	a3,16
  80040e:	8a3a                	mv	s4,a4
  800410:	b58d                	j	800272 <vprintfmt+0x128>
                    putch(ch, putdat);
  800412:	9902                	jalr	s2
  800414:	bf15                	j	800348 <vprintfmt+0x1fe>
                putch('-', putdat);
  800416:	85a6                	mv	a1,s1
  800418:	02d00513          	li	a0,45
  80041c:	9902                	jalr	s2
                num = -(long long)num;
  80041e:	40800633          	neg	a2,s0
  800422:	8a5e                	mv	s4,s7
  800424:	46a9                	li	a3,10
  800426:	b5b1                	j	800272 <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
  800428:	01905663          	blez	s9,800434 <vprintfmt+0x2ea>
  80042c:	02d00793          	li	a5,45
  800430:	04fd9263          	bne	s11,a5,800474 <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800434:	02800793          	li	a5,40
  800438:	00000a17          	auipc	s4,0x0
  80043c:	0e1a0a13          	addi	s4,s4,225 # 800519 <main+0x39>
  800440:	02800513          	li	a0,40
  800444:	b5cd                	j	800326 <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800446:	85ea                	mv	a1,s10
  800448:	8522                	mv	a0,s0
  80044a:	07a000ef          	jal	8004c4 <strnlen>
  80044e:	40ac8cbb          	subw	s9,s9,a0
  800452:	01905963          	blez	s9,800464 <vprintfmt+0x31a>
                    putch(padc, putdat);
  800456:	2d81                	sext.w	s11,s11
  800458:	85a6                	mv	a1,s1
  80045a:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
  80045c:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
  80045e:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800460:	fe0c9ce3          	bnez	s9,800458 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800464:	00044783          	lbu	a5,0(s0)
  800468:	0007851b          	sext.w	a0,a5
  80046c:	ea079de3          	bnez	a5,800326 <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
  800470:	6a22                	ld	s4,8(sp)
  800472:	b331                	j	80017e <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800474:	85ea                	mv	a1,s10
  800476:	00000517          	auipc	a0,0x0
  80047a:	0a250513          	addi	a0,a0,162 # 800518 <main+0x38>
  80047e:	046000ef          	jal	8004c4 <strnlen>
  800482:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
  800486:	00000417          	auipc	s0,0x0
  80048a:	09240413          	addi	s0,s0,146 # 800518 <main+0x38>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80048e:	00000a17          	auipc	s4,0x0
  800492:	08ba0a13          	addi	s4,s4,139 # 800519 <main+0x39>
  800496:	02800793          	li	a5,40
  80049a:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
  80049e:	fb904ce3          	bgtz	s9,800456 <vprintfmt+0x30c>
  8004a2:	b551                	j	800326 <vprintfmt+0x1dc>

00000000008004a4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004a4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004a6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004aa:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ac:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ae:	ec06                	sd	ra,24(sp)
  8004b0:	f83a                	sd	a4,48(sp)
  8004b2:	fc3e                	sd	a5,56(sp)
  8004b4:	e0c2                	sd	a6,64(sp)
  8004b6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004b8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ba:	c91ff0ef          	jal	80014a <vprintfmt>
}
  8004be:	60e2                	ld	ra,24(sp)
  8004c0:	6161                	addi	sp,sp,80
  8004c2:	8082                	ret

00000000008004c4 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8004c4:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8004c6:	e589                	bnez	a1,8004d0 <strnlen+0xc>
  8004c8:	a811                	j	8004dc <strnlen+0x18>
        cnt ++;
  8004ca:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004cc:	00f58863          	beq	a1,a5,8004dc <strnlen+0x18>
  8004d0:	00f50733          	add	a4,a0,a5
  8004d4:	00074703          	lbu	a4,0(a4)
  8004d8:	fb6d                	bnez	a4,8004ca <strnlen+0x6>
  8004da:	85be                	mv	a1,a5
    }
    return cnt;
}
  8004dc:	852e                	mv	a0,a1
  8004de:	8082                	ret

00000000008004e0 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
    cprintf("I read %8x from 0.\n", *(unsigned int *)0);
  8004e0:	00002783          	lw	a5,0(zero) # 0 <_start-0x800020>
  8004e4:	9002                	ebreak
