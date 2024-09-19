
bin/kernel：     文件格式 elf64-littleriscv


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
    80200022:	1eb000ef          	jal	80200a0c <memset>

    cons_init();  // init the console
    80200026:	146000ef          	jal	8020016c <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	9f658593          	addi	a1,a1,-1546 # 80200a20 <etext+0x2>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a0e50513          	addi	a0,a0,-1522 # 80200a40 <etext+0x22>
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
    80200092:	596000ef          	jal	80200628 <vprintfmt>
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
    802000a4:	9a850513          	addi	a0,a0,-1624 # 80200a48 <etext+0x2a>
void print_kerninfo(void) {
    802000a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000aa:	fc1ff0ef          	jal	8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000ae:	00000597          	auipc	a1,0x0
    802000b2:	f5c58593          	addi	a1,a1,-164 # 8020000a <kern_init>
    802000b6:	00001517          	auipc	a0,0x1
    802000ba:	9b250513          	addi	a0,a0,-1614 # 80200a68 <etext+0x4a>
    802000be:	fadff0ef          	jal	8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c2:	00001597          	auipc	a1,0x1
    802000c6:	95c58593          	addi	a1,a1,-1700 # 80200a1e <etext>
    802000ca:	00001517          	auipc	a0,0x1
    802000ce:	9be50513          	addi	a0,a0,-1602 # 80200a88 <etext+0x6a>
    802000d2:	f99ff0ef          	jal	8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d6:	00004597          	auipc	a1,0x4
    802000da:	f3a58593          	addi	a1,a1,-198 # 80204010 <ticks>
    802000de:	00001517          	auipc	a0,0x1
    802000e2:	9ca50513          	addi	a0,a0,-1590 # 80200aa8 <etext+0x8a>
    802000e6:	f85ff0ef          	jal	8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ea:	00004597          	auipc	a1,0x4
    802000ee:	f3e58593          	addi	a1,a1,-194 # 80204028 <end>
    802000f2:	00001517          	auipc	a0,0x1
    802000f6:	9d650513          	addi	a0,a0,-1578 # 80200ac8 <etext+0xaa>
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
    80200122:	9ca50513          	addi	a0,a0,-1590 # 80200ae8 <etext+0xca>
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
    80200142:	07b000ef          	jal	802009bc <sbi_set_timer>
}
    80200146:	60a2                	ld	ra,8(sp)
    ticks = 0;
    80200148:	00004797          	auipc	a5,0x4
    8020014c:	ec07b423          	sd	zero,-312(a5) # 80204010 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200150:	00001517          	auipc	a0,0x1
    80200154:	9c850513          	addi	a0,a0,-1592 # 80200b18 <etext+0xfa>
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
    80200168:	0550006f          	j	802009bc <sbi_set_timer>

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
    80200172:	0310006f          	j	802009a2 <sbi_console_putchar>

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
    80200184:	38478793          	addi	a5,a5,900 # 80200504 <__alltraps>
    80200188:	10579073          	csrw	stvec,a5
    // 插入非法指令
    
    __asm__ volatile("unimp");  // 触发非法指令异常
    8020018c:	0000                	unimp

    // 插入断点指令
    __asm__ volatile("ebreak"); // 触发断点异常
    8020018e:	9002                	ebreak
}
    80200190:	8082                	ret

0000000080200192 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200192:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200194:	1141                	addi	sp,sp,-16
    80200196:	e022                	sd	s0,0(sp)
    80200198:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019a:	00001517          	auipc	a0,0x1
    8020019e:	99e50513          	addi	a0,a0,-1634 # 80200b38 <etext+0x11a>
void print_regs(struct pushregs *gpr) {
    802001a2:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a4:	ec7ff0ef          	jal	8020006a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a8:	640c                	ld	a1,8(s0)
    802001aa:	00001517          	auipc	a0,0x1
    802001ae:	9a650513          	addi	a0,a0,-1626 # 80200b50 <etext+0x132>
    802001b2:	eb9ff0ef          	jal	8020006a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b6:	680c                	ld	a1,16(s0)
    802001b8:	00001517          	auipc	a0,0x1
    802001bc:	9b050513          	addi	a0,a0,-1616 # 80200b68 <etext+0x14a>
    802001c0:	eabff0ef          	jal	8020006a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c4:	6c0c                	ld	a1,24(s0)
    802001c6:	00001517          	auipc	a0,0x1
    802001ca:	9ba50513          	addi	a0,a0,-1606 # 80200b80 <etext+0x162>
    802001ce:	e9dff0ef          	jal	8020006a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d2:	700c                	ld	a1,32(s0)
    802001d4:	00001517          	auipc	a0,0x1
    802001d8:	9c450513          	addi	a0,a0,-1596 # 80200b98 <etext+0x17a>
    802001dc:	e8fff0ef          	jal	8020006a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e0:	740c                	ld	a1,40(s0)
    802001e2:	00001517          	auipc	a0,0x1
    802001e6:	9ce50513          	addi	a0,a0,-1586 # 80200bb0 <etext+0x192>
    802001ea:	e81ff0ef          	jal	8020006a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ee:	780c                	ld	a1,48(s0)
    802001f0:	00001517          	auipc	a0,0x1
    802001f4:	9d850513          	addi	a0,a0,-1576 # 80200bc8 <etext+0x1aa>
    802001f8:	e73ff0ef          	jal	8020006a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001fc:	7c0c                	ld	a1,56(s0)
    802001fe:	00001517          	auipc	a0,0x1
    80200202:	9e250513          	addi	a0,a0,-1566 # 80200be0 <etext+0x1c2>
    80200206:	e65ff0ef          	jal	8020006a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020a:	602c                	ld	a1,64(s0)
    8020020c:	00001517          	auipc	a0,0x1
    80200210:	9ec50513          	addi	a0,a0,-1556 # 80200bf8 <etext+0x1da>
    80200214:	e57ff0ef          	jal	8020006a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200218:	642c                	ld	a1,72(s0)
    8020021a:	00001517          	auipc	a0,0x1
    8020021e:	9f650513          	addi	a0,a0,-1546 # 80200c10 <etext+0x1f2>
    80200222:	e49ff0ef          	jal	8020006a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200226:	682c                	ld	a1,80(s0)
    80200228:	00001517          	auipc	a0,0x1
    8020022c:	a0050513          	addi	a0,a0,-1536 # 80200c28 <etext+0x20a>
    80200230:	e3bff0ef          	jal	8020006a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200234:	6c2c                	ld	a1,88(s0)
    80200236:	00001517          	auipc	a0,0x1
    8020023a:	a0a50513          	addi	a0,a0,-1526 # 80200c40 <etext+0x222>
    8020023e:	e2dff0ef          	jal	8020006a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200242:	702c                	ld	a1,96(s0)
    80200244:	00001517          	auipc	a0,0x1
    80200248:	a1450513          	addi	a0,a0,-1516 # 80200c58 <etext+0x23a>
    8020024c:	e1fff0ef          	jal	8020006a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200250:	742c                	ld	a1,104(s0)
    80200252:	00001517          	auipc	a0,0x1
    80200256:	a1e50513          	addi	a0,a0,-1506 # 80200c70 <etext+0x252>
    8020025a:	e11ff0ef          	jal	8020006a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025e:	782c                	ld	a1,112(s0)
    80200260:	00001517          	auipc	a0,0x1
    80200264:	a2850513          	addi	a0,a0,-1496 # 80200c88 <etext+0x26a>
    80200268:	e03ff0ef          	jal	8020006a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    8020026c:	7c2c                	ld	a1,120(s0)
    8020026e:	00001517          	auipc	a0,0x1
    80200272:	a3250513          	addi	a0,a0,-1486 # 80200ca0 <etext+0x282>
    80200276:	df5ff0ef          	jal	8020006a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027a:	604c                	ld	a1,128(s0)
    8020027c:	00001517          	auipc	a0,0x1
    80200280:	a3c50513          	addi	a0,a0,-1476 # 80200cb8 <etext+0x29a>
    80200284:	de7ff0ef          	jal	8020006a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200288:	644c                	ld	a1,136(s0)
    8020028a:	00001517          	auipc	a0,0x1
    8020028e:	a4650513          	addi	a0,a0,-1466 # 80200cd0 <etext+0x2b2>
    80200292:	dd9ff0ef          	jal	8020006a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200296:	684c                	ld	a1,144(s0)
    80200298:	00001517          	auipc	a0,0x1
    8020029c:	a5050513          	addi	a0,a0,-1456 # 80200ce8 <etext+0x2ca>
    802002a0:	dcbff0ef          	jal	8020006a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a4:	6c4c                	ld	a1,152(s0)
    802002a6:	00001517          	auipc	a0,0x1
    802002aa:	a5a50513          	addi	a0,a0,-1446 # 80200d00 <etext+0x2e2>
    802002ae:	dbdff0ef          	jal	8020006a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b2:	704c                	ld	a1,160(s0)
    802002b4:	00001517          	auipc	a0,0x1
    802002b8:	a6450513          	addi	a0,a0,-1436 # 80200d18 <etext+0x2fa>
    802002bc:	dafff0ef          	jal	8020006a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c0:	744c                	ld	a1,168(s0)
    802002c2:	00001517          	auipc	a0,0x1
    802002c6:	a6e50513          	addi	a0,a0,-1426 # 80200d30 <etext+0x312>
    802002ca:	da1ff0ef          	jal	8020006a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002ce:	784c                	ld	a1,176(s0)
    802002d0:	00001517          	auipc	a0,0x1
    802002d4:	a7850513          	addi	a0,a0,-1416 # 80200d48 <etext+0x32a>
    802002d8:	d93ff0ef          	jal	8020006a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002dc:	7c4c                	ld	a1,184(s0)
    802002de:	00001517          	auipc	a0,0x1
    802002e2:	a8250513          	addi	a0,a0,-1406 # 80200d60 <etext+0x342>
    802002e6:	d85ff0ef          	jal	8020006a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ea:	606c                	ld	a1,192(s0)
    802002ec:	00001517          	auipc	a0,0x1
    802002f0:	a8c50513          	addi	a0,a0,-1396 # 80200d78 <etext+0x35a>
    802002f4:	d77ff0ef          	jal	8020006a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f8:	646c                	ld	a1,200(s0)
    802002fa:	00001517          	auipc	a0,0x1
    802002fe:	a9650513          	addi	a0,a0,-1386 # 80200d90 <etext+0x372>
    80200302:	d69ff0ef          	jal	8020006a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200306:	686c                	ld	a1,208(s0)
    80200308:	00001517          	auipc	a0,0x1
    8020030c:	aa050513          	addi	a0,a0,-1376 # 80200da8 <etext+0x38a>
    80200310:	d5bff0ef          	jal	8020006a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200314:	6c6c                	ld	a1,216(s0)
    80200316:	00001517          	auipc	a0,0x1
    8020031a:	aaa50513          	addi	a0,a0,-1366 # 80200dc0 <etext+0x3a2>
    8020031e:	d4dff0ef          	jal	8020006a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200322:	706c                	ld	a1,224(s0)
    80200324:	00001517          	auipc	a0,0x1
    80200328:	ab450513          	addi	a0,a0,-1356 # 80200dd8 <etext+0x3ba>
    8020032c:	d3fff0ef          	jal	8020006a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200330:	746c                	ld	a1,232(s0)
    80200332:	00001517          	auipc	a0,0x1
    80200336:	abe50513          	addi	a0,a0,-1346 # 80200df0 <etext+0x3d2>
    8020033a:	d31ff0ef          	jal	8020006a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033e:	786c                	ld	a1,240(s0)
    80200340:	00001517          	auipc	a0,0x1
    80200344:	ac850513          	addi	a0,a0,-1336 # 80200e08 <etext+0x3ea>
    80200348:	d23ff0ef          	jal	8020006a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034c:	7c6c                	ld	a1,248(s0)
}
    8020034e:	6402                	ld	s0,0(sp)
    80200350:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200352:	00001517          	auipc	a0,0x1
    80200356:	ace50513          	addi	a0,a0,-1330 # 80200e20 <etext+0x402>
}
    8020035a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035c:	b339                	j	8020006a <cprintf>

000000008020035e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020035e:	1141                	addi	sp,sp,-16
    80200360:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200362:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200364:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200366:	00001517          	auipc	a0,0x1
    8020036a:	ad250513          	addi	a0,a0,-1326 # 80200e38 <etext+0x41a>
void print_trapframe(struct trapframe *tf) {
    8020036e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200370:	cfbff0ef          	jal	8020006a <cprintf>
    print_regs(&tf->gpr);
    80200374:	8522                	mv	a0,s0
    80200376:	e1dff0ef          	jal	80200192 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    8020037a:	10043583          	ld	a1,256(s0)
    8020037e:	00001517          	auipc	a0,0x1
    80200382:	ad250513          	addi	a0,a0,-1326 # 80200e50 <etext+0x432>
    80200386:	ce5ff0ef          	jal	8020006a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);//记录触发中断的那条指令的地址
    8020038a:	10843583          	ld	a1,264(s0)
    8020038e:	00001517          	auipc	a0,0x1
    80200392:	ada50513          	addi	a0,a0,-1318 # 80200e68 <etext+0x44a>
    80200396:	cd5ff0ef          	jal	8020006a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    8020039a:	11043583          	ld	a1,272(s0)
    8020039e:	00001517          	auipc	a0,0x1
    802003a2:	ae250513          	addi	a0,a0,-1310 # 80200e80 <etext+0x462>
    802003a6:	cc5ff0ef          	jal	8020006a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003aa:	11843583          	ld	a1,280(s0)
}
    802003ae:	6402                	ld	s0,0(sp)
    802003b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b2:	00001517          	auipc	a0,0x1
    802003b6:	ae650513          	addi	a0,a0,-1306 # 80200e98 <etext+0x47a>
}
    802003ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003bc:	b17d                	j	8020006a <cprintf>

00000000802003be <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
    802003be:	11853783          	ld	a5,280(a0)
    802003c2:	472d                	li	a4,11
    802003c4:	0786                	slli	a5,a5,0x1
    802003c6:	8385                	srli	a5,a5,0x1
    802003c8:	08f76263          	bltu	a4,a5,8020044c <interrupt_handler+0x8e>
    802003cc:	00001717          	auipc	a4,0x1
    802003d0:	cd870713          	addi	a4,a4,-808 # 802010a4 <etext+0x686>
    802003d4:	078a                	slli	a5,a5,0x2
    802003d6:	97ba                	add	a5,a5,a4
    802003d8:	439c                	lw	a5,0(a5)
    802003da:	97ba                	add	a5,a5,a4
    802003dc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003de:	00001517          	auipc	a0,0x1
    802003e2:	b3250513          	addi	a0,a0,-1230 # 80200f10 <etext+0x4f2>
    802003e6:	b151                	j	8020006a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	b0850513          	addi	a0,a0,-1272 # 80200ef0 <etext+0x4d2>
    802003f0:	b9ad                	j	8020006a <cprintf>
            cprintf("User software interrupt\n");
    802003f2:	00001517          	auipc	a0,0x1
    802003f6:	abe50513          	addi	a0,a0,-1346 # 80200eb0 <etext+0x492>
    802003fa:	b985                	j	8020006a <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	ad450513          	addi	a0,a0,-1324 # 80200ed0 <etext+0x4b2>
    80200404:	b19d                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200406:	1141                	addi	sp,sp,-16
    80200408:	e022                	sd	s0,0(sp)
    8020040a:	e406                	sd	ra,8(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
    8020040c:	d51ff0ef          	jal	8020015c <clock_set_next_event>
            ticks++;
    80200410:	00004797          	auipc	a5,0x4
    80200414:	c0078793          	addi	a5,a5,-1024 # 80204010 <ticks>
    80200418:	6398                	ld	a4,0(a5)
    8020041a:	00004417          	auipc	s0,0x4
    8020041e:	bfe40413          	addi	s0,s0,-1026 # 80204018 <num>
    80200422:	0705                	addi	a4,a4,1
    80200424:	e398                	sd	a4,0(a5)
            if(ticks%TICK_NUM==0){
    80200426:	639c                	ld	a5,0(a5)
    80200428:	06400713          	li	a4,100
    8020042c:	02e7f7b3          	remu	a5,a5,a4
    80200430:	cf99                	beqz	a5,8020044e <interrupt_handler+0x90>
                print_ticks();
                num++;
            }
            if(num==10){
    80200432:	6018                	ld	a4,0(s0)
    80200434:	47a9                	li	a5,10
    80200436:	02f70863          	beq	a4,a5,80200466 <interrupt_handler+0xa8>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020043a:	60a2                	ld	ra,8(sp)
    8020043c:	6402                	ld	s0,0(sp)
    8020043e:	0141                	addi	sp,sp,16
    80200440:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    80200442:	00001517          	auipc	a0,0x1
    80200446:	afe50513          	addi	a0,a0,-1282 # 80200f40 <etext+0x522>
    8020044a:	b105                	j	8020006a <cprintf>
            print_trapframe(tf);
    8020044c:	bf09                	j	8020035e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020044e:	06400593          	li	a1,100
    80200452:	00001517          	auipc	a0,0x1
    80200456:	ade50513          	addi	a0,a0,-1314 # 80200f30 <etext+0x512>
    8020045a:	c11ff0ef          	jal	8020006a <cprintf>
                num++;
    8020045e:	601c                	ld	a5,0(s0)
    80200460:	0785                	addi	a5,a5,1
    80200462:	e01c                	sd	a5,0(s0)
    80200464:	b7f9                	j	80200432 <interrupt_handler+0x74>
}
    80200466:	6402                	ld	s0,0(sp)
    80200468:	60a2                	ld	ra,8(sp)
    8020046a:	0141                	addi	sp,sp,16
                sbi_shutdown();
    8020046c:	a3ad                	j	802009d6 <sbi_shutdown>

000000008020046e <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020046e:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    80200472:	1141                	addi	sp,sp,-16
    80200474:	e022                	sd	s0,0(sp)
    80200476:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
    80200478:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    8020047a:	842a                	mv	s0,a0
    switch (tf->cause) {
    8020047c:	04e78663          	beq	a5,a4,802004c8 <exception_handler+0x5a>
    80200480:	02f76c63          	bltu	a4,a5,802004b8 <exception_handler+0x4a>
    80200484:	4709                	li	a4,2
    80200486:	02e79563          	bne	a5,a4,802004b0 <exception_handler+0x42>
             /* LAB1 CHALLENGE3   YOUR CODE :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception type: Illegal instruction\n");
    8020048a:	00001517          	auipc	a0,0x1
    8020048e:	ad650513          	addi	a0,a0,-1322 # 80200f60 <etext+0x542>
    80200492:	bd9ff0ef          	jal	8020006a <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n",tf->epc);
    80200496:	10843583          	ld	a1,264(s0)
    8020049a:	00001517          	auipc	a0,0x1
    8020049e:	aee50513          	addi	a0,a0,-1298 # 80200f88 <etext+0x56a>
    802004a2:	bc9ff0ef          	jal	8020006a <cprintf>
            tf->epc+=2;//恢复处理，跳过触发异常的指令
    802004a6:	10843783          	ld	a5,264(s0)
    802004aa:	0789                	addi	a5,a5,2
    802004ac:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004b0:	60a2                	ld	ra,8(sp)
    802004b2:	6402                	ld	s0,0(sp)
    802004b4:	0141                	addi	sp,sp,16
    802004b6:	8082                	ret
    switch (tf->cause) {
    802004b8:	17f1                	addi	a5,a5,-4
    802004ba:	471d                	li	a4,7
    802004bc:	fef77ae3          	bgeu	a4,a5,802004b0 <exception_handler+0x42>
}
    802004c0:	6402                	ld	s0,0(sp)
    802004c2:	60a2                	ld	ra,8(sp)
    802004c4:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004c6:	bd61                	j	8020035e <print_trapframe>
            cprintf("Exception type: Breakpoint\n");
    802004c8:	00001517          	auipc	a0,0x1
    802004cc:	ae850513          	addi	a0,a0,-1304 # 80200fb0 <etext+0x592>
    802004d0:	b9bff0ef          	jal	8020006a <cprintf>
            cprintf("Ebreak caught at 0x%08x\n", tf->epc);
    802004d4:	10843583          	ld	a1,264(s0)
    802004d8:	00001517          	auipc	a0,0x1
    802004dc:	af850513          	addi	a0,a0,-1288 # 80200fd0 <etext+0x5b2>
    802004e0:	b8bff0ef          	jal	8020006a <cprintf>
            tf->epc+=2;
    802004e4:	10843783          	ld	a5,264(s0)
}
    802004e8:	60a2                	ld	ra,8(sp)
            tf->epc+=2;
    802004ea:	0789                	addi	a5,a5,2
    802004ec:	10f43423          	sd	a5,264(s0)
}
    802004f0:	6402                	ld	s0,0(sp)
    802004f2:	0141                	addi	sp,sp,16
    802004f4:	8082                	ret

00000000802004f6 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004f6:	11853783          	ld	a5,280(a0)
    802004fa:	0007c363          	bltz	a5,80200500 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802004fe:	bf85                	j	8020046e <exception_handler>
        interrupt_handler(tf);
    80200500:	bd7d                	j	802003be <interrupt_handler>
	...

0000000080200504 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    80200504:	14011073          	csrw	sscratch,sp
    80200508:	712d                	addi	sp,sp,-288
    8020050a:	e002                	sd	zero,0(sp)
    8020050c:	e406                	sd	ra,8(sp)
    8020050e:	ec0e                	sd	gp,24(sp)
    80200510:	f012                	sd	tp,32(sp)
    80200512:	f416                	sd	t0,40(sp)
    80200514:	f81a                	sd	t1,48(sp)
    80200516:	fc1e                	sd	t2,56(sp)
    80200518:	e0a2                	sd	s0,64(sp)
    8020051a:	e4a6                	sd	s1,72(sp)
    8020051c:	e8aa                	sd	a0,80(sp)
    8020051e:	ecae                	sd	a1,88(sp)
    80200520:	f0b2                	sd	a2,96(sp)
    80200522:	f4b6                	sd	a3,104(sp)
    80200524:	f8ba                	sd	a4,112(sp)
    80200526:	fcbe                	sd	a5,120(sp)
    80200528:	e142                	sd	a6,128(sp)
    8020052a:	e546                	sd	a7,136(sp)
    8020052c:	e94a                	sd	s2,144(sp)
    8020052e:	ed4e                	sd	s3,152(sp)
    80200530:	f152                	sd	s4,160(sp)
    80200532:	f556                	sd	s5,168(sp)
    80200534:	f95a                	sd	s6,176(sp)
    80200536:	fd5e                	sd	s7,184(sp)
    80200538:	e1e2                	sd	s8,192(sp)
    8020053a:	e5e6                	sd	s9,200(sp)
    8020053c:	e9ea                	sd	s10,208(sp)
    8020053e:	edee                	sd	s11,216(sp)
    80200540:	f1f2                	sd	t3,224(sp)
    80200542:	f5f6                	sd	t4,232(sp)
    80200544:	f9fa                	sd	t5,240(sp)
    80200546:	fdfe                	sd	t6,248(sp)
    80200548:	14001473          	csrrw	s0,sscratch,zero
    8020054c:	100024f3          	csrr	s1,sstatus
    80200550:	14102973          	csrr	s2,sepc
    80200554:	143029f3          	csrr	s3,stval
    80200558:	14202a73          	csrr	s4,scause
    8020055c:	e822                	sd	s0,16(sp)
    8020055e:	e226                	sd	s1,256(sp)
    80200560:	e64a                	sd	s2,264(sp)
    80200562:	ea4e                	sd	s3,272(sp)
    80200564:	ee52                	sd	s4,280(sp)

    move  a0, sp
    80200566:	850a                	mv	a0,sp
    jal trap
    80200568:	f8fff0ef          	jal	802004f6 <trap>

000000008020056c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    8020056c:	6492                	ld	s1,256(sp)
    8020056e:	6932                	ld	s2,264(sp)
    80200570:	10049073          	csrw	sstatus,s1
    80200574:	14191073          	csrw	sepc,s2
    80200578:	60a2                	ld	ra,8(sp)
    8020057a:	61e2                	ld	gp,24(sp)
    8020057c:	7202                	ld	tp,32(sp)
    8020057e:	72a2                	ld	t0,40(sp)
    80200580:	7342                	ld	t1,48(sp)
    80200582:	73e2                	ld	t2,56(sp)
    80200584:	6406                	ld	s0,64(sp)
    80200586:	64a6                	ld	s1,72(sp)
    80200588:	6546                	ld	a0,80(sp)
    8020058a:	65e6                	ld	a1,88(sp)
    8020058c:	7606                	ld	a2,96(sp)
    8020058e:	76a6                	ld	a3,104(sp)
    80200590:	7746                	ld	a4,112(sp)
    80200592:	77e6                	ld	a5,120(sp)
    80200594:	680a                	ld	a6,128(sp)
    80200596:	68aa                	ld	a7,136(sp)
    80200598:	694a                	ld	s2,144(sp)
    8020059a:	69ea                	ld	s3,152(sp)
    8020059c:	7a0a                	ld	s4,160(sp)
    8020059e:	7aaa                	ld	s5,168(sp)
    802005a0:	7b4a                	ld	s6,176(sp)
    802005a2:	7bea                	ld	s7,184(sp)
    802005a4:	6c0e                	ld	s8,192(sp)
    802005a6:	6cae                	ld	s9,200(sp)
    802005a8:	6d4e                	ld	s10,208(sp)
    802005aa:	6dee                	ld	s11,216(sp)
    802005ac:	7e0e                	ld	t3,224(sp)
    802005ae:	7eae                	ld	t4,232(sp)
    802005b0:	7f4e                	ld	t5,240(sp)
    802005b2:	7fee                	ld	t6,248(sp)
    802005b4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005b6:	10200073          	sret

00000000802005ba <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005ba:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005be:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005c0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005c4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005c6:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005ca:	f022                	sd	s0,32(sp)
    802005cc:	ec26                	sd	s1,24(sp)
    802005ce:	e84a                	sd	s2,16(sp)
    802005d0:	f406                	sd	ra,40(sp)
    802005d2:	84aa                	mv	s1,a0
    802005d4:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005d6:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005da:	2a01                	sext.w	s4,s4
    if (num >= base) {
    802005dc:	05067063          	bgeu	a2,a6,8020061c <printnum+0x62>
    802005e0:	e44e                	sd	s3,8(sp)
    802005e2:	89be                	mv	s3,a5
        while (-- width > 0)
    802005e4:	4785                	li	a5,1
    802005e6:	00e7d763          	bge	a5,a4,802005f4 <printnum+0x3a>
            putch(padc, putdat);
    802005ea:	85ca                	mv	a1,s2
    802005ec:	854e                	mv	a0,s3
        while (-- width > 0)
    802005ee:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802005f0:	9482                	jalr	s1
        while (-- width > 0)
    802005f2:	fc65                	bnez	s0,802005ea <printnum+0x30>
    802005f4:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802005f6:	1a02                	slli	s4,s4,0x20
    802005f8:	020a5a13          	srli	s4,s4,0x20
    802005fc:	00001797          	auipc	a5,0x1
    80200600:	9f478793          	addi	a5,a5,-1548 # 80200ff0 <etext+0x5d2>
    80200604:	97d2                	add	a5,a5,s4
}
    80200606:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200608:	0007c503          	lbu	a0,0(a5)
}
    8020060c:	70a2                	ld	ra,40(sp)
    8020060e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200610:	85ca                	mv	a1,s2
    80200612:	87a6                	mv	a5,s1
}
    80200614:	6942                	ld	s2,16(sp)
    80200616:	64e2                	ld	s1,24(sp)
    80200618:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    8020061a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
    8020061c:	03065633          	divu	a2,a2,a6
    80200620:	8722                	mv	a4,s0
    80200622:	f99ff0ef          	jal	802005ba <printnum>
    80200626:	bfc1                	j	802005f6 <printnum+0x3c>

0000000080200628 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    80200628:	7119                	addi	sp,sp,-128
    8020062a:	f4a6                	sd	s1,104(sp)
    8020062c:	f0ca                	sd	s2,96(sp)
    8020062e:	ecce                	sd	s3,88(sp)
    80200630:	e8d2                	sd	s4,80(sp)
    80200632:	e4d6                	sd	s5,72(sp)
    80200634:	e0da                	sd	s6,64(sp)
    80200636:	f862                	sd	s8,48(sp)
    80200638:	fc86                	sd	ra,120(sp)
    8020063a:	f8a2                	sd	s0,112(sp)
    8020063c:	fc5e                	sd	s7,56(sp)
    8020063e:	f466                	sd	s9,40(sp)
    80200640:	f06a                	sd	s10,32(sp)
    80200642:	ec6e                	sd	s11,24(sp)
    80200644:	892a                	mv	s2,a0
    80200646:	84ae                	mv	s1,a1
    80200648:	8c32                	mv	s8,a2
    8020064a:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020064c:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    80200650:	05500b13          	li	s6,85
    80200654:	00001a97          	auipc	s5,0x1
    80200658:	a80a8a93          	addi	s5,s5,-1408 # 802010d4 <etext+0x6b6>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020065c:	000c4503          	lbu	a0,0(s8)
    80200660:	001c0413          	addi	s0,s8,1
    80200664:	01350a63          	beq	a0,s3,80200678 <vprintfmt+0x50>
            if (ch == '\0') {
    80200668:	cd0d                	beqz	a0,802006a2 <vprintfmt+0x7a>
            putch(ch, putdat);
    8020066a:	85a6                	mv	a1,s1
    8020066c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020066e:	00044503          	lbu	a0,0(s0)
    80200672:	0405                	addi	s0,s0,1
    80200674:	ff351ae3          	bne	a0,s3,80200668 <vprintfmt+0x40>
        char padc = ' ';
    80200678:	02000d93          	li	s11,32
        lflag = altflag = 0;
    8020067c:	4b81                	li	s7,0
    8020067e:	4601                	li	a2,0
        width = precision = -1;
    80200680:	5d7d                	li	s10,-1
    80200682:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
    80200684:	00044683          	lbu	a3,0(s0)
    80200688:	00140c13          	addi	s8,s0,1
    8020068c:	fdd6859b          	addiw	a1,a3,-35
    80200690:	0ff5f593          	zext.b	a1,a1
    80200694:	02bb6663          	bltu	s6,a1,802006c0 <vprintfmt+0x98>
    80200698:	058a                	slli	a1,a1,0x2
    8020069a:	95d6                	add	a1,a1,s5
    8020069c:	4198                	lw	a4,0(a1)
    8020069e:	9756                	add	a4,a4,s5
    802006a0:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006a2:	70e6                	ld	ra,120(sp)
    802006a4:	7446                	ld	s0,112(sp)
    802006a6:	74a6                	ld	s1,104(sp)
    802006a8:	7906                	ld	s2,96(sp)
    802006aa:	69e6                	ld	s3,88(sp)
    802006ac:	6a46                	ld	s4,80(sp)
    802006ae:	6aa6                	ld	s5,72(sp)
    802006b0:	6b06                	ld	s6,64(sp)
    802006b2:	7be2                	ld	s7,56(sp)
    802006b4:	7c42                	ld	s8,48(sp)
    802006b6:	7ca2                	ld	s9,40(sp)
    802006b8:	7d02                	ld	s10,32(sp)
    802006ba:	6de2                	ld	s11,24(sp)
    802006bc:	6109                	addi	sp,sp,128
    802006be:	8082                	ret
            putch('%', putdat);
    802006c0:	85a6                	mv	a1,s1
    802006c2:	02500513          	li	a0,37
    802006c6:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802006c8:	fff44703          	lbu	a4,-1(s0)
    802006cc:	02500793          	li	a5,37
    802006d0:	8c22                	mv	s8,s0
    802006d2:	f8f705e3          	beq	a4,a5,8020065c <vprintfmt+0x34>
    802006d6:	02500713          	li	a4,37
    802006da:	ffec4783          	lbu	a5,-2(s8)
    802006de:	1c7d                	addi	s8,s8,-1
    802006e0:	fee79de3          	bne	a5,a4,802006da <vprintfmt+0xb2>
    802006e4:	bfa5                	j	8020065c <vprintfmt+0x34>
                ch = *fmt;
    802006e6:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
    802006ea:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
    802006ec:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
    802006f0:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
    802006f4:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
    802006f8:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
    802006fa:	02b76563          	bltu	a4,a1,80200724 <vprintfmt+0xfc>
    802006fe:	4525                	li	a0,9
                ch = *fmt;
    80200700:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
    80200704:	002d171b          	slliw	a4,s10,0x2
    80200708:	01a7073b          	addw	a4,a4,s10
    8020070c:	0017171b          	slliw	a4,a4,0x1
    80200710:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
    80200712:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
    80200716:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    80200718:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
    8020071c:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
    80200720:	feb570e3          	bgeu	a0,a1,80200700 <vprintfmt+0xd8>
            if (width < 0)
    80200724:	f60cd0e3          	bgez	s9,80200684 <vprintfmt+0x5c>
                width = precision, precision = -1;
    80200728:	8cea                	mv	s9,s10
    8020072a:	5d7d                	li	s10,-1
    8020072c:	bfa1                	j	80200684 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
    8020072e:	8db6                	mv	s11,a3
    80200730:	8462                	mv	s0,s8
    80200732:	bf89                	j	80200684 <vprintfmt+0x5c>
    80200734:	8462                	mv	s0,s8
            altflag = 1;
    80200736:	4b85                	li	s7,1
            goto reswitch;
    80200738:	b7b1                	j	80200684 <vprintfmt+0x5c>
    if (lflag >= 2) {
    8020073a:	4785                	li	a5,1
            precision = va_arg(ap, int);
    8020073c:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    80200740:	00c7c463          	blt	a5,a2,80200748 <vprintfmt+0x120>
    else if (lflag) {
    80200744:	1a060163          	beqz	a2,802008e6 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
    80200748:	000a3603          	ld	a2,0(s4)
    8020074c:	46c1                	li	a3,16
    8020074e:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
    80200750:	000d879b          	sext.w	a5,s11
    80200754:	8766                	mv	a4,s9
    80200756:	85a6                	mv	a1,s1
    80200758:	854a                	mv	a0,s2
    8020075a:	e61ff0ef          	jal	802005ba <printnum>
            break;
    8020075e:	bdfd                	j	8020065c <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
    80200760:	000a2503          	lw	a0,0(s4)
    80200764:	85a6                	mv	a1,s1
    80200766:	0a21                	addi	s4,s4,8
    80200768:	9902                	jalr	s2
            break;
    8020076a:	bdcd                	j	8020065c <vprintfmt+0x34>
    if (lflag >= 2) {
    8020076c:	4785                	li	a5,1
            precision = va_arg(ap, int);
    8020076e:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    80200772:	00c7c463          	blt	a5,a2,8020077a <vprintfmt+0x152>
    else if (lflag) {
    80200776:	16060363          	beqz	a2,802008dc <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
    8020077a:	000a3603          	ld	a2,0(s4)
    8020077e:	46a9                	li	a3,10
    80200780:	8a3a                	mv	s4,a4
    80200782:	b7f9                	j	80200750 <vprintfmt+0x128>
            putch('0', putdat);
    80200784:	85a6                	mv	a1,s1
    80200786:	03000513          	li	a0,48
    8020078a:	9902                	jalr	s2
            putch('x', putdat);
    8020078c:	85a6                	mv	a1,s1
    8020078e:	07800513          	li	a0,120
    80200792:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200794:	000a3603          	ld	a2,0(s4)
            goto number;
    80200798:	46c1                	li	a3,16
            num = (unsigned long long)va_arg(ap, void *);
    8020079a:	0a21                	addi	s4,s4,8
            goto number;
    8020079c:	bf55                	j	80200750 <vprintfmt+0x128>
            putch(ch, putdat);
    8020079e:	85a6                	mv	a1,s1
    802007a0:	02500513          	li	a0,37
    802007a4:	9902                	jalr	s2
            break;
    802007a6:	bd5d                	j	8020065c <vprintfmt+0x34>
            precision = va_arg(ap, int);
    802007a8:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
    802007ac:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
    802007ae:	0a21                	addi	s4,s4,8
            goto process_precision;
    802007b0:	bf95                	j	80200724 <vprintfmt+0xfc>
    if (lflag >= 2) {
    802007b2:	4785                	li	a5,1
            precision = va_arg(ap, int);
    802007b4:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
    802007b8:	00c7c463          	blt	a5,a2,802007c0 <vprintfmt+0x198>
    else if (lflag) {
    802007bc:	10060b63          	beqz	a2,802008d2 <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
    802007c0:	000a3603          	ld	a2,0(s4)
    802007c4:	46a1                	li	a3,8
    802007c6:	8a3a                	mv	s4,a4
    802007c8:	b761                	j	80200750 <vprintfmt+0x128>
            if (width < 0)
    802007ca:	fffcc793          	not	a5,s9
    802007ce:	97fd                	srai	a5,a5,0x3f
    802007d0:	00fcf7b3          	and	a5,s9,a5
    802007d4:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
    802007d8:	8462                	mv	s0,s8
            goto reswitch;
    802007da:	b56d                	j	80200684 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007dc:	000a3403          	ld	s0,0(s4)
    802007e0:	008a0793          	addi	a5,s4,8
    802007e4:	e43e                	sd	a5,8(sp)
    802007e6:	12040063          	beqz	s0,80200906 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
    802007ea:	0d905963          	blez	s9,802008bc <vprintfmt+0x294>
    802007ee:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007f2:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
    802007f6:	12fd9763          	bne	s11,a5,80200924 <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007fa:	00044783          	lbu	a5,0(s0)
    802007fe:	0007851b          	sext.w	a0,a5
    80200802:	cb9d                	beqz	a5,80200838 <vprintfmt+0x210>
    80200804:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200806:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020080a:	000d4563          	bltz	s10,80200814 <vprintfmt+0x1ec>
    8020080e:	3d7d                	addiw	s10,s10,-1
    80200810:	028d0263          	beq	s10,s0,80200834 <vprintfmt+0x20c>
                    putch('?', putdat);
    80200814:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    80200816:	0c0b8d63          	beqz	s7,802008f0 <vprintfmt+0x2c8>
    8020081a:	3781                	addiw	a5,a5,-32
    8020081c:	0cfdfa63          	bgeu	s11,a5,802008f0 <vprintfmt+0x2c8>
                    putch('?', putdat);
    80200820:	03f00513          	li	a0,63
    80200824:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200826:	000a4783          	lbu	a5,0(s4)
    8020082a:	3cfd                	addiw	s9,s9,-1
    8020082c:	0a05                	addi	s4,s4,1
    8020082e:	0007851b          	sext.w	a0,a5
    80200832:	ffe1                	bnez	a5,8020080a <vprintfmt+0x1e2>
            for (; width > 0; width --) {
    80200834:	01905963          	blez	s9,80200846 <vprintfmt+0x21e>
                putch(' ', putdat);
    80200838:	85a6                	mv	a1,s1
    8020083a:	02000513          	li	a0,32
            for (; width > 0; width --) {
    8020083e:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
    80200840:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200842:	fe0c9be3          	bnez	s9,80200838 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
    80200846:	6a22                	ld	s4,8(sp)
    80200848:	bd11                	j	8020065c <vprintfmt+0x34>
    if (lflag >= 2) {
    8020084a:	4785                	li	a5,1
            precision = va_arg(ap, int);
    8020084c:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
    80200850:	00c7c363          	blt	a5,a2,80200856 <vprintfmt+0x22e>
    else if (lflag) {
    80200854:	ce25                	beqz	a2,802008cc <vprintfmt+0x2a4>
        return va_arg(*ap, long);
    80200856:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
    8020085a:	08044d63          	bltz	s0,802008f4 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
    8020085e:	8622                	mv	a2,s0
    80200860:	8a5e                	mv	s4,s7
    80200862:	46a9                	li	a3,10
    80200864:	b5f5                	j	80200750 <vprintfmt+0x128>
            if (err < 0) {
    80200866:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020086a:	4619                	li	a2,6
            if (err < 0) {
    8020086c:	41f7d71b          	sraiw	a4,a5,0x1f
    80200870:	8fb9                	xor	a5,a5,a4
    80200872:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200876:	02d64663          	blt	a2,a3,802008a2 <vprintfmt+0x27a>
    8020087a:	00369713          	slli	a4,a3,0x3
    8020087e:	00001797          	auipc	a5,0x1
    80200882:	9b278793          	addi	a5,a5,-1614 # 80201230 <error_string>
    80200886:	97ba                	add	a5,a5,a4
    80200888:	639c                	ld	a5,0(a5)
    8020088a:	cf81                	beqz	a5,802008a2 <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
    8020088c:	86be                	mv	a3,a5
    8020088e:	00000617          	auipc	a2,0x0
    80200892:	79260613          	addi	a2,a2,1938 # 80201020 <etext+0x602>
    80200896:	85a6                	mv	a1,s1
    80200898:	854a                	mv	a0,s2
    8020089a:	0e8000ef          	jal	80200982 <printfmt>
            err = va_arg(ap, int);
    8020089e:	0a21                	addi	s4,s4,8
    802008a0:	bb75                	j	8020065c <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
    802008a2:	00000617          	auipc	a2,0x0
    802008a6:	76e60613          	addi	a2,a2,1902 # 80201010 <etext+0x5f2>
    802008aa:	85a6                	mv	a1,s1
    802008ac:	854a                	mv	a0,s2
    802008ae:	0d4000ef          	jal	80200982 <printfmt>
            err = va_arg(ap, int);
    802008b2:	0a21                	addi	s4,s4,8
    802008b4:	b365                	j	8020065c <vprintfmt+0x34>
            lflag ++;
    802008b6:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
    802008b8:	8462                	mv	s0,s8
            goto reswitch;
    802008ba:	b3e9                	j	80200684 <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802008bc:	00044783          	lbu	a5,0(s0)
    802008c0:	0007851b          	sext.w	a0,a5
    802008c4:	d3c9                	beqz	a5,80200846 <vprintfmt+0x21e>
    802008c6:	00140a13          	addi	s4,s0,1
    802008ca:	bf2d                	j	80200804 <vprintfmt+0x1dc>
        return va_arg(*ap, int);
    802008cc:	000a2403          	lw	s0,0(s4)
    802008d0:	b769                	j	8020085a <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
    802008d2:	000a6603          	lwu	a2,0(s4)
    802008d6:	46a1                	li	a3,8
    802008d8:	8a3a                	mv	s4,a4
    802008da:	bd9d                	j	80200750 <vprintfmt+0x128>
    802008dc:	000a6603          	lwu	a2,0(s4)
    802008e0:	46a9                	li	a3,10
    802008e2:	8a3a                	mv	s4,a4
    802008e4:	b5b5                	j	80200750 <vprintfmt+0x128>
    802008e6:	000a6603          	lwu	a2,0(s4)
    802008ea:	46c1                	li	a3,16
    802008ec:	8a3a                	mv	s4,a4
    802008ee:	b58d                	j	80200750 <vprintfmt+0x128>
                    putch(ch, putdat);
    802008f0:	9902                	jalr	s2
    802008f2:	bf15                	j	80200826 <vprintfmt+0x1fe>
                putch('-', putdat);
    802008f4:	85a6                	mv	a1,s1
    802008f6:	02d00513          	li	a0,45
    802008fa:	9902                	jalr	s2
                num = -(long long)num;
    802008fc:	40800633          	neg	a2,s0
    80200900:	8a5e                	mv	s4,s7
    80200902:	46a9                	li	a3,10
    80200904:	b5b1                	j	80200750 <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
    80200906:	01905663          	blez	s9,80200912 <vprintfmt+0x2ea>
    8020090a:	02d00793          	li	a5,45
    8020090e:	04fd9263          	bne	s11,a5,80200952 <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200912:	02800793          	li	a5,40
    80200916:	00000a17          	auipc	s4,0x0
    8020091a:	6f3a0a13          	addi	s4,s4,1779 # 80201009 <etext+0x5eb>
    8020091e:	02800513          	li	a0,40
    80200922:	b5cd                	j	80200804 <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200924:	85ea                	mv	a1,s10
    80200926:	8522                	mv	a0,s0
    80200928:	0c8000ef          	jal	802009f0 <strnlen>
    8020092c:	40ac8cbb          	subw	s9,s9,a0
    80200930:	01905963          	blez	s9,80200942 <vprintfmt+0x31a>
                    putch(padc, putdat);
    80200934:	2d81                	sext.w	s11,s11
    80200936:	85a6                	mv	a1,s1
    80200938:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020093a:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
    8020093c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020093e:	fe0c9ce3          	bnez	s9,80200936 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200942:	00044783          	lbu	a5,0(s0)
    80200946:	0007851b          	sext.w	a0,a5
    8020094a:	ea079de3          	bnez	a5,80200804 <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
    8020094e:	6a22                	ld	s4,8(sp)
    80200950:	b331                	j	8020065c <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200952:	85ea                	mv	a1,s10
    80200954:	00000517          	auipc	a0,0x0
    80200958:	6b450513          	addi	a0,a0,1716 # 80201008 <etext+0x5ea>
    8020095c:	094000ef          	jal	802009f0 <strnlen>
    80200960:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
    80200964:	00000417          	auipc	s0,0x0
    80200968:	6a440413          	addi	s0,s0,1700 # 80201008 <etext+0x5ea>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    8020096c:	00000a17          	auipc	s4,0x0
    80200970:	69da0a13          	addi	s4,s4,1693 # 80201009 <etext+0x5eb>
    80200974:	02800793          	li	a5,40
    80200978:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020097c:	fb904ce3          	bgtz	s9,80200934 <vprintfmt+0x30c>
    80200980:	b551                	j	80200804 <vprintfmt+0x1dc>

0000000080200982 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200982:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200984:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200988:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    8020098a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020098c:	ec06                	sd	ra,24(sp)
    8020098e:	f83a                	sd	a4,48(sp)
    80200990:	fc3e                	sd	a5,56(sp)
    80200992:	e0c2                	sd	a6,64(sp)
    80200994:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    80200996:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200998:	c91ff0ef          	jal	80200628 <vprintfmt>
}
    8020099c:	60e2                	ld	ra,24(sp)
    8020099e:	6161                	addi	sp,sp,80
    802009a0:	8082                	ret

00000000802009a2 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
    802009a2:	4781                	li	a5,0
    802009a4:	00003717          	auipc	a4,0x3
    802009a8:	66473703          	ld	a4,1636(a4) # 80204008 <SBI_CONSOLE_PUTCHAR>
    802009ac:	88ba                	mv	a7,a4
    802009ae:	852a                	mv	a0,a0
    802009b0:	85be                	mv	a1,a5
    802009b2:	863e                	mv	a2,a5
    802009b4:	00000073          	ecall
    802009b8:	87aa                	mv	a5,a0
int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
    802009ba:	8082                	ret

00000000802009bc <sbi_set_timer>:
    __asm__ volatile (
    802009bc:	4781                	li	a5,0
    802009be:	00003717          	auipc	a4,0x3
    802009c2:	66273703          	ld	a4,1634(a4) # 80204020 <SBI_SET_TIMER>
    802009c6:	88ba                	mv	a7,a4
    802009c8:	852a                	mv	a0,a0
    802009ca:	85be                	mv	a1,a5
    802009cc:	863e                	mv	a2,a5
    802009ce:	00000073          	ecall
    802009d2:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
    802009d4:	8082                	ret

00000000802009d6 <sbi_shutdown>:
    __asm__ volatile (
    802009d6:	4781                	li	a5,0
    802009d8:	00003717          	auipc	a4,0x3
    802009dc:	62873703          	ld	a4,1576(a4) # 80204000 <SBI_SHUTDOWN>
    802009e0:	88ba                	mv	a7,a4
    802009e2:	853e                	mv	a0,a5
    802009e4:	85be                	mv	a1,a5
    802009e6:	863e                	mv	a2,a5
    802009e8:	00000073          	ecall
    802009ec:	87aa                	mv	a5,a0


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    802009ee:	8082                	ret

00000000802009f0 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    802009f0:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
    802009f2:	e589                	bnez	a1,802009fc <strnlen+0xc>
    802009f4:	a811                	j	80200a08 <strnlen+0x18>
        cnt ++;
    802009f6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    802009f8:	00f58863          	beq	a1,a5,80200a08 <strnlen+0x18>
    802009fc:	00f50733          	add	a4,a0,a5
    80200a00:	00074703          	lbu	a4,0(a4)
    80200a04:	fb6d                	bnez	a4,802009f6 <strnlen+0x6>
    80200a06:	85be                	mv	a1,a5
    }
    return cnt;
}
    80200a08:	852e                	mv	a0,a1
    80200a0a:	8082                	ret

0000000080200a0c <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a0c:	ca01                	beqz	a2,80200a1c <memset+0x10>
    80200a0e:	962a                	add	a2,a2,a0
    char *p = s;
    80200a10:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a12:	0785                	addi	a5,a5,1
    80200a14:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a18:	fef61de3          	bne	a2,a5,80200a12 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a1c:	8082                	ret
