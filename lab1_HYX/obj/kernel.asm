
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16 # 80203ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	1ed000ef          	jal	80200a0e <memset>

    cons_init();  // init the console
    80200026:	146000ef          	jal	8020016c <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	9f658593          	addi	a1,a1,-1546 # 80200a20 <etext>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a0e50513          	addi	a0,a0,-1522 # 80200a40 <etext+0x20>
    8020003a:	030000ef          	jal	8020006a <cprintf>

    print_kerninfo();
    8020003e:	060000ef          	jal	8020009e <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	13a000ef          	jal	8020017c <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e4000ef          	jal	8020012a <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	12c000ef          	jal	80200176 <intr_enable>
    
    while (1)
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    cons_putc(c);
    80200058:	116000ef          	jal	8020016e <cons_putc>
    (*cnt)++;
    8020005c:	401c                	lw	a5,0(s0)
}
    8020005e:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
}
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006a:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006c:	02810313          	addi	t1,sp,40
int cprintf(const char *fmt, ...) {
    80200070:	f42e                	sd	a1,40(sp)
    80200072:	f832                	sd	a2,48(sp)
    80200074:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200076:	862a                	mv	a2,a0
    80200078:	004c                	addi	a1,sp,4
    8020007a:	00000517          	auipc	a0,0x0
    8020007e:	fd650513          	addi	a0,a0,-42 # 80200050 <cputch>
    80200082:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200084:	ec06                	sd	ra,24(sp)
    80200086:	e0ba                	sd	a4,64(sp)
    80200088:	e4be                	sd	a5,72(sp)
    8020008a:	e8c2                	sd	a6,80(sp)
    8020008c:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    8020008e:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200090:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200092:	592000ef          	jal	80200624 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200096:	60e2                	ld	ra,24(sp)
    80200098:	4512                	lw	a0,4(sp)
    8020009a:	6125                	addi	sp,sp,96
    8020009c:	8082                	ret

000000008020009e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    8020009e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a0:	00001517          	auipc	a0,0x1
    802000a4:	9a850513          	addi	a0,a0,-1624 # 80200a48 <etext+0x28>
void print_kerninfo(void) {
    802000a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000aa:	fc1ff0ef          	jal	8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000ae:	00000597          	auipc	a1,0x0
    802000b2:	f5c58593          	addi	a1,a1,-164 # 8020000a <kern_init>
    802000b6:	00001517          	auipc	a0,0x1
    802000ba:	9b250513          	addi	a0,a0,-1614 # 80200a68 <etext+0x48>
    802000be:	fadff0ef          	jal	8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c2:	00001597          	auipc	a1,0x1
    802000c6:	95e58593          	addi	a1,a1,-1698 # 80200a20 <etext>
    802000ca:	00001517          	auipc	a0,0x1
    802000ce:	9be50513          	addi	a0,a0,-1602 # 80200a88 <etext+0x68>
    802000d2:	f99ff0ef          	jal	8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d6:	00004597          	auipc	a1,0x4
    802000da:	f3a58593          	addi	a1,a1,-198 # 80204010 <ticks>
    802000de:	00001517          	auipc	a0,0x1
    802000e2:	9ca50513          	addi	a0,a0,-1590 # 80200aa8 <etext+0x88>
    802000e6:	f85ff0ef          	jal	8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ea:	00004597          	auipc	a1,0x4
    802000ee:	f3e58593          	addi	a1,a1,-194 # 80204028 <end>
    802000f2:	00001517          	auipc	a0,0x1
    802000f6:	9d650513          	addi	a0,a0,-1578 # 80200ac8 <etext+0xa8>
    802000fa:	f71ff0ef          	jal	8020006a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    802000fe:	00004797          	auipc	a5,0x4
    80200102:	32978793          	addi	a5,a5,809 # 80204427 <end+0x3ff>
    80200106:	00000717          	auipc	a4,0x0
    8020010a:	f0470713          	addi	a4,a4,-252 # 8020000a <kern_init>
    8020010e:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200110:	43f7d593          	srai	a1,a5,0x3f
}
    80200114:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200116:	3ff5f593          	andi	a1,a1,1023
    8020011a:	95be                	add	a1,a1,a5
    8020011c:	85a9                	srai	a1,a1,0xa
    8020011e:	00001517          	auipc	a0,0x1
    80200122:	9ca50513          	addi	a0,a0,-1590 # 80200ae8 <etext+0xc8>
}
    80200126:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200128:	b789                	j	8020006a <cprintf>

000000008020012a <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    8020012a:	1141                	addi	sp,sp,-16
    8020012c:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    8020012e:	02000793          	li	a5,32
    80200132:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200136:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020013a:	67e1                	lui	a5,0x18
    8020013c:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200140:	953e                	add	a0,a0,a5
    80200142:	077000ef          	jal	802009b8 <sbi_set_timer>
}
    80200146:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200148:	00004797          	auipc	a5,0x4
    8020014c:	ec07b423          	sd	zero,-312(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200150:	00001517          	auipc	a0,0x1
    80200154:	9c850513          	addi	a0,a0,-1592 # 80200b18 <etext+0xf8>
}
    80200158:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    8020015a:	bf01                	j	8020006a <cprintf>

000000008020015c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020015c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200160:	67e1                	lui	a5,0x18
    80200162:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200166:	953e                	add	a0,a0,a5
    80200168:	0510006f          	j	802009b8 <sbi_set_timer>

000000008020016c <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    8020016c:	8082                	ret

000000008020016e <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    8020016e:	0ff57513          	zext.b	a0,a0
    80200172:	02d0006f          	j	8020099e <sbi_console_putchar>

0000000080200176 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200176:	100167f3          	csrrsi	a5,sstatus,2
    8020017a:	8082                	ret

000000008020017c <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    8020017c:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200180:	00000797          	auipc	a5,0x0
    80200184:	38078793          	addi	a5,a5,896 # 80200500 <__alltraps>
    80200188:	10579073          	csrw	stvec,a5
}
    8020018c:	8082                	ret

000000008020018e <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);//打印出 badvaddr 字段，badvaddr 是发生异常的错误地址（Bad Virtual Address），通常在内存访问异常（如页错误）时使用。
    cprintf("  cause    0x%08x\n", tf->cause);//打印出 cause 字段，表示导致异常的原因码（Cause Register），通常指出是哪种中断或异常触发的。
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020018e:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200190:	1141                	addi	sp,sp,-16
    80200192:	e022                	sd	s0,0(sp)
    80200194:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200196:	00001517          	auipc	a0,0x1
    8020019a:	9a250513          	addi	a0,a0,-1630 # 80200b38 <etext+0x118>
void print_regs(struct pushregs *gpr) {
    8020019e:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a0:	ecbff0ef          	jal	8020006a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a4:	640c                	ld	a1,8(s0)
    802001a6:	00001517          	auipc	a0,0x1
    802001aa:	9aa50513          	addi	a0,a0,-1622 # 80200b50 <etext+0x130>
    802001ae:	ebdff0ef          	jal	8020006a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b2:	680c                	ld	a1,16(s0)
    802001b4:	00001517          	auipc	a0,0x1
    802001b8:	9b450513          	addi	a0,a0,-1612 # 80200b68 <etext+0x148>
    802001bc:	eafff0ef          	jal	8020006a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c0:	6c0c                	ld	a1,24(s0)
    802001c2:	00001517          	auipc	a0,0x1
    802001c6:	9be50513          	addi	a0,a0,-1602 # 80200b80 <etext+0x160>
    802001ca:	ea1ff0ef          	jal	8020006a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001ce:	700c                	ld	a1,32(s0)
    802001d0:	00001517          	auipc	a0,0x1
    802001d4:	9c850513          	addi	a0,a0,-1592 # 80200b98 <etext+0x178>
    802001d8:	e93ff0ef          	jal	8020006a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001dc:	740c                	ld	a1,40(s0)
    802001de:	00001517          	auipc	a0,0x1
    802001e2:	9d250513          	addi	a0,a0,-1582 # 80200bb0 <etext+0x190>
    802001e6:	e85ff0ef          	jal	8020006a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ea:	780c                	ld	a1,48(s0)
    802001ec:	00001517          	auipc	a0,0x1
    802001f0:	9dc50513          	addi	a0,a0,-1572 # 80200bc8 <etext+0x1a8>
    802001f4:	e77ff0ef          	jal	8020006a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001f8:	7c0c                	ld	a1,56(s0)
    802001fa:	00001517          	auipc	a0,0x1
    802001fe:	9e650513          	addi	a0,a0,-1562 # 80200be0 <etext+0x1c0>
    80200202:	e69ff0ef          	jal	8020006a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200206:	602c                	ld	a1,64(s0)
    80200208:	00001517          	auipc	a0,0x1
    8020020c:	9f050513          	addi	a0,a0,-1552 # 80200bf8 <etext+0x1d8>
    80200210:	e5bff0ef          	jal	8020006a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200214:	642c                	ld	a1,72(s0)
    80200216:	00001517          	auipc	a0,0x1
    8020021a:	9fa50513          	addi	a0,a0,-1542 # 80200c10 <etext+0x1f0>
    8020021e:	e4dff0ef          	jal	8020006a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200222:	682c                	ld	a1,80(s0)
    80200224:	00001517          	auipc	a0,0x1
    80200228:	a0450513          	addi	a0,a0,-1532 # 80200c28 <etext+0x208>
    8020022c:	e3fff0ef          	jal	8020006a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200230:	6c2c                	ld	a1,88(s0)
    80200232:	00001517          	auipc	a0,0x1
    80200236:	a0e50513          	addi	a0,a0,-1522 # 80200c40 <etext+0x220>
    8020023a:	e31ff0ef          	jal	8020006a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    8020023e:	702c                	ld	a1,96(s0)
    80200240:	00001517          	auipc	a0,0x1
    80200244:	a1850513          	addi	a0,a0,-1512 # 80200c58 <etext+0x238>
    80200248:	e23ff0ef          	jal	8020006a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020024c:	742c                	ld	a1,104(s0)
    8020024e:	00001517          	auipc	a0,0x1
    80200252:	a2250513          	addi	a0,a0,-1502 # 80200c70 <etext+0x250>
    80200256:	e15ff0ef          	jal	8020006a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025a:	782c                	ld	a1,112(s0)
    8020025c:	00001517          	auipc	a0,0x1
    80200260:	a2c50513          	addi	a0,a0,-1492 # 80200c88 <etext+0x268>
    80200264:	e07ff0ef          	jal	8020006a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    80200268:	7c2c                	ld	a1,120(s0)
    8020026a:	00001517          	auipc	a0,0x1
    8020026e:	a3650513          	addi	a0,a0,-1482 # 80200ca0 <etext+0x280>
    80200272:	df9ff0ef          	jal	8020006a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200276:	604c                	ld	a1,128(s0)
    80200278:	00001517          	auipc	a0,0x1
    8020027c:	a4050513          	addi	a0,a0,-1472 # 80200cb8 <etext+0x298>
    80200280:	debff0ef          	jal	8020006a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200284:	644c                	ld	a1,136(s0)
    80200286:	00001517          	auipc	a0,0x1
    8020028a:	a4a50513          	addi	a0,a0,-1462 # 80200cd0 <etext+0x2b0>
    8020028e:	dddff0ef          	jal	8020006a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200292:	684c                	ld	a1,144(s0)
    80200294:	00001517          	auipc	a0,0x1
    80200298:	a5450513          	addi	a0,a0,-1452 # 80200ce8 <etext+0x2c8>
    8020029c:	dcfff0ef          	jal	8020006a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a0:	6c4c                	ld	a1,152(s0)
    802002a2:	00001517          	auipc	a0,0x1
    802002a6:	a5e50513          	addi	a0,a0,-1442 # 80200d00 <etext+0x2e0>
    802002aa:	dc1ff0ef          	jal	8020006a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002ae:	704c                	ld	a1,160(s0)
    802002b0:	00001517          	auipc	a0,0x1
    802002b4:	a6850513          	addi	a0,a0,-1432 # 80200d18 <etext+0x2f8>
    802002b8:	db3ff0ef          	jal	8020006a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002bc:	744c                	ld	a1,168(s0)
    802002be:	00001517          	auipc	a0,0x1
    802002c2:	a7250513          	addi	a0,a0,-1422 # 80200d30 <etext+0x310>
    802002c6:	da5ff0ef          	jal	8020006a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002ca:	784c                	ld	a1,176(s0)
    802002cc:	00001517          	auipc	a0,0x1
    802002d0:	a7c50513          	addi	a0,a0,-1412 # 80200d48 <etext+0x328>
    802002d4:	d97ff0ef          	jal	8020006a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002d8:	7c4c                	ld	a1,184(s0)
    802002da:	00001517          	auipc	a0,0x1
    802002de:	a8650513          	addi	a0,a0,-1402 # 80200d60 <etext+0x340>
    802002e2:	d89ff0ef          	jal	8020006a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002e6:	606c                	ld	a1,192(s0)
    802002e8:	00001517          	auipc	a0,0x1
    802002ec:	a9050513          	addi	a0,a0,-1392 # 80200d78 <etext+0x358>
    802002f0:	d7bff0ef          	jal	8020006a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f4:	646c                	ld	a1,200(s0)
    802002f6:	00001517          	auipc	a0,0x1
    802002fa:	a9a50513          	addi	a0,a0,-1382 # 80200d90 <etext+0x370>
    802002fe:	d6dff0ef          	jal	8020006a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200302:	686c                	ld	a1,208(s0)
    80200304:	00001517          	auipc	a0,0x1
    80200308:	aa450513          	addi	a0,a0,-1372 # 80200da8 <etext+0x388>
    8020030c:	d5fff0ef          	jal	8020006a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200310:	6c6c                	ld	a1,216(s0)
    80200312:	00001517          	auipc	a0,0x1
    80200316:	aae50513          	addi	a0,a0,-1362 # 80200dc0 <etext+0x3a0>
    8020031a:	d51ff0ef          	jal	8020006a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    8020031e:	706c                	ld	a1,224(s0)
    80200320:	00001517          	auipc	a0,0x1
    80200324:	ab850513          	addi	a0,a0,-1352 # 80200dd8 <etext+0x3b8>
    80200328:	d43ff0ef          	jal	8020006a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020032c:	746c                	ld	a1,232(s0)
    8020032e:	00001517          	auipc	a0,0x1
    80200332:	ac250513          	addi	a0,a0,-1342 # 80200df0 <etext+0x3d0>
    80200336:	d35ff0ef          	jal	8020006a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033a:	786c                	ld	a1,240(s0)
    8020033c:	00001517          	auipc	a0,0x1
    80200340:	acc50513          	addi	a0,a0,-1332 # 80200e08 <etext+0x3e8>
    80200344:	d27ff0ef          	jal	8020006a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200348:	7c6c                	ld	a1,248(s0)
}
    8020034a:	6402                	ld	s0,0(sp)
    8020034c:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034e:	00001517          	auipc	a0,0x1
    80200352:	ad250513          	addi	a0,a0,-1326 # 80200e20 <etext+0x400>
}
    80200356:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200358:	bb09                	j	8020006a <cprintf>

000000008020035a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {  //定义了一个返回值为 void 的函数 print_trapframe，它接收一个指向 struct trapframe 类型的指针 tf。trapframe 是保存中断或异常发生时 CPU 状态的结构，通常包含寄存器、程序计数器等重要信息。
    8020035a:	1141                	addi	sp,sp,-16
    8020035c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);//通过 cprintf 打印出传递的 trapframe 结构体的地址。%p 是一个格式化输出符号，用来打印指针（内存地址）
    8020035e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {  //定义了一个返回值为 void 的函数 print_trapframe，它接收一个指向 struct trapframe 类型的指针 tf。trapframe 是保存中断或异常发生时 CPU 状态的结构，通常包含寄存器、程序计数器等重要信息。
    80200360:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);//通过 cprintf 打印出传递的 trapframe 结构体的地址。%p 是一个格式化输出符号，用来打印指针（内存地址）
    80200362:	00001517          	auipc	a0,0x1
    80200366:	ad650513          	addi	a0,a0,-1322 # 80200e38 <etext+0x418>
void print_trapframe(struct trapframe *tf) {  //定义了一个返回值为 void 的函数 print_trapframe，它接收一个指向 struct trapframe 类型的指针 tf。trapframe 是保存中断或异常发生时 CPU 状态的结构，通常包含寄存器、程序计数器等重要信息。
    8020036a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);//通过 cprintf 打印出传递的 trapframe 结构体的地址。%p 是一个格式化输出符号，用来打印指针（内存地址）
    8020036c:	cffff0ef          	jal	8020006a <cprintf>
    print_regs(&tf->gpr);//调用了 print_regs 函数，传递了 tf->gpr 的地址，gpr 是 trapframe 中保存的一般寄存器（General Purpose Registers）的部分，通过这个函数来打印出各个寄存器的值。
    80200370:	8522                	mv	a0,s0
    80200372:	e1dff0ef          	jal	8020018e <print_regs>
    cprintf("  status   0x%08x\n", tf->status);//打印出 trapframe 结构体中的 status 字段，通常表示CPU的状态寄存器，控制着中断、异常处理等。0x%08x 是用16进制的格式输出，并固定输出8位数（不足的前面补0）。
    80200376:	10043583          	ld	a1,256(s0)
    8020037a:	00001517          	auipc	a0,0x1
    8020037e:	ad650513          	addi	a0,a0,-1322 # 80200e50 <etext+0x430>
    80200382:	ce9ff0ef          	jal	8020006a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);//打印出 trapframe 中的 epc 字段，epc 是异常发生时的程序计数器（Exception Program Counter），它指向导致异常的指令地址。
    80200386:	10843583          	ld	a1,264(s0)
    8020038a:	00001517          	auipc	a0,0x1
    8020038e:	ade50513          	addi	a0,a0,-1314 # 80200e68 <etext+0x448>
    80200392:	cd9ff0ef          	jal	8020006a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);//打印出 badvaddr 字段，badvaddr 是发生异常的错误地址（Bad Virtual Address），通常在内存访问异常（如页错误）时使用。
    80200396:	11043583          	ld	a1,272(s0)
    8020039a:	00001517          	auipc	a0,0x1
    8020039e:	ae650513          	addi	a0,a0,-1306 # 80200e80 <etext+0x460>
    802003a2:	cc9ff0ef          	jal	8020006a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);//打印出 cause 字段，表示导致异常的原因码（Cause Register），通常指出是哪种中断或异常触发的。
    802003a6:	11843583          	ld	a1,280(s0)
}
    802003aa:	6402                	ld	s0,0(sp)
    802003ac:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);//打印出 cause 字段，表示导致异常的原因码（Cause Register），通常指出是哪种中断或异常触发的。
    802003ae:	00001517          	auipc	a0,0x1
    802003b2:	aea50513          	addi	a0,a0,-1302 # 80200e98 <etext+0x478>
}
    802003b6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);//打印出 cause 字段，表示导致异常的原因码（Cause Register），通常指出是哪种中断或异常触发的。
    802003b8:	b94d                	j	8020006a <cprintf>

00000000802003ba <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
    802003ba:	11853783          	ld	a5,280(a0)
    802003be:	472d                	li	a4,11
    802003c0:	0786                	slli	a5,a5,0x1
    802003c2:	8385                	srli	a5,a5,0x1
    802003c4:	08f76263          	bltu	a4,a5,80200448 <interrupt_handler+0x8e>
    802003c8:	00001717          	auipc	a4,0x1
    802003cc:	cdc70713          	addi	a4,a4,-804 # 802010a4 <etext+0x684>
    802003d0:	078a                	slli	a5,a5,0x2
    802003d2:	97ba                	add	a5,a5,a4
    802003d4:	439c                	lw	a5,0(a5)
    802003d6:	97ba                	add	a5,a5,a4
    802003d8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003da:	00001517          	auipc	a0,0x1
    802003de:	b3650513          	addi	a0,a0,-1226 # 80200f10 <etext+0x4f0>
    802003e2:	b161                	j	8020006a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e4:	00001517          	auipc	a0,0x1
    802003e8:	b0c50513          	addi	a0,a0,-1268 # 80200ef0 <etext+0x4d0>
    802003ec:	b9bd                	j	8020006a <cprintf>
            cprintf("User software interrupt\n");
    802003ee:	00001517          	auipc	a0,0x1
    802003f2:	ac250513          	addi	a0,a0,-1342 # 80200eb0 <etext+0x490>
    802003f6:	b995                	j	8020006a <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003f8:	00001517          	auipc	a0,0x1
    802003fc:	ad850513          	addi	a0,a0,-1320 # 80200ed0 <etext+0x4b0>
    80200400:	b1ad                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200402:	1141                	addi	sp,sp,-16
    80200404:	e022                	sd	s0,0(sp)
    80200406:	e406                	sd	ra,8(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();//这个代码的原型在clock.h中定义
    80200408:	d55ff0ef          	jal	8020015c <clock_set_next_event>
            ticks++;//也是在clock.h中被声明为volatile size_t ticks;volatile 是用来告诉编译器这个变量的值可能会被程序以外的因素改变。例如，它可能被硬件、异步事件、或其他线程改变。size_t: 这是一个无符号整型数据类型，用来表示对象的大小
    8020040c:	00004797          	auipc	a5,0x4
    80200410:	c0478793          	addi	a5,a5,-1020 # 80204010 <ticks>
    80200414:	6398                	ld	a4,0(a5)
    80200416:	00004417          	auipc	s0,0x4
    8020041a:	c0240413          	addi	s0,s0,-1022 # 80204018 <num>
    8020041e:	0705                	addi	a4,a4,1
    80200420:	e398                	sd	a4,0(a5)
            if(ticks%TICK_NUM==0){
    80200422:	639c                	ld	a5,0(a5)
    80200424:	06400713          	li	a4,100
    80200428:	02e7f7b3          	remu	a5,a5,a4
    8020042c:	cf99                	beqz	a5,8020044a <interrupt_handler+0x90>
            print_ticks();
            num++;//就在trap.c中就有定义
            }
            if(num==10){
    8020042e:	6018                	ld	a4,0(s0)
    80200430:	47a9                	li	a5,10
    80200432:	02f70863          	beq	a4,a5,80200462 <interrupt_handler+0xa8>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200436:	60a2                	ld	ra,8(sp)
    80200438:	6402                	ld	s0,0(sp)
    8020043a:	0141                	addi	sp,sp,16
    8020043c:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    8020043e:	00001517          	auipc	a0,0x1
    80200442:	b0250513          	addi	a0,a0,-1278 # 80200f40 <etext+0x520>
    80200446:	b115                	j	8020006a <cprintf>
            print_trapframe(tf);
    80200448:	bf09                	j	8020035a <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020044a:	06400593          	li	a1,100
    8020044e:	00001517          	auipc	a0,0x1
    80200452:	ae250513          	addi	a0,a0,-1310 # 80200f30 <etext+0x510>
    80200456:	c15ff0ef          	jal	8020006a <cprintf>
            num++;//就在trap.c中就有定义
    8020045a:	601c                	ld	a5,0(s0)
    8020045c:	0785                	addi	a5,a5,1
    8020045e:	e01c                	sd	a5,0(s0)
    80200460:	b7f9                	j	8020042e <interrupt_handler+0x74>
}
    80200462:	6402                	ld	s0,0(sp)
    80200464:	60a2                	ld	ra,8(sp)
    80200466:	0141                	addi	sp,sp,16
            sbi_shutdown();//在实验指导书里面写的是shut_down,但是在sbi.c中这个函数英国被命名为sbi_shutdown
    80200468:	a3ad                	j	802009d2 <sbi_shutdown>

000000008020046a <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020046a:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    8020046e:	1141                	addi	sp,sp,-16
    80200470:	e022                	sd	s0,0(sp)
    80200472:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
    80200474:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    80200476:	842a                	mv	s0,a0
    switch (tf->cause) {
    80200478:	04e78663          	beq	a5,a4,802004c4 <exception_handler+0x5a>
    8020047c:	02f76c63          	bltu	a4,a5,802004b4 <exception_handler+0x4a>
    80200480:	4709                	li	a4,2
    80200482:	02e79563          	bne	a5,a4,802004ac <exception_handler+0x42>
            
             *(2)输出异常指令地址
            
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception type:Illegal instruction\n");
    80200486:	00001517          	auipc	a0,0x1
    8020048a:	ada50513          	addi	a0,a0,-1318 # 80200f60 <etext+0x540>
    8020048e:	bddff0ef          	jal	8020006a <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n",tf->epc);
    80200492:	10843583          	ld	a1,264(s0)
    80200496:	00001517          	auipc	a0,0x1
    8020049a:	af250513          	addi	a0,a0,-1294 # 80200f88 <etext+0x568>
    8020049e:	bcdff0ef          	jal	8020006a <cprintf>
             tf->epc+=4;//恢复处理，跳过触发异常的指令
    802004a2:	10843783          	ld	a5,264(s0)
    802004a6:	0791                	addi	a5,a5,4
    802004a8:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004ac:	60a2                	ld	ra,8(sp)
    802004ae:	6402                	ld	s0,0(sp)
    802004b0:	0141                	addi	sp,sp,16
    802004b2:	8082                	ret
    switch (tf->cause) {
    802004b4:	17f1                	addi	a5,a5,-4
    802004b6:	471d                	li	a4,7
    802004b8:	fef77ae3          	bgeu	a4,a5,802004ac <exception_handler+0x42>
}
    802004bc:	6402                	ld	s0,0(sp)
    802004be:	60a2                	ld	ra,8(sp)
    802004c0:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004c2:	bd61                	j	8020035a <print_trapframe>
            cprintf("Exception type: breakpoint\n");
    802004c4:	00001517          	auipc	a0,0x1
    802004c8:	aec50513          	addi	a0,a0,-1300 # 80200fb0 <etext+0x590>
    802004cc:	b9fff0ef          	jal	8020006a <cprintf>
            cprintf("ebreak caught at 0x%08x\n",tf->epc);
    802004d0:	10843583          	ld	a1,264(s0)
    802004d4:	00001517          	auipc	a0,0x1
    802004d8:	afc50513          	addi	a0,a0,-1284 # 80200fd0 <etext+0x5b0>
    802004dc:	b8fff0ef          	jal	8020006a <cprintf>
            tf->epc+=2;//恢复处理，跳过触发异常的指令
    802004e0:	10843783          	ld	a5,264(s0)
}
    802004e4:	60a2                	ld	ra,8(sp)
            tf->epc+=2;//恢复处理，跳过触发异常的指令
    802004e6:	0789                	addi	a5,a5,2
    802004e8:	10f43423          	sd	a5,264(s0)
}
    802004ec:	6402                	ld	s0,0(sp)
    802004ee:	0141                	addi	sp,sp,16
    802004f0:	8082                	ret

00000000802004f2 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004f2:	11853783          	ld	a5,280(a0)
    802004f6:	0007c363          	bltz	a5,802004fc <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802004fa:	bf85                	j	8020046a <exception_handler>
        interrupt_handler(tf);
    802004fc:	bd7d                	j	802003ba <interrupt_handler>
	...

0000000080200500 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200500:	14011073          	csrw	sscratch,sp
    80200504:	712d                	addi	sp,sp,-288
    80200506:	e002                	sd	zero,0(sp)
    80200508:	e406                	sd	ra,8(sp)
    8020050a:	ec0e                	sd	gp,24(sp)
    8020050c:	f012                	sd	tp,32(sp)
    8020050e:	f416                	sd	t0,40(sp)
    80200510:	f81a                	sd	t1,48(sp)
    80200512:	fc1e                	sd	t2,56(sp)
    80200514:	e0a2                	sd	s0,64(sp)
    80200516:	e4a6                	sd	s1,72(sp)
    80200518:	e8aa                	sd	a0,80(sp)
    8020051a:	ecae                	sd	a1,88(sp)
    8020051c:	f0b2                	sd	a2,96(sp)
    8020051e:	f4b6                	sd	a3,104(sp)
    80200520:	f8ba                	sd	a4,112(sp)
    80200522:	fcbe                	sd	a5,120(sp)
    80200524:	e142                	sd	a6,128(sp)
    80200526:	e546                	sd	a7,136(sp)
    80200528:	e94a                	sd	s2,144(sp)
    8020052a:	ed4e                	sd	s3,152(sp)
    8020052c:	f152                	sd	s4,160(sp)
    8020052e:	f556                	sd	s5,168(sp)
    80200530:	f95a                	sd	s6,176(sp)
    80200532:	fd5e                	sd	s7,184(sp)
    80200534:	e1e2                	sd	s8,192(sp)
    80200536:	e5e6                	sd	s9,200(sp)
    80200538:	e9ea                	sd	s10,208(sp)
    8020053a:	edee                	sd	s11,216(sp)
    8020053c:	f1f2                	sd	t3,224(sp)
    8020053e:	f5f6                	sd	t4,232(sp)
    80200540:	f9fa                	sd	t5,240(sp)
    80200542:	fdfe                	sd	t6,248(sp)
    80200544:	14001473          	csrrw	s0,sscratch,zero
    80200548:	100024f3          	csrr	s1,sstatus
    8020054c:	14102973          	csrr	s2,sepc
    80200550:	143029f3          	csrr	s3,stval
    80200554:	14202a73          	csrr	s4,scause
    80200558:	e822                	sd	s0,16(sp)
    8020055a:	e226                	sd	s1,256(sp)
    8020055c:	e64a                	sd	s2,264(sp)
    8020055e:	ea4e                	sd	s3,272(sp)
    80200560:	ee52                	sd	s4,280(sp)

    move  a0, sp
    80200562:	850a                	mv	a0,sp
    jal trap
    80200564:	f8fff0ef          	jal	802004f2 <trap>

0000000080200568 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200568:	6492                	ld	s1,256(sp)
    8020056a:	6932                	ld	s2,264(sp)
    8020056c:	10049073          	csrw	sstatus,s1
    80200570:	14191073          	csrw	sepc,s2
    80200574:	60a2                	ld	ra,8(sp)
    80200576:	61e2                	ld	gp,24(sp)
    80200578:	7202                	ld	tp,32(sp)
    8020057a:	72a2                	ld	t0,40(sp)
    8020057c:	7342                	ld	t1,48(sp)
    8020057e:	73e2                	ld	t2,56(sp)
    80200580:	6406                	ld	s0,64(sp)
    80200582:	64a6                	ld	s1,72(sp)
    80200584:	6546                	ld	a0,80(sp)
    80200586:	65e6                	ld	a1,88(sp)
    80200588:	7606                	ld	a2,96(sp)
    8020058a:	76a6                	ld	a3,104(sp)
    8020058c:	7746                	ld	a4,112(sp)
    8020058e:	77e6                	ld	a5,120(sp)
    80200590:	680a                	ld	a6,128(sp)
    80200592:	68aa                	ld	a7,136(sp)
    80200594:	694a                	ld	s2,144(sp)
    80200596:	69ea                	ld	s3,152(sp)
    80200598:	7a0a                	ld	s4,160(sp)
    8020059a:	7aaa                	ld	s5,168(sp)
    8020059c:	7b4a                	ld	s6,176(sp)
    8020059e:	7bea                	ld	s7,184(sp)
    802005a0:	6c0e                	ld	s8,192(sp)
    802005a2:	6cae                	ld	s9,200(sp)
    802005a4:	6d4e                	ld	s10,208(sp)
    802005a6:	6dee                	ld	s11,216(sp)
    802005a8:	7e0e                	ld	t3,224(sp)
    802005aa:	7eae                	ld	t4,232(sp)
    802005ac:	7f4e                	ld	t5,240(sp)
    802005ae:	7fee                	ld	t6,248(sp)
    802005b0:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005b2:	10200073          	sret

00000000802005b6 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005b6:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005ba:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005bc:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005c0:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005c2:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005c6:	f022                	sd	s0,32(sp)
    802005c8:	ec26                	sd	s1,24(sp)
    802005ca:	e84a                	sd	s2,16(sp)
    802005cc:	f406                	sd	ra,40(sp)
    802005ce:	84aa                	mv	s1,a0
    802005d0:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005d2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005d6:	2a01                	sext.w	s4,s4
    if (num >= base) {
    802005d8:	05067063          	bgeu	a2,a6,80200618 <printnum+0x62>
    802005dc:	e44e                	sd	s3,8(sp)
    802005de:	89be                	mv	s3,a5
        while (-- width > 0)
    802005e0:	4785                	li	a5,1
    802005e2:	00e7d763          	bge	a5,a4,802005f0 <printnum+0x3a>
            putch(padc, putdat);
    802005e6:	85ca                	mv	a1,s2
    802005e8:	854e                	mv	a0,s3
        while (-- width > 0)
    802005ea:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802005ec:	9482                	jalr	s1
        while (-- width > 0)
    802005ee:	fc65                	bnez	s0,802005e6 <printnum+0x30>
    802005f0:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802005f2:	1a02                	slli	s4,s4,0x20
    802005f4:	020a5a13          	srli	s4,s4,0x20
    802005f8:	00001797          	auipc	a5,0x1
    802005fc:	9f878793          	addi	a5,a5,-1544 # 80200ff0 <etext+0x5d0>
    80200600:	97d2                	add	a5,a5,s4
}
    80200602:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200604:	0007c503          	lbu	a0,0(a5)
}
    80200608:	70a2                	ld	ra,40(sp)
    8020060a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020060c:	85ca                	mv	a1,s2
    8020060e:	87a6                	mv	a5,s1
}
    80200610:	6942                	ld	s2,16(sp)
    80200612:	64e2                	ld	s1,24(sp)
    80200614:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200616:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    80200618:	03065633          	divu	a2,a2,a6
    8020061c:	8722                	mv	a4,s0
    8020061e:	f99ff0ef          	jal	802005b6 <printnum>
    80200622:	bfc1                	j	802005f2 <printnum+0x3c>

0000000080200624 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200624:	7119                	addi	sp,sp,-128
    80200626:	f4a6                	sd	s1,104(sp)
    80200628:	f0ca                	sd	s2,96(sp)
    8020062a:	ecce                	sd	s3,88(sp)
    8020062c:	e8d2                	sd	s4,80(sp)
    8020062e:	e4d6                	sd	s5,72(sp)
    80200630:	e0da                	sd	s6,64(sp)
    80200632:	f862                	sd	s8,48(sp)
    80200634:	fc86                	sd	ra,120(sp)
    80200636:	f8a2                	sd	s0,112(sp)
    80200638:	fc5e                	sd	s7,56(sp)
    8020063a:	f466                	sd	s9,40(sp)
    8020063c:	f06a                	sd	s10,32(sp)
    8020063e:	ec6e                	sd	s11,24(sp)
    80200640:	892a                	mv	s2,a0
    80200642:	84ae                	mv	s1,a1
    80200644:	8c32                	mv	s8,a2
    80200646:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200648:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    8020064c:	05500b13          	li	s6,85
    80200650:	00001a97          	auipc	s5,0x1
    80200654:	a84a8a93          	addi	s5,s5,-1404 # 802010d4 <etext+0x6b4>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200658:	000c4503          	lbu	a0,0(s8)
    8020065c:	001c0413          	addi	s0,s8,1
    80200660:	01350a63          	beq	a0,s3,80200674 <vprintfmt+0x50>
            if (ch == '\0') {
    80200664:	cd0d                	beqz	a0,8020069e <vprintfmt+0x7a>
            putch(ch, putdat);
    80200666:	85a6                	mv	a1,s1
    80200668:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020066a:	00044503          	lbu	a0,0(s0)
    8020066e:	0405                	addi	s0,s0,1
    80200670:	ff351ae3          	bne	a0,s3,80200664 <vprintfmt+0x40>
        char padc = ' ';
    80200674:	02000d93          	li	s11,32
        lflag = altflag = 0;
    80200678:	4b81                	li	s7,0
    8020067a:	4601                	li	a2,0
        width = precision = -1;
    8020067c:	5d7d                	li	s10,-1
    8020067e:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
    80200680:	00044683          	lbu	a3,0(s0)
    80200684:	00140c13          	addi	s8,s0,1
    80200688:	fdd6859b          	addiw	a1,a3,-35
    8020068c:	0ff5f593          	zext.b	a1,a1
    80200690:	02bb6663          	bltu	s6,a1,802006bc <vprintfmt+0x98>
    80200694:	058a                	slli	a1,a1,0x2
    80200696:	95d6                	add	a1,a1,s5
    80200698:	4198                	lw	a4,0(a1)
    8020069a:	9756                	add	a4,a4,s5
    8020069c:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    8020069e:	70e6                	ld	ra,120(sp)
    802006a0:	7446                	ld	s0,112(sp)
    802006a2:	74a6                	ld	s1,104(sp)
    802006a4:	7906                	ld	s2,96(sp)
    802006a6:	69e6                	ld	s3,88(sp)
    802006a8:	6a46                	ld	s4,80(sp)
    802006aa:	6aa6                	ld	s5,72(sp)
    802006ac:	6b06                	ld	s6,64(sp)
    802006ae:	7be2                	ld	s7,56(sp)
    802006b0:	7c42                	ld	s8,48(sp)
    802006b2:	7ca2                	ld	s9,40(sp)
    802006b4:	7d02                	ld	s10,32(sp)
    802006b6:	6de2                	ld	s11,24(sp)
    802006b8:	6109                	addi	sp,sp,128
    802006ba:	8082                	ret
            putch('%', putdat);
    802006bc:	85a6                	mv	a1,s1
    802006be:	02500513          	li	a0,37
    802006c2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802006c4:	fff44703          	lbu	a4,-1(s0)
    802006c8:	02500793          	li	a5,37
    802006cc:	8c22                	mv	s8,s0
    802006ce:	f8f705e3          	beq	a4,a5,80200658 <vprintfmt+0x34>
    802006d2:	02500713          	li	a4,37
    802006d6:	ffec4783          	lbu	a5,-2(s8)
    802006da:	1c7d                	addi	s8,s8,-1
    802006dc:	fee79de3          	bne	a5,a4,802006d6 <vprintfmt+0xb2>
    802006e0:	bfa5                	j	80200658 <vprintfmt+0x34>
                ch = *fmt;
    802006e2:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
    802006e6:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
    802006e8:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
    802006ec:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
    802006f0:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
    802006f4:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
    802006f6:	02b76563          	bltu	a4,a1,80200720 <vprintfmt+0xfc>
    802006fa:	4525                	li	a0,9
                ch = *fmt;
    802006fc:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
    80200700:	002d171b          	slliw	a4,s10,0x2
    80200704:	01a7073b          	addw	a4,a4,s10
    80200708:	0017171b          	slliw	a4,a4,0x1
    8020070c:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
    8020070e:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
    80200712:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    80200714:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
    80200718:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
    8020071c:	feb570e3          	bgeu	a0,a1,802006fc <vprintfmt+0xd8>
            if (width < 0)
    80200720:	f60cd0e3          	bgez	s9,80200680 <vprintfmt+0x5c>
                width = precision, precision = -1;
    80200724:	8cea                	mv	s9,s10
    80200726:	5d7d                	li	s10,-1
    80200728:	bfa1                	j	80200680 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
    8020072a:	8db6                	mv	s11,a3
    8020072c:	8462                	mv	s0,s8
    8020072e:	bf89                	j	80200680 <vprintfmt+0x5c>
    80200730:	8462                	mv	s0,s8
            altflag = 1;
    80200732:	4b85                	li	s7,1
            goto reswitch;
    80200734:	b7b1                	j	80200680 <vprintfmt+0x5c>
    if (lflag >= 2) {
    80200736:	4785                	li	a5,1
            precision = va_arg(ap, int);
    80200738:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    8020073c:	00c7c463          	blt	a5,a2,80200744 <vprintfmt+0x120>
    else if (lflag) {
    80200740:	1a060163          	beqz	a2,802008e2 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
    80200744:	000a3603          	ld	a2,0(s4)
    80200748:	46c1                	li	a3,16
    8020074a:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
    8020074c:	000d879b          	sext.w	a5,s11
    80200750:	8766                	mv	a4,s9
    80200752:	85a6                	mv	a1,s1
    80200754:	854a                	mv	a0,s2
    80200756:	e61ff0ef          	jal	802005b6 <printnum>
            break;
    8020075a:	bdfd                	j	80200658 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
    8020075c:	000a2503          	lw	a0,0(s4)
    80200760:	85a6                	mv	a1,s1
    80200762:	0a21                	addi	s4,s4,8
    80200764:	9902                	jalr	s2
            break;
    80200766:	bdcd                	j	80200658 <vprintfmt+0x34>
    if (lflag >= 2) {
    80200768:	4785                	li	a5,1
            precision = va_arg(ap, int);
    8020076a:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    8020076e:	00c7c463          	blt	a5,a2,80200776 <vprintfmt+0x152>
    else if (lflag) {
    80200772:	16060363          	beqz	a2,802008d8 <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
    80200776:	000a3603          	ld	a2,0(s4)
    8020077a:	46a9                	li	a3,10
    8020077c:	8a3a                	mv	s4,a4
    8020077e:	b7f9                	j	8020074c <vprintfmt+0x128>
            putch('0', putdat);
    80200780:	85a6                	mv	a1,s1
    80200782:	03000513          	li	a0,48
    80200786:	9902                	jalr	s2
            putch('x', putdat);
    80200788:	85a6                	mv	a1,s1
    8020078a:	07800513          	li	a0,120
    8020078e:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200790:	000a3603          	ld	a2,0(s4)
            goto number;
    80200794:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    80200796:	0a21                	addi	s4,s4,8
            goto number;
    80200798:	bf55                	j	8020074c <vprintfmt+0x128>
            putch(ch, putdat);
    8020079a:	85a6                	mv	a1,s1
    8020079c:	02500513          	li	a0,37
    802007a0:	9902                	jalr	s2
            break;
    802007a2:	bd5d                	j	80200658 <vprintfmt+0x34>
            precision = va_arg(ap, int);
    802007a4:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    802007a8:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
    802007aa:	0a21                	addi	s4,s4,8
            goto process_precision;
    802007ac:	bf95                	j	80200720 <vprintfmt+0xfc>
    if (lflag >= 2) {
    802007ae:	4785                	li	a5,1
            precision = va_arg(ap, int);
    802007b0:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    802007b4:	00c7c463          	blt	a5,a2,802007bc <vprintfmt+0x198>
    else if (lflag) {
    802007b8:	10060b63          	beqz	a2,802008ce <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
    802007bc:	000a3603          	ld	a2,0(s4)
    802007c0:	46a1                	li	a3,8
    802007c2:	8a3a                	mv	s4,a4
    802007c4:	b761                	j	8020074c <vprintfmt+0x128>
            if (width < 0)
    802007c6:	fffcc793          	not	a5,s9
    802007ca:	97fd                	srai	a5,a5,0x3f
    802007cc:	00fcf7b3          	and	a5,s9,a5
    802007d0:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
    802007d4:	8462                	mv	s0,s8
            goto reswitch;
    802007d6:	b56d                	j	80200680 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007d8:	000a3403          	ld	s0,0(s4)
    802007dc:	008a0793          	addi	a5,s4,8
    802007e0:	e43e                	sd	a5,8(sp)
    802007e2:	12040063          	beqz	s0,80200902 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
    802007e6:	0d905963          	blez	s9,802008b8 <vprintfmt+0x294>
    802007ea:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007ee:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
    802007f2:	12fd9763          	bne	s11,a5,80200920 <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007f6:	00044783          	lbu	a5,0(s0)
    802007fa:	0007851b          	sext.w	a0,a5
    802007fe:	cb9d                	beqz	a5,80200834 <vprintfmt+0x210>
    80200800:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200802:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200806:	000d4563          	bltz	s10,80200810 <vprintfmt+0x1ec>
    8020080a:	3d7d                	addiw	s10,s10,-1
    8020080c:	028d0263          	beq	s10,s0,80200830 <vprintfmt+0x20c>
                    putch('?', putdat);
    80200810:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200812:	0c0b8d63          	beqz	s7,802008ec <vprintfmt+0x2c8>
    80200816:	3781                	addiw	a5,a5,-32
    80200818:	0cfdfa63          	bgeu	s11,a5,802008ec <vprintfmt+0x2c8>
                    putch('?', putdat);
    8020081c:	03f00513          	li	a0,63
    80200820:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200822:	000a4783          	lbu	a5,0(s4)
    80200826:	3cfd                	addiw	s9,s9,-1
    80200828:	0a05                	addi	s4,s4,1
    8020082a:	0007851b          	sext.w	a0,a5
    8020082e:	ffe1                	bnez	a5,80200806 <vprintfmt+0x1e2>
            for (; width > 0; width --) {
    80200830:	01905963          	blez	s9,80200842 <vprintfmt+0x21e>
                putch(' ', putdat);
    80200834:	85a6                	mv	a1,s1
    80200836:	02000513          	li	a0,32
            for (; width > 0; width --) {
    8020083a:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
    8020083c:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020083e:	fe0c9be3          	bnez	s9,80200834 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200842:	6a22                	ld	s4,8(sp)
    80200844:	bd11                	j	80200658 <vprintfmt+0x34>
    if (lflag >= 2) {
    80200846:	4785                	li	a5,1
            precision = va_arg(ap, int);
    80200848:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
    8020084c:	00c7c363          	blt	a5,a2,80200852 <vprintfmt+0x22e>
    else if (lflag) {
    80200850:	ce25                	beqz	a2,802008c8 <vprintfmt+0x2a4>
        return va_arg(*ap, long);
    80200852:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    80200856:	08044d63          	bltz	s0,802008f0 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
    8020085a:	8622                	mv	a2,s0
    8020085c:	8a5e                	mv	s4,s7
    8020085e:	46a9                	li	a3,10
    80200860:	b5f5                	j	8020074c <vprintfmt+0x128>
            if (err < 0) {
    80200862:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200866:	4619                	li	a2,6
            if (err < 0) {
    80200868:	41f7d71b          	sraiw	a4,a5,0x1f
    8020086c:	8fb9                	xor	a5,a5,a4
    8020086e:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200872:	02d64663          	blt	a2,a3,8020089e <vprintfmt+0x27a>
    80200876:	00369713          	slli	a4,a3,0x3
    8020087a:	00001797          	auipc	a5,0x1
    8020087e:	9b678793          	addi	a5,a5,-1610 # 80201230 <error_string>
    80200882:	97ba                	add	a5,a5,a4
    80200884:	639c                	ld	a5,0(a5)
    80200886:	cf81                	beqz	a5,8020089e <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
    80200888:	86be                	mv	a3,a5
    8020088a:	00000617          	auipc	a2,0x0
    8020088e:	79660613          	addi	a2,a2,1942 # 80201020 <etext+0x600>
    80200892:	85a6                	mv	a1,s1
    80200894:	854a                	mv	a0,s2
    80200896:	0e8000ef          	jal	8020097e <printfmt>
            err = va_arg(ap, int);
    8020089a:	0a21                	addi	s4,s4,8
    8020089c:	bb75                	j	80200658 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
    8020089e:	00000617          	auipc	a2,0x0
    802008a2:	77260613          	addi	a2,a2,1906 # 80201010 <etext+0x5f0>
    802008a6:	85a6                	mv	a1,s1
    802008a8:	854a                	mv	a0,s2
    802008aa:	0d4000ef          	jal	8020097e <printfmt>
            err = va_arg(ap, int);
    802008ae:	0a21                	addi	s4,s4,8
    802008b0:	b365                	j	80200658 <vprintfmt+0x34>
            lflag ++;
    802008b2:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
    802008b4:	8462                	mv	s0,s8
            goto reswitch;
    802008b6:	b3e9                	j	80200680 <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008b8:	00044783          	lbu	a5,0(s0)
    802008bc:	0007851b          	sext.w	a0,a5
    802008c0:	d3c9                	beqz	a5,80200842 <vprintfmt+0x21e>
    802008c2:	00140a13          	addi	s4,s0,1
    802008c6:	bf2d                	j	80200800 <vprintfmt+0x1dc>
        return va_arg(*ap, int);
    802008c8:	000a2403          	lw	s0,0(s4)
    802008cc:	b769                	j	80200856 <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
    802008ce:	000a6603          	lwu	a2,0(s4)
    802008d2:	46a1                	li	a3,8
    802008d4:	8a3a                	mv	s4,a4
    802008d6:	bd9d                	j	8020074c <vprintfmt+0x128>
    802008d8:	000a6603          	lwu	a2,0(s4)
    802008dc:	46a9                	li	a3,10
    802008de:	8a3a                	mv	s4,a4
    802008e0:	b5b5                	j	8020074c <vprintfmt+0x128>
    802008e2:	000a6603          	lwu	a2,0(s4)
    802008e6:	46c1                	li	a3,16
    802008e8:	8a3a                	mv	s4,a4
    802008ea:	b58d                	j	8020074c <vprintfmt+0x128>
                    putch(ch, putdat);
    802008ec:	9902                	jalr	s2
    802008ee:	bf15                	j	80200822 <vprintfmt+0x1fe>
                putch('-', putdat);
    802008f0:	85a6                	mv	a1,s1
    802008f2:	02d00513          	li	a0,45
    802008f6:	9902                	jalr	s2
                num = -(long long)num;
    802008f8:	40800633          	neg	a2,s0
    802008fc:	8a5e                	mv	s4,s7
    802008fe:	46a9                	li	a3,10
    80200900:	b5b1                	j	8020074c <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
    80200902:	01905663          	blez	s9,8020090e <vprintfmt+0x2ea>
    80200906:	02d00793          	li	a5,45
    8020090a:	04fd9263          	bne	s11,a5,8020094e <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020090e:	02800793          	li	a5,40
    80200912:	00000a17          	auipc	s4,0x0
    80200916:	6f7a0a13          	addi	s4,s4,1783 # 80201009 <etext+0x5e9>
    8020091a:	02800513          	li	a0,40
    8020091e:	b5cd                	j	80200800 <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200920:	85ea                	mv	a1,s10
    80200922:	8522                	mv	a0,s0
    80200924:	0ce000ef          	jal	802009f2 <strnlen>
    80200928:	40ac8cbb          	subw	s9,s9,a0
    8020092c:	01905963          	blez	s9,8020093e <vprintfmt+0x31a>
                    putch(padc, putdat);
    80200930:	2d81                	sext.w	s11,s11
    80200932:	85a6                	mv	a1,s1
    80200934:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200936:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
    80200938:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020093a:	fe0c9ce3          	bnez	s9,80200932 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020093e:	00044783          	lbu	a5,0(s0)
    80200942:	0007851b          	sext.w	a0,a5
    80200946:	ea079de3          	bnez	a5,80200800 <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020094a:	6a22                	ld	s4,8(sp)
    8020094c:	b331                	j	80200658 <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020094e:	85ea                	mv	a1,s10
    80200950:	00000517          	auipc	a0,0x0
    80200954:	6b850513          	addi	a0,a0,1720 # 80201008 <etext+0x5e8>
    80200958:	09a000ef          	jal	802009f2 <strnlen>
    8020095c:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
    80200960:	00000417          	auipc	s0,0x0
    80200964:	6a840413          	addi	s0,s0,1704 # 80201008 <etext+0x5e8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200968:	00000a17          	auipc	s4,0x0
    8020096c:	6a1a0a13          	addi	s4,s4,1697 # 80201009 <etext+0x5e9>
    80200970:	02800793          	li	a5,40
    80200974:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200978:	fb904ce3          	bgtz	s9,80200930 <vprintfmt+0x30c>
    8020097c:	b551                	j	80200800 <vprintfmt+0x1dc>

000000008020097e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020097e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200980:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200984:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200986:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200988:	ec06                	sd	ra,24(sp)
    8020098a:	f83a                	sd	a4,48(sp)
    8020098c:	fc3e                	sd	a5,56(sp)
    8020098e:	e0c2                	sd	a6,64(sp)
    80200990:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200992:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200994:	c91ff0ef          	jal	80200624 <vprintfmt>
}
    80200998:	60e2                	ld	ra,24(sp)
    8020099a:	6161                	addi	sp,sp,80
    8020099c:	8082                	ret

000000008020099e <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    8020099e:	4781                	li	a5,0
    802009a0:	00003717          	auipc	a4,0x3
    802009a4:	66873703          	ld	a4,1640(a4) # 80204008 <SBI_CONSOLE_PUTCHAR>
    802009a8:	88ba                	mv	a7,a4
    802009aa:	852a                	mv	a0,a0
    802009ac:	85be                	mv	a1,a5
    802009ae:	863e                	mv	a2,a5
    802009b0:	00000073          	ecall
    802009b4:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    802009b6:	8082                	ret

00000000802009b8 <sbi_set_timer>:
    __asm__ volatile (
    802009b8:	4781                	li	a5,0
    802009ba:	00003717          	auipc	a4,0x3
    802009be:	66673703          	ld	a4,1638(a4) # 80204020 <SBI_SET_TIMER>
    802009c2:	88ba                	mv	a7,a4
    802009c4:	852a                	mv	a0,a0
    802009c6:	85be                	mv	a1,a5
    802009c8:	863e                	mv	a2,a5
    802009ca:	00000073          	ecall
    802009ce:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    802009d0:	8082                	ret

00000000802009d2 <sbi_shutdown>:


void sbi_shutdown(void)
{
    802009d2:	ffffffff          	.word	0xffffffff
              __asm__ volatile(".word 0xFFFFFFFF");  // 触发非法指令异常
   __asm__ volatile("ebreak");  // 触发断点异常
    802009d6:	9002                	ebreak
    __asm__ volatile (
    802009d8:	4781                	li	a5,0
    802009da:	00003717          	auipc	a4,0x3
    802009de:	62673703          	ld	a4,1574(a4) # 80204000 <SBI_SHUTDOWN>
    802009e2:	88ba                	mv	a7,a4
    802009e4:	853e                	mv	a0,a5
    802009e6:	85be                	mv	a1,a5
    802009e8:	863e                	mv	a2,a5
    802009ea:	00000073          	ecall
    802009ee:	87aa                	mv	a5,a0
    sbi_call(SBI_SHUTDOWN,0,0,0);
}
    802009f0:	8082                	ret

00000000802009f2 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    802009f2:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    802009f4:	e589                	bnez	a1,802009fe <strnlen+0xc>
    802009f6:	a811                	j	80200a0a <strnlen+0x18>
        cnt ++;
    802009f8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    802009fa:	00f58863          	beq	a1,a5,80200a0a <strnlen+0x18>
    802009fe:	00f50733          	add	a4,a0,a5
    80200a02:	00074703          	lbu	a4,0(a4)
    80200a06:	fb6d                	bnez	a4,802009f8 <strnlen+0x6>
    80200a08:	85be                	mv	a1,a5
    }
    return cnt;
}
    80200a0a:	852e                	mv	a0,a1
    80200a0c:	8082                	ret

0000000080200a0e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a0e:	ca01                	beqz	a2,80200a1e <memset+0x10>
    80200a10:	962a                	add	a2,a2,a0
    char *p = s;
    80200a12:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a14:	0785                	addi	a5,a5,1
    80200a16:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a1a:	fef61de3          	bne	a2,a5,80200a14 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a1e:	8082                	ret
