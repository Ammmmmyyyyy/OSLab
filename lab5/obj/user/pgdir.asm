
obj/__user_pgdir.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0bc000ef          	jal	8000dc <umain>
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
  800068:	0ee000ef          	jal	800156 <vprintfmt>
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

00000000008000be <sys_pgdir>:
}

int
sys_pgdir(void) {
    return syscall(SYS_pgdir);
  8000be:	457d                	li	a0,31
  8000c0:	bf55                	j	800074 <syscall>

00000000008000c2 <exit>:
/*
为何不让进程本身完成所有的资源回收工作呢？这是因为进程要执行回收操作，就表明此进程还存在，还在执行指令，这就需要内核栈的空间不能释放，
且表示进程存在的进程控制块不能释放。所以需要父进程来帮忙释放子进程无法完成的这两个资源回收工作。
*/
void
exit(int error_code) {
  8000c2:	1141                	addi	sp,sp,-16
  8000c4:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c6:	fe9ff0ef          	jal	8000ae <sys_exit>
    cprintf("BUG: exit failed.\n"); //执行完sys_exit后，按理说进程就结束了，后面的语句不应该再执行，
  8000ca:	00000517          	auipc	a0,0x0
  8000ce:	45650513          	addi	a0,a0,1110 # 800520 <main+0x34>
  8000d2:	f6fff0ef          	jal	800040 <cprintf>
    //所以执行到这里就说明exit失败了
    while (1);
  8000d6:	a001                	j	8000d6 <exit+0x14>

00000000008000d8 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000d8:	bff1                	j	8000b4 <sys_getpid>

00000000008000da <print_pgdir>:
}

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    sys_pgdir();
  8000da:	b7d5                	j	8000be <sys_pgdir>

00000000008000dc <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000dc:	1141                	addi	sp,sp,-16
  8000de:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e0:	40c000ef          	jal	8004ec <main>
    exit(ret);
  8000e4:	fdfff0ef          	jal	8000c2 <exit>

00000000008000e8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000e8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000ec:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000ee:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000f4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000f8:	f022                	sd	s0,32(sp)
  8000fa:	ec26                	sd	s1,24(sp)
  8000fc:	e84a                	sd	s2,16(sp)
  8000fe:	f406                	sd	ra,40(sp)
  800100:	84aa                	mv	s1,a0
  800102:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800104:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800108:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80010a:	05067063          	bgeu	a2,a6,80014a <printnum+0x62>
  80010e:	e44e                	sd	s3,8(sp)
  800110:	89be                	mv	s3,a5
        while (-- width > 0)
  800112:	4785                	li	a5,1
  800114:	00e7d763          	bge	a5,a4,800122 <printnum+0x3a>
            putch(padc, putdat);
  800118:	85ca                	mv	a1,s2
  80011a:	854e                	mv	a0,s3
        while (-- width > 0)
  80011c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80011e:	9482                	jalr	s1
        while (-- width > 0)
  800120:	fc65                	bnez	s0,800118 <printnum+0x30>
  800122:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800124:	1a02                	slli	s4,s4,0x20
  800126:	020a5a13          	srli	s4,s4,0x20
  80012a:	00000797          	auipc	a5,0x0
  80012e:	40e78793          	addi	a5,a5,1038 # 800538 <main+0x4c>
  800132:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800134:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800136:	0007c503          	lbu	a0,0(a5)
}
  80013a:	70a2                	ld	ra,40(sp)
  80013c:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013e:	85ca                	mv	a1,s2
  800140:	87a6                	mv	a5,s1
}
  800142:	6942                	ld	s2,16(sp)
  800144:	64e2                	ld	s1,24(sp)
  800146:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800148:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80014a:	03065633          	divu	a2,a2,a6
  80014e:	8722                	mv	a4,s0
  800150:	f99ff0ef          	jal	8000e8 <printnum>
  800154:	bfc1                	j	800124 <printnum+0x3c>

0000000000800156 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800156:	7119                	addi	sp,sp,-128
  800158:	f4a6                	sd	s1,104(sp)
  80015a:	f0ca                	sd	s2,96(sp)
  80015c:	ecce                	sd	s3,88(sp)
  80015e:	e8d2                	sd	s4,80(sp)
  800160:	e4d6                	sd	s5,72(sp)
  800162:	e0da                	sd	s6,64(sp)
  800164:	f862                	sd	s8,48(sp)
  800166:	fc86                	sd	ra,120(sp)
  800168:	f8a2                	sd	s0,112(sp)
  80016a:	fc5e                	sd	s7,56(sp)
  80016c:	f466                	sd	s9,40(sp)
  80016e:	f06a                	sd	s10,32(sp)
  800170:	ec6e                	sd	s11,24(sp)
  800172:	892a                	mv	s2,a0
  800174:	84ae                	mv	s1,a1
  800176:	8c32                	mv	s8,a2
  800178:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80017a:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80017e:	05500b13          	li	s6,85
  800182:	00000a97          	auipc	s5,0x0
  800186:	4dea8a93          	addi	s5,s5,1246 # 800660 <main+0x174>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80018a:	000c4503          	lbu	a0,0(s8)
  80018e:	001c0413          	addi	s0,s8,1
  800192:	01350a63          	beq	a0,s3,8001a6 <vprintfmt+0x50>
            if (ch == '\0') {
  800196:	cd0d                	beqz	a0,8001d0 <vprintfmt+0x7a>
            putch(ch, putdat);
  800198:	85a6                	mv	a1,s1
  80019a:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80019c:	00044503          	lbu	a0,0(s0)
  8001a0:	0405                	addi	s0,s0,1
  8001a2:	ff351ae3          	bne	a0,s3,800196 <vprintfmt+0x40>
        char padc = ' ';
  8001a6:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001aa:	4b81                	li	s7,0
  8001ac:	4601                	li	a2,0
        width = precision = -1;
  8001ae:	5d7d                	li	s10,-1
  8001b0:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001b2:	00044683          	lbu	a3,0(s0)
  8001b6:	00140c13          	addi	s8,s0,1
  8001ba:	fdd6859b          	addiw	a1,a3,-35
  8001be:	0ff5f593          	zext.b	a1,a1
  8001c2:	02bb6663          	bltu	s6,a1,8001ee <vprintfmt+0x98>
  8001c6:	058a                	slli	a1,a1,0x2
  8001c8:	95d6                	add	a1,a1,s5
  8001ca:	4198                	lw	a4,0(a1)
  8001cc:	9756                	add	a4,a4,s5
  8001ce:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001d0:	70e6                	ld	ra,120(sp)
  8001d2:	7446                	ld	s0,112(sp)
  8001d4:	74a6                	ld	s1,104(sp)
  8001d6:	7906                	ld	s2,96(sp)
  8001d8:	69e6                	ld	s3,88(sp)
  8001da:	6a46                	ld	s4,80(sp)
  8001dc:	6aa6                	ld	s5,72(sp)
  8001de:	6b06                	ld	s6,64(sp)
  8001e0:	7be2                	ld	s7,56(sp)
  8001e2:	7c42                	ld	s8,48(sp)
  8001e4:	7ca2                	ld	s9,40(sp)
  8001e6:	7d02                	ld	s10,32(sp)
  8001e8:	6de2                	ld	s11,24(sp)
  8001ea:	6109                	addi	sp,sp,128
  8001ec:	8082                	ret
            putch('%', putdat);
  8001ee:	85a6                	mv	a1,s1
  8001f0:	02500513          	li	a0,37
  8001f4:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8001f6:	fff44703          	lbu	a4,-1(s0)
  8001fa:	02500793          	li	a5,37
  8001fe:	8c22                	mv	s8,s0
  800200:	f8f705e3          	beq	a4,a5,80018a <vprintfmt+0x34>
  800204:	02500713          	li	a4,37
  800208:	ffec4783          	lbu	a5,-2(s8)
  80020c:	1c7d                	addi	s8,s8,-1
  80020e:	fee79de3          	bne	a5,a4,800208 <vprintfmt+0xb2>
  800212:	bfa5                	j	80018a <vprintfmt+0x34>
                ch = *fmt;
  800214:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  800218:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
  80021a:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
  80021e:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
  800222:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
  800226:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
  800228:	02b76563          	bltu	a4,a1,800252 <vprintfmt+0xfc>
  80022c:	4525                	li	a0,9
                ch = *fmt;
  80022e:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
  800232:	002d171b          	slliw	a4,s10,0x2
  800236:	01a7073b          	addw	a4,a4,s10
  80023a:	0017171b          	slliw	a4,a4,0x1
  80023e:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
  800240:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
  800244:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800246:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
  80024a:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
  80024e:	feb570e3          	bgeu	a0,a1,80022e <vprintfmt+0xd8>
            if (width < 0)
  800252:	f60cd0e3          	bgez	s9,8001b2 <vprintfmt+0x5c>
                width = precision, precision = -1;
  800256:	8cea                	mv	s9,s10
  800258:	5d7d                	li	s10,-1
  80025a:	bfa1                	j	8001b2 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  80025c:	8db6                	mv	s11,a3
  80025e:	8462                	mv	s0,s8
  800260:	bf89                	j	8001b2 <vprintfmt+0x5c>
  800262:	8462                	mv	s0,s8
            altflag = 1;
  800264:	4b85                	li	s7,1
            goto reswitch;
  800266:	b7b1                	j	8001b2 <vprintfmt+0x5c>
    if (lflag >= 2) {
  800268:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80026a:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  80026e:	00c7c463          	blt	a5,a2,800276 <vprintfmt+0x120>
    else if (lflag) {
  800272:	1a060163          	beqz	a2,800414 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
  800276:	000a3603          	ld	a2,0(s4)
  80027a:	46c1                	li	a3,16
  80027c:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  80027e:	000d879b          	sext.w	a5,s11
  800282:	8766                	mv	a4,s9
  800284:	85a6                	mv	a1,s1
  800286:	854a                	mv	a0,s2
  800288:	e61ff0ef          	jal	8000e8 <printnum>
            break;
  80028c:	bdfd                	j	80018a <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  80028e:	000a2503          	lw	a0,0(s4)
  800292:	85a6                	mv	a1,s1
  800294:	0a21                	addi	s4,s4,8
  800296:	9902                	jalr	s2
            break;
  800298:	bdcd                	j	80018a <vprintfmt+0x34>
    if (lflag >= 2) {
  80029a:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80029c:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002a0:	00c7c463          	blt	a5,a2,8002a8 <vprintfmt+0x152>
    else if (lflag) {
  8002a4:	16060363          	beqz	a2,80040a <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
  8002a8:	000a3603          	ld	a2,0(s4)
  8002ac:	46a9                	li	a3,10
  8002ae:	8a3a                	mv	s4,a4
  8002b0:	b7f9                	j	80027e <vprintfmt+0x128>
            putch('0', putdat);
  8002b2:	85a6                	mv	a1,s1
  8002b4:	03000513          	li	a0,48
  8002b8:	9902                	jalr	s2
            putch('x', putdat);
  8002ba:	85a6                	mv	a1,s1
  8002bc:	07800513          	li	a0,120
  8002c0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002c2:	000a3603          	ld	a2,0(s4)
            goto number;
  8002c6:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002c8:	0a21                	addi	s4,s4,8
            goto number;
  8002ca:	bf55                	j	80027e <vprintfmt+0x128>
            putch(ch, putdat);
  8002cc:	85a6                	mv	a1,s1
  8002ce:	02500513          	li	a0,37
  8002d2:	9902                	jalr	s2
            break;
  8002d4:	bd5d                	j	80018a <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002d6:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002da:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002dc:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002de:	bf95                	j	800252 <vprintfmt+0xfc>
    if (lflag >= 2) {
  8002e0:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002e2:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002e6:	00c7c463          	blt	a5,a2,8002ee <vprintfmt+0x198>
    else if (lflag) {
  8002ea:	10060b63          	beqz	a2,800400 <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
  8002ee:	000a3603          	ld	a2,0(s4)
  8002f2:	46a1                	li	a3,8
  8002f4:	8a3a                	mv	s4,a4
  8002f6:	b761                	j	80027e <vprintfmt+0x128>
            if (width < 0)
  8002f8:	fffcc793          	not	a5,s9
  8002fc:	97fd                	srai	a5,a5,0x3f
  8002fe:	00fcf7b3          	and	a5,s9,a5
  800302:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
  800306:	8462                	mv	s0,s8
            goto reswitch;
  800308:	b56d                	j	8001b2 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  80030a:	000a3403          	ld	s0,0(s4)
  80030e:	008a0793          	addi	a5,s4,8
  800312:	e43e                	sd	a5,8(sp)
  800314:	12040063          	beqz	s0,800434 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800318:	0d905963          	blez	s9,8003ea <vprintfmt+0x294>
  80031c:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800320:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
  800324:	12fd9763          	bne	s11,a5,800452 <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800328:	00044783          	lbu	a5,0(s0)
  80032c:	0007851b          	sext.w	a0,a5
  800330:	cb9d                	beqz	a5,800366 <vprintfmt+0x210>
  800332:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800334:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800338:	000d4563          	bltz	s10,800342 <vprintfmt+0x1ec>
  80033c:	3d7d                	addiw	s10,s10,-1
  80033e:	028d0263          	beq	s10,s0,800362 <vprintfmt+0x20c>
                    putch('?', putdat);
  800342:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800344:	0c0b8d63          	beqz	s7,80041e <vprintfmt+0x2c8>
  800348:	3781                	addiw	a5,a5,-32
  80034a:	0cfdfa63          	bgeu	s11,a5,80041e <vprintfmt+0x2c8>
                    putch('?', putdat);
  80034e:	03f00513          	li	a0,63
  800352:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800354:	000a4783          	lbu	a5,0(s4)
  800358:	3cfd                	addiw	s9,s9,-1
  80035a:	0a05                	addi	s4,s4,1
  80035c:	0007851b          	sext.w	a0,a5
  800360:	ffe1                	bnez	a5,800338 <vprintfmt+0x1e2>
            for (; width > 0; width --) {
  800362:	01905963          	blez	s9,800374 <vprintfmt+0x21e>
                putch(' ', putdat);
  800366:	85a6                	mv	a1,s1
  800368:	02000513          	li	a0,32
            for (; width > 0; width --) {
  80036c:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
  80036e:	9902                	jalr	s2
            for (; width > 0; width --) {
  800370:	fe0c9be3          	bnez	s9,800366 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
  800374:	6a22                	ld	s4,8(sp)
  800376:	bd11                	j	80018a <vprintfmt+0x34>
    if (lflag >= 2) {
  800378:	4785                	li	a5,1
            precision = va_arg(ap, int);
  80037a:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  80037e:	00c7c363          	blt	a5,a2,800384 <vprintfmt+0x22e>
    else if (lflag) {
  800382:	ce25                	beqz	a2,8003fa <vprintfmt+0x2a4>
        return va_arg(*ap, long);
  800384:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800388:	08044d63          	bltz	s0,800422 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  80038c:	8622                	mv	a2,s0
  80038e:	8a5e                	mv	s4,s7
  800390:	46a9                	li	a3,10
  800392:	b5f5                	j	80027e <vprintfmt+0x128>
            if (err < 0) {
  800394:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800398:	4661                	li	a2,24
            if (err < 0) {
  80039a:	41f7d71b          	sraiw	a4,a5,0x1f
  80039e:	8fb9                	xor	a5,a5,a4
  8003a0:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003a4:	02d64663          	blt	a2,a3,8003d0 <vprintfmt+0x27a>
  8003a8:	00369713          	slli	a4,a3,0x3
  8003ac:	00000797          	auipc	a5,0x0
  8003b0:	40c78793          	addi	a5,a5,1036 # 8007b8 <error_string>
  8003b4:	97ba                	add	a5,a5,a4
  8003b6:	639c                	ld	a5,0(a5)
  8003b8:	cf81                	beqz	a5,8003d0 <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
  8003ba:	86be                	mv	a3,a5
  8003bc:	00000617          	auipc	a2,0x0
  8003c0:	1b460613          	addi	a2,a2,436 # 800570 <main+0x84>
  8003c4:	85a6                	mv	a1,s1
  8003c6:	854a                	mv	a0,s2
  8003c8:	0e8000ef          	jal	8004b0 <printfmt>
            err = va_arg(ap, int);
  8003cc:	0a21                	addi	s4,s4,8
  8003ce:	bb75                	j	80018a <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003d0:	00000617          	auipc	a2,0x0
  8003d4:	19060613          	addi	a2,a2,400 # 800560 <main+0x74>
  8003d8:	85a6                	mv	a1,s1
  8003da:	854a                	mv	a0,s2
  8003dc:	0d4000ef          	jal	8004b0 <printfmt>
            err = va_arg(ap, int);
  8003e0:	0a21                	addi	s4,s4,8
  8003e2:	b365                	j	80018a <vprintfmt+0x34>
            lflag ++;
  8003e4:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003e6:	8462                	mv	s0,s8
            goto reswitch;
  8003e8:	b3e9                	j	8001b2 <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ea:	00044783          	lbu	a5,0(s0)
  8003ee:	0007851b          	sext.w	a0,a5
  8003f2:	d3c9                	beqz	a5,800374 <vprintfmt+0x21e>
  8003f4:	00140a13          	addi	s4,s0,1
  8003f8:	bf2d                	j	800332 <vprintfmt+0x1dc>
        return va_arg(*ap, int);
  8003fa:	000a2403          	lw	s0,0(s4)
  8003fe:	b769                	j	800388 <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
  800400:	000a6603          	lwu	a2,0(s4)
  800404:	46a1                	li	a3,8
  800406:	8a3a                	mv	s4,a4
  800408:	bd9d                	j	80027e <vprintfmt+0x128>
  80040a:	000a6603          	lwu	a2,0(s4)
  80040e:	46a9                	li	a3,10
  800410:	8a3a                	mv	s4,a4
  800412:	b5b5                	j	80027e <vprintfmt+0x128>
  800414:	000a6603          	lwu	a2,0(s4)
  800418:	46c1                	li	a3,16
  80041a:	8a3a                	mv	s4,a4
  80041c:	b58d                	j	80027e <vprintfmt+0x128>
                    putch(ch, putdat);
  80041e:	9902                	jalr	s2
  800420:	bf15                	j	800354 <vprintfmt+0x1fe>
                putch('-', putdat);
  800422:	85a6                	mv	a1,s1
  800424:	02d00513          	li	a0,45
  800428:	9902                	jalr	s2
                num = -(long long)num;
  80042a:	40800633          	neg	a2,s0
  80042e:	8a5e                	mv	s4,s7
  800430:	46a9                	li	a3,10
  800432:	b5b1                	j	80027e <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
  800434:	01905663          	blez	s9,800440 <vprintfmt+0x2ea>
  800438:	02d00793          	li	a5,45
  80043c:	04fd9263          	bne	s11,a5,800480 <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800440:	02800793          	li	a5,40
  800444:	00000a17          	auipc	s4,0x0
  800448:	10da0a13          	addi	s4,s4,269 # 800551 <main+0x65>
  80044c:	02800513          	li	a0,40
  800450:	b5cd                	j	800332 <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800452:	85ea                	mv	a1,s10
  800454:	8522                	mv	a0,s0
  800456:	07a000ef          	jal	8004d0 <strnlen>
  80045a:	40ac8cbb          	subw	s9,s9,a0
  80045e:	01905963          	blez	s9,800470 <vprintfmt+0x31a>
                    putch(padc, putdat);
  800462:	2d81                	sext.w	s11,s11
  800464:	85a6                	mv	a1,s1
  800466:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
  800468:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
  80046a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80046c:	fe0c9ce3          	bnez	s9,800464 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800470:	00044783          	lbu	a5,0(s0)
  800474:	0007851b          	sext.w	a0,a5
  800478:	ea079de3          	bnez	a5,800332 <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
  80047c:	6a22                	ld	s4,8(sp)
  80047e:	b331                	j	80018a <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800480:	85ea                	mv	a1,s10
  800482:	00000517          	auipc	a0,0x0
  800486:	0ce50513          	addi	a0,a0,206 # 800550 <main+0x64>
  80048a:	046000ef          	jal	8004d0 <strnlen>
  80048e:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
  800492:	00000417          	auipc	s0,0x0
  800496:	0be40413          	addi	s0,s0,190 # 800550 <main+0x64>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80049a:	00000a17          	auipc	s4,0x0
  80049e:	0b7a0a13          	addi	s4,s4,183 # 800551 <main+0x65>
  8004a2:	02800793          	li	a5,40
  8004a6:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004aa:	fb904ce3          	bgtz	s9,800462 <vprintfmt+0x30c>
  8004ae:	b551                	j	800332 <vprintfmt+0x1dc>

00000000008004b0 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b0:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004b2:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b6:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004b8:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ba:	ec06                	sd	ra,24(sp)
  8004bc:	f83a                	sd	a4,48(sp)
  8004be:	fc3e                	sd	a5,56(sp)
  8004c0:	e0c2                	sd	a6,64(sp)
  8004c2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004c4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004c6:	c91ff0ef          	jal	800156 <vprintfmt>
}
  8004ca:	60e2                	ld	ra,24(sp)
  8004cc:	6161                	addi	sp,sp,80
  8004ce:	8082                	ret

00000000008004d0 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8004d0:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8004d2:	e589                	bnez	a1,8004dc <strnlen+0xc>
  8004d4:	a811                	j	8004e8 <strnlen+0x18>
        cnt ++;
  8004d6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004d8:	00f58863          	beq	a1,a5,8004e8 <strnlen+0x18>
  8004dc:	00f50733          	add	a4,a0,a5
  8004e0:	00074703          	lbu	a4,0(a4)
  8004e4:	fb6d                	bnez	a4,8004d6 <strnlen+0x6>
  8004e6:	85be                	mv	a1,a5
    }
    return cnt;
}
  8004e8:	852e                	mv	a0,a1
  8004ea:	8082                	ret

00000000008004ec <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8004ec:	1141                	addi	sp,sp,-16
  8004ee:	e406                	sd	ra,8(sp)
    cprintf("I am %d, print pgdir.\n", getpid());
  8004f0:	be9ff0ef          	jal	8000d8 <getpid>
  8004f4:	85aa                	mv	a1,a0
  8004f6:	00000517          	auipc	a0,0x0
  8004fa:	14250513          	addi	a0,a0,322 # 800638 <main+0x14c>
  8004fe:	b43ff0ef          	jal	800040 <cprintf>
    print_pgdir();
  800502:	bd9ff0ef          	jal	8000da <print_pgdir>
    cprintf("pgdir pass.\n");
  800506:	00000517          	auipc	a0,0x0
  80050a:	14a50513          	addi	a0,a0,330 # 800650 <main+0x164>
  80050e:	b33ff0ef          	jal	800040 <cprintf>
    return 0;
}
  800512:	60a2                	ld	ra,8(sp)
  800514:	4501                	li	a0,0
  800516:	0141                	addi	sp,sp,16
  800518:	8082                	ret
