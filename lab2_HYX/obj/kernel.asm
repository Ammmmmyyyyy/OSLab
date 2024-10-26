
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	ffe50513          	addi	a0,a0,-2 # ffffffffc0206030 <b>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	59660613          	addi	a2,a2,1430 # ffffffffc02065d0 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16 # ffffffffc0204ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	73c010ef          	jal	ffffffffc0201786 <memset>
    cons_init();  // init the console
ffffffffc020004e:	400000ef          	jal	ffffffffc020044e <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	74650513          	addi	a0,a0,1862 # ffffffffc0201798 <etext>
ffffffffc020005a:	096000ef          	jal	ffffffffc02000f0 <cputs>

    print_kerninfo();
ffffffffc020005e:	0f0000ef          	jal	ffffffffc020014e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	406000ef          	jal	ffffffffc0200468 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	549000ef          	jal	ffffffffc0200dae <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fe000ef          	jal	ffffffffc0200468 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39e000ef          	jal	ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3ea000ef          	jal	ffffffffc020045c <intr_enable>
    
    slub_init();
ffffffffc0200076:	048010ef          	jal	ffffffffc02010be <slub_init>
    slub_check();
ffffffffc020007a:	0a4010ef          	jal	ffffffffc020111e <slub_check>
    



    /* do nothing */
    while (1)
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	3c8000ef          	jal	ffffffffc0200450 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	1d6010ef          	jal	ffffffffc0201284 <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	f42e                	sd	a1,40(sp)
ffffffffc02000c2:	f832                	sd	a2,48(sp)
ffffffffc02000c4:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c6:	862a                	mv	a2,a0
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	00000517          	auipc	a0,0x0
ffffffffc02000ce:	fb650513          	addi	a0,a0,-74 # ffffffffc0200080 <cputch>
ffffffffc02000d2:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d4:	ec06                	sd	ra,24(sp)
ffffffffc02000d6:	e0ba                	sd	a4,64(sp)
ffffffffc02000d8:	e4be                	sd	a5,72(sp)
ffffffffc02000da:	e8c2                	sd	a6,80(sp)
ffffffffc02000dc:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000de:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e0:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e2:	1a2010ef          	jal	ffffffffc0201284 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e6:	60e2                	ld	ra,24(sp)
ffffffffc02000e8:	4512                	lw	a0,4(sp)
ffffffffc02000ea:	6125                	addi	sp,sp,96
ffffffffc02000ec:	8082                	ret

ffffffffc02000ee <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ee:	a68d                	j	ffffffffc0200450 <cons_putc>

ffffffffc02000f0 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000f0:	1101                	addi	sp,sp,-32
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e822                	sd	s0,16(sp)
ffffffffc02000f6:	87aa                	mv	a5,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c905                	beqz	a0,ffffffffc020012c <cputs+0x3c>
ffffffffc02000fe:	e426                	sd	s1,8(sp)
ffffffffc0200100:	00178493          	addi	s1,a5,1
ffffffffc0200104:	8426                	mv	s0,s1
    cons_putc(c);
ffffffffc0200106:	34a000ef          	jal	ffffffffc0200450 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020010a:	00044503          	lbu	a0,0(s0)
ffffffffc020010e:	87a2                	mv	a5,s0
ffffffffc0200110:	0405                	addi	s0,s0,1
ffffffffc0200112:	f975                	bnez	a0,ffffffffc0200106 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200114:	9f85                	subw	a5,a5,s1
    cons_putc(c);
ffffffffc0200116:	4529                	li	a0,10
    (*cnt) ++;
ffffffffc0200118:	0027841b          	addiw	s0,a5,2
ffffffffc020011c:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc020011e:	332000ef          	jal	ffffffffc0200450 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200122:	60e2                	ld	ra,24(sp)
ffffffffc0200124:	8522                	mv	a0,s0
ffffffffc0200126:	6442                	ld	s0,16(sp)
ffffffffc0200128:	6105                	addi	sp,sp,32
ffffffffc020012a:	8082                	ret
    cons_putc(c);
ffffffffc020012c:	4529                	li	a0,10
ffffffffc020012e:	322000ef          	jal	ffffffffc0200450 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200132:	4405                	li	s0,1
}
ffffffffc0200134:	60e2                	ld	ra,24(sp)
ffffffffc0200136:	8522                	mv	a0,s0
ffffffffc0200138:	6442                	ld	s0,16(sp)
ffffffffc020013a:	6105                	addi	sp,sp,32
ffffffffc020013c:	8082                	ret

ffffffffc020013e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
ffffffffc0200140:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200142:	316000ef          	jal	ffffffffc0200458 <cons_getc>
ffffffffc0200146:	dd75                	beqz	a0,ffffffffc0200142 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200148:	60a2                	ld	ra,8(sp)
ffffffffc020014a:	0141                	addi	sp,sp,16
ffffffffc020014c:	8082                	ret

ffffffffc020014e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020014e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200150:	00001517          	auipc	a0,0x1
ffffffffc0200154:	66850513          	addi	a0,a0,1640 # ffffffffc02017b8 <etext+0x20>
void print_kerninfo(void) {
ffffffffc0200158:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020015a:	f61ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020015e:	00000597          	auipc	a1,0x0
ffffffffc0200162:	ed458593          	addi	a1,a1,-300 # ffffffffc0200032 <kern_init>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	67250513          	addi	a0,a0,1650 # ffffffffc02017d8 <etext+0x40>
ffffffffc020016e:	f4dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200172:	00001597          	auipc	a1,0x1
ffffffffc0200176:	62658593          	addi	a1,a1,1574 # ffffffffc0201798 <etext>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	67e50513          	addi	a0,a0,1662 # ffffffffc02017f8 <etext+0x60>
ffffffffc0200182:	f39ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	eaa58593          	addi	a1,a1,-342 # ffffffffc0206030 <b>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	68a50513          	addi	a0,a0,1674 # ffffffffc0201818 <etext+0x80>
ffffffffc0200196:	f25ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	43658593          	addi	a1,a1,1078 # ffffffffc02065d0 <end>
ffffffffc02001a2:	00001517          	auipc	a0,0x1
ffffffffc02001a6:	69650513          	addi	a0,a0,1686 # ffffffffc0201838 <etext+0xa0>
ffffffffc02001aa:	f11ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001ae:	00007797          	auipc	a5,0x7
ffffffffc02001b2:	82178793          	addi	a5,a5,-2015 # ffffffffc02069cf <end+0x3ff>
ffffffffc02001b6:	00000717          	auipc	a4,0x0
ffffffffc02001ba:	e7c70713          	addi	a4,a4,-388 # ffffffffc0200032 <kern_init>
ffffffffc02001be:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c0:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001c4:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001ca:	95be                	add	a1,a1,a5
ffffffffc02001cc:	85a9                	srai	a1,a1,0xa
ffffffffc02001ce:	00001517          	auipc	a0,0x1
ffffffffc02001d2:	68a50513          	addi	a0,a0,1674 # ffffffffc0201858 <etext+0xc0>
}
ffffffffc02001d6:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001d8:	b5cd                	j	ffffffffc02000ba <cprintf>

ffffffffc02001da <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001da:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001dc:	00001617          	auipc	a2,0x1
ffffffffc02001e0:	6ac60613          	addi	a2,a2,1708 # ffffffffc0201888 <etext+0xf0>
ffffffffc02001e4:	04e00593          	li	a1,78
ffffffffc02001e8:	00001517          	auipc	a0,0x1
ffffffffc02001ec:	6b850513          	addi	a0,a0,1720 # ffffffffc02018a0 <etext+0x108>
void print_stackframe(void) {
ffffffffc02001f0:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001f2:	1bc000ef          	jal	ffffffffc02003ae <__panic>

ffffffffc02001f6 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001f6:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001f8:	00001617          	auipc	a2,0x1
ffffffffc02001fc:	6c060613          	addi	a2,a2,1728 # ffffffffc02018b8 <etext+0x120>
ffffffffc0200200:	00001597          	auipc	a1,0x1
ffffffffc0200204:	6d858593          	addi	a1,a1,1752 # ffffffffc02018d8 <etext+0x140>
ffffffffc0200208:	00001517          	auipc	a0,0x1
ffffffffc020020c:	6d850513          	addi	a0,a0,1752 # ffffffffc02018e0 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200210:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200212:	ea9ff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0200216:	00001617          	auipc	a2,0x1
ffffffffc020021a:	6da60613          	addi	a2,a2,1754 # ffffffffc02018f0 <etext+0x158>
ffffffffc020021e:	00001597          	auipc	a1,0x1
ffffffffc0200222:	6fa58593          	addi	a1,a1,1786 # ffffffffc0201918 <etext+0x180>
ffffffffc0200226:	00001517          	auipc	a0,0x1
ffffffffc020022a:	6ba50513          	addi	a0,a0,1722 # ffffffffc02018e0 <etext+0x148>
ffffffffc020022e:	e8dff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0200232:	00001617          	auipc	a2,0x1
ffffffffc0200236:	6f660613          	addi	a2,a2,1782 # ffffffffc0201928 <etext+0x190>
ffffffffc020023a:	00001597          	auipc	a1,0x1
ffffffffc020023e:	70e58593          	addi	a1,a1,1806 # ffffffffc0201948 <etext+0x1b0>
ffffffffc0200242:	00001517          	auipc	a0,0x1
ffffffffc0200246:	69e50513          	addi	a0,a0,1694 # ffffffffc02018e0 <etext+0x148>
ffffffffc020024a:	e71ff0ef          	jal	ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc020024e:	60a2                	ld	ra,8(sp)
ffffffffc0200250:	4501                	li	a0,0
ffffffffc0200252:	0141                	addi	sp,sp,16
ffffffffc0200254:	8082                	ret

ffffffffc0200256 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200256:	1141                	addi	sp,sp,-16
ffffffffc0200258:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020025a:	ef5ff0ef          	jal	ffffffffc020014e <print_kerninfo>
    return 0;
}
ffffffffc020025e:	60a2                	ld	ra,8(sp)
ffffffffc0200260:	4501                	li	a0,0
ffffffffc0200262:	0141                	addi	sp,sp,16
ffffffffc0200264:	8082                	ret

ffffffffc0200266 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200266:	1141                	addi	sp,sp,-16
ffffffffc0200268:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020026a:	f71ff0ef          	jal	ffffffffc02001da <print_stackframe>
    return 0;
}
ffffffffc020026e:	60a2                	ld	ra,8(sp)
ffffffffc0200270:	4501                	li	a0,0
ffffffffc0200272:	0141                	addi	sp,sp,16
ffffffffc0200274:	8082                	ret

ffffffffc0200276 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200276:	7115                	addi	sp,sp,-224
ffffffffc0200278:	f15a                	sd	s6,160(sp)
ffffffffc020027a:	8b2a                	mv	s6,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020027c:	00001517          	auipc	a0,0x1
ffffffffc0200280:	6dc50513          	addi	a0,a0,1756 # ffffffffc0201958 <etext+0x1c0>
kmonitor(struct trapframe *tf) {
ffffffffc0200284:	ed86                	sd	ra,216(sp)
ffffffffc0200286:	e9a2                	sd	s0,208(sp)
ffffffffc0200288:	e5a6                	sd	s1,200(sp)
ffffffffc020028a:	e1ca                	sd	s2,192(sp)
ffffffffc020028c:	fd4e                	sd	s3,184(sp)
ffffffffc020028e:	f952                	sd	s4,176(sp)
ffffffffc0200290:	f556                	sd	s5,168(sp)
ffffffffc0200292:	ed5e                	sd	s7,152(sp)
ffffffffc0200294:	e962                	sd	s8,144(sp)
ffffffffc0200296:	e566                	sd	s9,136(sp)
ffffffffc0200298:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020029a:	e21ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020029e:	00001517          	auipc	a0,0x1
ffffffffc02002a2:	6e250513          	addi	a0,a0,1762 # ffffffffc0201980 <etext+0x1e8>
ffffffffc02002a6:	e15ff0ef          	jal	ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002aa:	000b0563          	beqz	s6,ffffffffc02002b4 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002ae:	855a                	mv	a0,s6
ffffffffc02002b0:	396000ef          	jal	ffffffffc0200646 <print_trapframe>
ffffffffc02002b4:	00002c17          	auipc	s8,0x2
ffffffffc02002b8:	f54c0c13          	addi	s8,s8,-172 # ffffffffc0202208 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002bc:	00001917          	auipc	s2,0x1
ffffffffc02002c0:	6ec90913          	addi	s2,s2,1772 # ffffffffc02019a8 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002c4:	00001497          	auipc	s1,0x1
ffffffffc02002c8:	6ec48493          	addi	s1,s1,1772 # ffffffffc02019b0 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002cc:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002ce:	00001a97          	auipc	s5,0x1
ffffffffc02002d2:	6eaa8a93          	addi	s5,s5,1770 # ffffffffc02019b8 <etext+0x220>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d6:	4a0d                	li	s4,3
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02002d8:	00001b97          	auipc	s7,0x1
ffffffffc02002dc:	700b8b93          	addi	s7,s7,1792 # ffffffffc02019d8 <etext+0x240>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002e0:	854a                	mv	a0,s2
ffffffffc02002e2:	31c010ef          	jal	ffffffffc02015fe <readline>
ffffffffc02002e6:	842a                	mv	s0,a0
ffffffffc02002e8:	dd65                	beqz	a0,ffffffffc02002e0 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ea:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002ee:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f0:	e59d                	bnez	a1,ffffffffc020031e <kmonitor+0xa8>
    if (argc == 0) {
ffffffffc02002f2:	fe0c87e3          	beqz	s9,ffffffffc02002e0 <kmonitor+0x6a>
ffffffffc02002f6:	00002d17          	auipc	s10,0x2
ffffffffc02002fa:	f12d0d13          	addi	s10,s10,-238 # ffffffffc0202208 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fe:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	6582                	ld	a1,0(sp)
ffffffffc0200302:	000d3503          	ld	a0,0(s10)
ffffffffc0200306:	432010ef          	jal	ffffffffc0201738 <strcmp>
ffffffffc020030a:	c53d                	beqz	a0,ffffffffc0200378 <kmonitor+0x102>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020030c:	2405                	addiw	s0,s0,1
ffffffffc020030e:	0d61                	addi	s10,s10,24
ffffffffc0200310:	ff4418e3          	bne	s0,s4,ffffffffc0200300 <kmonitor+0x8a>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200314:	6582                	ld	a1,0(sp)
ffffffffc0200316:	855e                	mv	a0,s7
ffffffffc0200318:	da3ff0ef          	jal	ffffffffc02000ba <cprintf>
    return 0;
ffffffffc020031c:	b7d1                	j	ffffffffc02002e0 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020031e:	8526                	mv	a0,s1
ffffffffc0200320:	450010ef          	jal	ffffffffc0201770 <strchr>
ffffffffc0200324:	c901                	beqz	a0,ffffffffc0200334 <kmonitor+0xbe>
ffffffffc0200326:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc020032a:	00040023          	sb	zero,0(s0)
ffffffffc020032e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200330:	d1e9                	beqz	a1,ffffffffc02002f2 <kmonitor+0x7c>
ffffffffc0200332:	b7f5                	j	ffffffffc020031e <kmonitor+0xa8>
        if (*buf == '\0') {
ffffffffc0200334:	00044783          	lbu	a5,0(s0)
ffffffffc0200338:	dfcd                	beqz	a5,ffffffffc02002f2 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc020033a:	033c8a63          	beq	s9,s3,ffffffffc020036e <kmonitor+0xf8>
        argv[argc ++] = buf;
ffffffffc020033e:	003c9793          	slli	a5,s9,0x3
ffffffffc0200342:	08078793          	addi	a5,a5,128
ffffffffc0200346:	978a                	add	a5,a5,sp
ffffffffc0200348:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020034c:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200350:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200352:	e591                	bnez	a1,ffffffffc020035e <kmonitor+0xe8>
ffffffffc0200354:	bf79                	j	ffffffffc02002f2 <kmonitor+0x7c>
ffffffffc0200356:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020035a:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020035c:	d9d9                	beqz	a1,ffffffffc02002f2 <kmonitor+0x7c>
ffffffffc020035e:	8526                	mv	a0,s1
ffffffffc0200360:	410010ef          	jal	ffffffffc0201770 <strchr>
ffffffffc0200364:	d96d                	beqz	a0,ffffffffc0200356 <kmonitor+0xe0>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200366:	00044583          	lbu	a1,0(s0)
ffffffffc020036a:	d5c1                	beqz	a1,ffffffffc02002f2 <kmonitor+0x7c>
ffffffffc020036c:	bf4d                	j	ffffffffc020031e <kmonitor+0xa8>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020036e:	45c1                	li	a1,16
ffffffffc0200370:	8556                	mv	a0,s5
ffffffffc0200372:	d49ff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0200376:	b7e1                	j	ffffffffc020033e <kmonitor+0xc8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200378:	00141793          	slli	a5,s0,0x1
ffffffffc020037c:	97a2                	add	a5,a5,s0
ffffffffc020037e:	078e                	slli	a5,a5,0x3
ffffffffc0200380:	97e2                	add	a5,a5,s8
ffffffffc0200382:	6b9c                	ld	a5,16(a5)
ffffffffc0200384:	865a                	mv	a2,s6
ffffffffc0200386:	002c                	addi	a1,sp,8
ffffffffc0200388:	fffc851b          	addiw	a0,s9,-1
ffffffffc020038c:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020038e:	f40559e3          	bgez	a0,ffffffffc02002e0 <kmonitor+0x6a>
}
ffffffffc0200392:	60ee                	ld	ra,216(sp)
ffffffffc0200394:	644e                	ld	s0,208(sp)
ffffffffc0200396:	64ae                	ld	s1,200(sp)
ffffffffc0200398:	690e                	ld	s2,192(sp)
ffffffffc020039a:	79ea                	ld	s3,184(sp)
ffffffffc020039c:	7a4a                	ld	s4,176(sp)
ffffffffc020039e:	7aaa                	ld	s5,168(sp)
ffffffffc02003a0:	7b0a                	ld	s6,160(sp)
ffffffffc02003a2:	6bea                	ld	s7,152(sp)
ffffffffc02003a4:	6c4a                	ld	s8,144(sp)
ffffffffc02003a6:	6caa                	ld	s9,136(sp)
ffffffffc02003a8:	6d0a                	ld	s10,128(sp)
ffffffffc02003aa:	612d                	addi	sp,sp,224
ffffffffc02003ac:	8082                	ret

ffffffffc02003ae <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ae:	00006317          	auipc	t1,0x6
ffffffffc02003b2:	1c230313          	addi	t1,t1,450 # ffffffffc0206570 <is_panic>
ffffffffc02003b6:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003ba:	715d                	addi	sp,sp,-80
ffffffffc02003bc:	ec06                	sd	ra,24(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1c63          	bnez	t3,ffffffffc0200400 <__panic+0x52>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	e822                	sd	s0,16(sp)
ffffffffc02003d4:	103c                	addi	a5,sp,40
ffffffffc02003d6:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
ffffffffc02003da:	85aa                	mv	a1,a0
ffffffffc02003dc:	00001517          	auipc	a0,0x1
ffffffffc02003e0:	61450513          	addi	a0,a0,1556 # ffffffffc02019f0 <etext+0x258>
    va_start(ap, fmt);
ffffffffc02003e4:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e6:	cd5ff0ef          	jal	ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ea:	65a2                	ld	a1,8(sp)
ffffffffc02003ec:	8522                	mv	a0,s0
ffffffffc02003ee:	cadff0ef          	jal	ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc02003f2:	00001517          	auipc	a0,0x1
ffffffffc02003f6:	61e50513          	addi	a0,a0,1566 # ffffffffc0201a10 <etext+0x278>
ffffffffc02003fa:	cc1ff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc02003fe:	6442                	ld	s0,16(sp)
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	062000ef          	jal	ffffffffc0200462 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e71ff0ef          	jal	ffffffffc0200276 <kmonitor>
    while (1) {
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x56>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	2a8010ef          	jal	ffffffffc02016cc <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	1407b723          	sd	zero,334(a5) # ffffffffc0206578 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00001517          	auipc	a0,0x1
ffffffffc0200436:	5e650513          	addi	a0,a0,1510 # ffffffffc0201a18 <etext+0x280>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	b9bd                	j	ffffffffc02000ba <cprintf>

ffffffffc020043e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200442:	67e1                	lui	a5,0x18
ffffffffc0200444:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200448:	953e                	add	a0,a0,a5
ffffffffc020044a:	2820106f          	j	ffffffffc02016cc <sbi_set_timer>

ffffffffc020044e <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044e:	8082                	ret

ffffffffc0200450 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200450:	0ff57513          	zext.b	a0,a0
ffffffffc0200454:	25e0106f          	j	ffffffffc02016b2 <sbi_console_putchar>

ffffffffc0200458 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200458:	28e0106f          	j	ffffffffc02016e6 <sbi_console_getchar>

ffffffffc020045c <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200460:	8082                	ret

ffffffffc0200462 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200462:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200466:	8082                	ret

ffffffffc0200468 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200468:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046c:	00000797          	auipc	a5,0x0
ffffffffc0200470:	31078793          	addi	a5,a5,784 # ffffffffc020077c <__alltraps>
ffffffffc0200474:	10579073          	csrw	stvec,a5
}
ffffffffc0200478:	8082                	ret

ffffffffc020047a <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047a:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047c:	1141                	addi	sp,sp,-16
ffffffffc020047e:	e022                	sd	s0,0(sp)
ffffffffc0200480:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200482:	00001517          	auipc	a0,0x1
ffffffffc0200486:	5b650513          	addi	a0,a0,1462 # ffffffffc0201a38 <etext+0x2a0>
void print_regs(struct pushregs *gpr) {
ffffffffc020048a:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048c:	c2fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200490:	640c                	ld	a1,8(s0)
ffffffffc0200492:	00001517          	auipc	a0,0x1
ffffffffc0200496:	5be50513          	addi	a0,a0,1470 # ffffffffc0201a50 <etext+0x2b8>
ffffffffc020049a:	c21ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049e:	680c                	ld	a1,16(s0)
ffffffffc02004a0:	00001517          	auipc	a0,0x1
ffffffffc02004a4:	5c850513          	addi	a0,a0,1480 # ffffffffc0201a68 <etext+0x2d0>
ffffffffc02004a8:	c13ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ac:	6c0c                	ld	a1,24(s0)
ffffffffc02004ae:	00001517          	auipc	a0,0x1
ffffffffc02004b2:	5d250513          	addi	a0,a0,1490 # ffffffffc0201a80 <etext+0x2e8>
ffffffffc02004b6:	c05ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004ba:	700c                	ld	a1,32(s0)
ffffffffc02004bc:	00001517          	auipc	a0,0x1
ffffffffc02004c0:	5dc50513          	addi	a0,a0,1500 # ffffffffc0201a98 <etext+0x300>
ffffffffc02004c4:	bf7ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c8:	740c                	ld	a1,40(s0)
ffffffffc02004ca:	00001517          	auipc	a0,0x1
ffffffffc02004ce:	5e650513          	addi	a0,a0,1510 # ffffffffc0201ab0 <etext+0x318>
ffffffffc02004d2:	be9ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d6:	780c                	ld	a1,48(s0)
ffffffffc02004d8:	00001517          	auipc	a0,0x1
ffffffffc02004dc:	5f050513          	addi	a0,a0,1520 # ffffffffc0201ac8 <etext+0x330>
ffffffffc02004e0:	bdbff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e4:	7c0c                	ld	a1,56(s0)
ffffffffc02004e6:	00001517          	auipc	a0,0x1
ffffffffc02004ea:	5fa50513          	addi	a0,a0,1530 # ffffffffc0201ae0 <etext+0x348>
ffffffffc02004ee:	bcdff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f2:	602c                	ld	a1,64(s0)
ffffffffc02004f4:	00001517          	auipc	a0,0x1
ffffffffc02004f8:	60450513          	addi	a0,a0,1540 # ffffffffc0201af8 <etext+0x360>
ffffffffc02004fc:	bbfff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200500:	642c                	ld	a1,72(s0)
ffffffffc0200502:	00001517          	auipc	a0,0x1
ffffffffc0200506:	60e50513          	addi	a0,a0,1550 # ffffffffc0201b10 <etext+0x378>
ffffffffc020050a:	bb1ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050e:	682c                	ld	a1,80(s0)
ffffffffc0200510:	00001517          	auipc	a0,0x1
ffffffffc0200514:	61850513          	addi	a0,a0,1560 # ffffffffc0201b28 <etext+0x390>
ffffffffc0200518:	ba3ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051c:	6c2c                	ld	a1,88(s0)
ffffffffc020051e:	00001517          	auipc	a0,0x1
ffffffffc0200522:	62250513          	addi	a0,a0,1570 # ffffffffc0201b40 <etext+0x3a8>
ffffffffc0200526:	b95ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052a:	702c                	ld	a1,96(s0)
ffffffffc020052c:	00001517          	auipc	a0,0x1
ffffffffc0200530:	62c50513          	addi	a0,a0,1580 # ffffffffc0201b58 <etext+0x3c0>
ffffffffc0200534:	b87ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200538:	742c                	ld	a1,104(s0)
ffffffffc020053a:	00001517          	auipc	a0,0x1
ffffffffc020053e:	63650513          	addi	a0,a0,1590 # ffffffffc0201b70 <etext+0x3d8>
ffffffffc0200542:	b79ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200546:	782c                	ld	a1,112(s0)
ffffffffc0200548:	00001517          	auipc	a0,0x1
ffffffffc020054c:	64050513          	addi	a0,a0,1600 # ffffffffc0201b88 <etext+0x3f0>
ffffffffc0200550:	b6bff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200554:	7c2c                	ld	a1,120(s0)
ffffffffc0200556:	00001517          	auipc	a0,0x1
ffffffffc020055a:	64a50513          	addi	a0,a0,1610 # ffffffffc0201ba0 <etext+0x408>
ffffffffc020055e:	b5dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200562:	604c                	ld	a1,128(s0)
ffffffffc0200564:	00001517          	auipc	a0,0x1
ffffffffc0200568:	65450513          	addi	a0,a0,1620 # ffffffffc0201bb8 <etext+0x420>
ffffffffc020056c:	b4fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200570:	644c                	ld	a1,136(s0)
ffffffffc0200572:	00001517          	auipc	a0,0x1
ffffffffc0200576:	65e50513          	addi	a0,a0,1630 # ffffffffc0201bd0 <etext+0x438>
ffffffffc020057a:	b41ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057e:	684c                	ld	a1,144(s0)
ffffffffc0200580:	00001517          	auipc	a0,0x1
ffffffffc0200584:	66850513          	addi	a0,a0,1640 # ffffffffc0201be8 <etext+0x450>
ffffffffc0200588:	b33ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058c:	6c4c                	ld	a1,152(s0)
ffffffffc020058e:	00001517          	auipc	a0,0x1
ffffffffc0200592:	67250513          	addi	a0,a0,1650 # ffffffffc0201c00 <etext+0x468>
ffffffffc0200596:	b25ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059a:	704c                	ld	a1,160(s0)
ffffffffc020059c:	00001517          	auipc	a0,0x1
ffffffffc02005a0:	67c50513          	addi	a0,a0,1660 # ffffffffc0201c18 <etext+0x480>
ffffffffc02005a4:	b17ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a8:	744c                	ld	a1,168(s0)
ffffffffc02005aa:	00001517          	auipc	a0,0x1
ffffffffc02005ae:	68650513          	addi	a0,a0,1670 # ffffffffc0201c30 <etext+0x498>
ffffffffc02005b2:	b09ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b6:	784c                	ld	a1,176(s0)
ffffffffc02005b8:	00001517          	auipc	a0,0x1
ffffffffc02005bc:	69050513          	addi	a0,a0,1680 # ffffffffc0201c48 <etext+0x4b0>
ffffffffc02005c0:	afbff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c4:	7c4c                	ld	a1,184(s0)
ffffffffc02005c6:	00001517          	auipc	a0,0x1
ffffffffc02005ca:	69a50513          	addi	a0,a0,1690 # ffffffffc0201c60 <etext+0x4c8>
ffffffffc02005ce:	aedff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d2:	606c                	ld	a1,192(s0)
ffffffffc02005d4:	00001517          	auipc	a0,0x1
ffffffffc02005d8:	6a450513          	addi	a0,a0,1700 # ffffffffc0201c78 <etext+0x4e0>
ffffffffc02005dc:	adfff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e0:	646c                	ld	a1,200(s0)
ffffffffc02005e2:	00001517          	auipc	a0,0x1
ffffffffc02005e6:	6ae50513          	addi	a0,a0,1710 # ffffffffc0201c90 <etext+0x4f8>
ffffffffc02005ea:	ad1ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ee:	686c                	ld	a1,208(s0)
ffffffffc02005f0:	00001517          	auipc	a0,0x1
ffffffffc02005f4:	6b850513          	addi	a0,a0,1720 # ffffffffc0201ca8 <etext+0x510>
ffffffffc02005f8:	ac3ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fc:	6c6c                	ld	a1,216(s0)
ffffffffc02005fe:	00001517          	auipc	a0,0x1
ffffffffc0200602:	6c250513          	addi	a0,a0,1730 # ffffffffc0201cc0 <etext+0x528>
ffffffffc0200606:	ab5ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060a:	706c                	ld	a1,224(s0)
ffffffffc020060c:	00001517          	auipc	a0,0x1
ffffffffc0200610:	6cc50513          	addi	a0,a0,1740 # ffffffffc0201cd8 <etext+0x540>
ffffffffc0200614:	aa7ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200618:	746c                	ld	a1,232(s0)
ffffffffc020061a:	00001517          	auipc	a0,0x1
ffffffffc020061e:	6d650513          	addi	a0,a0,1750 # ffffffffc0201cf0 <etext+0x558>
ffffffffc0200622:	a99ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200626:	786c                	ld	a1,240(s0)
ffffffffc0200628:	00001517          	auipc	a0,0x1
ffffffffc020062c:	6e050513          	addi	a0,a0,1760 # ffffffffc0201d08 <etext+0x570>
ffffffffc0200630:	a8bff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200634:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200636:	6402                	ld	s0,0(sp)
ffffffffc0200638:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063a:	00001517          	auipc	a0,0x1
ffffffffc020063e:	6e650513          	addi	a0,a0,1766 # ffffffffc0201d20 <etext+0x588>
}
ffffffffc0200642:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200644:	bc9d                	j	ffffffffc02000ba <cprintf>

ffffffffc0200646 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200646:	1141                	addi	sp,sp,-16
ffffffffc0200648:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc020064c:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	00001517          	auipc	a0,0x1
ffffffffc0200652:	6ea50513          	addi	a0,a0,1770 # ffffffffc0201d38 <etext+0x5a0>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200656:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200658:	a63ff0ef          	jal	ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc020065c:	8522                	mv	a0,s0
ffffffffc020065e:	e1dff0ef          	jal	ffffffffc020047a <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200662:	10043583          	ld	a1,256(s0)
ffffffffc0200666:	00001517          	auipc	a0,0x1
ffffffffc020066a:	6ea50513          	addi	a0,a0,1770 # ffffffffc0201d50 <etext+0x5b8>
ffffffffc020066e:	a4dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200672:	10843583          	ld	a1,264(s0)
ffffffffc0200676:	00001517          	auipc	a0,0x1
ffffffffc020067a:	6f250513          	addi	a0,a0,1778 # ffffffffc0201d68 <etext+0x5d0>
ffffffffc020067e:	a3dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200682:	11043583          	ld	a1,272(s0)
ffffffffc0200686:	00001517          	auipc	a0,0x1
ffffffffc020068a:	6fa50513          	addi	a0,a0,1786 # ffffffffc0201d80 <etext+0x5e8>
ffffffffc020068e:	a2dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200692:	11843583          	ld	a1,280(s0)
}
ffffffffc0200696:	6402                	ld	s0,0(sp)
ffffffffc0200698:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069a:	00001517          	auipc	a0,0x1
ffffffffc020069e:	6fe50513          	addi	a0,a0,1790 # ffffffffc0201d98 <etext+0x600>
}
ffffffffc02006a2:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a4:	bc19                	j	ffffffffc02000ba <cprintf>

ffffffffc02006a6 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
ffffffffc02006a6:	11853783          	ld	a5,280(a0)
ffffffffc02006aa:	472d                	li	a4,11
ffffffffc02006ac:	0786                	slli	a5,a5,0x1
ffffffffc02006ae:	8385                	srli	a5,a5,0x1
ffffffffc02006b0:	08f76963          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x9c>
ffffffffc02006b4:	00002717          	auipc	a4,0x2
ffffffffc02006b8:	b9c70713          	addi	a4,a4,-1124 # ffffffffc0202250 <commands+0x48>
ffffffffc02006bc:	078a                	slli	a5,a5,0x2
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	439c                	lw	a5,0(a5)
ffffffffc02006c2:	97ba                	add	a5,a5,a4
ffffffffc02006c4:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c6:	00001517          	auipc	a0,0x1
ffffffffc02006ca:	74a50513          	addi	a0,a0,1866 # ffffffffc0201e10 <etext+0x678>
ffffffffc02006ce:	b2f5                	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006d0:	00001517          	auipc	a0,0x1
ffffffffc02006d4:	72050513          	addi	a0,a0,1824 # ffffffffc0201df0 <etext+0x658>
ffffffffc02006d8:	b2cd                	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	6d650513          	addi	a0,a0,1750 # ffffffffc0201db0 <etext+0x618>
ffffffffc02006e2:	bae1                	j	ffffffffc02000ba <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e4:	00001517          	auipc	a0,0x1
ffffffffc02006e8:	74c50513          	addi	a0,a0,1868 # ffffffffc0201e30 <etext+0x698>
ffffffffc02006ec:	b2f9                	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ee:	1141                	addi	sp,sp,-16
ffffffffc02006f0:	e022                	sd	s0,0(sp)
ffffffffc02006f2:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();//这个代码的原型在clock.h中定义
ffffffffc02006f4:	d4bff0ef          	jal	ffffffffc020043e <clock_set_next_event>
            ticks++;//也是在clock.h中被声明为volatile size_t ticks;volatile 是用来告诉编译器这个变量的值可能会被程序以外的因素改变。例如，它可能被硬件、异步事件、或其他线程改变。size_t: 这是一个无符号整型数据类型，用来表示对象的大小
ffffffffc02006f8:	00006797          	auipc	a5,0x6
ffffffffc02006fc:	e8078793          	addi	a5,a5,-384 # ffffffffc0206578 <ticks>
ffffffffc0200700:	6398                	ld	a4,0(a5)
ffffffffc0200702:	00006417          	auipc	s0,0x6
ffffffffc0200706:	e7e40413          	addi	s0,s0,-386 # ffffffffc0206580 <num>
ffffffffc020070a:	0705                	addi	a4,a4,1
ffffffffc020070c:	e398                	sd	a4,0(a5)
            if(ticks%TICK_NUM==0){
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	02e7f7b3          	remu	a5,a5,a4
ffffffffc0200718:	c795                	beqz	a5,ffffffffc0200744 <interrupt_handler+0x9e>
            print_ticks();
            num++;//就在trap.c中就有定义
            }
            if(num==10){
ffffffffc020071a:	6018                	ld	a4,0(s0)
ffffffffc020071c:	47a9                	li	a5,10
ffffffffc020071e:	02f70f63          	beq	a4,a5,ffffffffc020075c <interrupt_handler+0xb6>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200722:	60a2                	ld	ra,8(sp)
ffffffffc0200724:	6402                	ld	s0,0(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	72e50513          	addi	a0,a0,1838 # ffffffffc0201e58 <etext+0x6c0>
ffffffffc0200732:	989ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	69a50513          	addi	a0,a0,1690 # ffffffffc0201dd0 <etext+0x638>
ffffffffc020073e:	97dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	b711                	j	ffffffffc0200646 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200744:	06400593          	li	a1,100
ffffffffc0200748:	00001517          	auipc	a0,0x1
ffffffffc020074c:	70050513          	addi	a0,a0,1792 # ffffffffc0201e48 <etext+0x6b0>
ffffffffc0200750:	96bff0ef          	jal	ffffffffc02000ba <cprintf>
            num++;//就在trap.c中就有定义
ffffffffc0200754:	601c                	ld	a5,0(s0)
ffffffffc0200756:	0785                	addi	a5,a5,1
ffffffffc0200758:	e01c                	sd	a5,0(s0)
ffffffffc020075a:	b7c1                	j	ffffffffc020071a <interrupt_handler+0x74>
}
ffffffffc020075c:	6402                	ld	s0,0(sp)
ffffffffc020075e:	60a2                	ld	ra,8(sp)
ffffffffc0200760:	0141                	addi	sp,sp,16
            sbi_shutdown();//在实验指导书里面写的是shut_down,但是在sbi.c中这个函数英国被命名为sbi_shutdown
ffffffffc0200762:	7a10006f          	j	ffffffffc0201702 <sbi_shutdown>

ffffffffc0200766 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200766:	11853783          	ld	a5,280(a0)
ffffffffc020076a:	0007c763          	bltz	a5,ffffffffc0200778 <trap+0x12>
    switch (tf->cause) {
ffffffffc020076e:	472d                	li	a4,11
ffffffffc0200770:	00f76363          	bltu	a4,a5,ffffffffc0200776 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200774:	8082                	ret
            print_trapframe(tf);
ffffffffc0200776:	bdc1                	j	ffffffffc0200646 <print_trapframe>
        interrupt_handler(tf);
ffffffffc0200778:	b73d                	j	ffffffffc02006a6 <interrupt_handler>
	...

ffffffffc020077c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020077c:	14011073          	csrw	sscratch,sp
ffffffffc0200780:	712d                	addi	sp,sp,-288
ffffffffc0200782:	e002                	sd	zero,0(sp)
ffffffffc0200784:	e406                	sd	ra,8(sp)
ffffffffc0200786:	ec0e                	sd	gp,24(sp)
ffffffffc0200788:	f012                	sd	tp,32(sp)
ffffffffc020078a:	f416                	sd	t0,40(sp)
ffffffffc020078c:	f81a                	sd	t1,48(sp)
ffffffffc020078e:	fc1e                	sd	t2,56(sp)
ffffffffc0200790:	e0a2                	sd	s0,64(sp)
ffffffffc0200792:	e4a6                	sd	s1,72(sp)
ffffffffc0200794:	e8aa                	sd	a0,80(sp)
ffffffffc0200796:	ecae                	sd	a1,88(sp)
ffffffffc0200798:	f0b2                	sd	a2,96(sp)
ffffffffc020079a:	f4b6                	sd	a3,104(sp)
ffffffffc020079c:	f8ba                	sd	a4,112(sp)
ffffffffc020079e:	fcbe                	sd	a5,120(sp)
ffffffffc02007a0:	e142                	sd	a6,128(sp)
ffffffffc02007a2:	e546                	sd	a7,136(sp)
ffffffffc02007a4:	e94a                	sd	s2,144(sp)
ffffffffc02007a6:	ed4e                	sd	s3,152(sp)
ffffffffc02007a8:	f152                	sd	s4,160(sp)
ffffffffc02007aa:	f556                	sd	s5,168(sp)
ffffffffc02007ac:	f95a                	sd	s6,176(sp)
ffffffffc02007ae:	fd5e                	sd	s7,184(sp)
ffffffffc02007b0:	e1e2                	sd	s8,192(sp)
ffffffffc02007b2:	e5e6                	sd	s9,200(sp)
ffffffffc02007b4:	e9ea                	sd	s10,208(sp)
ffffffffc02007b6:	edee                	sd	s11,216(sp)
ffffffffc02007b8:	f1f2                	sd	t3,224(sp)
ffffffffc02007ba:	f5f6                	sd	t4,232(sp)
ffffffffc02007bc:	f9fa                	sd	t5,240(sp)
ffffffffc02007be:	fdfe                	sd	t6,248(sp)
ffffffffc02007c0:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007c4:	100024f3          	csrr	s1,sstatus
ffffffffc02007c8:	14102973          	csrr	s2,sepc
ffffffffc02007cc:	143029f3          	csrr	s3,stval
ffffffffc02007d0:	14202a73          	csrr	s4,scause
ffffffffc02007d4:	e822                	sd	s0,16(sp)
ffffffffc02007d6:	e226                	sd	s1,256(sp)
ffffffffc02007d8:	e64a                	sd	s2,264(sp)
ffffffffc02007da:	ea4e                	sd	s3,272(sp)
ffffffffc02007dc:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007de:	850a                	mv	a0,sp
    jal trap
ffffffffc02007e0:	f87ff0ef          	jal	ffffffffc0200766 <trap>

ffffffffc02007e4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007e4:	6492                	ld	s1,256(sp)
ffffffffc02007e6:	6932                	ld	s2,264(sp)
ffffffffc02007e8:	10049073          	csrw	sstatus,s1
ffffffffc02007ec:	14191073          	csrw	sepc,s2
ffffffffc02007f0:	60a2                	ld	ra,8(sp)
ffffffffc02007f2:	61e2                	ld	gp,24(sp)
ffffffffc02007f4:	7202                	ld	tp,32(sp)
ffffffffc02007f6:	72a2                	ld	t0,40(sp)
ffffffffc02007f8:	7342                	ld	t1,48(sp)
ffffffffc02007fa:	73e2                	ld	t2,56(sp)
ffffffffc02007fc:	6406                	ld	s0,64(sp)
ffffffffc02007fe:	64a6                	ld	s1,72(sp)
ffffffffc0200800:	6546                	ld	a0,80(sp)
ffffffffc0200802:	65e6                	ld	a1,88(sp)
ffffffffc0200804:	7606                	ld	a2,96(sp)
ffffffffc0200806:	76a6                	ld	a3,104(sp)
ffffffffc0200808:	7746                	ld	a4,112(sp)
ffffffffc020080a:	77e6                	ld	a5,120(sp)
ffffffffc020080c:	680a                	ld	a6,128(sp)
ffffffffc020080e:	68aa                	ld	a7,136(sp)
ffffffffc0200810:	694a                	ld	s2,144(sp)
ffffffffc0200812:	69ea                	ld	s3,152(sp)
ffffffffc0200814:	7a0a                	ld	s4,160(sp)
ffffffffc0200816:	7aaa                	ld	s5,168(sp)
ffffffffc0200818:	7b4a                	ld	s6,176(sp)
ffffffffc020081a:	7bea                	ld	s7,184(sp)
ffffffffc020081c:	6c0e                	ld	s8,192(sp)
ffffffffc020081e:	6cae                	ld	s9,200(sp)
ffffffffc0200820:	6d4e                	ld	s10,208(sp)
ffffffffc0200822:	6dee                	ld	s11,216(sp)
ffffffffc0200824:	7e0e                	ld	t3,224(sp)
ffffffffc0200826:	7eae                	ld	t4,232(sp)
ffffffffc0200828:	7f4e                	ld	t5,240(sp)
ffffffffc020082a:	7fee                	ld	t6,248(sp)
ffffffffc020082c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc020082e:	10200073          	sret

ffffffffc0200832 <buddy_init>:
}

static void
buddy_init() {

}
ffffffffc0200832:	8082                	ret

ffffffffc0200834 <buddy_nr_free_pages>:


static size_t
buddy_nr_free_pages(void) {
    size_t total_free_pages = 0;
    for (int i = 0; i < id_; i++) {
ffffffffc0200834:	00006697          	auipc	a3,0x6
ffffffffc0200838:	d546a683          	lw	a3,-684(a3) # ffffffffc0206588 <id_>
ffffffffc020083c:	02d05063          	blez	a3,ffffffffc020085c <buddy_nr_free_pages+0x28>
ffffffffc0200840:	00006797          	auipc	a5,0x6
ffffffffc0200844:	80078793          	addi	a5,a5,-2048 # ffffffffc0206040 <b+0x10>
ffffffffc0200848:	0696                	slli	a3,a3,0x5
ffffffffc020084a:	96be                	add	a3,a3,a5
    size_t total_free_pages = 0;
ffffffffc020084c:	4501                	li	a0,0
        total_free_pages += b[i].curr_free;
ffffffffc020084e:	6398                	ld	a4,0(a5)
    for (int i = 0; i < id_; i++) {
ffffffffc0200850:	02078793          	addi	a5,a5,32
        total_free_pages += b[i].curr_free;
ffffffffc0200854:	953a                	add	a0,a0,a4
    for (int i = 0; i < id_; i++) {
ffffffffc0200856:	fed79ce3          	bne	a5,a3,ffffffffc020084e <buddy_nr_free_pages+0x1a>
ffffffffc020085a:	8082                	ret
    size_t total_free_pages = 0;
ffffffffc020085c:	4501                	li	a0,0
    }
    return total_free_pages;
}
ffffffffc020085e:	8082                	ret

ffffffffc0200860 <buddy_free_pages>:
    for(int i = 0 ; i < id_ ; i++){//寻找base在哪个b[i]里
ffffffffc0200860:	00006617          	auipc	a2,0x6
ffffffffc0200864:	d2862603          	lw	a2,-728(a2) # ffffffffc0206588 <id_>
ffffffffc0200868:	12c05e63          	blez	a2,ffffffffc02009a4 <buddy_free_pages+0x144>
ffffffffc020086c:	00005797          	auipc	a5,0x5
ffffffffc0200870:	7c478793          	addi	a5,a5,1988 # ffffffffc0206030 <b>
ffffffffc0200874:	0616                	slli	a2,a2,0x5
ffffffffc0200876:	963e                	add	a2,a2,a5
    struct buddy *bu = NULL;
ffffffffc0200878:	4801                	li	a6,0
        if(base >= bb -> begin_page && base < bb -> begin_page + bb -> size){
ffffffffc020087a:	6f98                	ld	a4,24(a5)
ffffffffc020087c:	00e56b63          	bltu	a0,a4,ffffffffc0200892 <buddy_free_pages+0x32>
ffffffffc0200880:	638c                	ld	a1,0(a5)
ffffffffc0200882:	00259693          	slli	a3,a1,0x2
ffffffffc0200886:	96ae                	add	a3,a3,a1
ffffffffc0200888:	068e                	slli	a3,a3,0x3
ffffffffc020088a:	9736                	add	a4,a4,a3
ffffffffc020088c:	00e57363          	bgeu	a0,a4,ffffffffc0200892 <buddy_free_pages+0x32>
            bu = bb;
ffffffffc0200890:	883e                	mv	a6,a5
    for(int i = 0 ; i < id_ ; i++){//寻找base在哪个b[i]里
ffffffffc0200892:	02078793          	addi	a5,a5,32
ffffffffc0200896:	fef612e3          	bne	a2,a5,ffffffffc020087a <buddy_free_pages+0x1a>
    unsigned offset = base - bu->begin_page;
ffffffffc020089a:	fcccd7b7          	lui	a5,0xfcccd
ffffffffc020089e:	ccd78793          	addi	a5,a5,-819 # fffffffffccccccd <end+0x3cac66fd>
ffffffffc02008a2:	07b2                	slli	a5,a5,0xc
ffffffffc02008a4:	01883703          	ld	a4,24(a6)
ffffffffc02008a8:	ccd78793          	addi	a5,a5,-819
ffffffffc02008ac:	07b2                	slli	a5,a5,0xc
ffffffffc02008ae:	ccd78793          	addi	a5,a5,-819
ffffffffc02008b2:	8d19                	sub	a0,a0,a4
ffffffffc02008b4:	07b2                	slli	a5,a5,0xc
ffffffffc02008b6:	ccd78793          	addi	a5,a5,-819
ffffffffc02008ba:	850d                	srai	a0,a0,0x3
ffffffffc02008bc:	02f50533          	mul	a0,a0,a5
    assert(bu && offset >= 0 && offset < bu->size);
ffffffffc02008c0:	00083783          	ld	a5,0(a6)
ffffffffc02008c4:	02051713          	slli	a4,a0,0x20
ffffffffc02008c8:	9301                	srli	a4,a4,0x20
    unsigned offset = base - bu->begin_page;
ffffffffc02008ca:	2501                	sext.w	a0,a0
    assert(bu && offset >= 0 && offset < bu->size);
ffffffffc02008cc:	0af77a63          	bgeu	a4,a5,ffffffffc0200980 <buddy_free_pages+0x120>
    index = offset + bu->size - 1;
ffffffffc02008d0:	37fd                	addiw	a5,a5,-1
    for (; bu->longest[index]; index = PARENT(index)) {
ffffffffc02008d2:	00883583          	ld	a1,8(a6)
    index = offset + bu->size - 1;
ffffffffc02008d6:	9fa9                	addw	a5,a5,a0
    for (; bu->longest[index]; index = PARENT(index)) {
ffffffffc02008d8:	02079713          	slli	a4,a5,0x20
ffffffffc02008dc:	01d75693          	srli	a3,a4,0x1d
ffffffffc02008e0:	96ae                	add	a3,a3,a1
ffffffffc02008e2:	6298                	ld	a4,0(a3)
ffffffffc02008e4:	cb59                	beqz	a4,ffffffffc020097a <buddy_free_pages+0x11a>
        node_size *= 2;
ffffffffc02008e6:	4709                	li	a4,2
        if (index == 0)
ffffffffc02008e8:	e789                	bnez	a5,ffffffffc02008f2 <buddy_free_pages+0x92>
ffffffffc02008ea:	8082                	ret
        node_size *= 2;
ffffffffc02008ec:	0017171b          	slliw	a4,a4,0x1
        if (index == 0)
ffffffffc02008f0:	c7c1                	beqz	a5,ffffffffc0200978 <buddy_free_pages+0x118>
    for (; bu->longest[index]; index = PARENT(index)) {
ffffffffc02008f2:	2785                	addiw	a5,a5,1
ffffffffc02008f4:	0017d79b          	srliw	a5,a5,0x1
ffffffffc02008f8:	37fd                	addiw	a5,a5,-1
ffffffffc02008fa:	02079613          	slli	a2,a5,0x20
ffffffffc02008fe:	01d65693          	srli	a3,a2,0x1d
ffffffffc0200902:	96ae                	add	a3,a3,a1
ffffffffc0200904:	6290                	ld	a2,0(a3)
ffffffffc0200906:	f27d                	bnez	a2,ffffffffc02008ec <buddy_free_pages+0x8c>
    bu->longest[index] = node_size;
ffffffffc0200908:	02071613          	slli	a2,a4,0x20
ffffffffc020090c:	9201                	srli	a2,a2,0x20
ffffffffc020090e:	e290                	sd	a2,0(a3)
    bu->curr_free += node_size;
ffffffffc0200910:	01083683          	ld	a3,16(a6)
ffffffffc0200914:	96b2                	add	a3,a3,a2
ffffffffc0200916:	00d83823          	sd	a3,16(a6)
    while (index) {
ffffffffc020091a:	cfb9                	beqz	a5,ffffffffc0200978 <buddy_free_pages+0x118>
        index = PARENT(index); // 移动到父节点
ffffffffc020091c:	2785                	addiw	a5,a5,1
ffffffffc020091e:	0017d61b          	srliw	a2,a5,0x1
ffffffffc0200922:	367d                	addiw	a2,a2,-1
        left_longest = bu->longest[LEFT_LEAF(index)];
ffffffffc0200924:	0016169b          	slliw	a3,a2,0x1
        right_longest = bu->longest[RIGHT_LEAF(index)];
ffffffffc0200928:	9bf9                	andi	a5,a5,-2
        left_longest = bu->longest[LEFT_LEAF(index)];
ffffffffc020092a:	2685                	addiw	a3,a3,1
        right_longest = bu->longest[RIGHT_LEAF(index)];
ffffffffc020092c:	1782                	slli	a5,a5,0x20
        left_longest = bu->longest[LEFT_LEAF(index)];
ffffffffc020092e:	02069513          	slli	a0,a3,0x20
        right_longest = bu->longest[RIGHT_LEAF(index)];
ffffffffc0200932:	9381                	srli	a5,a5,0x20
        left_longest = bu->longest[LEFT_LEAF(index)];
ffffffffc0200934:	01d55693          	srli	a3,a0,0x1d
        right_longest = bu->longest[RIGHT_LEAF(index)];
ffffffffc0200938:	078e                	slli	a5,a5,0x3
        left_longest = bu->longest[LEFT_LEAF(index)];
ffffffffc020093a:	96ae                	add	a3,a3,a1
        right_longest = bu->longest[RIGHT_LEAF(index)];
ffffffffc020093c:	97ae                	add	a5,a5,a1
        left_longest = bu->longest[LEFT_LEAF(index)];
ffffffffc020093e:	0006a883          	lw	a7,0(a3)
        right_longest = bu->longest[RIGHT_LEAF(index)];
ffffffffc0200942:	0007a803          	lw	a6,0(a5)
        node_size *= 2; // 节点大小翻倍
ffffffffc0200946:	0017169b          	slliw	a3,a4,0x1
            bu->longest[index] = node_size;
ffffffffc020094a:	02061793          	slli	a5,a2,0x20
ffffffffc020094e:	01d7d513          	srli	a0,a5,0x1d
        node_size *= 2; // 节点大小翻倍
ffffffffc0200952:	0006871b          	sext.w	a4,a3
        if (left_longest + right_longest == node_size)
ffffffffc0200956:	0118033b          	addw	t1,a6,a7
        index = PARENT(index); // 移动到父节点
ffffffffc020095a:	0006079b          	sext.w	a5,a2
            bu->longest[index] = node_size;
ffffffffc020095e:	00a58633          	add	a2,a1,a0
        if (left_longest + right_longest == node_size)
ffffffffc0200962:	00e30663          	beq	t1,a4,ffffffffc020096e <buddy_free_pages+0x10e>
            bu->longest[index] = MAX(left_longest, right_longest);
ffffffffc0200966:	86c2                	mv	a3,a6
ffffffffc0200968:	01187363          	bgeu	a6,a7,ffffffffc020096e <buddy_free_pages+0x10e>
ffffffffc020096c:	86c6                	mv	a3,a7
ffffffffc020096e:	1682                	slli	a3,a3,0x20
ffffffffc0200970:	9281                	srli	a3,a3,0x20
            bu->longest[index] = node_size;
ffffffffc0200972:	e214                	sd	a3,0(a2)
    while (index) {
ffffffffc0200974:	f7c5                	bnez	a5,ffffffffc020091c <buddy_free_pages+0xbc>
ffffffffc0200976:	8082                	ret
ffffffffc0200978:	8082                	ret
    for (; bu->longest[index]; index = PARENT(index)) {
ffffffffc020097a:	4605                	li	a2,1
    node_size = 1;
ffffffffc020097c:	4705                	li	a4,1
ffffffffc020097e:	bf41                	j	ffffffffc020090e <buddy_free_pages+0xae>
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200980:	1141                	addi	sp,sp,-16
    assert(bu && offset >= 0 && offset < bu->size);
ffffffffc0200982:	00001697          	auipc	a3,0x1
ffffffffc0200986:	4f668693          	addi	a3,a3,1270 # ffffffffc0201e78 <etext+0x6e0>
ffffffffc020098a:	00001617          	auipc	a2,0x1
ffffffffc020098e:	51660613          	addi	a2,a2,1302 # ffffffffc0201ea0 <etext+0x708>
ffffffffc0200992:	09600593          	li	a1,150
ffffffffc0200996:	00001517          	auipc	a0,0x1
ffffffffc020099a:	52250513          	addi	a0,a0,1314 # ffffffffc0201eb8 <etext+0x720>
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc020099e:	e406                	sd	ra,8(sp)
    assert(bu && offset >= 0 && offset < bu->size);
ffffffffc02009a0:	a0fff0ef          	jal	ffffffffc02003ae <__panic>
    unsigned offset = base - bu->begin_page;
ffffffffc02009a4:	01803783          	ld	a5,24(zero) # 18 <kern_entry-0xffffffffc01fffe8>
ffffffffc02009a8:	9002                	ebreak

ffffffffc02009aa <buddy_alloc_pages>:
    assert(n > 0);
ffffffffc02009aa:	10050463          	beqz	a0,ffffffffc0200ab2 <buddy_alloc_pages+0x108>
    if (!IS_POWER_OF_2(n))
ffffffffc02009ae:	fff50793          	addi	a5,a0,-1
ffffffffc02009b2:	8fe9                	and	a5,a5,a0
ffffffffc02009b4:	e7f1                	bnez	a5,ffffffffc0200a80 <buddy_alloc_pages+0xd6>
    for (int i = 0; i < id_; i++) {
ffffffffc02009b6:	00006597          	auipc	a1,0x6
ffffffffc02009ba:	bd25a583          	lw	a1,-1070(a1) # ffffffffc0206588 <id_>
ffffffffc02009be:	0ab05f63          	blez	a1,ffffffffc0200a7c <buddy_alloc_pages+0xd2>
ffffffffc02009c2:	00005717          	auipc	a4,0x5
ffffffffc02009c6:	67670713          	addi	a4,a4,1654 # ffffffffc0206038 <b+0x8>
ffffffffc02009ca:	4781                	li	a5,0
ffffffffc02009cc:	a031                	j	ffffffffc02009d8 <buddy_alloc_pages+0x2e>
ffffffffc02009ce:	2785                	addiw	a5,a5,1
ffffffffc02009d0:	02070713          	addi	a4,a4,32
ffffffffc02009d4:	0ab78463          	beq	a5,a1,ffffffffc0200a7c <buddy_alloc_pages+0xd2>
        if (b[i].longest[index] >= n) {
ffffffffc02009d8:	6314                	ld	a3,0(a4)
ffffffffc02009da:	6290                	ld	a2,0(a3)
ffffffffc02009dc:	fea669e3          	bltu	a2,a0,ffffffffc02009ce <buddy_alloc_pages+0x24>
    for (node_size = buddy->size; node_size != n; node_size /= 2) {
ffffffffc02009e0:	00579893          	slli	a7,a5,0x5
ffffffffc02009e4:	00005317          	auipc	t1,0x5
ffffffffc02009e8:	64c30313          	addi	t1,t1,1612 # ffffffffc0206030 <b>
ffffffffc02009ec:	01130733          	add	a4,t1,a7
ffffffffc02009f0:	6310                	ld	a2,0(a4)
    size_t index = 0;
ffffffffc02009f2:	4781                	li	a5,0
    for (node_size = buddy->size; node_size != n; node_size /= 2) {
ffffffffc02009f4:	00c51863          	bne	a0,a2,ffffffffc0200a04 <buddy_alloc_pages+0x5a>
ffffffffc02009f8:	a075                	j	ffffffffc0200aa4 <buddy_alloc_pages+0xfa>
            index = LEFT_LEAF(index);
ffffffffc02009fa:	0786                	slli	a5,a5,0x1
    for (node_size = buddy->size; node_size != n; node_size /= 2) {
ffffffffc02009fc:	8205                	srli	a2,a2,0x1
            index = LEFT_LEAF(index);
ffffffffc02009fe:	0785                	addi	a5,a5,1
    for (node_size = buddy->size; node_size != n; node_size /= 2) {
ffffffffc0200a00:	00c50d63          	beq	a0,a2,ffffffffc0200a1a <buddy_alloc_pages+0x70>
        if (buddy->longest[LEFT_LEAF(index)] >= n)
ffffffffc0200a04:	00479713          	slli	a4,a5,0x4
ffffffffc0200a08:	9736                	add	a4,a4,a3
ffffffffc0200a0a:	6718                	ld	a4,8(a4)
ffffffffc0200a0c:	fea777e3          	bgeu	a4,a0,ffffffffc02009fa <buddy_alloc_pages+0x50>
            index = RIGHT_LEAF(index);
ffffffffc0200a10:	0785                	addi	a5,a5,1
    for (node_size = buddy->size; node_size != n; node_size /= 2) {
ffffffffc0200a12:	8205                	srli	a2,a2,0x1
            index = RIGHT_LEAF(index);
ffffffffc0200a14:	0786                	slli	a5,a5,0x1
    for (node_size = buddy->size; node_size != n; node_size /= 2) {
ffffffffc0200a16:	fec517e3          	bne	a0,a2,ffffffffc0200a04 <buddy_alloc_pages+0x5a>
    offset = (index + 1) * node_size - buddy->size;
ffffffffc0200a1a:	00178713          	addi	a4,a5,1
ffffffffc0200a1e:	02a70833          	mul	a6,a4,a0
    buddy->longest[index] = 0;
ffffffffc0200a22:	00379613          	slli	a2,a5,0x3
ffffffffc0200a26:	9636                	add	a2,a2,a3
ffffffffc0200a28:	00063023          	sd	zero,0(a2)
    offset = (index + 1) * node_size - buddy->size;
ffffffffc0200a2c:	01130633          	add	a2,t1,a7
ffffffffc0200a30:	6210                	ld	a2,0(a2)
ffffffffc0200a32:	40c80833          	sub	a6,a6,a2
    while (index) {
ffffffffc0200a36:	e781                	bnez	a5,ffffffffc0200a3e <buddy_alloc_pages+0x94>
ffffffffc0200a38:	a02d                	j	ffffffffc0200a62 <buddy_alloc_pages+0xb8>
ffffffffc0200a3a:	00178713          	addi	a4,a5,1
        index = PARENT(index);
ffffffffc0200a3e:	8305                	srli	a4,a4,0x1
ffffffffc0200a40:	fff70793          	addi	a5,a4,-1
        buddy->longest[index] = MAX(buddy->longest[LEFT_LEAF(index)], buddy->longest[RIGHT_LEAF(index)]);
ffffffffc0200a44:	00479613          	slli	a2,a5,0x4
ffffffffc0200a48:	0712                	slli	a4,a4,0x4
ffffffffc0200a4a:	9736                	add	a4,a4,a3
ffffffffc0200a4c:	9636                	add	a2,a2,a3
ffffffffc0200a4e:	630c                	ld	a1,0(a4)
ffffffffc0200a50:	6610                	ld	a2,8(a2)
ffffffffc0200a52:	00379713          	slli	a4,a5,0x3
ffffffffc0200a56:	9736                	add	a4,a4,a3
ffffffffc0200a58:	00b67363          	bgeu	a2,a1,ffffffffc0200a5e <buddy_alloc_pages+0xb4>
ffffffffc0200a5c:	862e                	mv	a2,a1
ffffffffc0200a5e:	e310                	sd	a2,0(a4)
    while (index) {
ffffffffc0200a60:	ffe9                	bnez	a5,ffffffffc0200a3a <buddy_alloc_pages+0x90>
    buddy->curr_free -= n;
ffffffffc0200a62:	011307b3          	add	a5,t1,a7
ffffffffc0200a66:	6b90                	ld	a2,16(a5)
    return buddy->begin_page + offset;
ffffffffc0200a68:	6f98                	ld	a4,24(a5)
ffffffffc0200a6a:	00281693          	slli	a3,a6,0x2
ffffffffc0200a6e:	96c2                	add	a3,a3,a6
    buddy->curr_free -= n;
ffffffffc0200a70:	8e09                	sub	a2,a2,a0
    return buddy->begin_page + offset;
ffffffffc0200a72:	068e                	slli	a3,a3,0x3
    buddy->curr_free -= n;
ffffffffc0200a74:	eb90                	sd	a2,16(a5)
    return buddy->begin_page + offset;
ffffffffc0200a76:	00d70533          	add	a0,a4,a3
ffffffffc0200a7a:	8082                	ret
        return NULL;
ffffffffc0200a7c:	4501                	li	a0,0
}
ffffffffc0200a7e:	8082                	ret
    size |= size >> 1;
ffffffffc0200a80:	00155793          	srli	a5,a0,0x1
ffffffffc0200a84:	8fc9                	or	a5,a5,a0
    size |= size >> 2;
ffffffffc0200a86:	0027d713          	srli	a4,a5,0x2
ffffffffc0200a8a:	8fd9                	or	a5,a5,a4
    size |= size >> 4;
ffffffffc0200a8c:	0047d713          	srli	a4,a5,0x4
ffffffffc0200a90:	8fd9                	or	a5,a5,a4
    size |= size >> 8;
ffffffffc0200a92:	0087d713          	srli	a4,a5,0x8
ffffffffc0200a96:	8fd9                	or	a5,a5,a4
    size |= size >> 16;
ffffffffc0200a98:	0107d713          	srli	a4,a5,0x10
ffffffffc0200a9c:	8fd9                	or	a5,a5,a4
    return size + 1;
ffffffffc0200a9e:	00178513          	addi	a0,a5,1
ffffffffc0200aa2:	bf11                	j	ffffffffc02009b6 <buddy_alloc_pages+0xc>
    buddy->longest[index] = 0;
ffffffffc0200aa4:	0006b023          	sd	zero,0(a3)
    offset = (index + 1) * node_size - buddy->size;
ffffffffc0200aa8:	00073803          	ld	a6,0(a4)
ffffffffc0200aac:	41050833          	sub	a6,a0,a6
    while (index) {
ffffffffc0200ab0:	bf4d                	j	ffffffffc0200a62 <buddy_alloc_pages+0xb8>
static struct Page *buddy_alloc_pages(size_t n) {
ffffffffc0200ab2:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200ab4:	00001697          	auipc	a3,0x1
ffffffffc0200ab8:	41c68693          	addi	a3,a3,1052 # ffffffffc0201ed0 <etext+0x738>
ffffffffc0200abc:	00001617          	auipc	a2,0x1
ffffffffc0200ac0:	3e460613          	addi	a2,a2,996 # ffffffffc0201ea0 <etext+0x708>
ffffffffc0200ac4:	04f00593          	li	a1,79
ffffffffc0200ac8:	00001517          	auipc	a0,0x1
ffffffffc0200acc:	3f050513          	addi	a0,a0,1008 # ffffffffc0201eb8 <etext+0x720>
static struct Page *buddy_alloc_pages(size_t n) {
ffffffffc0200ad0:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200ad2:	8ddff0ef          	jal	ffffffffc02003ae <__panic>

ffffffffc0200ad6 <buddy_check>:


static void
buddy_check(void) {
ffffffffc0200ad6:	1141                	addi	sp,sp,-16

    cprintf("New test case: testing memory block validation...\n");
ffffffffc0200ad8:	00001517          	auipc	a0,0x1
ffffffffc0200adc:	40050513          	addi	a0,a0,1024 # ffffffffc0201ed8 <etext+0x740>
buddy_check(void) {
ffffffffc0200ae0:	e406                	sd	ra,8(sp)
ffffffffc0200ae2:	e022                	sd	s0,0(sp)
    cprintf("New test case: testing memory block validation...\n");
ffffffffc0200ae4:	dd6ff0ef          	jal	ffffffffc02000ba <cprintf>

    // 分配一页内存
    struct Page *p_ = buddy_alloc_pages(1);  // 假定1表示一页
ffffffffc0200ae8:	4505                	li	a0,1
ffffffffc0200aea:	ec1ff0ef          	jal	ffffffffc02009aa <buddy_alloc_pages>
    assert(p_ != NULL);
ffffffffc0200aee:	c549                	beqz	a0,ffffffffc0200b78 <buddy_check+0xa2>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200af0:	fcccd7b7          	lui	a5,0xfcccd
ffffffffc0200af4:	ccd78793          	addi	a5,a5,-819 # fffffffffccccccd <end+0x3cac66fd>
ffffffffc0200af8:	07b2                	slli	a5,a5,0xc
ffffffffc0200afa:	ccd78793          	addi	a5,a5,-819
ffffffffc0200afe:	07b2                	slli	a5,a5,0xc
ffffffffc0200b00:	ccd78793          	addi	a5,a5,-819
ffffffffc0200b04:	00006697          	auipc	a3,0x6
ffffffffc0200b08:	ab46b683          	ld	a3,-1356(a3) # ffffffffc02065b8 <pages>
ffffffffc0200b0c:	40d506b3          	sub	a3,a0,a3
ffffffffc0200b10:	07b2                	slli	a5,a5,0xc
ffffffffc0200b12:	ccd78793          	addi	a5,a5,-819
ffffffffc0200b16:	868d                	srai	a3,a3,0x3
ffffffffc0200b18:	02f686b3          	mul	a3,a3,a5
ffffffffc0200b1c:	00002797          	auipc	a5,0x2
ffffffffc0200b20:	92c7b783          	ld	a5,-1748(a5) # ffffffffc0202448 <nbase>

    // 获取页面的物理地址，并转换为可用的虚拟地址。这里需要根据你的实现来完成。
    // 注意：你可能需要使用其他函数来获取/转换地址，依据你的内核/平台实现。
    uintptr_t pa = page2pa(p_);
    uintptr_t *va = KADDR(pa);
ffffffffc0200b24:	00006717          	auipc	a4,0x6
ffffffffc0200b28:	a8c73703          	ld	a4,-1396(a4) # ffffffffc02065b0 <npage>
ffffffffc0200b2c:	842a                	mv	s0,a0
ffffffffc0200b2e:	96be                	add	a3,a3,a5
ffffffffc0200b30:	00c69793          	slli	a5,a3,0xc
ffffffffc0200b34:	83b1                	srli	a5,a5,0xc

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b36:	06b2                	slli	a3,a3,0xc
ffffffffc0200b38:	08e7f063          	bgeu	a5,a4,ffffffffc0200bb8 <buddy_check+0xe2>

    // 写入数据到分配的内存块
    int *data_ptr = (int *)va;
    *data_ptr = 0xdeadbeef;  // 写入一个魔数，稍后用于验证
ffffffffc0200b3c:	00006797          	auipc	a5,0x6
ffffffffc0200b40:	a6c7b783          	ld	a5,-1428(a5) # ffffffffc02065a8 <va_pa_offset>
ffffffffc0200b44:	deadc737          	lui	a4,0xdeadc
ffffffffc0200b48:	97b6                	add	a5,a5,a3
ffffffffc0200b4a:	eef70713          	addi	a4,a4,-273 # ffffffffdeadbeef <end+0x1e8d591f>
ffffffffc0200b4e:	c398                	sw	a4,0(a5)

    // 读取并验证数据
    assert(*data_ptr == 0xdeadbeef);

    // 释放内存块
    buddy_free_pages(p_, 1);
ffffffffc0200b50:	4585                	li	a1,1
ffffffffc0200b52:	d0fff0ef          	jal	ffffffffc0200860 <buddy_free_pages>

    // 验证是否可以正常释放，例如再次分配相同的内存块并检查地址是否相同
    struct Page *p_2 = buddy_alloc_pages(1);
ffffffffc0200b56:	4505                	li	a0,1
ffffffffc0200b58:	e53ff0ef          	jal	ffffffffc02009aa <buddy_alloc_pages>
    assert(p_ == p_2);  // 假定相同的内存块地址会被重新分配，这取决于你的内存分配器实现
ffffffffc0200b5c:	02a41e63          	bne	s0,a0,ffffffffc0200b98 <buddy_check+0xc2>

    // 清理
    buddy_free_pages(p_2, 1);
ffffffffc0200b60:	4585                	li	a1,1
ffffffffc0200b62:	cffff0ef          	jal	ffffffffc0200860 <buddy_free_pages>

    cprintf("Memory block validation test passed!\n");
}
ffffffffc0200b66:	6402                	ld	s0,0(sp)
ffffffffc0200b68:	60a2                	ld	ra,8(sp)
    cprintf("Memory block validation test passed!\n");
ffffffffc0200b6a:	00001517          	auipc	a0,0x1
ffffffffc0200b6e:	3ee50513          	addi	a0,a0,1006 # ffffffffc0201f58 <etext+0x7c0>
}
ffffffffc0200b72:	0141                	addi	sp,sp,16
    cprintf("Memory block validation test passed!\n");
ffffffffc0200b74:	d46ff06f          	j	ffffffffc02000ba <cprintf>
    assert(p_ != NULL);
ffffffffc0200b78:	00001697          	auipc	a3,0x1
ffffffffc0200b7c:	39868693          	addi	a3,a3,920 # ffffffffc0201f10 <etext+0x778>
ffffffffc0200b80:	00001617          	auipc	a2,0x1
ffffffffc0200b84:	32060613          	addi	a2,a2,800 # ffffffffc0201ea0 <etext+0x708>
ffffffffc0200b88:	0cf00593          	li	a1,207
ffffffffc0200b8c:	00001517          	auipc	a0,0x1
ffffffffc0200b90:	32c50513          	addi	a0,a0,812 # ffffffffc0201eb8 <etext+0x720>
ffffffffc0200b94:	81bff0ef          	jal	ffffffffc02003ae <__panic>
    assert(p_ == p_2);  // 假定相同的内存块地址会被重新分配，这取决于你的内存分配器实现
ffffffffc0200b98:	00001697          	auipc	a3,0x1
ffffffffc0200b9c:	3b068693          	addi	a3,a3,944 # ffffffffc0201f48 <etext+0x7b0>
ffffffffc0200ba0:	00001617          	auipc	a2,0x1
ffffffffc0200ba4:	30060613          	addi	a2,a2,768 # ffffffffc0201ea0 <etext+0x708>
ffffffffc0200ba8:	0e200593          	li	a1,226
ffffffffc0200bac:	00001517          	auipc	a0,0x1
ffffffffc0200bb0:	30c50513          	addi	a0,a0,780 # ffffffffc0201eb8 <etext+0x720>
ffffffffc0200bb4:	ffaff0ef          	jal	ffffffffc02003ae <__panic>
    uintptr_t *va = KADDR(pa);
ffffffffc0200bb8:	00001617          	auipc	a2,0x1
ffffffffc0200bbc:	36860613          	addi	a2,a2,872 # ffffffffc0201f20 <etext+0x788>
ffffffffc0200bc0:	0d400593          	li	a1,212
ffffffffc0200bc4:	00001517          	auipc	a0,0x1
ffffffffc0200bc8:	2f450513          	addi	a0,a0,756 # ffffffffc0201eb8 <etext+0x720>
ffffffffc0200bcc:	fe2ff0ef          	jal	ffffffffc02003ae <__panic>

ffffffffc0200bd0 <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200bd0:	1101                	addi	sp,sp,-32
ffffffffc0200bd2:	e426                	sd	s1,8(sp)
ffffffffc0200bd4:	84aa                	mv	s1,a0
    cprintf("n: %d\n", n);
ffffffffc0200bd6:	00001517          	auipc	a0,0x1
ffffffffc0200bda:	3aa50513          	addi	a0,a0,938 # ffffffffc0201f80 <etext+0x7e8>
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200bde:	e822                	sd	s0,16(sp)
ffffffffc0200be0:	ec06                	sd	ra,24(sp)
ffffffffc0200be2:	842e                	mv	s0,a1
    cprintf("n: %d\n", n);
ffffffffc0200be4:	cd6ff0ef          	jal	ffffffffc02000ba <cprintf>
    struct buddy *buddy = &b[id_++];
ffffffffc0200be8:	00006697          	auipc	a3,0x6
ffffffffc0200bec:	9a068693          	addi	a3,a3,-1632 # ffffffffc0206588 <id_>
ffffffffc0200bf0:	4298                	lw	a4,0(a3)
    if(!IS_POWER_OF_2(n)){
ffffffffc0200bf2:	fff40793          	addi	a5,s0,-1
ffffffffc0200bf6:	8fe1                	and	a5,a5,s0
    struct buddy *buddy = &b[id_++];
ffffffffc0200bf8:	0017061b          	addiw	a2,a4,1
ffffffffc0200bfc:	c290                	sw	a2,0(a3)
    if(!IS_POWER_OF_2(n)){
ffffffffc0200bfe:	c785                	beqz	a5,ffffffffc0200c26 <buddy_init_memmap+0x56>
    n |= (n >> 1);
ffffffffc0200c00:	00145793          	srli	a5,s0,0x1
ffffffffc0200c04:	8fc1                	or	a5,a5,s0
    n |= (n >> 2);
ffffffffc0200c06:	0027d693          	srli	a3,a5,0x2
ffffffffc0200c0a:	8fd5                	or	a5,a5,a3
    n |= (n >> 4);
ffffffffc0200c0c:	0047d693          	srli	a3,a5,0x4
ffffffffc0200c10:	8fd5                	or	a5,a5,a3
    n |= (n >> 8);
ffffffffc0200c12:	0087d693          	srli	a3,a5,0x8
ffffffffc0200c16:	8fd5                	or	a5,a5,a3
    n |= (n >> 16);
ffffffffc0200c18:	0107d693          	srli	a3,a5,0x10
ffffffffc0200c1c:	8fd5                	or	a5,a5,a3
    return n - (n >> 1);
ffffffffc0200c1e:	0017d413          	srli	s0,a5,0x1
ffffffffc0200c22:	40878433          	sub	s0,a5,s0
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c26:	fcccd7b7          	lui	a5,0xfcccd
ffffffffc0200c2a:	ccd78793          	addi	a5,a5,-819 # fffffffffccccccd <end+0x3cac66fd>
ffffffffc0200c2e:	07b2                	slli	a5,a5,0xc
ffffffffc0200c30:	ccd78793          	addi	a5,a5,-819
ffffffffc0200c34:	07b2                	slli	a5,a5,0xc
ffffffffc0200c36:	ccd78793          	addi	a5,a5,-819
ffffffffc0200c3a:	00006697          	auipc	a3,0x6
ffffffffc0200c3e:	97e6b683          	ld	a3,-1666(a3) # ffffffffc02065b8 <pages>
ffffffffc0200c42:	40d486b3          	sub	a3,s1,a3
ffffffffc0200c46:	07b2                	slli	a5,a5,0xc
ffffffffc0200c48:	ccd78793          	addi	a5,a5,-819
ffffffffc0200c4c:	868d                	srai	a3,a3,0x3
ffffffffc0200c4e:	02f686b3          	mul	a3,a3,a5
ffffffffc0200c52:	00001797          	auipc	a5,0x1
ffffffffc0200c56:	7f67b783          	ld	a5,2038(a5) # ffffffffc0202448 <nbase>
    buddy->size = s;//buddy的大小
ffffffffc0200c5a:	0716                	slli	a4,a4,0x5
ffffffffc0200c5c:	00005617          	auipc	a2,0x5
ffffffffc0200c60:	3d460613          	addi	a2,a2,980 # ffffffffc0206030 <b>
ffffffffc0200c64:	963a                	add	a2,a2,a4
ffffffffc0200c66:	e200                	sd	s0,0(a2)
    buddy->curr_free = s;//当前空闲的可用页数
ffffffffc0200c68:	ea00                	sd	s0,16(a2)
    buddy->longest = KADDR(page2pa(base));// 指向 base 的内存地址
ffffffffc0200c6a:	00006717          	auipc	a4,0x6
ffffffffc0200c6e:	94673703          	ld	a4,-1722(a4) # ffffffffc02065b0 <npage>
ffffffffc0200c72:	96be                	add	a3,a3,a5
ffffffffc0200c74:	00c69793          	slli	a5,a3,0xc
ffffffffc0200c78:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c7a:	06b2                	slli	a3,a3,0xc
ffffffffc0200c7c:	08e7fe63          	bgeu	a5,a4,ffffffffc0200d18 <buddy_init_memmap+0x148>
ffffffffc0200c80:	00006797          	auipc	a5,0x6
ffffffffc0200c84:	9287b783          	ld	a5,-1752(a5) # ffffffffc02065a8 <va_pa_offset>
ffffffffc0200c88:	97b6                	add	a5,a5,a3
ffffffffc0200c8a:	e61c                	sd	a5,8(a2)
    buddy->begin_page = base;
ffffffffc0200c8c:	ee04                	sd	s1,24(a2)
    size_t node_size = buddy->size * 2;
ffffffffc0200c8e:	00141693          	slli	a3,s0,0x1
    for (int i = 0; i < 2 * buddy->size - 1; i++) {
ffffffffc0200c92:	4781                	li	a5,0
        if (IS_POWER_OF_2(i + 1)) {
ffffffffc0200c94:	0017871b          	addiw	a4,a5,1
ffffffffc0200c98:	8f7d                	and	a4,a4,a5
ffffffffc0200c9a:	2701                	sext.w	a4,a4
ffffffffc0200c9c:	e311                	bnez	a4,ffffffffc0200ca0 <buddy_init_memmap+0xd0>
            node_size /= 2;
ffffffffc0200c9e:	8285                	srli	a3,a3,0x1
        buddy->longest[i] = node_size;
ffffffffc0200ca0:	6618                	ld	a4,8(a2)
ffffffffc0200ca2:	00379813          	slli	a6,a5,0x3
ffffffffc0200ca6:	0785                	addi	a5,a5,1
ffffffffc0200ca8:	9742                	add	a4,a4,a6
ffffffffc0200caa:	e314                	sd	a3,0(a4)
    for (int i = 0; i < 2 * buddy->size - 1; i++) {
ffffffffc0200cac:	6218                	ld	a4,0(a2)
ffffffffc0200cae:	0706                	slli	a4,a4,0x1
ffffffffc0200cb0:	177d                	addi	a4,a4,-1
ffffffffc0200cb2:	fee7e1e3          	bltu	a5,a4,ffffffffc0200c94 <buddy_init_memmap+0xc4>
    for (; p != base + buddy->curr_free; p ++) {
ffffffffc0200cb6:	6a18                	ld	a4,16(a2)
    struct Page *p = buddy->begin_page;
ffffffffc0200cb8:	6e1c                	ld	a5,24(a2)
    for (; p != base + buddy->curr_free; p ++) {
ffffffffc0200cba:	00271693          	slli	a3,a4,0x2
ffffffffc0200cbe:	96ba                	add	a3,a3,a4
ffffffffc0200cc0:	068e                	slli	a3,a3,0x3
ffffffffc0200cc2:	96a6                	add	a3,a3,s1
ffffffffc0200cc4:	00d78f63          	beq	a5,a3,ffffffffc0200ce2 <buddy_init_memmap+0x112>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200cc8:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200cca:	8b05                	andi	a4,a4,1
ffffffffc0200ccc:	c715                	beqz	a4,ffffffffc0200cf8 <buddy_init_memmap+0x128>
        p->flags = p->property = 0;
ffffffffc0200cce:	0007a823          	sw	zero,16(a5)
ffffffffc0200cd2:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200cd6:	0007a023          	sw	zero,0(a5)
    for (; p != base + buddy->curr_free; p ++) {
ffffffffc0200cda:	02878793          	addi	a5,a5,40
ffffffffc0200cde:	fed795e3          	bne	a5,a3,ffffffffc0200cc8 <buddy_init_memmap+0xf8>
    base->property = s;
ffffffffc0200ce2:	c880                	sw	s0,16(s1)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ce4:	4789                	li	a5,2
ffffffffc0200ce6:	00848713          	addi	a4,s1,8
ffffffffc0200cea:	40f7302f          	amoor.d	zero,a5,(a4)
}
ffffffffc0200cee:	60e2                	ld	ra,24(sp)
ffffffffc0200cf0:	6442                	ld	s0,16(sp)
ffffffffc0200cf2:	64a2                	ld	s1,8(sp)
ffffffffc0200cf4:	6105                	addi	sp,sp,32
ffffffffc0200cf6:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200cf8:	00001697          	auipc	a3,0x1
ffffffffc0200cfc:	29068693          	addi	a3,a3,656 # ffffffffc0201f88 <etext+0x7f0>
ffffffffc0200d00:	00001617          	auipc	a2,0x1
ffffffffc0200d04:	1a060613          	addi	a2,a2,416 # ffffffffc0201ea0 <etext+0x708>
ffffffffc0200d08:	04400593          	li	a1,68
ffffffffc0200d0c:	00001517          	auipc	a0,0x1
ffffffffc0200d10:	1ac50513          	addi	a0,a0,428 # ffffffffc0201eb8 <etext+0x720>
ffffffffc0200d14:	e9aff0ef          	jal	ffffffffc02003ae <__panic>
    buddy->longest = KADDR(page2pa(base));// 指向 base 的内存地址
ffffffffc0200d18:	00001617          	auipc	a2,0x1
ffffffffc0200d1c:	20860613          	addi	a2,a2,520 # ffffffffc0201f20 <etext+0x788>
ffffffffc0200d20:	03600593          	li	a1,54
ffffffffc0200d24:	00001517          	auipc	a0,0x1
ffffffffc0200d28:	19450513          	addi	a0,a0,404 # ffffffffc0201eb8 <etext+0x720>
ffffffffc0200d2c:	e82ff0ef          	jal	ffffffffc02003ae <__panic>

ffffffffc0200d30 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200d30:	100027f3          	csrr	a5,sstatus
ffffffffc0200d34:	8b89                	andi	a5,a5,2
ffffffffc0200d36:	e799                	bnez	a5,ffffffffc0200d44 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;//定义一个布尔变量 intr_flag，用于保存中断状态，在进行分配时禁用中断，完成分配后恢复之前的中断状态。
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200d38:	00006797          	auipc	a5,0x6
ffffffffc0200d3c:	8587b783          	ld	a5,-1960(a5) # ffffffffc0206590 <pmm_manager>
ffffffffc0200d40:	6f9c                	ld	a5,24(a5)
ffffffffc0200d42:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200d44:	1141                	addi	sp,sp,-16
ffffffffc0200d46:	e406                	sd	ra,8(sp)
ffffffffc0200d48:	e022                	sd	s0,0(sp)
ffffffffc0200d4a:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200d4c:	f16ff0ef          	jal	ffffffffc0200462 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200d50:	00006797          	auipc	a5,0x6
ffffffffc0200d54:	8407b783          	ld	a5,-1984(a5) # ffffffffc0206590 <pmm_manager>
ffffffffc0200d58:	6f9c                	ld	a5,24(a5)
ffffffffc0200d5a:	8522                	mv	a0,s0
ffffffffc0200d5c:	9782                	jalr	a5
ffffffffc0200d5e:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200d60:	efcff0ef          	jal	ffffffffc020045c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200d64:	60a2                	ld	ra,8(sp)
ffffffffc0200d66:	8522                	mv	a0,s0
ffffffffc0200d68:	6402                	ld	s0,0(sp)
ffffffffc0200d6a:	0141                	addi	sp,sp,16
ffffffffc0200d6c:	8082                	ret

ffffffffc0200d6e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200d6e:	100027f3          	csrr	a5,sstatus
ffffffffc0200d72:	8b89                	andi	a5,a5,2
ffffffffc0200d74:	e799                	bnez	a5,ffffffffc0200d82 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200d76:	00006797          	auipc	a5,0x6
ffffffffc0200d7a:	81a7b783          	ld	a5,-2022(a5) # ffffffffc0206590 <pmm_manager>
ffffffffc0200d7e:	739c                	ld	a5,32(a5)
ffffffffc0200d80:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200d82:	1101                	addi	sp,sp,-32
ffffffffc0200d84:	ec06                	sd	ra,24(sp)
ffffffffc0200d86:	e822                	sd	s0,16(sp)
ffffffffc0200d88:	e426                	sd	s1,8(sp)
ffffffffc0200d8a:	842a                	mv	s0,a0
ffffffffc0200d8c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200d8e:	ed4ff0ef          	jal	ffffffffc0200462 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200d92:	00005797          	auipc	a5,0x5
ffffffffc0200d96:	7fe7b783          	ld	a5,2046(a5) # ffffffffc0206590 <pmm_manager>
ffffffffc0200d9a:	739c                	ld	a5,32(a5)
ffffffffc0200d9c:	85a6                	mv	a1,s1
ffffffffc0200d9e:	8522                	mv	a0,s0
ffffffffc0200da0:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200da2:	6442                	ld	s0,16(sp)
ffffffffc0200da4:	60e2                	ld	ra,24(sp)
ffffffffc0200da6:	64a2                	ld	s1,8(sp)
ffffffffc0200da8:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200daa:	eb2ff06f          	j	ffffffffc020045c <intr_enable>

ffffffffc0200dae <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200dae:	00001797          	auipc	a5,0x1
ffffffffc0200db2:	4d278793          	addi	a5,a5,1234 # ffffffffc0202280 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200db6:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200db8:	1101                	addi	sp,sp,-32
ffffffffc0200dba:	ec06                	sd	ra,24(sp)
ffffffffc0200dbc:	e822                	sd	s0,16(sp)
ffffffffc0200dbe:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200dc0:	00001517          	auipc	a0,0x1
ffffffffc0200dc4:	1f050513          	addi	a0,a0,496 # ffffffffc0201fb0 <etext+0x818>
    pmm_manager = &buddy_pmm_manager;
ffffffffc0200dc8:	00005497          	auipc	s1,0x5
ffffffffc0200dcc:	7c848493          	addi	s1,s1,1992 # ffffffffc0206590 <pmm_manager>
ffffffffc0200dd0:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200dd2:	ae8ff0ef          	jal	ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0200dd6:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200dd8:	00005417          	auipc	s0,0x5
ffffffffc0200ddc:	7d040413          	addi	s0,s0,2000 # ffffffffc02065a8 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200de0:	679c                	ld	a5,8(a5)
ffffffffc0200de2:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200de4:	57f5                	li	a5,-3
ffffffffc0200de6:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200de8:	00001517          	auipc	a0,0x1
ffffffffc0200dec:	1e050513          	addi	a0,a0,480 # ffffffffc0201fc8 <etext+0x830>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200df0:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200df2:	ac8ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200df6:	46c5                	li	a3,17
ffffffffc0200df8:	06ee                	slli	a3,a3,0x1b
ffffffffc0200dfa:	40100613          	li	a2,1025
ffffffffc0200dfe:	16fd                	addi	a3,a3,-1
ffffffffc0200e00:	0656                	slli	a2,a2,0x15
ffffffffc0200e02:	07e005b7          	lui	a1,0x7e00
ffffffffc0200e06:	00001517          	auipc	a0,0x1
ffffffffc0200e0a:	1da50513          	addi	a0,a0,474 # ffffffffc0201fe0 <etext+0x848>
ffffffffc0200e0e:	aacff0ef          	jal	ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e12:	777d                	lui	a4,0xfffff
ffffffffc0200e14:	00006797          	auipc	a5,0x6
ffffffffc0200e18:	7bb78793          	addi	a5,a5,1979 # ffffffffc02075cf <end+0xfff>
ffffffffc0200e1c:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200e1e:	00005517          	auipc	a0,0x5
ffffffffc0200e22:	79250513          	addi	a0,a0,1938 # ffffffffc02065b0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e26:	00005597          	auipc	a1,0x5
ffffffffc0200e2a:	79258593          	addi	a1,a1,1938 # ffffffffc02065b8 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200e2e:	00088737          	lui	a4,0x88
ffffffffc0200e32:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200e34:	e19c                	sd	a5,0(a1)
ffffffffc0200e36:	4705                	li	a4,1
ffffffffc0200e38:	07a1                	addi	a5,a5,8
ffffffffc0200e3a:	40e7b02f          	amoor.d	zero,a4,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e3e:	02800693          	li	a3,40
ffffffffc0200e42:	4885                	li	a7,1
ffffffffc0200e44:	fff80837          	lui	a6,0xfff80
        SetPageReserved(pages + i);
ffffffffc0200e48:	619c                	ld	a5,0(a1)
ffffffffc0200e4a:	97b6                	add	a5,a5,a3
ffffffffc0200e4c:	07a1                	addi	a5,a5,8
ffffffffc0200e4e:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200e52:	611c                	ld	a5,0(a0)
ffffffffc0200e54:	0705                	addi	a4,a4,1 # 88001 <kern_entry-0xffffffffc0177fff>
ffffffffc0200e56:	02868693          	addi	a3,a3,40
ffffffffc0200e5a:	01078633          	add	a2,a5,a6
ffffffffc0200e5e:	fec765e3          	bltu	a4,a2,ffffffffc0200e48 <pmm_init+0x9a>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200e62:	6190                	ld	a2,0(a1)
ffffffffc0200e64:	00279693          	slli	a3,a5,0x2
ffffffffc0200e68:	96be                	add	a3,a3,a5
ffffffffc0200e6a:	fec00737          	lui	a4,0xfec00
ffffffffc0200e6e:	9732                	add	a4,a4,a2
ffffffffc0200e70:	068e                	slli	a3,a3,0x3
ffffffffc0200e72:	96ba                	add	a3,a3,a4
ffffffffc0200e74:	c0200737          	lui	a4,0xc0200
ffffffffc0200e78:	0ae6e463          	bltu	a3,a4,ffffffffc0200f20 <pmm_init+0x172>
ffffffffc0200e7c:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200e7e:	45c5                	li	a1,17
ffffffffc0200e80:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200e82:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200e84:	04b6e963          	bltu	a3,a1,ffffffffc0200ed6 <pmm_init+0x128>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200e88:	609c                	ld	a5,0(s1)
ffffffffc0200e8a:	7b9c                	ld	a5,48(a5)
ffffffffc0200e8c:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200e8e:	00001517          	auipc	a0,0x1
ffffffffc0200e92:	1ea50513          	addi	a0,a0,490 # ffffffffc0202078 <etext+0x8e0>
ffffffffc0200e96:	a24ff0ef          	jal	ffffffffc02000ba <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200e9a:	00004597          	auipc	a1,0x4
ffffffffc0200e9e:	16658593          	addi	a1,a1,358 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200ea2:	00005797          	auipc	a5,0x5
ffffffffc0200ea6:	6eb7bf23          	sd	a1,1790(a5) # ffffffffc02065a0 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200eaa:	c02007b7          	lui	a5,0xc0200
ffffffffc0200eae:	08f5e563          	bltu	a1,a5,ffffffffc0200f38 <pmm_init+0x18a>
ffffffffc0200eb2:	601c                	ld	a5,0(s0)
}
ffffffffc0200eb4:	6442                	ld	s0,16(sp)
ffffffffc0200eb6:	60e2                	ld	ra,24(sp)
ffffffffc0200eb8:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200eba:	40f586b3          	sub	a3,a1,a5
ffffffffc0200ebe:	00005797          	auipc	a5,0x5
ffffffffc0200ec2:	6cd7bd23          	sd	a3,1754(a5) # ffffffffc0206598 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200ec6:	00001517          	auipc	a0,0x1
ffffffffc0200eca:	1d250513          	addi	a0,a0,466 # ffffffffc0202098 <etext+0x900>
ffffffffc0200ece:	8636                	mv	a2,a3
}
ffffffffc0200ed0:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200ed2:	9e8ff06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200ed6:	6705                	lui	a4,0x1
ffffffffc0200ed8:	177d                	addi	a4,a4,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc0200eda:	96ba                	add	a3,a3,a4
ffffffffc0200edc:	777d                	lui	a4,0xfffff
ffffffffc0200ede:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200ee0:	00c6d713          	srli	a4,a3,0xc
ffffffffc0200ee4:	02f77263          	bgeu	a4,a5,ffffffffc0200f08 <pmm_init+0x15a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200ee8:	0004b803          	ld	a6,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200eec:	fff807b7          	lui	a5,0xfff80
ffffffffc0200ef0:	97ba                	add	a5,a5,a4
ffffffffc0200ef2:	00279513          	slli	a0,a5,0x2
ffffffffc0200ef6:	953e                	add	a0,a0,a5
ffffffffc0200ef8:	01083783          	ld	a5,16(a6) # fffffffffff80010 <end+0x3fd79a40>
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200efc:	8d95                	sub	a1,a1,a3
ffffffffc0200efe:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200f00:	81b1                	srli	a1,a1,0xc
ffffffffc0200f02:	9532                	add	a0,a0,a2
ffffffffc0200f04:	9782                	jalr	a5
}
ffffffffc0200f06:	b749                	j	ffffffffc0200e88 <pmm_init+0xda>
        panic("pa2page called with invalid pa");
ffffffffc0200f08:	00001617          	auipc	a2,0x1
ffffffffc0200f0c:	14060613          	addi	a2,a2,320 # ffffffffc0202048 <etext+0x8b0>
ffffffffc0200f10:	06a00593          	li	a1,106
ffffffffc0200f14:	00001517          	auipc	a0,0x1
ffffffffc0200f18:	15450513          	addi	a0,a0,340 # ffffffffc0202068 <etext+0x8d0>
ffffffffc0200f1c:	c92ff0ef          	jal	ffffffffc02003ae <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f20:	00001617          	auipc	a2,0x1
ffffffffc0200f24:	0f060613          	addi	a2,a2,240 # ffffffffc0202010 <etext+0x878>
ffffffffc0200f28:	06f00593          	li	a1,111
ffffffffc0200f2c:	00001517          	auipc	a0,0x1
ffffffffc0200f30:	10c50513          	addi	a0,a0,268 # ffffffffc0202038 <etext+0x8a0>
ffffffffc0200f34:	c7aff0ef          	jal	ffffffffc02003ae <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f38:	86ae                	mv	a3,a1
ffffffffc0200f3a:	00001617          	auipc	a2,0x1
ffffffffc0200f3e:	0d660613          	addi	a2,a2,214 # ffffffffc0202010 <etext+0x878>
ffffffffc0200f42:	08a00593          	li	a1,138
ffffffffc0200f46:	00001517          	auipc	a0,0x1
ffffffffc0200f4a:	0f250513          	addi	a0,a0,242 # ffffffffc0202038 <etext+0x8a0>
ffffffffc0200f4e:	c60ff0ef          	jal	ffffffffc02003ae <__panic>

ffffffffc0200f52 <slob_free>:
}

static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;//cur：用于遍历空闲链表的指针。b：将 block 转换为 slob_t* 类型，这是释放的内存块。slob_t 是内存块的基本结构，表示一个小块内存单元。
	if (!block)
ffffffffc0200f52:	cd0d                	beqz	a0,ffffffffc0200f8c <slob_free+0x3a>
		return;
	if (size)
ffffffffc0200f54:	ed8d                	bnez	a1,ffffffffc0200f8e <slob_free+0x3c>
        检查释放的块 b 是否与它后面的空闲块 cur->next 相邻。
      如果相邻：将它们合并，即：
   b->units += cur->next->units;：增加 b 的大小，包含 cur->next 的单元数。
   b->next = cur->next->next;：跳过 cur->next，直接指向它的后继块，完成链表的合并。
        */
	if (b + b->units == cur->next) {
ffffffffc0200f56:	4114                	lw	a3,0(a0)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)//这里通过遍历空闲链表，寻找释放块 b 应该插入的位置。遍历的链表是从 slobfree 开始的，cur 表示当前遍历到的空闲块。
ffffffffc0200f58:	00005597          	auipc	a1,0x5
ffffffffc0200f5c:	0b858593          	addi	a1,a1,184 # ffffffffc0206010 <slobfree>
ffffffffc0200f60:	619c                	ld	a5,0(a1)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0200f62:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)//这里通过遍历空闲链表，寻找释放块 b 应该插入的位置。遍历的链表是从 slobfree 开始的，cur 表示当前遍历到的空闲块。
ffffffffc0200f64:	02a7fa63          	bgeu	a5,a0,ffffffffc0200f98 <slob_free+0x46>
ffffffffc0200f68:	00e56463          	bltu	a0,a4,ffffffffc0200f70 <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0200f6c:	02e7ea63          	bltu	a5,a4,ffffffffc0200fa0 <slob_free+0x4e>
	if (b + b->units == cur->next) {
ffffffffc0200f70:	00469613          	slli	a2,a3,0x4
ffffffffc0200f74:	962a                	add	a2,a2,a0
ffffffffc0200f76:	02c70d63          	beq	a4,a2,ffffffffc0200fb0 <slob_free+0x5e>
		b->next = cur->next->next;
	} else{
		b->next = cur->next;
		}
     //与前面块相邻
	if (cur + cur->units == b) {
ffffffffc0200f7a:	4390                	lw	a2,0(a5)
ffffffffc0200f7c:	e518                	sd	a4,8(a0)
ffffffffc0200f7e:	00461693          	slli	a3,a2,0x4
ffffffffc0200f82:	96be                	add	a3,a3,a5
ffffffffc0200f84:	02d50063          	beq	a0,a3,ffffffffc0200fa4 <slob_free+0x52>
ffffffffc0200f88:	e788                	sd	a0,8(a5)
		cur->next = b->next;
	} else{
		cur->next = b;
		}

	slobfree = cur;
ffffffffc0200f8a:	e19c                	sd	a5,0(a1)
}
ffffffffc0200f8c:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0200f8e:	00f5869b          	addiw	a3,a1,15
ffffffffc0200f92:	8691                	srai	a3,a3,0x4
ffffffffc0200f94:	c114                	sw	a3,0(a0)
ffffffffc0200f96:	b7c9                	j	ffffffffc0200f58 <slob_free+0x6>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0200f98:	00e7e463          	bltu	a5,a4,ffffffffc0200fa0 <slob_free+0x4e>
ffffffffc0200f9c:	fce56ae3          	bltu	a0,a4,ffffffffc0200f70 <slob_free+0x1e>
{
ffffffffc0200fa0:	87ba                	mv	a5,a4
ffffffffc0200fa2:	b7c1                	j	ffffffffc0200f62 <slob_free+0x10>
		cur->units += b->units;
ffffffffc0200fa4:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0200fa6:	853a                	mv	a0,a4
		cur->units += b->units;
ffffffffc0200fa8:	00c6873b          	addw	a4,a3,a2
ffffffffc0200fac:	c398                	sw	a4,0(a5)
		cur->next = b->next;
ffffffffc0200fae:	bfe9                	j	ffffffffc0200f88 <slob_free+0x36>
		b->units += cur->next->units;
ffffffffc0200fb0:	4310                	lw	a2,0(a4)
		b->next = cur->next->next;
ffffffffc0200fb2:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0200fb4:	9eb1                	addw	a3,a3,a2
ffffffffc0200fb6:	c114                	sw	a3,0(a0)
		b->next = cur->next->next;
ffffffffc0200fb8:	b7c9                	j	ffffffffc0200f7a <slob_free+0x28>

ffffffffc0200fba <slob_alloc>:
{
ffffffffc0200fba:	1101                	addi	sp,sp,-32
ffffffffc0200fbc:	ec06                	sd	ra,24(sp)
ffffffffc0200fbe:	e822                	sd	s0,16(sp)
ffffffffc0200fc0:	e426                	sd	s1,8(sp)
ffffffffc0200fc2:	e04a                	sd	s2,0(sp)
    assert(size < PGSIZE);//确保请求的内存大小小于页面大小（PGSIZE，通常为 4KB），这是因为 slob_alloc 函数用于处理小块内存分配，如果内存大小大于等于一页，就不应该使用该函数。超出页面大小的分配将由其他机制（例如大块分配）处理。
ffffffffc0200fc4:	6785                	lui	a5,0x1
ffffffffc0200fc6:	08f57363          	bgeu	a0,a5,ffffffffc020104c <slob_alloc+0x92>
	prev = slobfree;
ffffffffc0200fca:	00005417          	auipc	s0,0x5
ffffffffc0200fce:	04640413          	addi	s0,s0,70 # ffffffffc0206010 <slobfree>
ffffffffc0200fd2:	6010                	ld	a2,0(s0)
	int  units = SLOB_UNITS(size);
ffffffffc0200fd4:	053d                	addi	a0,a0,15
ffffffffc0200fd6:	00455913          	srli	s2,a0,0x4
	cur = prev->next;	
ffffffffc0200fda:	6618                	ld	a4,8(a2)
	int  units = SLOB_UNITS(size);
ffffffffc0200fdc:	0009049b          	sext.w	s1,s2
	     if (cur->units >= units) { //cur->units 代表当前块的大小（以 slob_t 为单位）。如果当前块的大小大于或等于请求的大小（units），则说明该块可以满足分配请求。
ffffffffc0200fe0:	4314                	lw	a3,0(a4)
ffffffffc0200fe2:	0696d263          	bge	a3,s1,ffffffffc0201046 <slob_alloc+0x8c>
	     if (cur == slobfree) {
ffffffffc0200fe6:	00e60a63          	beq	a2,a4,ffffffffc0200ffa <slob_alloc+0x40>
	     cur=cur->next;
ffffffffc0200fea:	671c                	ld	a5,8(a4)
	     if (cur->units >= units) { //cur->units 代表当前块的大小（以 slob_t 为单位）。如果当前块的大小大于或等于请求的大小（units），则说明该块可以满足分配请求。
ffffffffc0200fec:	4394                	lw	a3,0(a5)
ffffffffc0200fee:	0296d363          	bge	a3,s1,ffffffffc0201014 <slob_alloc+0x5a>
	     if (cur == slobfree) {
ffffffffc0200ff2:	6010                	ld	a2,0(s0)
ffffffffc0200ff4:	873e                	mv	a4,a5
ffffffffc0200ff6:	fee61ae3          	bne	a2,a4,ffffffffc0200fea <slob_alloc+0x30>
			cur = (slob_t *)alloc_pages(1);
ffffffffc0200ffa:	4505                	li	a0,1
ffffffffc0200ffc:	d35ff0ef          	jal	ffffffffc0200d30 <alloc_pages>
ffffffffc0201000:	87aa                	mv	a5,a0
			if (!cur)
ffffffffc0201002:	c51d                	beqz	a0,ffffffffc0201030 <slob_alloc+0x76>
			slob_free(cur, PGSIZE);//将新分配的页面释放到空闲列表
ffffffffc0201004:	6585                	lui	a1,0x1
ffffffffc0201006:	f4dff0ef          	jal	ffffffffc0200f52 <slob_free>
			cur = slobfree;
ffffffffc020100a:	6018                	ld	a4,0(s0)
	     cur=cur->next;
ffffffffc020100c:	671c                	ld	a5,8(a4)
	     if (cur->units >= units) { //cur->units 代表当前块的大小（以 slob_t 为单位）。如果当前块的大小大于或等于请求的大小（units），则说明该块可以满足分配请求。
ffffffffc020100e:	4394                	lw	a3,0(a5)
ffffffffc0201010:	fe96c1e3          	blt	a3,s1,ffffffffc0200ff2 <slob_alloc+0x38>
			if (cur->units == units)//如果当前块的大小刚好等于请求的大小，则将该块从空闲链表中移除（prev->next = cur->next），因为它将被完全分配。
ffffffffc0201014:	02d48563          	beq	s1,a3,ffffffffc020103e <slob_alloc+0x84>
				prev->next = cur + units;
ffffffffc0201018:	0912                	slli	s2,s2,0x4
ffffffffc020101a:	993e                	add	s2,s2,a5
ffffffffc020101c:	01273423          	sd	s2,8(a4) # fffffffffffff008 <end+0x3fdf8a38>
				prev->next->next = cur->next;
ffffffffc0201020:	6790                	ld	a2,8(a5)
				prev->next->units = cur->units - units;
ffffffffc0201022:	9e85                	subw	a3,a3,s1
ffffffffc0201024:	00d92023          	sw	a3,0(s2)
				prev->next->next = cur->next;
ffffffffc0201028:	00c93423          	sd	a2,8(s2)
				cur->units = units;
ffffffffc020102c:	c384                	sw	s1,0(a5)
			slobfree = prev;
ffffffffc020102e:	e018                	sd	a4,0(s0)
}
ffffffffc0201030:	60e2                	ld	ra,24(sp)
ffffffffc0201032:	6442                	ld	s0,16(sp)
ffffffffc0201034:	64a2                	ld	s1,8(sp)
ffffffffc0201036:	6902                	ld	s2,0(sp)
ffffffffc0201038:	853e                	mv	a0,a5
ffffffffc020103a:	6105                	addi	sp,sp,32
ffffffffc020103c:	8082                	ret
				prev->next = cur->next;
ffffffffc020103e:	6794                	ld	a3,8(a5)
			slobfree = prev;
ffffffffc0201040:	e018                	sd	a4,0(s0)
				prev->next = cur->next;
ffffffffc0201042:	e714                	sd	a3,8(a4)
			return cur;
ffffffffc0201044:	b7f5                	j	ffffffffc0201030 <slob_alloc+0x76>
	cur = prev->next;	
ffffffffc0201046:	87ba                	mv	a5,a4
	prev = slobfree;
ffffffffc0201048:	8732                	mv	a4,a2
ffffffffc020104a:	b7e9                	j	ffffffffc0201014 <slob_alloc+0x5a>
    assert(size < PGSIZE);//确保请求的内存大小小于页面大小（PGSIZE，通常为 4KB），这是因为 slob_alloc 函数用于处理小块内存分配，如果内存大小大于等于一页，就不应该使用该函数。超出页面大小的分配将由其他机制（例如大块分配）处理。
ffffffffc020104c:	00001697          	auipc	a3,0x1
ffffffffc0201050:	08c68693          	addi	a3,a3,140 # ffffffffc02020d8 <etext+0x940>
ffffffffc0201054:	00001617          	auipc	a2,0x1
ffffffffc0201058:	e4c60613          	addi	a2,a2,-436 # ffffffffc0201ea0 <etext+0x708>
ffffffffc020105c:	02200593          	li	a1,34
ffffffffc0201060:	00001517          	auipc	a0,0x1
ffffffffc0201064:	08850513          	addi	a0,a0,136 # ffffffffc02020e8 <etext+0x950>
ffffffffc0201068:	b46ff0ef          	jal	ffffffffc02003ae <__panic>

ffffffffc020106c <slub_alloc.part.0>:
void 
slub_init(void) {
    cprintf("slub_init() succeeded!\n");
}

void *slub_alloc(size_t size)
ffffffffc020106c:	1101                	addi	sp,sp,-32
ffffffffc020106e:	e822                	sd	s0,16(sp)
ffffffffc0201070:	842a                	mv	s0,a0
		//m = slob_alloc(size + SLOB_UNIT);
		m = slob_alloc(size);
		return m ? (void *)(m + 1) : 0;
	}

	bb = slob_alloc(sizeof(bigblock_t));//尽管 slob_alloc() 返回的是一个 slob_t*，但从内存分配的角度来看，slob_t* 实际上就是一个指向内存块的指针。slob_t* 只是 void* 类型的替代形式，用于在分配时将管理结构与内存关联起来。
ffffffffc0201072:	4561                	li	a0,24
void *slub_alloc(size_t size)
ffffffffc0201074:	ec06                	sd	ra,24(sp)
	bb = slob_alloc(sizeof(bigblock_t));//尽管 slob_alloc() 返回的是一个 slob_t*，但从内存分配的角度来看，slob_t* 实际上就是一个指向内存块的指针。slob_t* 只是 void* 类型的替代形式，用于在分配时将管理结构与内存关联起来。
ffffffffc0201076:	f45ff0ef          	jal	ffffffffc0200fba <slob_alloc>
	if (!bb)
ffffffffc020107a:	cd0d                	beqz	a0,ffffffffc02010b4 <slub_alloc.part.0+0x48>
		return 0;

	//bb->order = ((size-1) >> PGSHIFT) + 1;//个公式通过右移 PGSHIFT 位，将 size 转换为页面数
	bb->order=size/4096+1;
ffffffffc020107c:	00c45793          	srli	a5,s0,0xc
ffffffffc0201080:	e426                	sd	s1,8(sp)
ffffffffc0201082:	84aa                	mv	s1,a0
ffffffffc0201084:	0017851b          	addiw	a0,a5,1 # 1001 <kern_entry-0xffffffffc01fefff>
ffffffffc0201088:	c088                	sw	a0,0(s1)
	bb->pages = (void *)alloc_pages(bb->order);
ffffffffc020108a:	ca7ff0ef          	jal	ffffffffc0200d30 <alloc_pages>
ffffffffc020108e:	e488                	sd	a0,8(s1)

	if (bb->pages) {
ffffffffc0201090:	cd09                	beqz	a0,ffffffffc02010aa <slub_alloc.part.0+0x3e>
		bb->next = bigblocks;
ffffffffc0201092:	00005797          	auipc	a5,0x5
ffffffffc0201096:	52e78793          	addi	a5,a5,1326 # ffffffffc02065c0 <bigblocks>
ffffffffc020109a:	6398                	ld	a4,0(a5)
		return bb->pages;
	}

	slob_free(bb, sizeof(bigblock_t));//如果大块页面分配失败，释放 bigblock_t 结构体所占用的内存。调用 slob_free(bb, sizeof(bigblock_t)) 将 bb 释放回空闲链表，然后返回 0，表示分配失败
	return 0;
}
ffffffffc020109c:	60e2                	ld	ra,24(sp)
ffffffffc020109e:	6442                	ld	s0,16(sp)
		bigblocks = bb;
ffffffffc02010a0:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc02010a2:	e898                	sd	a4,16(s1)
		return bb->pages;
ffffffffc02010a4:	64a2                	ld	s1,8(sp)
}
ffffffffc02010a6:	6105                	addi	sp,sp,32
ffffffffc02010a8:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));//如果大块页面分配失败，释放 bigblock_t 结构体所占用的内存。调用 slob_free(bb, sizeof(bigblock_t)) 将 bb 释放回空闲链表，然后返回 0，表示分配失败
ffffffffc02010aa:	8526                	mv	a0,s1
ffffffffc02010ac:	45e1                	li	a1,24
ffffffffc02010ae:	ea5ff0ef          	jal	ffffffffc0200f52 <slob_free>
ffffffffc02010b2:	64a2                	ld	s1,8(sp)
}
ffffffffc02010b4:	60e2                	ld	ra,24(sp)
ffffffffc02010b6:	6442                	ld	s0,16(sp)
		return 0;
ffffffffc02010b8:	4501                	li	a0,0
}
ffffffffc02010ba:	6105                	addi	sp,sp,32
ffffffffc02010bc:	8082                	ret

ffffffffc02010be <slub_init>:
    cprintf("slub_init() succeeded!\n");
ffffffffc02010be:	00001517          	auipc	a0,0x1
ffffffffc02010c2:	03a50513          	addi	a0,a0,58 # ffffffffc02020f8 <etext+0x960>
ffffffffc02010c6:	ff5fe06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02010ca <slub_free>:


void slub_free(void *block)//这段代码实现了 slub_free 函数，用于释放通过 slub_alloc 分配的内存
{

	if (!block)
ffffffffc02010ca:	c531                	beqz	a0,ffffffffc0201116 <slub_free+0x4c>
		return;

	if (!((unsigned long)block & (PGSIZE-1))) {//这个条件判断传入的 block 是否为页面对齐的地址（即大块内存）。页面对齐意味着 block 的地址是 PGSIZE（通常为 4KB）的倍数。是提取 block 地址的最低位，判断它是否与 PGSIZE 对齐。这是与号，就是0xFFF与12个0
ffffffffc02010cc:	03451793          	slli	a5,a0,0x34
ffffffffc02010d0:	e7a1                	bnez	a5,ffffffffc0201118 <slub_free+0x4e>
	        bigblock_t *bb, **last = &bigblocks;
		bb=bigblocks;
ffffffffc02010d2:	00005697          	auipc	a3,0x5
ffffffffc02010d6:	4ee68693          	addi	a3,a3,1262 # ffffffffc02065c0 <bigblocks>
ffffffffc02010da:	629c                	ld	a5,0(a3)
	        while(bb){
ffffffffc02010dc:	cf95                	beqz	a5,ffffffffc0201118 <slub_free+0x4e>
{
ffffffffc02010de:	1141                	addi	sp,sp,-16
ffffffffc02010e0:	e406                	sd	ra,8(sp)
ffffffffc02010e2:	e022                	sd	s0,0(sp)
ffffffffc02010e4:	a021                	j	ffffffffc02010ec <slub_free+0x22>
				*last = bb->next;
				free_pages((struct Page *)block, bb->order);//调用 free_pages 函数，释放大块内存块，bb->order 指示了分配的页数。
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
	                last=&bb->next;
ffffffffc02010e6:	01040693          	addi	a3,s0,16
	        while(bb){
ffffffffc02010ea:	c385                	beqz	a5,ffffffffc020110a <slub_free+0x40>
			if (bb->pages == block) {//如果 bb->pages 指向的内存块与 block 相同，说明找到了对应的大块内存块。
ffffffffc02010ec:	6798                	ld	a4,8(a5)
ffffffffc02010ee:	843e                	mv	s0,a5
				*last = bb->next;
ffffffffc02010f0:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {//如果 bb->pages 指向的内存块与 block 相同，说明找到了对应的大块内存块。
ffffffffc02010f2:	fea71ae3          	bne	a4,a0,ffffffffc02010e6 <slub_free+0x1c>
				free_pages((struct Page *)block, bb->order);//调用 free_pages 函数，释放大块内存块，bb->order 指示了分配的页数。
ffffffffc02010f6:	400c                	lw	a1,0(s0)
				*last = bb->next;
ffffffffc02010f8:	e29c                	sd	a5,0(a3)
				free_pages((struct Page *)block, bb->order);//调用 free_pages 函数，释放大块内存块，bb->order 指示了分配的页数。
ffffffffc02010fa:	c75ff0ef          	jal	ffffffffc0200d6e <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc02010fe:	8522                	mv	a0,s0
	        }
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201100:	6402                	ld	s0,0(sp)
ffffffffc0201102:	60a2                	ld	ra,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201104:	45e1                	li	a1,24
}
ffffffffc0201106:	0141                	addi	sp,sp,16
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201108:	b5a9                	j	ffffffffc0200f52 <slob_free>
}
ffffffffc020110a:	6402                	ld	s0,0(sp)
ffffffffc020110c:	60a2                	ld	ra,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc020110e:	4581                	li	a1,0
ffffffffc0201110:	1541                	addi	a0,a0,-16
}
ffffffffc0201112:	0141                	addi	sp,sp,16
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201114:	bd3d                	j	ffffffffc0200f52 <slob_free>
ffffffffc0201116:	8082                	ret
ffffffffc0201118:	4581                	li	a1,0
ffffffffc020111a:	1541                	addi	a0,a0,-16
ffffffffc020111c:	bd1d                	j	ffffffffc0200f52 <slob_free>

ffffffffc020111e <slub_check>:
        len ++;
    return len;
}

void slub_check()
{
ffffffffc020111e:	1101                	addi	sp,sp,-32
    cprintf("slub check begin\n");
ffffffffc0201120:	00001517          	auipc	a0,0x1
ffffffffc0201124:	ff050513          	addi	a0,a0,-16 # ffffffffc0202110 <etext+0x978>
{
ffffffffc0201128:	e822                	sd	s0,16(sp)
ffffffffc020112a:	ec06                	sd	ra,24(sp)
ffffffffc020112c:	e426                	sd	s1,8(sp)
ffffffffc020112e:	e04a                	sd	s2,0(sp)
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201130:	00005417          	auipc	s0,0x5
ffffffffc0201134:	ee040413          	addi	s0,s0,-288 # ffffffffc0206010 <slobfree>
    cprintf("slub check begin\n");
ffffffffc0201138:	f83fe0ef          	jal	ffffffffc02000ba <cprintf>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020113c:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc020113e:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201140:	671c                	ld	a5,8(a4)
ffffffffc0201142:	00f70663          	beq	a4,a5,ffffffffc020114e <slub_check+0x30>
ffffffffc0201146:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc0201148:	2585                	addiw	a1,a1,1 # 1001 <kern_entry-0xffffffffc01fefff>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020114a:	fef71ee3          	bne	a4,a5,ffffffffc0201146 <slub_check+0x28>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc020114e:	00001517          	auipc	a0,0x1
ffffffffc0201152:	fda50513          	addi	a0,a0,-38 # ffffffffc0202128 <etext+0x990>
ffffffffc0201156:	f65fe0ef          	jal	ffffffffc02000ba <cprintf>
	if (size < PGSIZE - SLOB_UNIT) {//如果 size 小于 PGSIZE - SLOB_UNIT（页面大小减去一个 slob_t 的大小），则认为这是一个小块内存请求。
ffffffffc020115a:	6505                	lui	a0,0x1
ffffffffc020115c:	f11ff0ef          	jal	ffffffffc020106c <slub_alloc.part.0>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201160:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc0201162:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201164:	671c                	ld	a5,8(a4)
ffffffffc0201166:	00f70663          	beq	a4,a5,ffffffffc0201172 <slub_check+0x54>
ffffffffc020116a:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc020116c:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020116e:	fef71ee3          	bne	a4,a5,ffffffffc020116a <slub_check+0x4c>
    void* p1 = slub_alloc(4096);
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc0201172:	00001517          	auipc	a0,0x1
ffffffffc0201176:	fb650513          	addi	a0,a0,-74 # ffffffffc0202128 <etext+0x990>
ffffffffc020117a:	f41fe0ef          	jal	ffffffffc02000ba <cprintf>
		m = slob_alloc(size);
ffffffffc020117e:	4509                	li	a0,2
ffffffffc0201180:	e3bff0ef          	jal	ffffffffc0200fba <slob_alloc>
ffffffffc0201184:	892a                	mv	s2,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc0201186:	c119                	beqz	a0,ffffffffc020118c <slub_check+0x6e>
ffffffffc0201188:	01050913          	addi	s2,a0,16
		m = slob_alloc(size);
ffffffffc020118c:	4509                	li	a0,2
ffffffffc020118e:	e2dff0ef          	jal	ffffffffc0200fba <slob_alloc>
ffffffffc0201192:	84aa                	mv	s1,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc0201194:	c119                	beqz	a0,ffffffffc020119a <slub_check+0x7c>
ffffffffc0201196:	01050493          	addi	s1,a0,16
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020119a:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc020119c:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020119e:	671c                	ld	a5,8(a4)
ffffffffc02011a0:	00f70663          	beq	a4,a5,ffffffffc02011ac <slub_check+0x8e>
ffffffffc02011a4:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc02011a6:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02011a8:	fef71ee3          	bne	a4,a5,ffffffffc02011a4 <slub_check+0x86>
    void* p2 = slub_alloc(2);
    void* p3 = slub_alloc(2);
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc02011ac:	00001517          	auipc	a0,0x1
ffffffffc02011b0:	f7c50513          	addi	a0,a0,-132 # ffffffffc0202128 <etext+0x990>
ffffffffc02011b4:	f07fe0ef          	jal	ffffffffc02000ba <cprintf>
    slub_free(p2);
ffffffffc02011b8:	854a                	mv	a0,s2
ffffffffc02011ba:	f11ff0ef          	jal	ffffffffc02010ca <slub_free>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02011be:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc02011c0:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02011c2:	671c                	ld	a5,8(a4)
ffffffffc02011c4:	00f70663          	beq	a4,a5,ffffffffc02011d0 <slub_check+0xb2>
ffffffffc02011c8:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc02011ca:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02011cc:	fef71ee3          	bne	a4,a5,ffffffffc02011c8 <slub_check+0xaa>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc02011d0:	00001517          	auipc	a0,0x1
ffffffffc02011d4:	f5850513          	addi	a0,a0,-168 # ffffffffc0202128 <etext+0x990>
ffffffffc02011d8:	ee3fe0ef          	jal	ffffffffc02000ba <cprintf>
    slub_free(p3);
ffffffffc02011dc:	8526                	mv	a0,s1
ffffffffc02011de:	eedff0ef          	jal	ffffffffc02010ca <slub_free>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02011e2:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc02011e4:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02011e6:	671c                	ld	a5,8(a4)
ffffffffc02011e8:	00e78663          	beq	a5,a4,ffffffffc02011f4 <slub_check+0xd6>
ffffffffc02011ec:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc02011ee:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02011f0:	fef71ee3          	bne	a4,a5,ffffffffc02011ec <slub_check+0xce>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc02011f4:	00001517          	auipc	a0,0x1
ffffffffc02011f8:	f3450513          	addi	a0,a0,-204 # ffffffffc0202128 <etext+0x990>
ffffffffc02011fc:	ebffe0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("slub check end\n");
}
ffffffffc0201200:	6442                	ld	s0,16(sp)
ffffffffc0201202:	60e2                	ld	ra,24(sp)
ffffffffc0201204:	64a2                	ld	s1,8(sp)
ffffffffc0201206:	6902                	ld	s2,0(sp)
    cprintf("slub check end\n");
ffffffffc0201208:	00001517          	auipc	a0,0x1
ffffffffc020120c:	f3850513          	addi	a0,a0,-200 # ffffffffc0202140 <etext+0x9a8>
}
ffffffffc0201210:	6105                	addi	sp,sp,32
    cprintf("slub check end\n");
ffffffffc0201212:	ea9fe06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0201216 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201216:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020121a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020121c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201220:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201222:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201226:	f022                	sd	s0,32(sp)
ffffffffc0201228:	ec26                	sd	s1,24(sp)
ffffffffc020122a:	e84a                	sd	s2,16(sp)
ffffffffc020122c:	f406                	sd	ra,40(sp)
ffffffffc020122e:	84aa                	mv	s1,a0
ffffffffc0201230:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201232:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201236:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201238:	05067063          	bgeu	a2,a6,ffffffffc0201278 <printnum+0x62>
ffffffffc020123c:	e44e                	sd	s3,8(sp)
ffffffffc020123e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201240:	4785                	li	a5,1
ffffffffc0201242:	00e7d763          	bge	a5,a4,ffffffffc0201250 <printnum+0x3a>
            putch(padc, putdat);
ffffffffc0201246:	85ca                	mv	a1,s2
ffffffffc0201248:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc020124a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020124c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020124e:	fc65                	bnez	s0,ffffffffc0201246 <printnum+0x30>
ffffffffc0201250:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201252:	1a02                	slli	s4,s4,0x20
ffffffffc0201254:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201258:	00001797          	auipc	a5,0x1
ffffffffc020125c:	ef878793          	addi	a5,a5,-264 # ffffffffc0202150 <etext+0x9b8>
ffffffffc0201260:	97d2                	add	a5,a5,s4
}
ffffffffc0201262:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201264:	0007c503          	lbu	a0,0(a5)
}
ffffffffc0201268:	70a2                	ld	ra,40(sp)
ffffffffc020126a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020126c:	85ca                	mv	a1,s2
ffffffffc020126e:	87a6                	mv	a5,s1
}
ffffffffc0201270:	6942                	ld	s2,16(sp)
ffffffffc0201272:	64e2                	ld	s1,24(sp)
ffffffffc0201274:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201276:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201278:	03065633          	divu	a2,a2,a6
ffffffffc020127c:	8722                	mv	a4,s0
ffffffffc020127e:	f99ff0ef          	jal	ffffffffc0201216 <printnum>
ffffffffc0201282:	bfc1                	j	ffffffffc0201252 <printnum+0x3c>

ffffffffc0201284 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201284:	7119                	addi	sp,sp,-128
ffffffffc0201286:	f4a6                	sd	s1,104(sp)
ffffffffc0201288:	f0ca                	sd	s2,96(sp)
ffffffffc020128a:	ecce                	sd	s3,88(sp)
ffffffffc020128c:	e8d2                	sd	s4,80(sp)
ffffffffc020128e:	e4d6                	sd	s5,72(sp)
ffffffffc0201290:	e0da                	sd	s6,64(sp)
ffffffffc0201292:	f862                	sd	s8,48(sp)
ffffffffc0201294:	fc86                	sd	ra,120(sp)
ffffffffc0201296:	f8a2                	sd	s0,112(sp)
ffffffffc0201298:	fc5e                	sd	s7,56(sp)
ffffffffc020129a:	f466                	sd	s9,40(sp)
ffffffffc020129c:	f06a                	sd	s10,32(sp)
ffffffffc020129e:	ec6e                	sd	s11,24(sp)
ffffffffc02012a0:	892a                	mv	s2,a0
ffffffffc02012a2:	84ae                	mv	s1,a1
ffffffffc02012a4:	8c32                	mv	s8,a2
ffffffffc02012a6:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012a8:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012ac:	05500b13          	li	s6,85
ffffffffc02012b0:	00001a97          	auipc	s5,0x1
ffffffffc02012b4:	008a8a93          	addi	s5,s5,8 # ffffffffc02022b8 <buddy_pmm_manager+0x38>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012b8:	000c4503          	lbu	a0,0(s8)
ffffffffc02012bc:	001c0413          	addi	s0,s8,1
ffffffffc02012c0:	01350a63          	beq	a0,s3,ffffffffc02012d4 <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc02012c4:	cd0d                	beqz	a0,ffffffffc02012fe <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc02012c6:	85a6                	mv	a1,s1
ffffffffc02012c8:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02012ca:	00044503          	lbu	a0,0(s0)
ffffffffc02012ce:	0405                	addi	s0,s0,1
ffffffffc02012d0:	ff351ae3          	bne	a0,s3,ffffffffc02012c4 <vprintfmt+0x40>
        char padc = ' ';
ffffffffc02012d4:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc02012d8:	4b81                	li	s7,0
ffffffffc02012da:	4601                	li	a2,0
        width = precision = -1;
ffffffffc02012dc:	5d7d                	li	s10,-1
ffffffffc02012de:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012e0:	00044683          	lbu	a3,0(s0)
ffffffffc02012e4:	00140c13          	addi	s8,s0,1
ffffffffc02012e8:	fdd6859b          	addiw	a1,a3,-35
ffffffffc02012ec:	0ff5f593          	zext.b	a1,a1
ffffffffc02012f0:	02bb6663          	bltu	s6,a1,ffffffffc020131c <vprintfmt+0x98>
ffffffffc02012f4:	058a                	slli	a1,a1,0x2
ffffffffc02012f6:	95d6                	add	a1,a1,s5
ffffffffc02012f8:	4198                	lw	a4,0(a1)
ffffffffc02012fa:	9756                	add	a4,a4,s5
ffffffffc02012fc:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02012fe:	70e6                	ld	ra,120(sp)
ffffffffc0201300:	7446                	ld	s0,112(sp)
ffffffffc0201302:	74a6                	ld	s1,104(sp)
ffffffffc0201304:	7906                	ld	s2,96(sp)
ffffffffc0201306:	69e6                	ld	s3,88(sp)
ffffffffc0201308:	6a46                	ld	s4,80(sp)
ffffffffc020130a:	6aa6                	ld	s5,72(sp)
ffffffffc020130c:	6b06                	ld	s6,64(sp)
ffffffffc020130e:	7be2                	ld	s7,56(sp)
ffffffffc0201310:	7c42                	ld	s8,48(sp)
ffffffffc0201312:	7ca2                	ld	s9,40(sp)
ffffffffc0201314:	7d02                	ld	s10,32(sp)
ffffffffc0201316:	6de2                	ld	s11,24(sp)
ffffffffc0201318:	6109                	addi	sp,sp,128
ffffffffc020131a:	8082                	ret
            putch('%', putdat);
ffffffffc020131c:	85a6                	mv	a1,s1
ffffffffc020131e:	02500513          	li	a0,37
ffffffffc0201322:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201324:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201328:	02500793          	li	a5,37
ffffffffc020132c:	8c22                	mv	s8,s0
ffffffffc020132e:	f8f705e3          	beq	a4,a5,ffffffffc02012b8 <vprintfmt+0x34>
ffffffffc0201332:	02500713          	li	a4,37
ffffffffc0201336:	ffec4783          	lbu	a5,-2(s8)
ffffffffc020133a:	1c7d                	addi	s8,s8,-1
ffffffffc020133c:	fee79de3          	bne	a5,a4,ffffffffc0201336 <vprintfmt+0xb2>
ffffffffc0201340:	bfa5                	j	ffffffffc02012b8 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc0201342:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc0201346:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
ffffffffc0201348:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc020134c:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
ffffffffc0201350:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201354:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
ffffffffc0201356:	02b76563          	bltu	a4,a1,ffffffffc0201380 <vprintfmt+0xfc>
ffffffffc020135a:	4525                	li	a0,9
                ch = *fmt;
ffffffffc020135c:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201360:	002d171b          	slliw	a4,s10,0x2
ffffffffc0201364:	01a7073b          	addw	a4,a4,s10
ffffffffc0201368:	0017171b          	slliw	a4,a4,0x1
ffffffffc020136c:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
ffffffffc020136e:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201372:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201374:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
ffffffffc0201378:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
ffffffffc020137c:	feb570e3          	bgeu	a0,a1,ffffffffc020135c <vprintfmt+0xd8>
            if (width < 0)
ffffffffc0201380:	f60cd0e3          	bgez	s9,ffffffffc02012e0 <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0201384:	8cea                	mv	s9,s10
ffffffffc0201386:	5d7d                	li	s10,-1
ffffffffc0201388:	bfa1                	j	ffffffffc02012e0 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020138a:	8db6                	mv	s11,a3
ffffffffc020138c:	8462                	mv	s0,s8
ffffffffc020138e:	bf89                	j	ffffffffc02012e0 <vprintfmt+0x5c>
ffffffffc0201390:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0201392:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0201394:	b7b1                	j	ffffffffc02012e0 <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0201396:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0201398:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc020139c:	00c7c463          	blt	a5,a2,ffffffffc02013a4 <vprintfmt+0x120>
    else if (lflag) {
ffffffffc02013a0:	1a060163          	beqz	a2,ffffffffc0201542 <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
ffffffffc02013a4:	000a3603          	ld	a2,0(s4)
ffffffffc02013a8:	46c1                	li	a3,16
ffffffffc02013aa:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02013ac:	000d879b          	sext.w	a5,s11
ffffffffc02013b0:	8766                	mv	a4,s9
ffffffffc02013b2:	85a6                	mv	a1,s1
ffffffffc02013b4:	854a                	mv	a0,s2
ffffffffc02013b6:	e61ff0ef          	jal	ffffffffc0201216 <printnum>
            break;
ffffffffc02013ba:	bdfd                	j	ffffffffc02012b8 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc02013bc:	000a2503          	lw	a0,0(s4)
ffffffffc02013c0:	85a6                	mv	a1,s1
ffffffffc02013c2:	0a21                	addi	s4,s4,8
ffffffffc02013c4:	9902                	jalr	s2
            break;
ffffffffc02013c6:	bdcd                	j	ffffffffc02012b8 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc02013c8:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc02013ca:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc02013ce:	00c7c463          	blt	a5,a2,ffffffffc02013d6 <vprintfmt+0x152>
    else if (lflag) {
ffffffffc02013d2:	16060363          	beqz	a2,ffffffffc0201538 <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
ffffffffc02013d6:	000a3603          	ld	a2,0(s4)
ffffffffc02013da:	46a9                	li	a3,10
ffffffffc02013dc:	8a3a                	mv	s4,a4
ffffffffc02013de:	b7f9                	j	ffffffffc02013ac <vprintfmt+0x128>
            putch('0', putdat);
ffffffffc02013e0:	85a6                	mv	a1,s1
ffffffffc02013e2:	03000513          	li	a0,48
ffffffffc02013e6:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02013e8:	85a6                	mv	a1,s1
ffffffffc02013ea:	07800513          	li	a0,120
ffffffffc02013ee:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02013f0:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc02013f4:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02013f6:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02013f8:	bf55                	j	ffffffffc02013ac <vprintfmt+0x128>
            putch(ch, putdat);
ffffffffc02013fa:	85a6                	mv	a1,s1
ffffffffc02013fc:	02500513          	li	a0,37
ffffffffc0201400:	9902                	jalr	s2
            break;
ffffffffc0201402:	bd5d                	j	ffffffffc02012b8 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0201404:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201408:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc020140a:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc020140c:	bf95                	j	ffffffffc0201380 <vprintfmt+0xfc>
    if (lflag >= 2) {
ffffffffc020140e:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0201410:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc0201414:	00c7c463          	blt	a5,a2,ffffffffc020141c <vprintfmt+0x198>
    else if (lflag) {
ffffffffc0201418:	10060b63          	beqz	a2,ffffffffc020152e <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
ffffffffc020141c:	000a3603          	ld	a2,0(s4)
ffffffffc0201420:	46a1                	li	a3,8
ffffffffc0201422:	8a3a                	mv	s4,a4
ffffffffc0201424:	b761                	j	ffffffffc02013ac <vprintfmt+0x128>
            if (width < 0)
ffffffffc0201426:	fffcc793          	not	a5,s9
ffffffffc020142a:	97fd                	srai	a5,a5,0x3f
ffffffffc020142c:	00fcf7b3          	and	a5,s9,a5
ffffffffc0201430:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201434:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0201436:	b56d                	j	ffffffffc02012e0 <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201438:	000a3403          	ld	s0,0(s4)
ffffffffc020143c:	008a0793          	addi	a5,s4,8
ffffffffc0201440:	e43e                	sd	a5,8(sp)
ffffffffc0201442:	12040063          	beqz	s0,ffffffffc0201562 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc0201446:	0d905963          	blez	s9,ffffffffc0201518 <vprintfmt+0x294>
ffffffffc020144a:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020144e:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
ffffffffc0201452:	12fd9763          	bne	s11,a5,ffffffffc0201580 <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201456:	00044783          	lbu	a5,0(s0)
ffffffffc020145a:	0007851b          	sext.w	a0,a5
ffffffffc020145e:	cb9d                	beqz	a5,ffffffffc0201494 <vprintfmt+0x210>
ffffffffc0201460:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201462:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201466:	000d4563          	bltz	s10,ffffffffc0201470 <vprintfmt+0x1ec>
ffffffffc020146a:	3d7d                	addiw	s10,s10,-1
ffffffffc020146c:	028d0263          	beq	s10,s0,ffffffffc0201490 <vprintfmt+0x20c>
                    putch('?', putdat);
ffffffffc0201470:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201472:	0c0b8d63          	beqz	s7,ffffffffc020154c <vprintfmt+0x2c8>
ffffffffc0201476:	3781                	addiw	a5,a5,-32
ffffffffc0201478:	0cfdfa63          	bgeu	s11,a5,ffffffffc020154c <vprintfmt+0x2c8>
                    putch('?', putdat);
ffffffffc020147c:	03f00513          	li	a0,63
ffffffffc0201480:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201482:	000a4783          	lbu	a5,0(s4)
ffffffffc0201486:	3cfd                	addiw	s9,s9,-1
ffffffffc0201488:	0a05                	addi	s4,s4,1
ffffffffc020148a:	0007851b          	sext.w	a0,a5
ffffffffc020148e:	ffe1                	bnez	a5,ffffffffc0201466 <vprintfmt+0x1e2>
            for (; width > 0; width --) {
ffffffffc0201490:	01905963          	blez	s9,ffffffffc02014a2 <vprintfmt+0x21e>
                putch(' ', putdat);
ffffffffc0201494:	85a6                	mv	a1,s1
ffffffffc0201496:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc020149a:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
ffffffffc020149c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020149e:	fe0c9be3          	bnez	s9,ffffffffc0201494 <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02014a2:	6a22                	ld	s4,8(sp)
ffffffffc02014a4:	bd11                	j	ffffffffc02012b8 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc02014a6:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc02014a8:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc02014ac:	00c7c363          	blt	a5,a2,ffffffffc02014b2 <vprintfmt+0x22e>
    else if (lflag) {
ffffffffc02014b0:	ce25                	beqz	a2,ffffffffc0201528 <vprintfmt+0x2a4>
        return va_arg(*ap, long);
ffffffffc02014b2:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02014b6:	08044d63          	bltz	s0,ffffffffc0201550 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc02014ba:	8622                	mv	a2,s0
ffffffffc02014bc:	8a5e                	mv	s4,s7
ffffffffc02014be:	46a9                	li	a3,10
ffffffffc02014c0:	b5f5                	j	ffffffffc02013ac <vprintfmt+0x128>
            if (err < 0) {
ffffffffc02014c2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014c6:	4619                	li	a2,6
            if (err < 0) {
ffffffffc02014c8:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc02014cc:	8fb9                	xor	a5,a5,a4
ffffffffc02014ce:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014d2:	02d64663          	blt	a2,a3,ffffffffc02014fe <vprintfmt+0x27a>
ffffffffc02014d6:	00369713          	slli	a4,a3,0x3
ffffffffc02014da:	00001797          	auipc	a5,0x1
ffffffffc02014de:	f3678793          	addi	a5,a5,-202 # ffffffffc0202410 <error_string>
ffffffffc02014e2:	97ba                	add	a5,a5,a4
ffffffffc02014e4:	639c                	ld	a5,0(a5)
ffffffffc02014e6:	cf81                	beqz	a5,ffffffffc02014fe <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02014e8:	86be                	mv	a3,a5
ffffffffc02014ea:	00001617          	auipc	a2,0x1
ffffffffc02014ee:	c9660613          	addi	a2,a2,-874 # ffffffffc0202180 <etext+0x9e8>
ffffffffc02014f2:	85a6                	mv	a1,s1
ffffffffc02014f4:	854a                	mv	a0,s2
ffffffffc02014f6:	0e8000ef          	jal	ffffffffc02015de <printfmt>
            err = va_arg(ap, int);
ffffffffc02014fa:	0a21                	addi	s4,s4,8
ffffffffc02014fc:	bb75                	j	ffffffffc02012b8 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02014fe:	00001617          	auipc	a2,0x1
ffffffffc0201502:	c7260613          	addi	a2,a2,-910 # ffffffffc0202170 <etext+0x9d8>
ffffffffc0201506:	85a6                	mv	a1,s1
ffffffffc0201508:	854a                	mv	a0,s2
ffffffffc020150a:	0d4000ef          	jal	ffffffffc02015de <printfmt>
            err = va_arg(ap, int);
ffffffffc020150e:	0a21                	addi	s4,s4,8
ffffffffc0201510:	b365                	j	ffffffffc02012b8 <vprintfmt+0x34>
            lflag ++;
ffffffffc0201512:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201514:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0201516:	b3e9                	j	ffffffffc02012e0 <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201518:	00044783          	lbu	a5,0(s0)
ffffffffc020151c:	0007851b          	sext.w	a0,a5
ffffffffc0201520:	d3c9                	beqz	a5,ffffffffc02014a2 <vprintfmt+0x21e>
ffffffffc0201522:	00140a13          	addi	s4,s0,1
ffffffffc0201526:	bf2d                	j	ffffffffc0201460 <vprintfmt+0x1dc>
        return va_arg(*ap, int);
ffffffffc0201528:	000a2403          	lw	s0,0(s4)
ffffffffc020152c:	b769                	j	ffffffffc02014b6 <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
ffffffffc020152e:	000a6603          	lwu	a2,0(s4)
ffffffffc0201532:	46a1                	li	a3,8
ffffffffc0201534:	8a3a                	mv	s4,a4
ffffffffc0201536:	bd9d                	j	ffffffffc02013ac <vprintfmt+0x128>
ffffffffc0201538:	000a6603          	lwu	a2,0(s4)
ffffffffc020153c:	46a9                	li	a3,10
ffffffffc020153e:	8a3a                	mv	s4,a4
ffffffffc0201540:	b5b5                	j	ffffffffc02013ac <vprintfmt+0x128>
ffffffffc0201542:	000a6603          	lwu	a2,0(s4)
ffffffffc0201546:	46c1                	li	a3,16
ffffffffc0201548:	8a3a                	mv	s4,a4
ffffffffc020154a:	b58d                	j	ffffffffc02013ac <vprintfmt+0x128>
                    putch(ch, putdat);
ffffffffc020154c:	9902                	jalr	s2
ffffffffc020154e:	bf15                	j	ffffffffc0201482 <vprintfmt+0x1fe>
                putch('-', putdat);
ffffffffc0201550:	85a6                	mv	a1,s1
ffffffffc0201552:	02d00513          	li	a0,45
ffffffffc0201556:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201558:	40800633          	neg	a2,s0
ffffffffc020155c:	8a5e                	mv	s4,s7
ffffffffc020155e:	46a9                	li	a3,10
ffffffffc0201560:	b5b1                	j	ffffffffc02013ac <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
ffffffffc0201562:	01905663          	blez	s9,ffffffffc020156e <vprintfmt+0x2ea>
ffffffffc0201566:	02d00793          	li	a5,45
ffffffffc020156a:	04fd9263          	bne	s11,a5,ffffffffc02015ae <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020156e:	02800793          	li	a5,40
ffffffffc0201572:	00001a17          	auipc	s4,0x1
ffffffffc0201576:	bf7a0a13          	addi	s4,s4,-1033 # ffffffffc0202169 <etext+0x9d1>
ffffffffc020157a:	02800513          	li	a0,40
ffffffffc020157e:	b5cd                	j	ffffffffc0201460 <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201580:	85ea                	mv	a1,s10
ffffffffc0201582:	8522                	mv	a0,s0
ffffffffc0201584:	198000ef          	jal	ffffffffc020171c <strnlen>
ffffffffc0201588:	40ac8cbb          	subw	s9,s9,a0
ffffffffc020158c:	01905963          	blez	s9,ffffffffc020159e <vprintfmt+0x31a>
                    putch(padc, putdat);
ffffffffc0201590:	2d81                	sext.w	s11,s11
ffffffffc0201592:	85a6                	mv	a1,s1
ffffffffc0201594:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201596:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
ffffffffc0201598:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020159a:	fe0c9ce3          	bnez	s9,ffffffffc0201592 <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020159e:	00044783          	lbu	a5,0(s0)
ffffffffc02015a2:	0007851b          	sext.w	a0,a5
ffffffffc02015a6:	ea079de3          	bnez	a5,ffffffffc0201460 <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02015aa:	6a22                	ld	s4,8(sp)
ffffffffc02015ac:	b331                	j	ffffffffc02012b8 <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02015ae:	85ea                	mv	a1,s10
ffffffffc02015b0:	00001517          	auipc	a0,0x1
ffffffffc02015b4:	bb850513          	addi	a0,a0,-1096 # ffffffffc0202168 <etext+0x9d0>
ffffffffc02015b8:	164000ef          	jal	ffffffffc020171c <strnlen>
ffffffffc02015bc:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
ffffffffc02015c0:	00001417          	auipc	s0,0x1
ffffffffc02015c4:	ba840413          	addi	s0,s0,-1112 # ffffffffc0202168 <etext+0x9d0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02015c8:	00001a17          	auipc	s4,0x1
ffffffffc02015cc:	ba1a0a13          	addi	s4,s4,-1119 # ffffffffc0202169 <etext+0x9d1>
ffffffffc02015d0:	02800793          	li	a5,40
ffffffffc02015d4:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02015d8:	fb904ce3          	bgtz	s9,ffffffffc0201590 <vprintfmt+0x30c>
ffffffffc02015dc:	b551                	j	ffffffffc0201460 <vprintfmt+0x1dc>

ffffffffc02015de <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015de:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02015e0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015e4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02015e6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02015e8:	ec06                	sd	ra,24(sp)
ffffffffc02015ea:	f83a                	sd	a4,48(sp)
ffffffffc02015ec:	fc3e                	sd	a5,56(sp)
ffffffffc02015ee:	e0c2                	sd	a6,64(sp)
ffffffffc02015f0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02015f2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02015f4:	c91ff0ef          	jal	ffffffffc0201284 <vprintfmt>
}
ffffffffc02015f8:	60e2                	ld	ra,24(sp)
ffffffffc02015fa:	6161                	addi	sp,sp,80
ffffffffc02015fc:	8082                	ret

ffffffffc02015fe <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02015fe:	715d                	addi	sp,sp,-80
ffffffffc0201600:	e486                	sd	ra,72(sp)
ffffffffc0201602:	e0a2                	sd	s0,64(sp)
ffffffffc0201604:	fc26                	sd	s1,56(sp)
ffffffffc0201606:	f84a                	sd	s2,48(sp)
ffffffffc0201608:	f44e                	sd	s3,40(sp)
ffffffffc020160a:	f052                	sd	s4,32(sp)
ffffffffc020160c:	ec56                	sd	s5,24(sp)
ffffffffc020160e:	e85a                	sd	s6,16(sp)
    if (prompt != NULL) {
ffffffffc0201610:	c901                	beqz	a0,ffffffffc0201620 <readline+0x22>
ffffffffc0201612:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201614:	00001517          	auipc	a0,0x1
ffffffffc0201618:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0202180 <etext+0x9e8>
ffffffffc020161c:	a9ffe0ef          	jal	ffffffffc02000ba <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc0201620:	4401                	li	s0,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201622:	44fd                	li	s1,31
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201624:	4921                	li	s2,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201626:	4a29                	li	s4,10
ffffffffc0201628:	4ab5                	li	s5,13
            buf[i ++] = c;
ffffffffc020162a:	00005b17          	auipc	s6,0x5
ffffffffc020162e:	b46b0b13          	addi	s6,s6,-1210 # ffffffffc0206170 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201632:	3fe00993          	li	s3,1022
        c = getchar();
ffffffffc0201636:	b09fe0ef          	jal	ffffffffc020013e <getchar>
        if (c < 0) {
ffffffffc020163a:	00054a63          	bltz	a0,ffffffffc020164e <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020163e:	00a4da63          	bge	s1,a0,ffffffffc0201652 <readline+0x54>
ffffffffc0201642:	0289d263          	bge	s3,s0,ffffffffc0201666 <readline+0x68>
        c = getchar();
ffffffffc0201646:	af9fe0ef          	jal	ffffffffc020013e <getchar>
        if (c < 0) {
ffffffffc020164a:	fe055ae3          	bgez	a0,ffffffffc020163e <readline+0x40>
            return NULL;
ffffffffc020164e:	4501                	li	a0,0
ffffffffc0201650:	a091                	j	ffffffffc0201694 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201652:	03251463          	bne	a0,s2,ffffffffc020167a <readline+0x7c>
ffffffffc0201656:	04804963          	bgtz	s0,ffffffffc02016a8 <readline+0xaa>
        c = getchar();
ffffffffc020165a:	ae5fe0ef          	jal	ffffffffc020013e <getchar>
        if (c < 0) {
ffffffffc020165e:	fe0548e3          	bltz	a0,ffffffffc020164e <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201662:	fea4d8e3          	bge	s1,a0,ffffffffc0201652 <readline+0x54>
            cputchar(c);
ffffffffc0201666:	e42a                	sd	a0,8(sp)
ffffffffc0201668:	a87fe0ef          	jal	ffffffffc02000ee <cputchar>
            buf[i ++] = c;
ffffffffc020166c:	6522                	ld	a0,8(sp)
ffffffffc020166e:	008b07b3          	add	a5,s6,s0
ffffffffc0201672:	2405                	addiw	s0,s0,1
ffffffffc0201674:	00a78023          	sb	a0,0(a5)
ffffffffc0201678:	bf7d                	j	ffffffffc0201636 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020167a:	01450463          	beq	a0,s4,ffffffffc0201682 <readline+0x84>
ffffffffc020167e:	fb551ce3          	bne	a0,s5,ffffffffc0201636 <readline+0x38>
            cputchar(c);
ffffffffc0201682:	a6dfe0ef          	jal	ffffffffc02000ee <cputchar>
            buf[i] = '\0';
ffffffffc0201686:	00005517          	auipc	a0,0x5
ffffffffc020168a:	aea50513          	addi	a0,a0,-1302 # ffffffffc0206170 <buf>
ffffffffc020168e:	942a                	add	s0,s0,a0
ffffffffc0201690:	00040023          	sb	zero,0(s0)
            return buf;
        }
    }
}
ffffffffc0201694:	60a6                	ld	ra,72(sp)
ffffffffc0201696:	6406                	ld	s0,64(sp)
ffffffffc0201698:	74e2                	ld	s1,56(sp)
ffffffffc020169a:	7942                	ld	s2,48(sp)
ffffffffc020169c:	79a2                	ld	s3,40(sp)
ffffffffc020169e:	7a02                	ld	s4,32(sp)
ffffffffc02016a0:	6ae2                	ld	s5,24(sp)
ffffffffc02016a2:	6b42                	ld	s6,16(sp)
ffffffffc02016a4:	6161                	addi	sp,sp,80
ffffffffc02016a6:	8082                	ret
            cputchar(c);
ffffffffc02016a8:	4521                	li	a0,8
ffffffffc02016aa:	a45fe0ef          	jal	ffffffffc02000ee <cputchar>
            i --;
ffffffffc02016ae:	347d                	addiw	s0,s0,-1
ffffffffc02016b0:	b759                	j	ffffffffc0201636 <readline+0x38>

ffffffffc02016b2 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02016b2:	4781                	li	a5,0
ffffffffc02016b4:	00005717          	auipc	a4,0x5
ffffffffc02016b8:	97473703          	ld	a4,-1676(a4) # ffffffffc0206028 <SBI_CONSOLE_PUTCHAR>
ffffffffc02016bc:	88ba                	mv	a7,a4
ffffffffc02016be:	852a                	mv	a0,a0
ffffffffc02016c0:	85be                	mv	a1,a5
ffffffffc02016c2:	863e                	mv	a2,a5
ffffffffc02016c4:	00000073          	ecall
ffffffffc02016c8:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02016ca:	8082                	ret

ffffffffc02016cc <sbi_set_timer>:
    __asm__ volatile (
ffffffffc02016cc:	4781                	li	a5,0
ffffffffc02016ce:	00005717          	auipc	a4,0x5
ffffffffc02016d2:	efa73703          	ld	a4,-262(a4) # ffffffffc02065c8 <SBI_SET_TIMER>
ffffffffc02016d6:	88ba                	mv	a7,a4
ffffffffc02016d8:	852a                	mv	a0,a0
ffffffffc02016da:	85be                	mv	a1,a5
ffffffffc02016dc:	863e                	mv	a2,a5
ffffffffc02016de:	00000073          	ecall
ffffffffc02016e2:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02016e4:	8082                	ret

ffffffffc02016e6 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02016e6:	4501                	li	a0,0
ffffffffc02016e8:	00005797          	auipc	a5,0x5
ffffffffc02016ec:	9387b783          	ld	a5,-1736(a5) # ffffffffc0206020 <SBI_CONSOLE_GETCHAR>
ffffffffc02016f0:	88be                	mv	a7,a5
ffffffffc02016f2:	852a                	mv	a0,a0
ffffffffc02016f4:	85aa                	mv	a1,a0
ffffffffc02016f6:	862a                	mv	a2,a0
ffffffffc02016f8:	00000073          	ecall
ffffffffc02016fc:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc02016fe:	2501                	sext.w	a0,a0
ffffffffc0201700:	8082                	ret

ffffffffc0201702 <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201702:	4781                	li	a5,0
ffffffffc0201704:	00005717          	auipc	a4,0x5
ffffffffc0201708:	91473703          	ld	a4,-1772(a4) # ffffffffc0206018 <SBI_SHUTDOWN>
ffffffffc020170c:	88ba                	mv	a7,a4
ffffffffc020170e:	853e                	mv	a0,a5
ffffffffc0201710:	85be                	mv	a1,a5
ffffffffc0201712:	863e                	mv	a2,a5
ffffffffc0201714:	00000073          	ecall
ffffffffc0201718:	87aa                	mv	a5,a0
void sbi_shutdown(void)
{
  //  __asm__ volatile(".word 0xFFFFFFFF");  // 触发非法指令异常
   //__asm__ volatile("ebreak");  // 触发断点异常
    sbi_call(SBI_SHUTDOWN,0,0,0);
}
ffffffffc020171a:	8082                	ret

ffffffffc020171c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020171c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020171e:	e589                	bnez	a1,ffffffffc0201728 <strnlen+0xc>
ffffffffc0201720:	a811                	j	ffffffffc0201734 <strnlen+0x18>
        cnt ++;
ffffffffc0201722:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201724:	00f58863          	beq	a1,a5,ffffffffc0201734 <strnlen+0x18>
ffffffffc0201728:	00f50733          	add	a4,a0,a5
ffffffffc020172c:	00074703          	lbu	a4,0(a4)
ffffffffc0201730:	fb6d                	bnez	a4,ffffffffc0201722 <strnlen+0x6>
ffffffffc0201732:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201734:	852e                	mv	a0,a1
ffffffffc0201736:	8082                	ret

ffffffffc0201738 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201738:	00054783          	lbu	a5,0(a0)
ffffffffc020173c:	e791                	bnez	a5,ffffffffc0201748 <strcmp+0x10>
ffffffffc020173e:	a02d                	j	ffffffffc0201768 <strcmp+0x30>
ffffffffc0201740:	00054783          	lbu	a5,0(a0)
ffffffffc0201744:	cf89                	beqz	a5,ffffffffc020175e <strcmp+0x26>
ffffffffc0201746:	85b6                	mv	a1,a3
ffffffffc0201748:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc020174c:	0505                	addi	a0,a0,1
ffffffffc020174e:	00158693          	addi	a3,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201752:	fef707e3          	beq	a4,a5,ffffffffc0201740 <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201756:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020175a:	9d19                	subw	a0,a0,a4
ffffffffc020175c:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020175e:	0015c703          	lbu	a4,1(a1)
ffffffffc0201762:	4501                	li	a0,0
}
ffffffffc0201764:	9d19                	subw	a0,a0,a4
ffffffffc0201766:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201768:	0005c703          	lbu	a4,0(a1)
ffffffffc020176c:	4501                	li	a0,0
ffffffffc020176e:	b7f5                	j	ffffffffc020175a <strcmp+0x22>

ffffffffc0201770 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201770:	00054783          	lbu	a5,0(a0)
ffffffffc0201774:	c799                	beqz	a5,ffffffffc0201782 <strchr+0x12>
        if (*s == c) {
ffffffffc0201776:	00f58763          	beq	a1,a5,ffffffffc0201784 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020177a:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020177e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201780:	fbfd                	bnez	a5,ffffffffc0201776 <strchr+0x6>
    }
    return NULL;
ffffffffc0201782:	4501                	li	a0,0
}
ffffffffc0201784:	8082                	ret

ffffffffc0201786 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201786:	ca01                	beqz	a2,ffffffffc0201796 <memset+0x10>
ffffffffc0201788:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020178a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020178c:	0785                	addi	a5,a5,1
ffffffffc020178e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201792:	fef61de3          	bne	a2,a5,ffffffffc020178c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201796:	8082                	ret
