
obj/__user_divzero.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	110000ef          	jal	800130 <umain>
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
  800038:	54c50513          	addi	a0,a0,1356 # 800580 <main+0x40>
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
  800058:	54c50513          	addi	a0,a0,1356 # 8005a0 <main+0x60>
  80005c:	044000ef          	jal	8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0b8000ef          	jal	80011a <exit>

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
  80006e:	0a6000ef          	jal	800114 <sys_putc>
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
  800094:	116000ef          	jal	8001aa <vprintfmt>
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
  8000c8:	0e2000ef          	jal	8001aa <vprintfmt>
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

0000000000800114 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  800114:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800116:	4579                	li	a0,30
  800118:	bf75                	j	8000d4 <syscall>

000000000080011a <exit>:
/*
为何不让进程本身完成所有的资源回收工作呢？这是因为进程要执行回收操作，就表明此进程还存在，还在执行指令，这就需要内核栈的空间不能释放，
且表示进程存在的进程控制块不能释放。所以需要父进程来帮忙释放子进程无法完成的这两个资源回收工作。
*/
void
exit(int error_code) {
  80011a:	1141                	addi	sp,sp,-16
  80011c:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80011e:	ff1ff0ef          	jal	80010e <sys_exit>
    cprintf("BUG: exit failed.\n"); //执行完sys_exit后，按理说进程就结束了，后面的语句不应该再执行，
  800122:	00000517          	auipc	a0,0x0
  800126:	48650513          	addi	a0,a0,1158 # 8005a8 <main+0x68>
  80012a:	f77ff0ef          	jal	8000a0 <cprintf>
    //所以执行到这里就说明exit失败了
    while (1);
  80012e:	a001                	j	80012e <exit+0x14>

0000000000800130 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800130:	1141                	addi	sp,sp,-16
  800132:	e406                	sd	ra,8(sp)
    int ret = main();
  800134:	40c000ef          	jal	800540 <main>
    exit(ret);
  800138:	fe3ff0ef          	jal	80011a <exit>

000000000080013c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80013c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800140:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800142:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800146:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800148:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80014c:	f022                	sd	s0,32(sp)
  80014e:	ec26                	sd	s1,24(sp)
  800150:	e84a                	sd	s2,16(sp)
  800152:	f406                	sd	ra,40(sp)
  800154:	84aa                	mv	s1,a0
  800156:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800158:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80015c:	2a01                	sext.w	s4,s4
    if (num >= base) {
  80015e:	05067063          	bgeu	a2,a6,80019e <printnum+0x62>
  800162:	e44e                	sd	s3,8(sp)
  800164:	89be                	mv	s3,a5
        while (-- width > 0)
  800166:	4785                	li	a5,1
  800168:	00e7d763          	bge	a5,a4,800176 <printnum+0x3a>
            putch(padc, putdat);
  80016c:	85ca                	mv	a1,s2
  80016e:	854e                	mv	a0,s3
        while (-- width > 0)
  800170:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800172:	9482                	jalr	s1
        while (-- width > 0)
  800174:	fc65                	bnez	s0,80016c <printnum+0x30>
  800176:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800178:	1a02                	slli	s4,s4,0x20
  80017a:	020a5a13          	srli	s4,s4,0x20
  80017e:	00000797          	auipc	a5,0x0
  800182:	44278793          	addi	a5,a5,1090 # 8005c0 <main+0x80>
  800186:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800188:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80018a:	0007c503          	lbu	a0,0(a5)
}
  80018e:	70a2                	ld	ra,40(sp)
  800190:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800192:	85ca                	mv	a1,s2
  800194:	87a6                	mv	a5,s1
}
  800196:	6942                	ld	s2,16(sp)
  800198:	64e2                	ld	s1,24(sp)
  80019a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80019c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80019e:	03065633          	divu	a2,a2,a6
  8001a2:	8722                	mv	a4,s0
  8001a4:	f99ff0ef          	jal	80013c <printnum>
  8001a8:	bfc1                	j	800178 <printnum+0x3c>

00000000008001aa <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001aa:	7119                	addi	sp,sp,-128
  8001ac:	f4a6                	sd	s1,104(sp)
  8001ae:	f0ca                	sd	s2,96(sp)
  8001b0:	ecce                	sd	s3,88(sp)
  8001b2:	e8d2                	sd	s4,80(sp)
  8001b4:	e4d6                	sd	s5,72(sp)
  8001b6:	e0da                	sd	s6,64(sp)
  8001b8:	f862                	sd	s8,48(sp)
  8001ba:	fc86                	sd	ra,120(sp)
  8001bc:	f8a2                	sd	s0,112(sp)
  8001be:	fc5e                	sd	s7,56(sp)
  8001c0:	f466                	sd	s9,40(sp)
  8001c2:	f06a                	sd	s10,32(sp)
  8001c4:	ec6e                	sd	s11,24(sp)
  8001c6:	892a                	mv	s2,a0
  8001c8:	84ae                	mv	s1,a1
  8001ca:	8c32                	mv	s8,a2
  8001cc:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ce:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001d2:	05500b13          	li	s6,85
  8001d6:	00000a97          	auipc	s5,0x0
  8001da:	512a8a93          	addi	s5,s5,1298 # 8006e8 <main+0x1a8>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001de:	000c4503          	lbu	a0,0(s8)
  8001e2:	001c0413          	addi	s0,s8,1
  8001e6:	01350a63          	beq	a0,s3,8001fa <vprintfmt+0x50>
            if (ch == '\0') {
  8001ea:	cd0d                	beqz	a0,800224 <vprintfmt+0x7a>
            putch(ch, putdat);
  8001ec:	85a6                	mv	a1,s1
  8001ee:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f0:	00044503          	lbu	a0,0(s0)
  8001f4:	0405                	addi	s0,s0,1
  8001f6:	ff351ae3          	bne	a0,s3,8001ea <vprintfmt+0x40>
        char padc = ' ';
  8001fa:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001fe:	4b81                	li	s7,0
  800200:	4601                	li	a2,0
        width = precision = -1;
  800202:	5d7d                	li	s10,-1
  800204:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800206:	00044683          	lbu	a3,0(s0)
  80020a:	00140c13          	addi	s8,s0,1
  80020e:	fdd6859b          	addiw	a1,a3,-35
  800212:	0ff5f593          	zext.b	a1,a1
  800216:	02bb6663          	bltu	s6,a1,800242 <vprintfmt+0x98>
  80021a:	058a                	slli	a1,a1,0x2
  80021c:	95d6                	add	a1,a1,s5
  80021e:	4198                	lw	a4,0(a1)
  800220:	9756                	add	a4,a4,s5
  800222:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800224:	70e6                	ld	ra,120(sp)
  800226:	7446                	ld	s0,112(sp)
  800228:	74a6                	ld	s1,104(sp)
  80022a:	7906                	ld	s2,96(sp)
  80022c:	69e6                	ld	s3,88(sp)
  80022e:	6a46                	ld	s4,80(sp)
  800230:	6aa6                	ld	s5,72(sp)
  800232:	6b06                	ld	s6,64(sp)
  800234:	7be2                	ld	s7,56(sp)
  800236:	7c42                	ld	s8,48(sp)
  800238:	7ca2                	ld	s9,40(sp)
  80023a:	7d02                	ld	s10,32(sp)
  80023c:	6de2                	ld	s11,24(sp)
  80023e:	6109                	addi	sp,sp,128
  800240:	8082                	ret
            putch('%', putdat);
  800242:	85a6                	mv	a1,s1
  800244:	02500513          	li	a0,37
  800248:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80024a:	fff44703          	lbu	a4,-1(s0)
  80024e:	02500793          	li	a5,37
  800252:	8c22                	mv	s8,s0
  800254:	f8f705e3          	beq	a4,a5,8001de <vprintfmt+0x34>
  800258:	02500713          	li	a4,37
  80025c:	ffec4783          	lbu	a5,-2(s8)
  800260:	1c7d                	addi	s8,s8,-1
  800262:	fee79de3          	bne	a5,a4,80025c <vprintfmt+0xb2>
  800266:	bfa5                	j	8001de <vprintfmt+0x34>
                ch = *fmt;
  800268:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
  80026c:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
  80026e:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
  800272:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
  800276:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
  80027a:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
  80027c:	02b76563          	bltu	a4,a1,8002a6 <vprintfmt+0xfc>
  800280:	4525                	li	a0,9
                ch = *fmt;
  800282:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
  800286:	002d171b          	slliw	a4,s10,0x2
  80028a:	01a7073b          	addw	a4,a4,s10
  80028e:	0017171b          	slliw	a4,a4,0x1
  800292:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
  800294:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
  800298:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80029a:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
  80029e:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
  8002a2:	feb570e3          	bgeu	a0,a1,800282 <vprintfmt+0xd8>
            if (width < 0)
  8002a6:	f60cd0e3          	bgez	s9,800206 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002aa:	8cea                	mv	s9,s10
  8002ac:	5d7d                	li	s10,-1
  8002ae:	bfa1                	j	800206 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002b0:	8db6                	mv	s11,a3
  8002b2:	8462                	mv	s0,s8
  8002b4:	bf89                	j	800206 <vprintfmt+0x5c>
  8002b6:	8462                	mv	s0,s8
            altflag = 1;
  8002b8:	4b85                	li	s7,1
            goto reswitch;
  8002ba:	b7b1                	j	800206 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002bc:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002be:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002c2:	00c7c463          	blt	a5,a2,8002ca <vprintfmt+0x120>
    else if (lflag) {
  8002c6:	1a060163          	beqz	a2,800468 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
  8002ca:	000a3603          	ld	a2,0(s4)
  8002ce:	46c1                	li	a3,16
  8002d0:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
  8002d2:	000d879b          	sext.w	a5,s11
  8002d6:	8766                	mv	a4,s9
  8002d8:	85a6                	mv	a1,s1
  8002da:	854a                	mv	a0,s2
  8002dc:	e61ff0ef          	jal	80013c <printnum>
            break;
  8002e0:	bdfd                	j	8001de <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002e2:	000a2503          	lw	a0,0(s4)
  8002e6:	85a6                	mv	a1,s1
  8002e8:	0a21                	addi	s4,s4,8
  8002ea:	9902                	jalr	s2
            break;
  8002ec:	bdcd                	j	8001de <vprintfmt+0x34>
    if (lflag >= 2) {
  8002ee:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8002f0:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  8002f4:	00c7c463          	blt	a5,a2,8002fc <vprintfmt+0x152>
    else if (lflag) {
  8002f8:	16060363          	beqz	a2,80045e <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
  8002fc:	000a3603          	ld	a2,0(s4)
  800300:	46a9                	li	a3,10
  800302:	8a3a                	mv	s4,a4
  800304:	b7f9                	j	8002d2 <vprintfmt+0x128>
            putch('0', putdat);
  800306:	85a6                	mv	a1,s1
  800308:	03000513          	li	a0,48
  80030c:	9902                	jalr	s2
            putch('x', putdat);
  80030e:	85a6                	mv	a1,s1
  800310:	07800513          	li	a0,120
  800314:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800316:	000a3603          	ld	a2,0(s4)
            goto number;
  80031a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80031c:	0a21                	addi	s4,s4,8
            goto number;
  80031e:	bf55                	j	8002d2 <vprintfmt+0x128>
            putch(ch, putdat);
  800320:	85a6                	mv	a1,s1
  800322:	02500513          	li	a0,37
  800326:	9902                	jalr	s2
            break;
  800328:	bd5d                	j	8001de <vprintfmt+0x34>
            precision = va_arg(ap, int);
  80032a:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80032e:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800330:	0a21                	addi	s4,s4,8
            goto process_precision;
  800332:	bf95                	j	8002a6 <vprintfmt+0xfc>
    if (lflag >= 2) {
  800334:	4785                	li	a5,1
            precision = va_arg(ap, int);
  800336:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
  80033a:	00c7c463          	blt	a5,a2,800342 <vprintfmt+0x198>
    else if (lflag) {
  80033e:	10060b63          	beqz	a2,800454 <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
  800342:	000a3603          	ld	a2,0(s4)
  800346:	46a1                	li	a3,8
  800348:	8a3a                	mv	s4,a4
  80034a:	b761                	j	8002d2 <vprintfmt+0x128>
            if (width < 0)
  80034c:	fffcc793          	not	a5,s9
  800350:	97fd                	srai	a5,a5,0x3f
  800352:	00fcf7b3          	and	a5,s9,a5
  800356:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
  80035a:	8462                	mv	s0,s8
            goto reswitch;
  80035c:	b56d                	j	800206 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
  80035e:	000a3403          	ld	s0,0(s4)
  800362:	008a0793          	addi	a5,s4,8
  800366:	e43e                	sd	a5,8(sp)
  800368:	12040063          	beqz	s0,800488 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  80036c:	0d905963          	blez	s9,80043e <vprintfmt+0x294>
  800370:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800374:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
  800378:	12fd9763          	bne	s11,a5,8004a6 <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80037c:	00044783          	lbu	a5,0(s0)
  800380:	0007851b          	sext.w	a0,a5
  800384:	cb9d                	beqz	a5,8003ba <vprintfmt+0x210>
  800386:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800388:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038c:	000d4563          	bltz	s10,800396 <vprintfmt+0x1ec>
  800390:	3d7d                	addiw	s10,s10,-1
  800392:	028d0263          	beq	s10,s0,8003b6 <vprintfmt+0x20c>
                    putch('?', putdat);
  800396:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800398:	0c0b8d63          	beqz	s7,800472 <vprintfmt+0x2c8>
  80039c:	3781                	addiw	a5,a5,-32
  80039e:	0cfdfa63          	bgeu	s11,a5,800472 <vprintfmt+0x2c8>
                    putch('?', putdat);
  8003a2:	03f00513          	li	a0,63
  8003a6:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a8:	000a4783          	lbu	a5,0(s4)
  8003ac:	3cfd                	addiw	s9,s9,-1
  8003ae:	0a05                	addi	s4,s4,1
  8003b0:	0007851b          	sext.w	a0,a5
  8003b4:	ffe1                	bnez	a5,80038c <vprintfmt+0x1e2>
            for (; width > 0; width --) {
  8003b6:	01905963          	blez	s9,8003c8 <vprintfmt+0x21e>
                putch(' ', putdat);
  8003ba:	85a6                	mv	a1,s1
  8003bc:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003c0:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
  8003c2:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003c4:	fe0c9be3          	bnez	s9,8003ba <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003c8:	6a22                	ld	s4,8(sp)
  8003ca:	bd11                	j	8001de <vprintfmt+0x34>
    if (lflag >= 2) {
  8003cc:	4785                	li	a5,1
            precision = va_arg(ap, int);
  8003ce:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003d2:	00c7c363          	blt	a5,a2,8003d8 <vprintfmt+0x22e>
    else if (lflag) {
  8003d6:	ce25                	beqz	a2,80044e <vprintfmt+0x2a4>
        return va_arg(*ap, long);
  8003d8:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003dc:	08044d63          	bltz	s0,800476 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  8003e0:	8622                	mv	a2,s0
  8003e2:	8a5e                	mv	s4,s7
  8003e4:	46a9                	li	a3,10
  8003e6:	b5f5                	j	8002d2 <vprintfmt+0x128>
            if (err < 0) {
  8003e8:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003ec:	4661                	li	a2,24
            if (err < 0) {
  8003ee:	41f7d71b          	sraiw	a4,a5,0x1f
  8003f2:	8fb9                	xor	a5,a5,a4
  8003f4:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003f8:	02d64663          	blt	a2,a3,800424 <vprintfmt+0x27a>
  8003fc:	00369713          	slli	a4,a3,0x3
  800400:	00000797          	auipc	a5,0x0
  800404:	44078793          	addi	a5,a5,1088 # 800840 <error_string>
  800408:	97ba                	add	a5,a5,a4
  80040a:	639c                	ld	a5,0(a5)
  80040c:	cf81                	beqz	a5,800424 <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
  80040e:	86be                	mv	a3,a5
  800410:	00000617          	auipc	a2,0x0
  800414:	1e060613          	addi	a2,a2,480 # 8005f0 <main+0xb0>
  800418:	85a6                	mv	a1,s1
  80041a:	854a                	mv	a0,s2
  80041c:	0e8000ef          	jal	800504 <printfmt>
            err = va_arg(ap, int);
  800420:	0a21                	addi	s4,s4,8
  800422:	bb75                	j	8001de <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800424:	00000617          	auipc	a2,0x0
  800428:	1bc60613          	addi	a2,a2,444 # 8005e0 <main+0xa0>
  80042c:	85a6                	mv	a1,s1
  80042e:	854a                	mv	a0,s2
  800430:	0d4000ef          	jal	800504 <printfmt>
            err = va_arg(ap, int);
  800434:	0a21                	addi	s4,s4,8
  800436:	b365                	j	8001de <vprintfmt+0x34>
            lflag ++;
  800438:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
  80043a:	8462                	mv	s0,s8
            goto reswitch;
  80043c:	b3e9                	j	800206 <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80043e:	00044783          	lbu	a5,0(s0)
  800442:	0007851b          	sext.w	a0,a5
  800446:	d3c9                	beqz	a5,8003c8 <vprintfmt+0x21e>
  800448:	00140a13          	addi	s4,s0,1
  80044c:	bf2d                	j	800386 <vprintfmt+0x1dc>
        return va_arg(*ap, int);
  80044e:	000a2403          	lw	s0,0(s4)
  800452:	b769                	j	8003dc <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
  800454:	000a6603          	lwu	a2,0(s4)
  800458:	46a1                	li	a3,8
  80045a:	8a3a                	mv	s4,a4
  80045c:	bd9d                	j	8002d2 <vprintfmt+0x128>
  80045e:	000a6603          	lwu	a2,0(s4)
  800462:	46a9                	li	a3,10
  800464:	8a3a                	mv	s4,a4
  800466:	b5b5                	j	8002d2 <vprintfmt+0x128>
  800468:	000a6603          	lwu	a2,0(s4)
  80046c:	46c1                	li	a3,16
  80046e:	8a3a                	mv	s4,a4
  800470:	b58d                	j	8002d2 <vprintfmt+0x128>
                    putch(ch, putdat);
  800472:	9902                	jalr	s2
  800474:	bf15                	j	8003a8 <vprintfmt+0x1fe>
                putch('-', putdat);
  800476:	85a6                	mv	a1,s1
  800478:	02d00513          	li	a0,45
  80047c:	9902                	jalr	s2
                num = -(long long)num;
  80047e:	40800633          	neg	a2,s0
  800482:	8a5e                	mv	s4,s7
  800484:	46a9                	li	a3,10
  800486:	b5b1                	j	8002d2 <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
  800488:	01905663          	blez	s9,800494 <vprintfmt+0x2ea>
  80048c:	02d00793          	li	a5,45
  800490:	04fd9263          	bne	s11,a5,8004d4 <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800494:	02800793          	li	a5,40
  800498:	00000a17          	auipc	s4,0x0
  80049c:	141a0a13          	addi	s4,s4,321 # 8005d9 <main+0x99>
  8004a0:	02800513          	li	a0,40
  8004a4:	b5cd                	j	800386 <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a6:	85ea                	mv	a1,s10
  8004a8:	8522                	mv	a0,s0
  8004aa:	07a000ef          	jal	800524 <strnlen>
  8004ae:	40ac8cbb          	subw	s9,s9,a0
  8004b2:	01905963          	blez	s9,8004c4 <vprintfmt+0x31a>
                    putch(padc, putdat);
  8004b6:	2d81                	sext.w	s11,s11
  8004b8:	85a6                	mv	a1,s1
  8004ba:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004bc:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
  8004be:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c0:	fe0c9ce3          	bnez	s9,8004b8 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c4:	00044783          	lbu	a5,0(s0)
  8004c8:	0007851b          	sext.w	a0,a5
  8004cc:	ea079de3          	bnez	a5,800386 <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004d0:	6a22                	ld	s4,8(sp)
  8004d2:	b331                	j	8001de <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d4:	85ea                	mv	a1,s10
  8004d6:	00000517          	auipc	a0,0x0
  8004da:	10250513          	addi	a0,a0,258 # 8005d8 <main+0x98>
  8004de:	046000ef          	jal	800524 <strnlen>
  8004e2:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
  8004e6:	00000417          	auipc	s0,0x0
  8004ea:	0f240413          	addi	s0,s0,242 # 8005d8 <main+0x98>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ee:	00000a17          	auipc	s4,0x0
  8004f2:	0eba0a13          	addi	s4,s4,235 # 8005d9 <main+0x99>
  8004f6:	02800793          	li	a5,40
  8004fa:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004fe:	fb904ce3          	bgtz	s9,8004b6 <vprintfmt+0x30c>
  800502:	b551                	j	800386 <vprintfmt+0x1dc>

0000000000800504 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800504:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800506:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80050c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050e:	ec06                	sd	ra,24(sp)
  800510:	f83a                	sd	a4,48(sp)
  800512:	fc3e                	sd	a5,56(sp)
  800514:	e0c2                	sd	a6,64(sp)
  800516:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800518:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80051a:	c91ff0ef          	jal	8001aa <vprintfmt>
}
  80051e:	60e2                	ld	ra,24(sp)
  800520:	6161                	addi	sp,sp,80
  800522:	8082                	ret

0000000000800524 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800524:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800526:	e589                	bnez	a1,800530 <strnlen+0xc>
  800528:	a811                	j	80053c <strnlen+0x18>
        cnt ++;
  80052a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80052c:	00f58863          	beq	a1,a5,80053c <strnlen+0x18>
  800530:	00f50733          	add	a4,a0,a5
  800534:	00074703          	lbu	a4,0(a4)
  800538:	fb6d                	bnez	a4,80052a <strnlen+0x6>
  80053a:	85be                	mv	a1,a5
    }
    return cnt;
}
  80053c:	852e                	mv	a0,a1
  80053e:	8082                	ret

0000000000800540 <main>:

int zero;

int
main(void) {
    cprintf("value is %d.\n", 1 / zero);
  800540:	00001717          	auipc	a4,0x1
  800544:	ac072703          	lw	a4,-1344(a4) # 801000 <zero>
main(void) {
  800548:	1141                	addi	sp,sp,-16
    cprintf("value is %d.\n", 1 / zero);
  80054a:	0017079b          	addiw	a5,a4,1
main(void) {
  80054e:	e406                	sd	ra,8(sp)
    cprintf("value is %d.\n", 1 / zero);
  800550:	0037b793          	sltiu	a5,a5,3
  800554:	0007059b          	sext.w	a1,a4
  800558:	e391                	bnez	a5,80055c <main+0x1c>
  80055a:	4581                	li	a1,0
  80055c:	00000517          	auipc	a0,0x0
  800560:	15c50513          	addi	a0,a0,348 # 8006b8 <main+0x178>
  800564:	b3dff0ef          	jal	8000a0 <cprintf>
    panic("FAIL: T.T\n");
  800568:	00000617          	auipc	a2,0x0
  80056c:	16060613          	addi	a2,a2,352 # 8006c8 <main+0x188>
  800570:	45a5                	li	a1,9
  800572:	00000517          	auipc	a0,0x0
  800576:	16650513          	addi	a0,a0,358 # 8006d8 <main+0x198>
  80057a:	aadff0ef          	jal	800026 <__panic>
