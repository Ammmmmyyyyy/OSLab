
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits # "ax" 表示这是一个可执行和可读的段。
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)# lui 指令将 boot_page_table_sv39 的高位部分加载到寄存器 t0
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000# 0xffffffffc0000000 是虚拟地址，0x80000000 是映射的物理地址
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
    or      t0, t0, t1 # 将 t0 中计算出来的物理页号与 t1 中的 Sv39 模式组合，形成完整的 satp 值
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0 #csrw 指令将 t0 中的值写入 satp 寄存器，激活三级页表和虚拟内存模式
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
    lui t0, %hi(kern_init)# %hi(kern_init) 是内核函数 kern_init 地址的高 20 位
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
ffffffffc0200036:	ffe50513          	addi	a0,a0,-2 # ffffffffc0206030 <free_area2>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	46660613          	addi	a2,a2,1126 # ffffffffc02064a0 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16 # ffffffffc0204ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	497010ef          	jal	ffffffffc0201ce0 <memset>
    cons_init();  // init the console
ffffffffc020004e:	400000ef          	jal	ffffffffc020044e <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00002517          	auipc	a0,0x2
ffffffffc0200056:	ca650513          	addi	a0,a0,-858 # ffffffffc0201cf8 <etext+0x6>
ffffffffc020005a:	096000ef          	jal	ffffffffc02000f0 <cputs>

    print_kerninfo();
ffffffffc020005e:	0f0000ef          	jal	ffffffffc020014e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	406000ef          	jal	ffffffffc0200468 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	2a2010ef          	jal	ffffffffc0201308 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fe000ef          	jal	ffffffffc0200468 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39e000ef          	jal	ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3ea000ef          	jal	ffffffffc020045c <intr_enable>

    slub_init();
ffffffffc0200076:	5a2010ef          	jal	ffffffffc0201618 <slub_init>
    slub_check();
ffffffffc020007a:	5fe010ef          	jal	ffffffffc0201678 <slub_check>

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
ffffffffc02000ae:	730010ef          	jal	ffffffffc02017de <vprintfmt>
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
ffffffffc02000e2:	6fc010ef          	jal	ffffffffc02017de <vprintfmt>
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
ffffffffc0200150:	00002517          	auipc	a0,0x2
ffffffffc0200154:	bc850513          	addi	a0,a0,-1080 # ffffffffc0201d18 <etext+0x26>
void print_kerninfo(void) {
ffffffffc0200158:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020015a:	f61ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020015e:	00000597          	auipc	a1,0x0
ffffffffc0200162:	ed458593          	addi	a1,a1,-300 # ffffffffc0200032 <kern_init>
ffffffffc0200166:	00002517          	auipc	a0,0x2
ffffffffc020016a:	bd250513          	addi	a0,a0,-1070 # ffffffffc0201d38 <etext+0x46>
ffffffffc020016e:	f4dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200172:	00002597          	auipc	a1,0x2
ffffffffc0200176:	b8058593          	addi	a1,a1,-1152 # ffffffffc0201cf2 <etext>
ffffffffc020017a:	00002517          	auipc	a0,0x2
ffffffffc020017e:	bde50513          	addi	a0,a0,-1058 # ffffffffc0201d58 <etext+0x66>
ffffffffc0200182:	f39ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	eaa58593          	addi	a1,a1,-342 # ffffffffc0206030 <free_area2>
ffffffffc020018e:	00002517          	auipc	a0,0x2
ffffffffc0200192:	bea50513          	addi	a0,a0,-1046 # ffffffffc0201d78 <etext+0x86>
ffffffffc0200196:	f25ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	30658593          	addi	a1,a1,774 # ffffffffc02064a0 <end>
ffffffffc02001a2:	00002517          	auipc	a0,0x2
ffffffffc02001a6:	bf650513          	addi	a0,a0,-1034 # ffffffffc0201d98 <etext+0xa6>
ffffffffc02001aa:	f11ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001ae:	00006797          	auipc	a5,0x6
ffffffffc02001b2:	6f178793          	addi	a5,a5,1777 # ffffffffc020689f <end+0x3ff>
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
ffffffffc02001ce:	00002517          	auipc	a0,0x2
ffffffffc02001d2:	bea50513          	addi	a0,a0,-1046 # ffffffffc0201db8 <etext+0xc6>
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
ffffffffc02001dc:	00002617          	auipc	a2,0x2
ffffffffc02001e0:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0201de8 <etext+0xf6>
ffffffffc02001e4:	04e00593          	li	a1,78
ffffffffc02001e8:	00002517          	auipc	a0,0x2
ffffffffc02001ec:	c1850513          	addi	a0,a0,-1000 # ffffffffc0201e00 <etext+0x10e>
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
ffffffffc02001f8:	00002617          	auipc	a2,0x2
ffffffffc02001fc:	c2060613          	addi	a2,a2,-992 # ffffffffc0201e18 <etext+0x126>
ffffffffc0200200:	00002597          	auipc	a1,0x2
ffffffffc0200204:	c3858593          	addi	a1,a1,-968 # ffffffffc0201e38 <etext+0x146>
ffffffffc0200208:	00002517          	auipc	a0,0x2
ffffffffc020020c:	c3850513          	addi	a0,a0,-968 # ffffffffc0201e40 <etext+0x14e>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200210:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200212:	ea9ff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0200216:	00002617          	auipc	a2,0x2
ffffffffc020021a:	c3a60613          	addi	a2,a2,-966 # ffffffffc0201e50 <etext+0x15e>
ffffffffc020021e:	00002597          	auipc	a1,0x2
ffffffffc0200222:	c5a58593          	addi	a1,a1,-934 # ffffffffc0201e78 <etext+0x186>
ffffffffc0200226:	00002517          	auipc	a0,0x2
ffffffffc020022a:	c1a50513          	addi	a0,a0,-998 # ffffffffc0201e40 <etext+0x14e>
ffffffffc020022e:	e8dff0ef          	jal	ffffffffc02000ba <cprintf>
ffffffffc0200232:	00002617          	auipc	a2,0x2
ffffffffc0200236:	c5660613          	addi	a2,a2,-938 # ffffffffc0201e88 <etext+0x196>
ffffffffc020023a:	00002597          	auipc	a1,0x2
ffffffffc020023e:	c6e58593          	addi	a1,a1,-914 # ffffffffc0201ea8 <etext+0x1b6>
ffffffffc0200242:	00002517          	auipc	a0,0x2
ffffffffc0200246:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0201e40 <etext+0x14e>
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
ffffffffc020027c:	00002517          	auipc	a0,0x2
ffffffffc0200280:	c3c50513          	addi	a0,a0,-964 # ffffffffc0201eb8 <etext+0x1c6>
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
ffffffffc020029e:	00002517          	auipc	a0,0x2
ffffffffc02002a2:	c4250513          	addi	a0,a0,-958 # ffffffffc0201ee0 <etext+0x1ee>
ffffffffc02002a6:	e15ff0ef          	jal	ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002aa:	000b0563          	beqz	s6,ffffffffc02002b4 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002ae:	855a                	mv	a0,s6
ffffffffc02002b0:	396000ef          	jal	ffffffffc0200646 <print_trapframe>
ffffffffc02002b4:	00002c17          	auipc	s8,0x2
ffffffffc02002b8:	6ccc0c13          	addi	s8,s8,1740 # ffffffffc0202980 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002bc:	00002917          	auipc	s2,0x2
ffffffffc02002c0:	c4c90913          	addi	s2,s2,-948 # ffffffffc0201f08 <etext+0x216>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002c4:	00002497          	auipc	s1,0x2
ffffffffc02002c8:	c4c48493          	addi	s1,s1,-948 # ffffffffc0201f10 <etext+0x21e>
        if (argc == MAXARGS - 1) {
ffffffffc02002cc:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002ce:	00002a97          	auipc	s5,0x2
ffffffffc02002d2:	c4aa8a93          	addi	s5,s5,-950 # ffffffffc0201f18 <etext+0x226>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d6:	4a0d                	li	s4,3
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02002d8:	00002b97          	auipc	s7,0x2
ffffffffc02002dc:	c60b8b93          	addi	s7,s7,-928 # ffffffffc0201f38 <etext+0x246>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002e0:	854a                	mv	a0,s2
ffffffffc02002e2:	077010ef          	jal	ffffffffc0201b58 <readline>
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
ffffffffc02002fa:	68ad0d13          	addi	s10,s10,1674 # ffffffffc0202980 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fe:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	6582                	ld	a1,0(sp)
ffffffffc0200302:	000d3503          	ld	a0,0(s10)
ffffffffc0200306:	18d010ef          	jal	ffffffffc0201c92 <strcmp>
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
ffffffffc0200320:	1ab010ef          	jal	ffffffffc0201cca <strchr>
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
ffffffffc0200360:	16b010ef          	jal	ffffffffc0201cca <strchr>
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
ffffffffc02003b2:	09a30313          	addi	t1,t1,154 # ffffffffc0206448 <is_panic>
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
ffffffffc02003dc:	00002517          	auipc	a0,0x2
ffffffffc02003e0:	b7450513          	addi	a0,a0,-1164 # ffffffffc0201f50 <etext+0x25e>
    va_start(ap, fmt);
ffffffffc02003e4:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e6:	cd5ff0ef          	jal	ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ea:	65a2                	ld	a1,8(sp)
ffffffffc02003ec:	8522                	mv	a0,s0
ffffffffc02003ee:	cadff0ef          	jal	ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc02003f2:	00002517          	auipc	a0,0x2
ffffffffc02003f6:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0201f70 <etext+0x27e>
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
ffffffffc0200424:	003010ef          	jal	ffffffffc0201c26 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0207b323          	sd	zero,38(a5) # ffffffffc0206450 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	b4650513          	addi	a0,a0,-1210 # ffffffffc0201f78 <etext+0x286>
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
ffffffffc020044a:	7dc0106f          	j	ffffffffc0201c26 <sbi_set_timer>

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
ffffffffc0200454:	7b80106f          	j	ffffffffc0201c0c <sbi_console_putchar>

ffffffffc0200458 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200458:	7e80106f          	j	ffffffffc0201c40 <sbi_console_getchar>

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
ffffffffc0200482:	00002517          	auipc	a0,0x2
ffffffffc0200486:	b1650513          	addi	a0,a0,-1258 # ffffffffc0201f98 <etext+0x2a6>
void print_regs(struct pushregs *gpr) {
ffffffffc020048a:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048c:	c2fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200490:	640c                	ld	a1,8(s0)
ffffffffc0200492:	00002517          	auipc	a0,0x2
ffffffffc0200496:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0201fb0 <etext+0x2be>
ffffffffc020049a:	c21ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049e:	680c                	ld	a1,16(s0)
ffffffffc02004a0:	00002517          	auipc	a0,0x2
ffffffffc02004a4:	b2850513          	addi	a0,a0,-1240 # ffffffffc0201fc8 <etext+0x2d6>
ffffffffc02004a8:	c13ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ac:	6c0c                	ld	a1,24(s0)
ffffffffc02004ae:	00002517          	auipc	a0,0x2
ffffffffc02004b2:	b3250513          	addi	a0,a0,-1230 # ffffffffc0201fe0 <etext+0x2ee>
ffffffffc02004b6:	c05ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004ba:	700c                	ld	a1,32(s0)
ffffffffc02004bc:	00002517          	auipc	a0,0x2
ffffffffc02004c0:	b3c50513          	addi	a0,a0,-1220 # ffffffffc0201ff8 <etext+0x306>
ffffffffc02004c4:	bf7ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c8:	740c                	ld	a1,40(s0)
ffffffffc02004ca:	00002517          	auipc	a0,0x2
ffffffffc02004ce:	b4650513          	addi	a0,a0,-1210 # ffffffffc0202010 <etext+0x31e>
ffffffffc02004d2:	be9ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d6:	780c                	ld	a1,48(s0)
ffffffffc02004d8:	00002517          	auipc	a0,0x2
ffffffffc02004dc:	b5050513          	addi	a0,a0,-1200 # ffffffffc0202028 <etext+0x336>
ffffffffc02004e0:	bdbff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e4:	7c0c                	ld	a1,56(s0)
ffffffffc02004e6:	00002517          	auipc	a0,0x2
ffffffffc02004ea:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0202040 <etext+0x34e>
ffffffffc02004ee:	bcdff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f2:	602c                	ld	a1,64(s0)
ffffffffc02004f4:	00002517          	auipc	a0,0x2
ffffffffc02004f8:	b6450513          	addi	a0,a0,-1180 # ffffffffc0202058 <etext+0x366>
ffffffffc02004fc:	bbfff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200500:	642c                	ld	a1,72(s0)
ffffffffc0200502:	00002517          	auipc	a0,0x2
ffffffffc0200506:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0202070 <etext+0x37e>
ffffffffc020050a:	bb1ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050e:	682c                	ld	a1,80(s0)
ffffffffc0200510:	00002517          	auipc	a0,0x2
ffffffffc0200514:	b7850513          	addi	a0,a0,-1160 # ffffffffc0202088 <etext+0x396>
ffffffffc0200518:	ba3ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051c:	6c2c                	ld	a1,88(s0)
ffffffffc020051e:	00002517          	auipc	a0,0x2
ffffffffc0200522:	b8250513          	addi	a0,a0,-1150 # ffffffffc02020a0 <etext+0x3ae>
ffffffffc0200526:	b95ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052a:	702c                	ld	a1,96(s0)
ffffffffc020052c:	00002517          	auipc	a0,0x2
ffffffffc0200530:	b8c50513          	addi	a0,a0,-1140 # ffffffffc02020b8 <etext+0x3c6>
ffffffffc0200534:	b87ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200538:	742c                	ld	a1,104(s0)
ffffffffc020053a:	00002517          	auipc	a0,0x2
ffffffffc020053e:	b9650513          	addi	a0,a0,-1130 # ffffffffc02020d0 <etext+0x3de>
ffffffffc0200542:	b79ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200546:	782c                	ld	a1,112(s0)
ffffffffc0200548:	00002517          	auipc	a0,0x2
ffffffffc020054c:	ba050513          	addi	a0,a0,-1120 # ffffffffc02020e8 <etext+0x3f6>
ffffffffc0200550:	b6bff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200554:	7c2c                	ld	a1,120(s0)
ffffffffc0200556:	00002517          	auipc	a0,0x2
ffffffffc020055a:	baa50513          	addi	a0,a0,-1110 # ffffffffc0202100 <etext+0x40e>
ffffffffc020055e:	b5dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200562:	604c                	ld	a1,128(s0)
ffffffffc0200564:	00002517          	auipc	a0,0x2
ffffffffc0200568:	bb450513          	addi	a0,a0,-1100 # ffffffffc0202118 <etext+0x426>
ffffffffc020056c:	b4fff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200570:	644c                	ld	a1,136(s0)
ffffffffc0200572:	00002517          	auipc	a0,0x2
ffffffffc0200576:	bbe50513          	addi	a0,a0,-1090 # ffffffffc0202130 <etext+0x43e>
ffffffffc020057a:	b41ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057e:	684c                	ld	a1,144(s0)
ffffffffc0200580:	00002517          	auipc	a0,0x2
ffffffffc0200584:	bc850513          	addi	a0,a0,-1080 # ffffffffc0202148 <etext+0x456>
ffffffffc0200588:	b33ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058c:	6c4c                	ld	a1,152(s0)
ffffffffc020058e:	00002517          	auipc	a0,0x2
ffffffffc0200592:	bd250513          	addi	a0,a0,-1070 # ffffffffc0202160 <etext+0x46e>
ffffffffc0200596:	b25ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059a:	704c                	ld	a1,160(s0)
ffffffffc020059c:	00002517          	auipc	a0,0x2
ffffffffc02005a0:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0202178 <etext+0x486>
ffffffffc02005a4:	b17ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a8:	744c                	ld	a1,168(s0)
ffffffffc02005aa:	00002517          	auipc	a0,0x2
ffffffffc02005ae:	be650513          	addi	a0,a0,-1050 # ffffffffc0202190 <etext+0x49e>
ffffffffc02005b2:	b09ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b6:	784c                	ld	a1,176(s0)
ffffffffc02005b8:	00002517          	auipc	a0,0x2
ffffffffc02005bc:	bf050513          	addi	a0,a0,-1040 # ffffffffc02021a8 <etext+0x4b6>
ffffffffc02005c0:	afbff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c4:	7c4c                	ld	a1,184(s0)
ffffffffc02005c6:	00002517          	auipc	a0,0x2
ffffffffc02005ca:	bfa50513          	addi	a0,a0,-1030 # ffffffffc02021c0 <etext+0x4ce>
ffffffffc02005ce:	aedff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d2:	606c                	ld	a1,192(s0)
ffffffffc02005d4:	00002517          	auipc	a0,0x2
ffffffffc02005d8:	c0450513          	addi	a0,a0,-1020 # ffffffffc02021d8 <etext+0x4e6>
ffffffffc02005dc:	adfff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e0:	646c                	ld	a1,200(s0)
ffffffffc02005e2:	00002517          	auipc	a0,0x2
ffffffffc02005e6:	c0e50513          	addi	a0,a0,-1010 # ffffffffc02021f0 <etext+0x4fe>
ffffffffc02005ea:	ad1ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ee:	686c                	ld	a1,208(s0)
ffffffffc02005f0:	00002517          	auipc	a0,0x2
ffffffffc02005f4:	c1850513          	addi	a0,a0,-1000 # ffffffffc0202208 <etext+0x516>
ffffffffc02005f8:	ac3ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fc:	6c6c                	ld	a1,216(s0)
ffffffffc02005fe:	00002517          	auipc	a0,0x2
ffffffffc0200602:	c2250513          	addi	a0,a0,-990 # ffffffffc0202220 <etext+0x52e>
ffffffffc0200606:	ab5ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060a:	706c                	ld	a1,224(s0)
ffffffffc020060c:	00002517          	auipc	a0,0x2
ffffffffc0200610:	c2c50513          	addi	a0,a0,-980 # ffffffffc0202238 <etext+0x546>
ffffffffc0200614:	aa7ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200618:	746c                	ld	a1,232(s0)
ffffffffc020061a:	00002517          	auipc	a0,0x2
ffffffffc020061e:	c3650513          	addi	a0,a0,-970 # ffffffffc0202250 <etext+0x55e>
ffffffffc0200622:	a99ff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200626:	786c                	ld	a1,240(s0)
ffffffffc0200628:	00002517          	auipc	a0,0x2
ffffffffc020062c:	c4050513          	addi	a0,a0,-960 # ffffffffc0202268 <etext+0x576>
ffffffffc0200630:	a8bff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200634:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200636:	6402                	ld	s0,0(sp)
ffffffffc0200638:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063a:	00002517          	auipc	a0,0x2
ffffffffc020063e:	c4650513          	addi	a0,a0,-954 # ffffffffc0202280 <etext+0x58e>
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
ffffffffc020064e:	00002517          	auipc	a0,0x2
ffffffffc0200652:	c4a50513          	addi	a0,a0,-950 # ffffffffc0202298 <etext+0x5a6>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200656:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200658:	a63ff0ef          	jal	ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc020065c:	8522                	mv	a0,s0
ffffffffc020065e:	e1dff0ef          	jal	ffffffffc020047a <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200662:	10043583          	ld	a1,256(s0)
ffffffffc0200666:	00002517          	auipc	a0,0x2
ffffffffc020066a:	c4a50513          	addi	a0,a0,-950 # ffffffffc02022b0 <etext+0x5be>
ffffffffc020066e:	a4dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200672:	10843583          	ld	a1,264(s0)
ffffffffc0200676:	00002517          	auipc	a0,0x2
ffffffffc020067a:	c5250513          	addi	a0,a0,-942 # ffffffffc02022c8 <etext+0x5d6>
ffffffffc020067e:	a3dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200682:	11043583          	ld	a1,272(s0)
ffffffffc0200686:	00002517          	auipc	a0,0x2
ffffffffc020068a:	c5a50513          	addi	a0,a0,-934 # ffffffffc02022e0 <etext+0x5ee>
ffffffffc020068e:	a2dff0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200692:	11843583          	ld	a1,280(s0)
}
ffffffffc0200696:	6402                	ld	s0,0(sp)
ffffffffc0200698:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069a:	00002517          	auipc	a0,0x2
ffffffffc020069e:	c5e50513          	addi	a0,a0,-930 # ffffffffc02022f8 <etext+0x606>
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
ffffffffc02006b8:	31470713          	addi	a4,a4,788 # ffffffffc02029c8 <commands+0x48>
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
ffffffffc02006c6:	00002517          	auipc	a0,0x2
ffffffffc02006ca:	caa50513          	addi	a0,a0,-854 # ffffffffc0202370 <etext+0x67e>
ffffffffc02006ce:	b2f5                	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006d0:	00002517          	auipc	a0,0x2
ffffffffc02006d4:	c8050513          	addi	a0,a0,-896 # ffffffffc0202350 <etext+0x65e>
ffffffffc02006d8:	b2cd                	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006da:	00002517          	auipc	a0,0x2
ffffffffc02006de:	c3650513          	addi	a0,a0,-970 # ffffffffc0202310 <etext+0x61e>
ffffffffc02006e2:	bae1                	j	ffffffffc02000ba <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e4:	00002517          	auipc	a0,0x2
ffffffffc02006e8:	cac50513          	addi	a0,a0,-852 # ffffffffc0202390 <etext+0x69e>
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
ffffffffc02006fc:	d5878793          	addi	a5,a5,-680 # ffffffffc0206450 <ticks>
ffffffffc0200700:	6398                	ld	a4,0(a5)
ffffffffc0200702:	00006417          	auipc	s0,0x6
ffffffffc0200706:	d5640413          	addi	s0,s0,-682 # ffffffffc0206458 <num>
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
ffffffffc020072a:	00002517          	auipc	a0,0x2
ffffffffc020072e:	c8e50513          	addi	a0,a0,-882 # ffffffffc02023b8 <etext+0x6c6>
ffffffffc0200732:	989ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00002517          	auipc	a0,0x2
ffffffffc020073a:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0202330 <etext+0x63e>
ffffffffc020073e:	97dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	b711                	j	ffffffffc0200646 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200744:	06400593          	li	a1,100
ffffffffc0200748:	00002517          	auipc	a0,0x2
ffffffffc020074c:	c6050513          	addi	a0,a0,-928 # ffffffffc02023a8 <etext+0x6b6>
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
            sbi_shutdown();//在实验指导书里面写的是shut_down,但是在sbi.c中这个函数被命名为sbi_shutdown
ffffffffc0200762:	4fa0106f          	j	ffffffffc0201c5c <sbi_shutdown>

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

ffffffffc0200832 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200832:	00005797          	auipc	a5,0x5
ffffffffc0200836:	7fe78793          	addi	a5,a5,2046 # ffffffffc0206030 <free_area2>
ffffffffc020083a:	e79c                	sd	a5,8(a5)
ffffffffc020083c:	e39c                	sd	a5,0(a5)
#define nr_free (free_area2.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc020083e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200842:	8082                	ret

ffffffffc0200844 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200844:	00005517          	auipc	a0,0x5
ffffffffc0200848:	7fc56503          	lwu	a0,2044(a0) # ffffffffc0206040 <free_area2+0x10>
ffffffffc020084c:	8082                	ret

ffffffffc020084e <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc020084e:	c14d                	beqz	a0,ffffffffc02008f0 <best_fit_alloc_pages+0xa2>
    if (n > nr_free) {
ffffffffc0200850:	00005617          	auipc	a2,0x5
ffffffffc0200854:	7e060613          	addi	a2,a2,2016 # ffffffffc0206030 <free_area2>
ffffffffc0200858:	01062803          	lw	a6,16(a2)
ffffffffc020085c:	86aa                	mv	a3,a0
ffffffffc020085e:	02081793          	slli	a5,a6,0x20
ffffffffc0200862:	9381                	srli	a5,a5,0x20
ffffffffc0200864:	08a7e463          	bltu	a5,a0,ffffffffc02008ec <best_fit_alloc_pages+0x9e>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200868:	661c                	ld	a5,8(a2)
    size_t min_size = nr_free + 1;
ffffffffc020086a:	0018059b          	addiw	a1,a6,1
ffffffffc020086e:	1582                	slli	a1,a1,0x20
ffffffffc0200870:	9181                	srli	a1,a1,0x20
    struct Page *page = NULL;
ffffffffc0200872:	4501                	li	a0,0
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200874:	06c78b63          	beq	a5,a2,ffffffffc02008ea <best_fit_alloc_pages+0x9c>
        if (p->property >= n) {
ffffffffc0200878:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020087c:	00d76763          	bltu	a4,a3,ffffffffc020088a <best_fit_alloc_pages+0x3c>
            if(current_size < min_size){
ffffffffc0200880:	00b77563          	bgeu	a4,a1,ffffffffc020088a <best_fit_alloc_pages+0x3c>
        struct Page *p = le2page(le, page_link);
ffffffffc0200884:	fe878513          	addi	a0,a5,-24
                min_size = current_size;
ffffffffc0200888:	85ba                	mv	a1,a4
ffffffffc020088a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020088c:	fec796e3          	bne	a5,a2,ffffffffc0200878 <best_fit_alloc_pages+0x2a>
    if (page != NULL) {
ffffffffc0200890:	cd29                	beqz	a0,ffffffffc02008ea <best_fit_alloc_pages+0x9c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200892:	711c                	ld	a5,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200894:	6d18                	ld	a4,24(a0)
        if (page->property > n) {
ffffffffc0200896:	490c                	lw	a1,16(a0)
            p->property = page->property - n;
ffffffffc0200898:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020089c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020089e:	e398                	sd	a4,0(a5)
        if (page->property > n) {
ffffffffc02008a0:	02059793          	slli	a5,a1,0x20
ffffffffc02008a4:	9381                	srli	a5,a5,0x20
ffffffffc02008a6:	02f6f863          	bgeu	a3,a5,ffffffffc02008d6 <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc02008aa:	00269793          	slli	a5,a3,0x2
ffffffffc02008ae:	97b6                	add	a5,a5,a3
ffffffffc02008b0:	078e                	slli	a5,a5,0x3
ffffffffc02008b2:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc02008b4:	411585bb          	subw	a1,a1,a7
ffffffffc02008b8:	cb8c                	sw	a1,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02008ba:	4689                	li	a3,2
ffffffffc02008bc:	00878593          	addi	a1,a5,8
ffffffffc02008c0:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02008c4:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc02008c6:	01878593          	addi	a1,a5,24
        nr_free -= n;
ffffffffc02008ca:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc02008ce:	e28c                	sd	a1,0(a3)
ffffffffc02008d0:	e70c                	sd	a1,8(a4)
    elm->next = next;
ffffffffc02008d2:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc02008d4:	ef98                	sd	a4,24(a5)
ffffffffc02008d6:	4118083b          	subw	a6,a6,a7
ffffffffc02008da:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008de:	57f5                	li	a5,-3
ffffffffc02008e0:	00850713          	addi	a4,a0,8
ffffffffc02008e4:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc02008e8:	8082                	ret
}
ffffffffc02008ea:	8082                	ret
        return NULL;
ffffffffc02008ec:	4501                	li	a0,0
ffffffffc02008ee:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02008f0:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008f2:	00002697          	auipc	a3,0x2
ffffffffc02008f6:	ae668693          	addi	a3,a3,-1306 # ffffffffc02023d8 <etext+0x6e6>
ffffffffc02008fa:	00002617          	auipc	a2,0x2
ffffffffc02008fe:	ae660613          	addi	a2,a2,-1306 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200902:	07200593          	li	a1,114
ffffffffc0200906:	00002517          	auipc	a0,0x2
ffffffffc020090a:	af250513          	addi	a0,a0,-1294 # ffffffffc02023f8 <etext+0x706>
best_fit_alloc_pages(size_t n) {
ffffffffc020090e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200910:	a9fff0ef          	jal	ffffffffc02003ae <__panic>

ffffffffc0200914 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200914:	715d                	addi	sp,sp,-80
ffffffffc0200916:	e0a2                	sd	s0,64(sp)
    return listelm->next;
ffffffffc0200918:	00005417          	auipc	s0,0x5
ffffffffc020091c:	71840413          	addi	s0,s0,1816 # ffffffffc0206030 <free_area2>
ffffffffc0200920:	641c                	ld	a5,8(s0)
ffffffffc0200922:	e486                	sd	ra,72(sp)
ffffffffc0200924:	fc26                	sd	s1,56(sp)
ffffffffc0200926:	f84a                	sd	s2,48(sp)
ffffffffc0200928:	f44e                	sd	s3,40(sp)
ffffffffc020092a:	f052                	sd	s4,32(sp)
ffffffffc020092c:	ec56                	sd	s5,24(sp)
ffffffffc020092e:	e85a                	sd	s6,16(sp)
ffffffffc0200930:	e45e                	sd	s7,8(sp)
ffffffffc0200932:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200934:	28878463          	beq	a5,s0,ffffffffc0200bbc <best_fit_check+0x2a8>
    int count = 0, total = 0;
ffffffffc0200938:	4481                	li	s1,0
ffffffffc020093a:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020093c:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200940:	8b09                	andi	a4,a4,2
ffffffffc0200942:	28070163          	beqz	a4,ffffffffc0200bc4 <best_fit_check+0x2b0>
        count ++, total += p->property;
ffffffffc0200946:	ff87a703          	lw	a4,-8(a5)
ffffffffc020094a:	679c                	ld	a5,8(a5)
ffffffffc020094c:	2905                	addiw	s2,s2,1
ffffffffc020094e:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200950:	fe8796e3          	bne	a5,s0,ffffffffc020093c <best_fit_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200954:	89a6                	mv	s3,s1
ffffffffc0200956:	179000ef          	jal	ffffffffc02012ce <nr_free_pages>
ffffffffc020095a:	35351563          	bne	a0,s3,ffffffffc0200ca4 <best_fit_check+0x390>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020095e:	4505                	li	a0,1
ffffffffc0200960:	0f1000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200964:	8a2a                	mv	s4,a0
ffffffffc0200966:	36050f63          	beqz	a0,ffffffffc0200ce4 <best_fit_check+0x3d0>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020096a:	4505                	li	a0,1
ffffffffc020096c:	0e5000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200970:	89aa                	mv	s3,a0
ffffffffc0200972:	34050963          	beqz	a0,ffffffffc0200cc4 <best_fit_check+0x3b0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200976:	4505                	li	a0,1
ffffffffc0200978:	0d9000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc020097c:	8aaa                	mv	s5,a0
ffffffffc020097e:	2e050363          	beqz	a0,ffffffffc0200c64 <best_fit_check+0x350>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200982:	273a0163          	beq	s4,s3,ffffffffc0200be4 <best_fit_check+0x2d0>
ffffffffc0200986:	24aa0f63          	beq	s4,a0,ffffffffc0200be4 <best_fit_check+0x2d0>
ffffffffc020098a:	24a98d63          	beq	s3,a0,ffffffffc0200be4 <best_fit_check+0x2d0>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020098e:	000a2783          	lw	a5,0(s4)
ffffffffc0200992:	26079963          	bnez	a5,ffffffffc0200c04 <best_fit_check+0x2f0>
ffffffffc0200996:	0009a783          	lw	a5,0(s3)
ffffffffc020099a:	26079563          	bnez	a5,ffffffffc0200c04 <best_fit_check+0x2f0>
ffffffffc020099e:	411c                	lw	a5,0(a0)
ffffffffc02009a0:	26079263          	bnez	a5,ffffffffc0200c04 <best_fit_check+0x2f0>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }//将 Page 结构体的指针转换为物理页号
ffffffffc02009a4:	fcccd7b7          	lui	a5,0xfcccd
ffffffffc02009a8:	ccd78793          	addi	a5,a5,-819 # fffffffffccccccd <end+0x3cac682d>
ffffffffc02009ac:	07b2                	slli	a5,a5,0xc
ffffffffc02009ae:	ccd78793          	addi	a5,a5,-819
ffffffffc02009b2:	07b2                	slli	a5,a5,0xc
ffffffffc02009b4:	00006717          	auipc	a4,0x6
ffffffffc02009b8:	ad473703          	ld	a4,-1324(a4) # ffffffffc0206488 <pages>
ffffffffc02009bc:	ccd78793          	addi	a5,a5,-819
ffffffffc02009c0:	40ea06b3          	sub	a3,s4,a4
ffffffffc02009c4:	07b2                	slli	a5,a5,0xc
ffffffffc02009c6:	868d                	srai	a3,a3,0x3
ffffffffc02009c8:	ccd78793          	addi	a5,a5,-819
ffffffffc02009cc:	02f686b3          	mul	a3,a3,a5
ffffffffc02009d0:	00002597          	auipc	a1,0x2
ffffffffc02009d4:	1f05b583          	ld	a1,496(a1) # ffffffffc0202bc0 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02009d8:	00006617          	auipc	a2,0x6
ffffffffc02009dc:	aa863603          	ld	a2,-1368(a2) # ffffffffc0206480 <npage>
ffffffffc02009e0:	0632                	slli	a2,a2,0xc
ffffffffc02009e2:	96ae                	add	a3,a3,a1

static inline uintptr_t page2pa(struct Page *page) {//将 Page 结构体转换为物理地址。通过 page2ppn 得到物理页号后，将其左移 PGSHIFT 位（通常为12，表示页大小为4KB），得到对应的物理地址。
    return page2ppn(page) << PGSHIFT;
ffffffffc02009e4:	06b2                	slli	a3,a3,0xc
ffffffffc02009e6:	22c6ff63          	bgeu	a3,a2,ffffffffc0200c24 <best_fit_check+0x310>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }//将 Page 结构体的指针转换为物理页号
ffffffffc02009ea:	40e986b3          	sub	a3,s3,a4
ffffffffc02009ee:	868d                	srai	a3,a3,0x3
ffffffffc02009f0:	02f686b3          	mul	a3,a3,a5
ffffffffc02009f4:	96ae                	add	a3,a3,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc02009f6:	06b2                	slli	a3,a3,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02009f8:	3ec6f663          	bgeu	a3,a2,ffffffffc0200de4 <best_fit_check+0x4d0>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }//将 Page 结构体的指针转换为物理页号
ffffffffc02009fc:	40e50733          	sub	a4,a0,a4
ffffffffc0200a00:	870d                	srai	a4,a4,0x3
ffffffffc0200a02:	02f707b3          	mul	a5,a4,a5
ffffffffc0200a06:	97ae                	add	a5,a5,a1
    return page2ppn(page) << PGSHIFT;
ffffffffc0200a08:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200a0a:	3ac7fd63          	bgeu	a5,a2,ffffffffc0200dc4 <best_fit_check+0x4b0>
    assert(alloc_page() == NULL);
ffffffffc0200a0e:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200a10:	00043c03          	ld	s8,0(s0)
ffffffffc0200a14:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200a18:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200a1c:	e400                	sd	s0,8(s0)
ffffffffc0200a1e:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200a20:	00005797          	auipc	a5,0x5
ffffffffc0200a24:	6207a023          	sw	zero,1568(a5) # ffffffffc0206040 <free_area2+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200a28:	029000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200a2c:	36051c63          	bnez	a0,ffffffffc0200da4 <best_fit_check+0x490>
    free_page(p0);
ffffffffc0200a30:	4585                	li	a1,1
ffffffffc0200a32:	8552                	mv	a0,s4
ffffffffc0200a34:	05b000ef          	jal	ffffffffc020128e <free_pages>
    free_page(p1);
ffffffffc0200a38:	4585                	li	a1,1
ffffffffc0200a3a:	854e                	mv	a0,s3
ffffffffc0200a3c:	053000ef          	jal	ffffffffc020128e <free_pages>
    free_page(p2);
ffffffffc0200a40:	4585                	li	a1,1
ffffffffc0200a42:	8556                	mv	a0,s5
ffffffffc0200a44:	04b000ef          	jal	ffffffffc020128e <free_pages>
    assert(nr_free == 3);
ffffffffc0200a48:	4818                	lw	a4,16(s0)
ffffffffc0200a4a:	478d                	li	a5,3
ffffffffc0200a4c:	32f71c63          	bne	a4,a5,ffffffffc0200d84 <best_fit_check+0x470>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a50:	4505                	li	a0,1
ffffffffc0200a52:	7fe000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200a56:	89aa                	mv	s3,a0
ffffffffc0200a58:	30050663          	beqz	a0,ffffffffc0200d64 <best_fit_check+0x450>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a5c:	4505                	li	a0,1
ffffffffc0200a5e:	7f2000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200a62:	8aaa                	mv	s5,a0
ffffffffc0200a64:	2e050063          	beqz	a0,ffffffffc0200d44 <best_fit_check+0x430>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a68:	4505                	li	a0,1
ffffffffc0200a6a:	7e6000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200a6e:	8a2a                	mv	s4,a0
ffffffffc0200a70:	2a050a63          	beqz	a0,ffffffffc0200d24 <best_fit_check+0x410>
    assert(alloc_page() == NULL);
ffffffffc0200a74:	4505                	li	a0,1
ffffffffc0200a76:	7da000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200a7a:	28051563          	bnez	a0,ffffffffc0200d04 <best_fit_check+0x3f0>
    free_page(p0);
ffffffffc0200a7e:	4585                	li	a1,1
ffffffffc0200a80:	854e                	mv	a0,s3
ffffffffc0200a82:	00d000ef          	jal	ffffffffc020128e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a86:	641c                	ld	a5,8(s0)
ffffffffc0200a88:	1a878e63          	beq	a5,s0,ffffffffc0200c44 <best_fit_check+0x330>
    assert((p = alloc_page()) == p0);
ffffffffc0200a8c:	4505                	li	a0,1
ffffffffc0200a8e:	7c2000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200a92:	52a99963          	bne	s3,a0,ffffffffc0200fc4 <best_fit_check+0x6b0>
    assert(alloc_page() == NULL);
ffffffffc0200a96:	4505                	li	a0,1
ffffffffc0200a98:	7b8000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200a9c:	50051463          	bnez	a0,ffffffffc0200fa4 <best_fit_check+0x690>
    assert(nr_free == 0);
ffffffffc0200aa0:	481c                	lw	a5,16(s0)
ffffffffc0200aa2:	4e079163          	bnez	a5,ffffffffc0200f84 <best_fit_check+0x670>
    free_page(p);
ffffffffc0200aa6:	854e                	mv	a0,s3
ffffffffc0200aa8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200aaa:	01843023          	sd	s8,0(s0)
ffffffffc0200aae:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200ab2:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200ab6:	7d8000ef          	jal	ffffffffc020128e <free_pages>
    free_page(p1);
ffffffffc0200aba:	4585                	li	a1,1
ffffffffc0200abc:	8556                	mv	a0,s5
ffffffffc0200abe:	7d0000ef          	jal	ffffffffc020128e <free_pages>
    free_page(p2);
ffffffffc0200ac2:	4585                	li	a1,1
ffffffffc0200ac4:	8552                	mv	a0,s4
ffffffffc0200ac6:	7c8000ef          	jal	ffffffffc020128e <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200aca:	4515                	li	a0,5
ffffffffc0200acc:	784000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200ad0:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200ad2:	48050963          	beqz	a0,ffffffffc0200f64 <best_fit_check+0x650>
ffffffffc0200ad6:	651c                	ld	a5,8(a0)
ffffffffc0200ad8:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200ada:	8b85                	andi	a5,a5,1
ffffffffc0200adc:	46079463          	bnez	a5,ffffffffc0200f44 <best_fit_check+0x630>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200ae0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ae2:	00043a83          	ld	s5,0(s0)
ffffffffc0200ae6:	00843a03          	ld	s4,8(s0)
ffffffffc0200aea:	e000                	sd	s0,0(s0)
ffffffffc0200aec:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200aee:	762000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200af2:	42051963          	bnez	a0,ffffffffc0200f24 <best_fit_check+0x610>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200af6:	4589                	li	a1,2
ffffffffc0200af8:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200afc:	01042b03          	lw	s6,16(s0)
    free_pages(p0 + 4, 1);
ffffffffc0200b00:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200b04:	00005797          	auipc	a5,0x5
ffffffffc0200b08:	5207ae23          	sw	zero,1340(a5) # ffffffffc0206040 <free_area2+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200b0c:	782000ef          	jal	ffffffffc020128e <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200b10:	8562                	mv	a0,s8
ffffffffc0200b12:	4585                	li	a1,1
ffffffffc0200b14:	77a000ef          	jal	ffffffffc020128e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200b18:	4511                	li	a0,4
ffffffffc0200b1a:	736000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200b1e:	3e051363          	bnez	a0,ffffffffc0200f04 <best_fit_check+0x5f0>
ffffffffc0200b22:	0309b783          	ld	a5,48(s3)
ffffffffc0200b26:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200b28:	8b85                	andi	a5,a5,1
ffffffffc0200b2a:	3a078d63          	beqz	a5,ffffffffc0200ee4 <best_fit_check+0x5d0>
ffffffffc0200b2e:	0389a703          	lw	a4,56(s3)
ffffffffc0200b32:	4789                	li	a5,2
ffffffffc0200b34:	3af71863          	bne	a4,a5,ffffffffc0200ee4 <best_fit_check+0x5d0>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200b38:	4505                	li	a0,1
ffffffffc0200b3a:	716000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200b3e:	8baa                	mv	s7,a0
ffffffffc0200b40:	38050263          	beqz	a0,ffffffffc0200ec4 <best_fit_check+0x5b0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b44:	4509                	li	a0,2
ffffffffc0200b46:	70a000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200b4a:	34050d63          	beqz	a0,ffffffffc0200ea4 <best_fit_check+0x590>
    assert(p0 + 4 == p1);
ffffffffc0200b4e:	337c1b63          	bne	s8,s7,ffffffffc0200e84 <best_fit_check+0x570>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b52:	854e                	mv	a0,s3
ffffffffc0200b54:	4595                	li	a1,5
ffffffffc0200b56:	738000ef          	jal	ffffffffc020128e <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b5a:	4515                	li	a0,5
ffffffffc0200b5c:	6f4000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200b60:	89aa                	mv	s3,a0
ffffffffc0200b62:	30050163          	beqz	a0,ffffffffc0200e64 <best_fit_check+0x550>
    assert(alloc_page() == NULL);
ffffffffc0200b66:	4505                	li	a0,1
ffffffffc0200b68:	6e8000ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc0200b6c:	2c051c63          	bnez	a0,ffffffffc0200e44 <best_fit_check+0x530>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200b70:	481c                	lw	a5,16(s0)
ffffffffc0200b72:	2a079963          	bnez	a5,ffffffffc0200e24 <best_fit_check+0x510>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200b76:	4595                	li	a1,5
ffffffffc0200b78:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200b7a:	01642823          	sw	s6,16(s0)
    free_list = free_list_store;
ffffffffc0200b7e:	01543023          	sd	s5,0(s0)
ffffffffc0200b82:	01443423          	sd	s4,8(s0)
    free_pages(p0, 5);
ffffffffc0200b86:	708000ef          	jal	ffffffffc020128e <free_pages>
    return listelm->next;
ffffffffc0200b8a:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b8c:	00878963          	beq	a5,s0,ffffffffc0200b9e <best_fit_check+0x28a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200b90:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b94:	679c                	ld	a5,8(a5)
ffffffffc0200b96:	397d                	addiw	s2,s2,-1
ffffffffc0200b98:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b9a:	fe879be3          	bne	a5,s0,ffffffffc0200b90 <best_fit_check+0x27c>
    }
    assert(count == 0);
ffffffffc0200b9e:	26091363          	bnez	s2,ffffffffc0200e04 <best_fit_check+0x4f0>
    assert(total == 0);
ffffffffc0200ba2:	e0ed                	bnez	s1,ffffffffc0200c84 <best_fit_check+0x370>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200ba4:	60a6                	ld	ra,72(sp)
ffffffffc0200ba6:	6406                	ld	s0,64(sp)
ffffffffc0200ba8:	74e2                	ld	s1,56(sp)
ffffffffc0200baa:	7942                	ld	s2,48(sp)
ffffffffc0200bac:	79a2                	ld	s3,40(sp)
ffffffffc0200bae:	7a02                	ld	s4,32(sp)
ffffffffc0200bb0:	6ae2                	ld	s5,24(sp)
ffffffffc0200bb2:	6b42                	ld	s6,16(sp)
ffffffffc0200bb4:	6ba2                	ld	s7,8(sp)
ffffffffc0200bb6:	6c02                	ld	s8,0(sp)
ffffffffc0200bb8:	6161                	addi	sp,sp,80
ffffffffc0200bba:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bbc:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200bbe:	4481                	li	s1,0
ffffffffc0200bc0:	4901                	li	s2,0
ffffffffc0200bc2:	bb51                	j	ffffffffc0200956 <best_fit_check+0x42>
        assert(PageProperty(p));
ffffffffc0200bc4:	00002697          	auipc	a3,0x2
ffffffffc0200bc8:	84c68693          	addi	a3,a3,-1972 # ffffffffc0202410 <etext+0x71e>
ffffffffc0200bcc:	00002617          	auipc	a2,0x2
ffffffffc0200bd0:	81460613          	addi	a2,a2,-2028 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200bd4:	11a00593          	li	a1,282
ffffffffc0200bd8:	00002517          	auipc	a0,0x2
ffffffffc0200bdc:	82050513          	addi	a0,a0,-2016 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200be0:	fceff0ef          	jal	ffffffffc02003ae <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200be4:	00002697          	auipc	a3,0x2
ffffffffc0200be8:	8bc68693          	addi	a3,a3,-1860 # ffffffffc02024a0 <etext+0x7ae>
ffffffffc0200bec:	00001617          	auipc	a2,0x1
ffffffffc0200bf0:	7f460613          	addi	a2,a2,2036 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200bf4:	0e600593          	li	a1,230
ffffffffc0200bf8:	00002517          	auipc	a0,0x2
ffffffffc0200bfc:	80050513          	addi	a0,a0,-2048 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200c00:	faeff0ef          	jal	ffffffffc02003ae <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c04:	00002697          	auipc	a3,0x2
ffffffffc0200c08:	8c468693          	addi	a3,a3,-1852 # ffffffffc02024c8 <etext+0x7d6>
ffffffffc0200c0c:	00001617          	auipc	a2,0x1
ffffffffc0200c10:	7d460613          	addi	a2,a2,2004 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200c14:	0e700593          	li	a1,231
ffffffffc0200c18:	00001517          	auipc	a0,0x1
ffffffffc0200c1c:	7e050513          	addi	a0,a0,2016 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200c20:	f8eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c24:	00002697          	auipc	a3,0x2
ffffffffc0200c28:	8e468693          	addi	a3,a3,-1820 # ffffffffc0202508 <etext+0x816>
ffffffffc0200c2c:	00001617          	auipc	a2,0x1
ffffffffc0200c30:	7b460613          	addi	a2,a2,1972 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200c34:	0e900593          	li	a1,233
ffffffffc0200c38:	00001517          	auipc	a0,0x1
ffffffffc0200c3c:	7c050513          	addi	a0,a0,1984 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200c40:	f6eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c44:	00002697          	auipc	a3,0x2
ffffffffc0200c48:	94c68693          	addi	a3,a3,-1716 # ffffffffc0202590 <etext+0x89e>
ffffffffc0200c4c:	00001617          	auipc	a2,0x1
ffffffffc0200c50:	79460613          	addi	a2,a2,1940 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200c54:	10200593          	li	a1,258
ffffffffc0200c58:	00001517          	auipc	a0,0x1
ffffffffc0200c5c:	7a050513          	addi	a0,a0,1952 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200c60:	f4eff0ef          	jal	ffffffffc02003ae <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c64:	00002697          	auipc	a3,0x2
ffffffffc0200c68:	81c68693          	addi	a3,a3,-2020 # ffffffffc0202480 <etext+0x78e>
ffffffffc0200c6c:	00001617          	auipc	a2,0x1
ffffffffc0200c70:	77460613          	addi	a2,a2,1908 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200c74:	0e400593          	li	a1,228
ffffffffc0200c78:	00001517          	auipc	a0,0x1
ffffffffc0200c7c:	78050513          	addi	a0,a0,1920 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200c80:	f2eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(total == 0);
ffffffffc0200c84:	00002697          	auipc	a3,0x2
ffffffffc0200c88:	a3c68693          	addi	a3,a3,-1476 # ffffffffc02026c0 <etext+0x9ce>
ffffffffc0200c8c:	00001617          	auipc	a2,0x1
ffffffffc0200c90:	75460613          	addi	a2,a2,1876 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200c94:	15c00593          	li	a1,348
ffffffffc0200c98:	00001517          	auipc	a0,0x1
ffffffffc0200c9c:	76050513          	addi	a0,a0,1888 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200ca0:	f0eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(total == nr_free_pages());
ffffffffc0200ca4:	00001697          	auipc	a3,0x1
ffffffffc0200ca8:	77c68693          	addi	a3,a3,1916 # ffffffffc0202420 <etext+0x72e>
ffffffffc0200cac:	00001617          	auipc	a2,0x1
ffffffffc0200cb0:	73460613          	addi	a2,a2,1844 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200cb4:	11d00593          	li	a1,285
ffffffffc0200cb8:	00001517          	auipc	a0,0x1
ffffffffc0200cbc:	74050513          	addi	a0,a0,1856 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200cc0:	eeeff0ef          	jal	ffffffffc02003ae <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200cc4:	00001697          	auipc	a3,0x1
ffffffffc0200cc8:	79c68693          	addi	a3,a3,1948 # ffffffffc0202460 <etext+0x76e>
ffffffffc0200ccc:	00001617          	auipc	a2,0x1
ffffffffc0200cd0:	71460613          	addi	a2,a2,1812 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200cd4:	0e300593          	li	a1,227
ffffffffc0200cd8:	00001517          	auipc	a0,0x1
ffffffffc0200cdc:	72050513          	addi	a0,a0,1824 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200ce0:	eceff0ef          	jal	ffffffffc02003ae <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200ce4:	00001697          	auipc	a3,0x1
ffffffffc0200ce8:	75c68693          	addi	a3,a3,1884 # ffffffffc0202440 <etext+0x74e>
ffffffffc0200cec:	00001617          	auipc	a2,0x1
ffffffffc0200cf0:	6f460613          	addi	a2,a2,1780 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200cf4:	0e200593          	li	a1,226
ffffffffc0200cf8:	00001517          	auipc	a0,0x1
ffffffffc0200cfc:	70050513          	addi	a0,a0,1792 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200d00:	eaeff0ef          	jal	ffffffffc02003ae <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d04:	00002697          	auipc	a3,0x2
ffffffffc0200d08:	86468693          	addi	a3,a3,-1948 # ffffffffc0202568 <etext+0x876>
ffffffffc0200d0c:	00001617          	auipc	a2,0x1
ffffffffc0200d10:	6d460613          	addi	a2,a2,1748 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200d14:	0ff00593          	li	a1,255
ffffffffc0200d18:	00001517          	auipc	a0,0x1
ffffffffc0200d1c:	6e050513          	addi	a0,a0,1760 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200d20:	e8eff0ef          	jal	ffffffffc02003ae <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d24:	00001697          	auipc	a3,0x1
ffffffffc0200d28:	75c68693          	addi	a3,a3,1884 # ffffffffc0202480 <etext+0x78e>
ffffffffc0200d2c:	00001617          	auipc	a2,0x1
ffffffffc0200d30:	6b460613          	addi	a2,a2,1716 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200d34:	0fd00593          	li	a1,253
ffffffffc0200d38:	00001517          	auipc	a0,0x1
ffffffffc0200d3c:	6c050513          	addi	a0,a0,1728 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200d40:	e6eff0ef          	jal	ffffffffc02003ae <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d44:	00001697          	auipc	a3,0x1
ffffffffc0200d48:	71c68693          	addi	a3,a3,1820 # ffffffffc0202460 <etext+0x76e>
ffffffffc0200d4c:	00001617          	auipc	a2,0x1
ffffffffc0200d50:	69460613          	addi	a2,a2,1684 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200d54:	0fc00593          	li	a1,252
ffffffffc0200d58:	00001517          	auipc	a0,0x1
ffffffffc0200d5c:	6a050513          	addi	a0,a0,1696 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200d60:	e4eff0ef          	jal	ffffffffc02003ae <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d64:	00001697          	auipc	a3,0x1
ffffffffc0200d68:	6dc68693          	addi	a3,a3,1756 # ffffffffc0202440 <etext+0x74e>
ffffffffc0200d6c:	00001617          	auipc	a2,0x1
ffffffffc0200d70:	67460613          	addi	a2,a2,1652 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200d74:	0fb00593          	li	a1,251
ffffffffc0200d78:	00001517          	auipc	a0,0x1
ffffffffc0200d7c:	68050513          	addi	a0,a0,1664 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200d80:	e2eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(nr_free == 3);
ffffffffc0200d84:	00001697          	auipc	a3,0x1
ffffffffc0200d88:	7fc68693          	addi	a3,a3,2044 # ffffffffc0202580 <etext+0x88e>
ffffffffc0200d8c:	00001617          	auipc	a2,0x1
ffffffffc0200d90:	65460613          	addi	a2,a2,1620 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200d94:	0f900593          	li	a1,249
ffffffffc0200d98:	00001517          	auipc	a0,0x1
ffffffffc0200d9c:	66050513          	addi	a0,a0,1632 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200da0:	e0eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200da4:	00001697          	auipc	a3,0x1
ffffffffc0200da8:	7c468693          	addi	a3,a3,1988 # ffffffffc0202568 <etext+0x876>
ffffffffc0200dac:	00001617          	auipc	a2,0x1
ffffffffc0200db0:	63460613          	addi	a2,a2,1588 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200db4:	0f400593          	li	a1,244
ffffffffc0200db8:	00001517          	auipc	a0,0x1
ffffffffc0200dbc:	64050513          	addi	a0,a0,1600 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200dc0:	deeff0ef          	jal	ffffffffc02003ae <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200dc4:	00001697          	auipc	a3,0x1
ffffffffc0200dc8:	78468693          	addi	a3,a3,1924 # ffffffffc0202548 <etext+0x856>
ffffffffc0200dcc:	00001617          	auipc	a2,0x1
ffffffffc0200dd0:	61460613          	addi	a2,a2,1556 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200dd4:	0eb00593          	li	a1,235
ffffffffc0200dd8:	00001517          	auipc	a0,0x1
ffffffffc0200ddc:	62050513          	addi	a0,a0,1568 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200de0:	dceff0ef          	jal	ffffffffc02003ae <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200de4:	00001697          	auipc	a3,0x1
ffffffffc0200de8:	74468693          	addi	a3,a3,1860 # ffffffffc0202528 <etext+0x836>
ffffffffc0200dec:	00001617          	auipc	a2,0x1
ffffffffc0200df0:	5f460613          	addi	a2,a2,1524 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200df4:	0ea00593          	li	a1,234
ffffffffc0200df8:	00001517          	auipc	a0,0x1
ffffffffc0200dfc:	60050513          	addi	a0,a0,1536 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200e00:	daeff0ef          	jal	ffffffffc02003ae <__panic>
    assert(count == 0);
ffffffffc0200e04:	00002697          	auipc	a3,0x2
ffffffffc0200e08:	8ac68693          	addi	a3,a3,-1876 # ffffffffc02026b0 <etext+0x9be>
ffffffffc0200e0c:	00001617          	auipc	a2,0x1
ffffffffc0200e10:	5d460613          	addi	a2,a2,1492 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200e14:	15b00593          	li	a1,347
ffffffffc0200e18:	00001517          	auipc	a0,0x1
ffffffffc0200e1c:	5e050513          	addi	a0,a0,1504 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200e20:	d8eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(nr_free == 0);
ffffffffc0200e24:	00001697          	auipc	a3,0x1
ffffffffc0200e28:	7a468693          	addi	a3,a3,1956 # ffffffffc02025c8 <etext+0x8d6>
ffffffffc0200e2c:	00001617          	auipc	a2,0x1
ffffffffc0200e30:	5b460613          	addi	a2,a2,1460 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200e34:	15000593          	li	a1,336
ffffffffc0200e38:	00001517          	auipc	a0,0x1
ffffffffc0200e3c:	5c050513          	addi	a0,a0,1472 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200e40:	d6eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e44:	00001697          	auipc	a3,0x1
ffffffffc0200e48:	72468693          	addi	a3,a3,1828 # ffffffffc0202568 <etext+0x876>
ffffffffc0200e4c:	00001617          	auipc	a2,0x1
ffffffffc0200e50:	59460613          	addi	a2,a2,1428 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200e54:	14a00593          	li	a1,330
ffffffffc0200e58:	00001517          	auipc	a0,0x1
ffffffffc0200e5c:	5a050513          	addi	a0,a0,1440 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200e60:	d4eff0ef          	jal	ffffffffc02003ae <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e64:	00002697          	auipc	a3,0x2
ffffffffc0200e68:	82c68693          	addi	a3,a3,-2004 # ffffffffc0202690 <etext+0x99e>
ffffffffc0200e6c:	00001617          	auipc	a2,0x1
ffffffffc0200e70:	57460613          	addi	a2,a2,1396 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200e74:	14900593          	li	a1,329
ffffffffc0200e78:	00001517          	auipc	a0,0x1
ffffffffc0200e7c:	58050513          	addi	a0,a0,1408 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200e80:	d2eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200e84:	00001697          	auipc	a3,0x1
ffffffffc0200e88:	7fc68693          	addi	a3,a3,2044 # ffffffffc0202680 <etext+0x98e>
ffffffffc0200e8c:	00001617          	auipc	a2,0x1
ffffffffc0200e90:	55460613          	addi	a2,a2,1364 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200e94:	14100593          	li	a1,321
ffffffffc0200e98:	00001517          	auipc	a0,0x1
ffffffffc0200e9c:	56050513          	addi	a0,a0,1376 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200ea0:	d0eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200ea4:	00001697          	auipc	a3,0x1
ffffffffc0200ea8:	7c468693          	addi	a3,a3,1988 # ffffffffc0202668 <etext+0x976>
ffffffffc0200eac:	00001617          	auipc	a2,0x1
ffffffffc0200eb0:	53460613          	addi	a2,a2,1332 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200eb4:	14000593          	li	a1,320
ffffffffc0200eb8:	00001517          	auipc	a0,0x1
ffffffffc0200ebc:	54050513          	addi	a0,a0,1344 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200ec0:	ceeff0ef          	jal	ffffffffc02003ae <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200ec4:	00001697          	auipc	a3,0x1
ffffffffc0200ec8:	78468693          	addi	a3,a3,1924 # ffffffffc0202648 <etext+0x956>
ffffffffc0200ecc:	00001617          	auipc	a2,0x1
ffffffffc0200ed0:	51460613          	addi	a2,a2,1300 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200ed4:	13f00593          	li	a1,319
ffffffffc0200ed8:	00001517          	auipc	a0,0x1
ffffffffc0200edc:	52050513          	addi	a0,a0,1312 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200ee0:	cceff0ef          	jal	ffffffffc02003ae <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200ee4:	00001697          	auipc	a3,0x1
ffffffffc0200ee8:	73468693          	addi	a3,a3,1844 # ffffffffc0202618 <etext+0x926>
ffffffffc0200eec:	00001617          	auipc	a2,0x1
ffffffffc0200ef0:	4f460613          	addi	a2,a2,1268 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200ef4:	13d00593          	li	a1,317
ffffffffc0200ef8:	00001517          	auipc	a0,0x1
ffffffffc0200efc:	50050513          	addi	a0,a0,1280 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200f00:	caeff0ef          	jal	ffffffffc02003ae <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f04:	00001697          	auipc	a3,0x1
ffffffffc0200f08:	6fc68693          	addi	a3,a3,1788 # ffffffffc0202600 <etext+0x90e>
ffffffffc0200f0c:	00001617          	auipc	a2,0x1
ffffffffc0200f10:	4d460613          	addi	a2,a2,1236 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200f14:	13c00593          	li	a1,316
ffffffffc0200f18:	00001517          	auipc	a0,0x1
ffffffffc0200f1c:	4e050513          	addi	a0,a0,1248 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200f20:	c8eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f24:	00001697          	auipc	a3,0x1
ffffffffc0200f28:	64468693          	addi	a3,a3,1604 # ffffffffc0202568 <etext+0x876>
ffffffffc0200f2c:	00001617          	auipc	a2,0x1
ffffffffc0200f30:	4b460613          	addi	a2,a2,1204 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200f34:	13000593          	li	a1,304
ffffffffc0200f38:	00001517          	auipc	a0,0x1
ffffffffc0200f3c:	4c050513          	addi	a0,a0,1216 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200f40:	c6eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f44:	00001697          	auipc	a3,0x1
ffffffffc0200f48:	6a468693          	addi	a3,a3,1700 # ffffffffc02025e8 <etext+0x8f6>
ffffffffc0200f4c:	00001617          	auipc	a2,0x1
ffffffffc0200f50:	49460613          	addi	a2,a2,1172 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200f54:	12700593          	li	a1,295
ffffffffc0200f58:	00001517          	auipc	a0,0x1
ffffffffc0200f5c:	4a050513          	addi	a0,a0,1184 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200f60:	c4eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(p0 != NULL);
ffffffffc0200f64:	00001697          	auipc	a3,0x1
ffffffffc0200f68:	67468693          	addi	a3,a3,1652 # ffffffffc02025d8 <etext+0x8e6>
ffffffffc0200f6c:	00001617          	auipc	a2,0x1
ffffffffc0200f70:	47460613          	addi	a2,a2,1140 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200f74:	12600593          	li	a1,294
ffffffffc0200f78:	00001517          	auipc	a0,0x1
ffffffffc0200f7c:	48050513          	addi	a0,a0,1152 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200f80:	c2eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(nr_free == 0);
ffffffffc0200f84:	00001697          	auipc	a3,0x1
ffffffffc0200f88:	64468693          	addi	a3,a3,1604 # ffffffffc02025c8 <etext+0x8d6>
ffffffffc0200f8c:	00001617          	auipc	a2,0x1
ffffffffc0200f90:	45460613          	addi	a2,a2,1108 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200f94:	10800593          	li	a1,264
ffffffffc0200f98:	00001517          	auipc	a0,0x1
ffffffffc0200f9c:	46050513          	addi	a0,a0,1120 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200fa0:	c0eff0ef          	jal	ffffffffc02003ae <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fa4:	00001697          	auipc	a3,0x1
ffffffffc0200fa8:	5c468693          	addi	a3,a3,1476 # ffffffffc0202568 <etext+0x876>
ffffffffc0200fac:	00001617          	auipc	a2,0x1
ffffffffc0200fb0:	43460613          	addi	a2,a2,1076 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200fb4:	10600593          	li	a1,262
ffffffffc0200fb8:	00001517          	auipc	a0,0x1
ffffffffc0200fbc:	44050513          	addi	a0,a0,1088 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200fc0:	beeff0ef          	jal	ffffffffc02003ae <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200fc4:	00001697          	auipc	a3,0x1
ffffffffc0200fc8:	5e468693          	addi	a3,a3,1508 # ffffffffc02025a8 <etext+0x8b6>
ffffffffc0200fcc:	00001617          	auipc	a2,0x1
ffffffffc0200fd0:	41460613          	addi	a2,a2,1044 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0200fd4:	10500593          	li	a1,261
ffffffffc0200fd8:	00001517          	auipc	a0,0x1
ffffffffc0200fdc:	42050513          	addi	a0,a0,1056 # ffffffffc02023f8 <etext+0x706>
ffffffffc0200fe0:	bceff0ef          	jal	ffffffffc02003ae <__panic>

ffffffffc0200fe4 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0200fe4:	1141                	addi	sp,sp,-16
ffffffffc0200fe6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200fe8:	14058a63          	beqz	a1,ffffffffc020113c <best_fit_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc0200fec:	00259713          	slli	a4,a1,0x2
ffffffffc0200ff0:	972e                	add	a4,a4,a1
ffffffffc0200ff2:	070e                	slli	a4,a4,0x3
ffffffffc0200ff4:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0200ff8:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc0200ffa:	c30d                	beqz	a4,ffffffffc020101c <best_fit_free_pages+0x38>
ffffffffc0200ffc:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200ffe:	8b05                	andi	a4,a4,1
ffffffffc0201000:	10071e63          	bnez	a4,ffffffffc020111c <best_fit_free_pages+0x138>
ffffffffc0201004:	6798                	ld	a4,8(a5)
ffffffffc0201006:	8b09                	andi	a4,a4,2
ffffffffc0201008:	10071a63          	bnez	a4,ffffffffc020111c <best_fit_free_pages+0x138>
        p->flags = 0;
ffffffffc020100c:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201010:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201014:	02878793          	addi	a5,a5,40
ffffffffc0201018:	fed792e3          	bne	a5,a3,ffffffffc0200ffc <best_fit_free_pages+0x18>
    base->property = n;
ffffffffc020101c:	2581                	sext.w	a1,a1
ffffffffc020101e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201020:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201024:	4789                	li	a5,2
ffffffffc0201026:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020102a:	00005697          	auipc	a3,0x5
ffffffffc020102e:	00668693          	addi	a3,a3,6 # ffffffffc0206030 <free_area2>
ffffffffc0201032:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201034:	669c                	ld	a5,8(a3)
ffffffffc0201036:	9f2d                	addw	a4,a4,a1
ffffffffc0201038:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020103a:	0ad78563          	beq	a5,a3,ffffffffc02010e4 <best_fit_free_pages+0x100>
            struct Page* page = le2page(le, page_link);
ffffffffc020103e:	fe878713          	addi	a4,a5,-24
ffffffffc0201042:	4581                	li	a1,0
ffffffffc0201044:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201048:	00e56a63          	bltu	a0,a4,ffffffffc020105c <best_fit_free_pages+0x78>
    return listelm->next;
ffffffffc020104c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020104e:	06d70263          	beq	a4,a3,ffffffffc02010b2 <best_fit_free_pages+0xce>
    struct Page *p = base;
ffffffffc0201052:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201054:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201058:	fee57ae3          	bgeu	a0,a4,ffffffffc020104c <best_fit_free_pages+0x68>
ffffffffc020105c:	c199                	beqz	a1,ffffffffc0201062 <best_fit_free_pages+0x7e>
ffffffffc020105e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201062:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0201064:	e390                	sd	a2,0(a5)
ffffffffc0201066:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201068:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020106a:	ed18                	sd	a4,24(a0)
    if (le != &free_list) {
ffffffffc020106c:	02d70063          	beq	a4,a3,ffffffffc020108c <best_fit_free_pages+0xa8>
        if (p + p->property == base) {
ffffffffc0201070:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201074:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc0201078:	02081613          	slli	a2,a6,0x20
ffffffffc020107c:	9201                	srli	a2,a2,0x20
ffffffffc020107e:	00261793          	slli	a5,a2,0x2
ffffffffc0201082:	97b2                	add	a5,a5,a2
ffffffffc0201084:	078e                	slli	a5,a5,0x3
ffffffffc0201086:	97ae                	add	a5,a5,a1
ffffffffc0201088:	02f50f63          	beq	a0,a5,ffffffffc02010c6 <best_fit_free_pages+0xe2>
    return listelm->next;
ffffffffc020108c:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc020108e:	00d70f63          	beq	a4,a3,ffffffffc02010ac <best_fit_free_pages+0xc8>
        if (base + base->property == p) {
ffffffffc0201092:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc0201094:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0201098:	02059613          	slli	a2,a1,0x20
ffffffffc020109c:	9201                	srli	a2,a2,0x20
ffffffffc020109e:	00261793          	slli	a5,a2,0x2
ffffffffc02010a2:	97b2                	add	a5,a5,a2
ffffffffc02010a4:	078e                	slli	a5,a5,0x3
ffffffffc02010a6:	97aa                	add	a5,a5,a0
ffffffffc02010a8:	04f68a63          	beq	a3,a5,ffffffffc02010fc <best_fit_free_pages+0x118>
}
ffffffffc02010ac:	60a2                	ld	ra,8(sp)
ffffffffc02010ae:	0141                	addi	sp,sp,16
ffffffffc02010b0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02010b2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010b4:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02010b6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02010b8:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02010ba:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010bc:	02d70d63          	beq	a4,a3,ffffffffc02010f6 <best_fit_free_pages+0x112>
ffffffffc02010c0:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc02010c2:	87ba                	mv	a5,a4
ffffffffc02010c4:	bf41                	j	ffffffffc0201054 <best_fit_free_pages+0x70>
            p->property += base->property;  // 合并块的大小
ffffffffc02010c6:	491c                	lw	a5,16(a0)
ffffffffc02010c8:	010787bb          	addw	a5,a5,a6
ffffffffc02010cc:	fef72c23          	sw	a5,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02010d0:	57f5                	li	a5,-3
ffffffffc02010d2:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02010d6:	6d10                	ld	a2,24(a0)
ffffffffc02010d8:	711c                	ld	a5,32(a0)
            base = p;  // 更新 base 指针，指向合并后的块
ffffffffc02010da:	852e                	mv	a0,a1
    prev->next = next;
ffffffffc02010dc:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02010de:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02010e0:	e390                	sd	a2,0(a5)
ffffffffc02010e2:	b775                	j	ffffffffc020108e <best_fit_free_pages+0xaa>
}
ffffffffc02010e4:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02010e6:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02010ea:	e398                	sd	a4,0(a5)
ffffffffc02010ec:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02010ee:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010f0:	ed1c                	sd	a5,24(a0)
}
ffffffffc02010f2:	0141                	addi	sp,sp,16
ffffffffc02010f4:	8082                	ret
ffffffffc02010f6:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02010f8:	873e                	mv	a4,a5
ffffffffc02010fa:	bf8d                	j	ffffffffc020106c <best_fit_free_pages+0x88>
            base->property += p->property;
ffffffffc02010fc:	ff872783          	lw	a5,-8(a4)
ffffffffc0201100:	ff070693          	addi	a3,a4,-16
ffffffffc0201104:	9fad                	addw	a5,a5,a1
ffffffffc0201106:	c91c                	sw	a5,16(a0)
ffffffffc0201108:	57f5                	li	a5,-3
ffffffffc020110a:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020110e:	6314                	ld	a3,0(a4)
ffffffffc0201110:	671c                	ld	a5,8(a4)
}
ffffffffc0201112:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201114:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201116:	e394                	sd	a3,0(a5)
ffffffffc0201118:	0141                	addi	sp,sp,16
ffffffffc020111a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020111c:	00001697          	auipc	a3,0x1
ffffffffc0201120:	5b468693          	addi	a3,a3,1460 # ffffffffc02026d0 <etext+0x9de>
ffffffffc0201124:	00001617          	auipc	a2,0x1
ffffffffc0201128:	2bc60613          	addi	a2,a2,700 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc020112c:	09c00593          	li	a1,156
ffffffffc0201130:	00001517          	auipc	a0,0x1
ffffffffc0201134:	2c850513          	addi	a0,a0,712 # ffffffffc02023f8 <etext+0x706>
ffffffffc0201138:	a76ff0ef          	jal	ffffffffc02003ae <__panic>
    assert(n > 0);
ffffffffc020113c:	00001697          	auipc	a3,0x1
ffffffffc0201140:	29c68693          	addi	a3,a3,668 # ffffffffc02023d8 <etext+0x6e6>
ffffffffc0201144:	00001617          	auipc	a2,0x1
ffffffffc0201148:	29c60613          	addi	a2,a2,668 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc020114c:	09900593          	li	a1,153
ffffffffc0201150:	00001517          	auipc	a0,0x1
ffffffffc0201154:	2a850513          	addi	a0,a0,680 # ffffffffc02023f8 <etext+0x706>
ffffffffc0201158:	a56ff0ef          	jal	ffffffffc02003ae <__panic>

ffffffffc020115c <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020115c:	1141                	addi	sp,sp,-16
ffffffffc020115e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201160:	c9e1                	beqz	a1,ffffffffc0201230 <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201162:	00259713          	slli	a4,a1,0x2
ffffffffc0201166:	972e                	add	a4,a4,a1
ffffffffc0201168:	070e                	slli	a4,a4,0x3
ffffffffc020116a:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc020116e:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc0201170:	cf11                	beqz	a4,ffffffffc020118c <best_fit_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201172:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201174:	8b05                	andi	a4,a4,1
ffffffffc0201176:	cf49                	beqz	a4,ffffffffc0201210 <best_fit_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201178:	0007a823          	sw	zero,16(a5)
ffffffffc020117c:	0007b423          	sd	zero,8(a5)
ffffffffc0201180:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201184:	02878793          	addi	a5,a5,40
ffffffffc0201188:	fed795e3          	bne	a5,a3,ffffffffc0201172 <best_fit_init_memmap+0x16>
    base->property = n;
ffffffffc020118c:	2581                	sext.w	a1,a1
ffffffffc020118e:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201190:	4789                	li	a5,2
ffffffffc0201192:	00850713          	addi	a4,a0,8
ffffffffc0201196:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020119a:	00005697          	auipc	a3,0x5
ffffffffc020119e:	e9668693          	addi	a3,a3,-362 # ffffffffc0206030 <free_area2>
ffffffffc02011a2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02011a4:	669c                	ld	a5,8(a3)
ffffffffc02011a6:	9f2d                	addw	a4,a4,a1
ffffffffc02011a8:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02011aa:	04d78663          	beq	a5,a3,ffffffffc02011f6 <best_fit_init_memmap+0x9a>
            struct Page* page = le2page(le, page_link);
ffffffffc02011ae:	fe878713          	addi	a4,a5,-24
ffffffffc02011b2:	4581                	li	a1,0
ffffffffc02011b4:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02011b8:	00e56a63          	bltu	a0,a4,ffffffffc02011cc <best_fit_init_memmap+0x70>
    return listelm->next;
ffffffffc02011bc:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list) {
ffffffffc02011be:	02d70263          	beq	a4,a3,ffffffffc02011e2 <best_fit_init_memmap+0x86>
    struct Page *p = base;
ffffffffc02011c2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02011c4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02011c8:	fee57ae3          	bgeu	a0,a4,ffffffffc02011bc <best_fit_init_memmap+0x60>
ffffffffc02011cc:	c199                	beqz	a1,ffffffffc02011d2 <best_fit_init_memmap+0x76>
ffffffffc02011ce:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02011d2:	6398                	ld	a4,0(a5)
}
ffffffffc02011d4:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02011d6:	e390                	sd	a2,0(a5)
ffffffffc02011d8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02011da:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02011dc:	ed18                	sd	a4,24(a0)
ffffffffc02011de:	0141                	addi	sp,sp,16
ffffffffc02011e0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02011e2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02011e4:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02011e6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02011e8:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02011ea:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02011ec:	00d70e63          	beq	a4,a3,ffffffffc0201208 <best_fit_init_memmap+0xac>
ffffffffc02011f0:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc02011f2:	87ba                	mv	a5,a4
ffffffffc02011f4:	bfc1                	j	ffffffffc02011c4 <best_fit_init_memmap+0x68>
}
ffffffffc02011f6:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02011f8:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc02011fc:	e398                	sd	a4,0(a5)
ffffffffc02011fe:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201200:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201202:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201204:	0141                	addi	sp,sp,16
ffffffffc0201206:	8082                	ret
ffffffffc0201208:	60a2                	ld	ra,8(sp)
ffffffffc020120a:	e290                	sd	a2,0(a3)
ffffffffc020120c:	0141                	addi	sp,sp,16
ffffffffc020120e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201210:	00001697          	auipc	a3,0x1
ffffffffc0201214:	4e868693          	addi	a3,a3,1256 # ffffffffc02026f8 <etext+0xa06>
ffffffffc0201218:	00001617          	auipc	a2,0x1
ffffffffc020121c:	1c860613          	addi	a2,a2,456 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0201220:	04a00593          	li	a1,74
ffffffffc0201224:	00001517          	auipc	a0,0x1
ffffffffc0201228:	1d450513          	addi	a0,a0,468 # ffffffffc02023f8 <etext+0x706>
ffffffffc020122c:	982ff0ef          	jal	ffffffffc02003ae <__panic>
    assert(n > 0);
ffffffffc0201230:	00001697          	auipc	a3,0x1
ffffffffc0201234:	1a868693          	addi	a3,a3,424 # ffffffffc02023d8 <etext+0x6e6>
ffffffffc0201238:	00001617          	auipc	a2,0x1
ffffffffc020123c:	1a860613          	addi	a2,a2,424 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc0201240:	04700593          	li	a1,71
ffffffffc0201244:	00001517          	auipc	a0,0x1
ffffffffc0201248:	1b450513          	addi	a0,a0,436 # ffffffffc02023f8 <etext+0x706>
ffffffffc020124c:	962ff0ef          	jal	ffffffffc02003ae <__panic>

ffffffffc0201250 <alloc_pages>:
    SSTATUS_SIE 是 sstatus 中的一个位，表示当前系统是否允许中断。如果该位被设置，意味着当前中断是启用的。
    if (read_csr(sstatus) & SSTATUS_SIE)：检查当前中断状态，如果中断是开启的，就执行下一步操作。
    intr_disable()：禁用中断，确保接下来的临界区代码不会被中断打断。
    返回值：函数返回 1 表示中断原本是开启的；返回 0 表示中断原本是关闭的。这个返回值用于后续恢复中断状态时判断之前是否应该启用中断。
    */
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201250:	100027f3          	csrr	a5,sstatus
ffffffffc0201254:	8b89                	andi	a5,a5,2
ffffffffc0201256:	e799                	bnez	a5,ffffffffc0201264 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);//为了防止中断影响，使用 local_intr_save 和 local_intr_restore 暂时禁用中断，保证内存分配是原子的。
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201258:	00005797          	auipc	a5,0x5
ffffffffc020125c:	2087b783          	ld	a5,520(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0201260:	6f9c                	ld	a5,24(a5)
ffffffffc0201262:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0201264:	1141                	addi	sp,sp,-16
ffffffffc0201266:	e406                	sd	ra,8(sp)
ffffffffc0201268:	e022                	sd	s0,0(sp)
ffffffffc020126a:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020126c:	9f6ff0ef          	jal	ffffffffc0200462 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201270:	00005797          	auipc	a5,0x5
ffffffffc0201274:	1f07b783          	ld	a5,496(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc0201278:	6f9c                	ld	a5,24(a5)
ffffffffc020127a:	8522                	mv	a0,s0
ffffffffc020127c:	9782                	jalr	a5
ffffffffc020127e:	842a                	mv	s0,a0
static inline void __intr_restore(bool flag) {
    /*
    if (flag)：如果 flag 是 1，则说明中断在进入临界区之前是启用的，所以在离开临界区时需要重新启用中断。
    */
    if (flag) {
        intr_enable();
ffffffffc0201280:	9dcff0ef          	jal	ffffffffc020045c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201284:	60a2                	ld	ra,8(sp)
ffffffffc0201286:	8522                	mv	a0,s0
ffffffffc0201288:	6402                	ld	s0,0(sp)
ffffffffc020128a:	0141                	addi	sp,sp,16
ffffffffc020128c:	8082                	ret

ffffffffc020128e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020128e:	100027f3          	csrr	a5,sstatus
ffffffffc0201292:	8b89                	andi	a5,a5,2
ffffffffc0201294:	e799                	bnez	a5,ffffffffc02012a2 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201296:	00005797          	auipc	a5,0x5
ffffffffc020129a:	1ca7b783          	ld	a5,458(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc020129e:	739c                	ld	a5,32(a5)
ffffffffc02012a0:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc02012a2:	1101                	addi	sp,sp,-32
ffffffffc02012a4:	ec06                	sd	ra,24(sp)
ffffffffc02012a6:	e822                	sd	s0,16(sp)
ffffffffc02012a8:	e426                	sd	s1,8(sp)
ffffffffc02012aa:	842a                	mv	s0,a0
ffffffffc02012ac:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02012ae:	9b4ff0ef          	jal	ffffffffc0200462 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02012b2:	00005797          	auipc	a5,0x5
ffffffffc02012b6:	1ae7b783          	ld	a5,430(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc02012ba:	739c                	ld	a5,32(a5)
ffffffffc02012bc:	85a6                	mv	a1,s1
ffffffffc02012be:	8522                	mv	a0,s0
ffffffffc02012c0:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc02012c2:	6442                	ld	s0,16(sp)
ffffffffc02012c4:	60e2                	ld	ra,24(sp)
ffffffffc02012c6:	64a2                	ld	s1,8(sp)
ffffffffc02012c8:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02012ca:	992ff06f          	j	ffffffffc020045c <intr_enable>

ffffffffc02012ce <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012ce:	100027f3          	csrr	a5,sstatus
ffffffffc02012d2:	8b89                	andi	a5,a5,2
ffffffffc02012d4:	e799                	bnez	a5,ffffffffc02012e2 <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc02012d6:	00005797          	auipc	a5,0x5
ffffffffc02012da:	18a7b783          	ld	a5,394(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc02012de:	779c                	ld	a5,40(a5)
ffffffffc02012e0:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02012e2:	1141                	addi	sp,sp,-16
ffffffffc02012e4:	e406                	sd	ra,8(sp)
ffffffffc02012e6:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02012e8:	97aff0ef          	jal	ffffffffc0200462 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02012ec:	00005797          	auipc	a5,0x5
ffffffffc02012f0:	1747b783          	ld	a5,372(a5) # ffffffffc0206460 <pmm_manager>
ffffffffc02012f4:	779c                	ld	a5,40(a5)
ffffffffc02012f6:	9782                	jalr	a5
ffffffffc02012f8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02012fa:	962ff0ef          	jal	ffffffffc020045c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02012fe:	60a2                	ld	ra,8(sp)
ffffffffc0201300:	8522                	mv	a0,s0
ffffffffc0201302:	6402                	ld	s0,0(sp)
ffffffffc0201304:	0141                	addi	sp,sp,16
ffffffffc0201306:	8082                	ret

ffffffffc0201308 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201308:	00001797          	auipc	a5,0x1
ffffffffc020130c:	6f078793          	addi	a5,a5,1776 # ffffffffc02029f8 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201310:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201312:	1101                	addi	sp,sp,-32
ffffffffc0201314:	ec06                	sd	ra,24(sp)
ffffffffc0201316:	e822                	sd	s0,16(sp)
ffffffffc0201318:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020131a:	00001517          	auipc	a0,0x1
ffffffffc020131e:	40650513          	addi	a0,a0,1030 # ffffffffc0202720 <etext+0xa2e>
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201322:	00005497          	auipc	s1,0x5
ffffffffc0201326:	13e48493          	addi	s1,s1,318 # ffffffffc0206460 <pmm_manager>
ffffffffc020132a:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020132c:	d8ffe0ef          	jal	ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0201330:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0201332:	00005417          	auipc	s0,0x5
ffffffffc0201336:	14640413          	addi	s0,s0,326 # ffffffffc0206478 <va_pa_offset>
    pmm_manager->init();
ffffffffc020133a:	679c                	ld	a5,8(a5)
ffffffffc020133c:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020133e:	57f5                	li	a5,-3
ffffffffc0201340:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0201342:	00001517          	auipc	a0,0x1
ffffffffc0201346:	3f650513          	addi	a0,a0,1014 # ffffffffc0202738 <etext+0xa46>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020134a:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc020134c:	d6ffe0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201350:	46c5                	li	a3,17
ffffffffc0201352:	06ee                	slli	a3,a3,0x1b
ffffffffc0201354:	40100613          	li	a2,1025
ffffffffc0201358:	16fd                	addi	a3,a3,-1
ffffffffc020135a:	0656                	slli	a2,a2,0x15
ffffffffc020135c:	07e005b7          	lui	a1,0x7e00
ffffffffc0201360:	00001517          	auipc	a0,0x1
ffffffffc0201364:	3f050513          	addi	a0,a0,1008 # ffffffffc0202750 <etext+0xa5e>
ffffffffc0201368:	d53fe0ef          	jal	ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);//是一个指向 Page 结构体数组的指针，管理每个物理页的元数据。它的起始地址通过 ROUNDUP 对齐到页大小，以确保 pages 数组的开始地址是页对齐的。
ffffffffc020136c:	777d                	lui	a4,0xfffff
ffffffffc020136e:	00006797          	auipc	a5,0x6
ffffffffc0201372:	13178793          	addi	a5,a5,305 # ffffffffc020749f <end+0xfff>
ffffffffc0201376:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;//最大物理地址 maxpa对应的页号
ffffffffc0201378:	00005517          	auipc	a0,0x5
ffffffffc020137c:	10850513          	addi	a0,a0,264 # ffffffffc0206480 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);//是一个指向 Page 结构体数组的指针，管理每个物理页的元数据。它的起始地址通过 ROUNDUP 对齐到页大小，以确保 pages 数组的开始地址是页对齐的。
ffffffffc0201380:	00005597          	auipc	a1,0x5
ffffffffc0201384:	10858593          	addi	a1,a1,264 # ffffffffc0206488 <pages>
    npage = maxpa / PGSIZE;//最大物理地址 maxpa对应的页号
ffffffffc0201388:	00088737          	lui	a4,0x88
ffffffffc020138c:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);//是一个指向 Page 结构体数组的指针，管理每个物理页的元数据。它的起始地址通过 ROUNDUP 对齐到页大小，以确保 pages 数组的开始地址是页对齐的。
ffffffffc020138e:	e19c                	sd	a5,0(a1)
ffffffffc0201390:	4705                	li	a4,1
ffffffffc0201392:	07a1                	addi	a5,a5,8
ffffffffc0201394:	40e7b02f          	amoor.d	zero,a4,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201398:	02800693          	li	a3,40
ffffffffc020139c:	4885                	li	a7,1
ffffffffc020139e:	fff80837          	lui	a6,0xfff80
        SetPageReserved(pages + i);
ffffffffc02013a2:	619c                	ld	a5,0(a1)
ffffffffc02013a4:	97b6                	add	a5,a5,a3
ffffffffc02013a6:	07a1                	addi	a5,a5,8
ffffffffc02013a8:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02013ac:	611c                	ld	a5,0(a0)
ffffffffc02013ae:	0705                	addi	a4,a4,1 # 88001 <kern_entry-0xffffffffc0177fff>
ffffffffc02013b0:	02868693          	addi	a3,a3,40
ffffffffc02013b4:	01078633          	add	a2,a5,a6
ffffffffc02013b8:	fec765e3          	bltu	a4,a2,ffffffffc02013a2 <pmm_init+0x9a>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));//计算 pages 数组结束后的地址。通过将 pages 的地址加上 Page 结构体的大小乘以 npage - nbase，我们可以得到 pages 数组在内存中的结束位置。通过 PADDR 宏将其转换为物理地址。
ffffffffc02013bc:	6190                	ld	a2,0(a1)
ffffffffc02013be:	00279693          	slli	a3,a5,0x2
ffffffffc02013c2:	96be                	add	a3,a3,a5
ffffffffc02013c4:	fec00737          	lui	a4,0xfec00
ffffffffc02013c8:	9732                	add	a4,a4,a2
ffffffffc02013ca:	068e                	slli	a3,a3,0x3
ffffffffc02013cc:	96ba                	add	a3,a3,a4
ffffffffc02013ce:	c0200737          	lui	a4,0xc0200
ffffffffc02013d2:	0ae6e463          	bltu	a3,a4,ffffffffc020147a <pmm_init+0x172>
ffffffffc02013d6:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc02013d8:	45c5                	li	a1,17
ffffffffc02013da:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));//计算 pages 数组结束后的地址。通过将 pages 的地址加上 Page 结构体的大小乘以 npage - nbase，我们可以得到 pages 数组在内存中的结束位置。通过 PADDR 宏将其转换为物理地址。
ffffffffc02013dc:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02013de:	04b6e963          	bltu	a3,a1,ffffffffc0201430 <pmm_init+0x128>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02013e2:	609c                	ld	a5,0(s1)
ffffffffc02013e4:	7b9c                	ld	a5,48(a5)
ffffffffc02013e6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02013e8:	00001517          	auipc	a0,0x1
ffffffffc02013ec:	40050513          	addi	a0,a0,1024 # ffffffffc02027e8 <etext+0xaf6>
ffffffffc02013f0:	ccbfe0ef          	jal	ffffffffc02000ba <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;// 这个变量指向 boot_page_table_sv39
ffffffffc02013f4:	00004597          	auipc	a1,0x4
ffffffffc02013f8:	c0c58593          	addi	a1,a1,-1012 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc02013fc:	00005797          	auipc	a5,0x5
ffffffffc0201400:	06b7ba23          	sd	a1,116(a5) # ffffffffc0206470 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201404:	c02007b7          	lui	a5,0xc0200
ffffffffc0201408:	08f5e563          	bltu	a1,a5,ffffffffc0201492 <pmm_init+0x18a>
ffffffffc020140c:	601c                	ld	a5,0(s0)
}
ffffffffc020140e:	6442                	ld	s0,16(sp)
ffffffffc0201410:	60e2                	ld	ra,24(sp)
ffffffffc0201412:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201414:	40f586b3          	sub	a3,a1,a5
ffffffffc0201418:	00005797          	auipc	a5,0x5
ffffffffc020141c:	04d7b823          	sd	a3,80(a5) # ffffffffc0206468 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201420:	00001517          	auipc	a0,0x1
ffffffffc0201424:	3e850513          	addi	a0,a0,1000 # ffffffffc0202808 <etext+0xb16>
ffffffffc0201428:	8636                	mv	a2,a3
}
ffffffffc020142a:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020142c:	c8ffe06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201430:	6705                	lui	a4,0x1
ffffffffc0201432:	177d                	addi	a4,a4,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc0201434:	96ba                	add	a3,a3,a4
ffffffffc0201436:	777d                	lui	a4,0xfffff
ffffffffc0201438:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {//将物理地址转换为对应的 Page 结构体指针。如果物理页号超出范围，会触发 panic。
    if (PPN(pa) >= npage) {
ffffffffc020143a:	00c6d713          	srli	a4,a3,0xc
ffffffffc020143e:	02f77263          	bgeu	a4,a5,ffffffffc0201462 <pmm_init+0x15a>
    pmm_manager->init_memmap(base, n);
ffffffffc0201442:	0004b803          	ld	a6,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201446:	fff807b7          	lui	a5,0xfff80
ffffffffc020144a:	97ba                	add	a5,a5,a4
ffffffffc020144c:	00279513          	slli	a0,a5,0x2
ffffffffc0201450:	953e                	add	a0,a0,a5
ffffffffc0201452:	01083783          	ld	a5,16(a6) # fffffffffff80010 <end+0x3fd79b70>
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201456:	8d95                	sub	a1,a1,a3
ffffffffc0201458:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc020145a:	81b1                	srli	a1,a1,0xc
ffffffffc020145c:	9532                	add	a0,a0,a2
ffffffffc020145e:	9782                	jalr	a5
}
ffffffffc0201460:	b749                	j	ffffffffc02013e2 <pmm_init+0xda>
        panic("pa2page called with invalid pa");
ffffffffc0201462:	00001617          	auipc	a2,0x1
ffffffffc0201466:	35660613          	addi	a2,a2,854 # ffffffffc02027b8 <etext+0xac6>
ffffffffc020146a:	07100593          	li	a1,113
ffffffffc020146e:	00001517          	auipc	a0,0x1
ffffffffc0201472:	36a50513          	addi	a0,a0,874 # ffffffffc02027d8 <etext+0xae6>
ffffffffc0201476:	f39fe0ef          	jal	ffffffffc02003ae <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));//计算 pages 数组结束后的地址。通过将 pages 的地址加上 Page 结构体的大小乘以 npage - nbase，我们可以得到 pages 数组在内存中的结束位置。通过 PADDR 宏将其转换为物理地址。
ffffffffc020147a:	00001617          	auipc	a2,0x1
ffffffffc020147e:	30660613          	addi	a2,a2,774 # ffffffffc0202780 <etext+0xa8e>
ffffffffc0201482:	07000593          	li	a1,112
ffffffffc0201486:	00001517          	auipc	a0,0x1
ffffffffc020148a:	32250513          	addi	a0,a0,802 # ffffffffc02027a8 <etext+0xab6>
ffffffffc020148e:	f21fe0ef          	jal	ffffffffc02003ae <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201492:	86ae                	mv	a3,a1
ffffffffc0201494:	00001617          	auipc	a2,0x1
ffffffffc0201498:	2ec60613          	addi	a2,a2,748 # ffffffffc0202780 <etext+0xa8e>
ffffffffc020149c:	08b00593          	li	a1,139
ffffffffc02014a0:	00001517          	auipc	a0,0x1
ffffffffc02014a4:	30850513          	addi	a0,a0,776 # ffffffffc02027a8 <etext+0xab6>
ffffffffc02014a8:	f07fe0ef          	jal	ffffffffc02003ae <__panic>

ffffffffc02014ac <slob_free>:
}

static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;//cur：用于遍历空闲链表的指针。b：将 block 转换为 slob_t* 类型，这是释放的内存块。slob_t 是内存块的基本结构，表示一个小块内存单元。
	if (!block)
ffffffffc02014ac:	cd0d                	beqz	a0,ffffffffc02014e6 <slob_free+0x3a>
		return;
	if (size)
ffffffffc02014ae:	ed8d                	bnez	a1,ffffffffc02014e8 <slob_free+0x3c>
        检查释放的块 b 是否与它后面的空闲块 cur->next 相邻。
      如果相邻：将它们合并，即：
   b->units += cur->next->units;：增加 b 的大小，包含 cur->next 的单元数。
   b->next = cur->next->next;：跳过 cur->next，直接指向它的后继块，完成链表的合并。
        */
	if (b + b->units == cur->next) {
ffffffffc02014b0:	4114                	lw	a3,0(a0)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)//这里通过遍历空闲链表，寻找释放块 b 应该插入的位置。遍历的链表是从 slobfree 开始的，cur 表示当前遍历到的空闲块。
ffffffffc02014b2:	00005597          	auipc	a1,0x5
ffffffffc02014b6:	b5e58593          	addi	a1,a1,-1186 # ffffffffc0206010 <slobfree>
ffffffffc02014ba:	619c                	ld	a5,0(a1)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02014bc:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)//这里通过遍历空闲链表，寻找释放块 b 应该插入的位置。遍历的链表是从 slobfree 开始的，cur 表示当前遍历到的空闲块。
ffffffffc02014be:	02a7fa63          	bgeu	a5,a0,ffffffffc02014f2 <slob_free+0x46>
ffffffffc02014c2:	00e56463          	bltu	a0,a4,ffffffffc02014ca <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02014c6:	02e7ea63          	bltu	a5,a4,ffffffffc02014fa <slob_free+0x4e>
	if (b + b->units == cur->next) {
ffffffffc02014ca:	00469613          	slli	a2,a3,0x4
ffffffffc02014ce:	962a                	add	a2,a2,a0
ffffffffc02014d0:	02c70d63          	beq	a4,a2,ffffffffc020150a <slob_free+0x5e>
		b->next = cur->next->next;
	} else{
		b->next = cur->next;
		}
     //与前面块相邻
	if (cur + cur->units == b) {
ffffffffc02014d4:	4390                	lw	a2,0(a5)
ffffffffc02014d6:	e518                	sd	a4,8(a0)
ffffffffc02014d8:	00461693          	slli	a3,a2,0x4
ffffffffc02014dc:	96be                	add	a3,a3,a5
ffffffffc02014de:	02d50063          	beq	a0,a3,ffffffffc02014fe <slob_free+0x52>
ffffffffc02014e2:	e788                	sd	a0,8(a5)
		cur->next = b->next;
	} else{
		cur->next = b;
		}

	slobfree = cur;
ffffffffc02014e4:	e19c                	sd	a5,0(a1)
}
ffffffffc02014e6:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02014e8:	00f5869b          	addiw	a3,a1,15
ffffffffc02014ec:	8691                	srai	a3,a3,0x4
ffffffffc02014ee:	c114                	sw	a3,0(a0)
ffffffffc02014f0:	b7c9                	j	ffffffffc02014b2 <slob_free+0x6>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02014f2:	00e7e463          	bltu	a5,a4,ffffffffc02014fa <slob_free+0x4e>
ffffffffc02014f6:	fce56ae3          	bltu	a0,a4,ffffffffc02014ca <slob_free+0x1e>
{
ffffffffc02014fa:	87ba                	mv	a5,a4
ffffffffc02014fc:	b7c1                	j	ffffffffc02014bc <slob_free+0x10>
		cur->units += b->units;
ffffffffc02014fe:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201500:	853a                	mv	a0,a4
		cur->units += b->units;
ffffffffc0201502:	00c6873b          	addw	a4,a3,a2
ffffffffc0201506:	c398                	sw	a4,0(a5)
		cur->next = b->next;
ffffffffc0201508:	bfe9                	j	ffffffffc02014e2 <slob_free+0x36>
		b->units += cur->next->units;
ffffffffc020150a:	4310                	lw	a2,0(a4)
		b->next = cur->next->next;
ffffffffc020150c:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc020150e:	9eb1                	addw	a3,a3,a2
ffffffffc0201510:	c114                	sw	a3,0(a0)
		b->next = cur->next->next;
ffffffffc0201512:	b7c9                	j	ffffffffc02014d4 <slob_free+0x28>

ffffffffc0201514 <slob_alloc>:
{
ffffffffc0201514:	1101                	addi	sp,sp,-32
ffffffffc0201516:	ec06                	sd	ra,24(sp)
ffffffffc0201518:	e822                	sd	s0,16(sp)
ffffffffc020151a:	e426                	sd	s1,8(sp)
ffffffffc020151c:	e04a                	sd	s2,0(sp)
    assert(size < PGSIZE);//确保请求的内存大小小于页面大小（PGSIZE，通常为 4KB），这是因为 slob_alloc 函数用于处理小块内存分配，如果内存大小大于等于一页，就不应该使用该函数。超出页面大小的分配将由其他机制（例如大块分配）处理。
ffffffffc020151e:	6785                	lui	a5,0x1
ffffffffc0201520:	08f57363          	bgeu	a0,a5,ffffffffc02015a6 <slob_alloc+0x92>
	prev = slobfree;
ffffffffc0201524:	00005417          	auipc	s0,0x5
ffffffffc0201528:	aec40413          	addi	s0,s0,-1300 # ffffffffc0206010 <slobfree>
ffffffffc020152c:	6010                	ld	a2,0(s0)
	int  units = SLOB_UNITS(size);
ffffffffc020152e:	053d                	addi	a0,a0,15
ffffffffc0201530:	00455913          	srli	s2,a0,0x4
	cur = prev->next;	
ffffffffc0201534:	6618                	ld	a4,8(a2)
	int  units = SLOB_UNITS(size);
ffffffffc0201536:	0009049b          	sext.w	s1,s2
	     if (cur->units >= units) { //cur->units 代表当前块的大小（以 slob_t 为单位）。如果当前块的大小大于或等于请求的大小（units），则说明该块可以满足分配请求。
ffffffffc020153a:	4314                	lw	a3,0(a4)
ffffffffc020153c:	0696d263          	bge	a3,s1,ffffffffc02015a0 <slob_alloc+0x8c>
	     if (cur == slobfree) {
ffffffffc0201540:	00e60a63          	beq	a2,a4,ffffffffc0201554 <slob_alloc+0x40>
	     cur=cur->next;
ffffffffc0201544:	671c                	ld	a5,8(a4)
	     if (cur->units >= units) { //cur->units 代表当前块的大小（以 slob_t 为单位）。如果当前块的大小大于或等于请求的大小（units），则说明该块可以满足分配请求。
ffffffffc0201546:	4394                	lw	a3,0(a5)
ffffffffc0201548:	0296d363          	bge	a3,s1,ffffffffc020156e <slob_alloc+0x5a>
	     if (cur == slobfree) {
ffffffffc020154c:	6010                	ld	a2,0(s0)
ffffffffc020154e:	873e                	mv	a4,a5
ffffffffc0201550:	fee61ae3          	bne	a2,a4,ffffffffc0201544 <slob_alloc+0x30>
			cur = (slob_t *)alloc_pages(1);
ffffffffc0201554:	4505                	li	a0,1
ffffffffc0201556:	cfbff0ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc020155a:	87aa                	mv	a5,a0
			if (!cur)
ffffffffc020155c:	c51d                	beqz	a0,ffffffffc020158a <slob_alloc+0x76>
			slob_free(cur, PGSIZE);//将新分配的页面释放到空闲列表
ffffffffc020155e:	6585                	lui	a1,0x1
ffffffffc0201560:	f4dff0ef          	jal	ffffffffc02014ac <slob_free>
			cur = slobfree;
ffffffffc0201564:	6018                	ld	a4,0(s0)
	     cur=cur->next;
ffffffffc0201566:	671c                	ld	a5,8(a4)
	     if (cur->units >= units) { //cur->units 代表当前块的大小（以 slob_t 为单位）。如果当前块的大小大于或等于请求的大小（units），则说明该块可以满足分配请求。
ffffffffc0201568:	4394                	lw	a3,0(a5)
ffffffffc020156a:	fe96c1e3          	blt	a3,s1,ffffffffc020154c <slob_alloc+0x38>
			if (cur->units == units)//如果当前块的大小刚好等于请求的大小，则将该块从空闲链表中移除（prev->next = cur->next），因为它将被完全分配。
ffffffffc020156e:	02d48563          	beq	s1,a3,ffffffffc0201598 <slob_alloc+0x84>
				prev->next = cur + units;
ffffffffc0201572:	0912                	slli	s2,s2,0x4
ffffffffc0201574:	993e                	add	s2,s2,a5
ffffffffc0201576:	01273423          	sd	s2,8(a4) # fffffffffffff008 <end+0x3fdf8b68>
				prev->next->next = cur->next;
ffffffffc020157a:	6790                	ld	a2,8(a5)
				prev->next->units = cur->units - units;
ffffffffc020157c:	9e85                	subw	a3,a3,s1
ffffffffc020157e:	00d92023          	sw	a3,0(s2)
				prev->next->next = cur->next;
ffffffffc0201582:	00c93423          	sd	a2,8(s2)
				cur->units = units;
ffffffffc0201586:	c384                	sw	s1,0(a5)
			slobfree = prev;
ffffffffc0201588:	e018                	sd	a4,0(s0)
}
ffffffffc020158a:	60e2                	ld	ra,24(sp)
ffffffffc020158c:	6442                	ld	s0,16(sp)
ffffffffc020158e:	64a2                	ld	s1,8(sp)
ffffffffc0201590:	6902                	ld	s2,0(sp)
ffffffffc0201592:	853e                	mv	a0,a5
ffffffffc0201594:	6105                	addi	sp,sp,32
ffffffffc0201596:	8082                	ret
				prev->next = cur->next;
ffffffffc0201598:	6794                	ld	a3,8(a5)
			slobfree = prev;
ffffffffc020159a:	e018                	sd	a4,0(s0)
				prev->next = cur->next;
ffffffffc020159c:	e714                	sd	a3,8(a4)
			return cur;
ffffffffc020159e:	b7f5                	j	ffffffffc020158a <slob_alloc+0x76>
	cur = prev->next;	
ffffffffc02015a0:	87ba                	mv	a5,a4
	prev = slobfree;
ffffffffc02015a2:	8732                	mv	a4,a2
ffffffffc02015a4:	b7e9                	j	ffffffffc020156e <slob_alloc+0x5a>
    assert(size < PGSIZE);//确保请求的内存大小小于页面大小（PGSIZE，通常为 4KB），这是因为 slob_alloc 函数用于处理小块内存分配，如果内存大小大于等于一页，就不应该使用该函数。超出页面大小的分配将由其他机制（例如大块分配）处理。
ffffffffc02015a6:	00001697          	auipc	a3,0x1
ffffffffc02015aa:	2a268693          	addi	a3,a3,674 # ffffffffc0202848 <etext+0xb56>
ffffffffc02015ae:	00001617          	auipc	a2,0x1
ffffffffc02015b2:	e3260613          	addi	a2,a2,-462 # ffffffffc02023e0 <etext+0x6ee>
ffffffffc02015b6:	02200593          	li	a1,34
ffffffffc02015ba:	00001517          	auipc	a0,0x1
ffffffffc02015be:	29e50513          	addi	a0,a0,670 # ffffffffc0202858 <etext+0xb66>
ffffffffc02015c2:	dedfe0ef          	jal	ffffffffc02003ae <__panic>

ffffffffc02015c6 <slub_alloc.part.0>:
void 
slub_init(void) {
    cprintf("slub_init() succeeded!\n");
}

void *slub_alloc(size_t size)
ffffffffc02015c6:	1101                	addi	sp,sp,-32
ffffffffc02015c8:	e822                	sd	s0,16(sp)
ffffffffc02015ca:	842a                	mv	s0,a0
		//m = slob_alloc(size + SLOB_UNIT);
		m = slob_alloc(size);
		return m ? (void *)(m + 1) : 0;
	}

	bb = slob_alloc(sizeof(bigblock_t));//尽管 slob_alloc() 返回的是一个 slob_t*，但从内存分配的角度来看，slob_t* 实际上就是一个指向内存块的指针。slob_t* 只是 void* 类型的替代形式，用于在分配时将管理结构与内存关联起来。
ffffffffc02015cc:	4561                	li	a0,24
void *slub_alloc(size_t size)
ffffffffc02015ce:	ec06                	sd	ra,24(sp)
	bb = slob_alloc(sizeof(bigblock_t));//尽管 slob_alloc() 返回的是一个 slob_t*，但从内存分配的角度来看，slob_t* 实际上就是一个指向内存块的指针。slob_t* 只是 void* 类型的替代形式，用于在分配时将管理结构与内存关联起来。
ffffffffc02015d0:	f45ff0ef          	jal	ffffffffc0201514 <slob_alloc>
	if (!bb)
ffffffffc02015d4:	cd0d                	beqz	a0,ffffffffc020160e <slub_alloc.part.0+0x48>
		return 0;

	//bb->order = ((size-1) >> PGSHIFT) + 1;//个公式通过右移 PGSHIFT 位，将 size 转换为页面数
	bb->order=size/4096+1;
ffffffffc02015d6:	00c45793          	srli	a5,s0,0xc
ffffffffc02015da:	e426                	sd	s1,8(sp)
ffffffffc02015dc:	84aa                	mv	s1,a0
ffffffffc02015de:	0017851b          	addiw	a0,a5,1 # 1001 <kern_entry-0xffffffffc01fefff>
ffffffffc02015e2:	c088                	sw	a0,0(s1)
	bb->pages = (void *)alloc_pages(bb->order);
ffffffffc02015e4:	c6dff0ef          	jal	ffffffffc0201250 <alloc_pages>
ffffffffc02015e8:	e488                	sd	a0,8(s1)

	if (bb->pages) {
ffffffffc02015ea:	cd09                	beqz	a0,ffffffffc0201604 <slub_alloc.part.0+0x3e>
		bb->next = bigblocks;
ffffffffc02015ec:	00005797          	auipc	a5,0x5
ffffffffc02015f0:	ea478793          	addi	a5,a5,-348 # ffffffffc0206490 <bigblocks>
ffffffffc02015f4:	6398                	ld	a4,0(a5)
		return bb->pages;
	}

	slob_free(bb, sizeof(bigblock_t));//如果大块页面分配失败，释放 bigblock_t 结构体所占用的内存。调用 slob_free(bb, sizeof(bigblock_t)) 将 bb 释放回空闲链表，然后返回 0，表示分配失败
	return 0;
}
ffffffffc02015f6:	60e2                	ld	ra,24(sp)
ffffffffc02015f8:	6442                	ld	s0,16(sp)
		bigblocks = bb;
ffffffffc02015fa:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc02015fc:	e898                	sd	a4,16(s1)
		return bb->pages;
ffffffffc02015fe:	64a2                	ld	s1,8(sp)
}
ffffffffc0201600:	6105                	addi	sp,sp,32
ffffffffc0201602:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));//如果大块页面分配失败，释放 bigblock_t 结构体所占用的内存。调用 slob_free(bb, sizeof(bigblock_t)) 将 bb 释放回空闲链表，然后返回 0，表示分配失败
ffffffffc0201604:	8526                	mv	a0,s1
ffffffffc0201606:	45e1                	li	a1,24
ffffffffc0201608:	ea5ff0ef          	jal	ffffffffc02014ac <slob_free>
ffffffffc020160c:	64a2                	ld	s1,8(sp)
}
ffffffffc020160e:	60e2                	ld	ra,24(sp)
ffffffffc0201610:	6442                	ld	s0,16(sp)
		return 0;
ffffffffc0201612:	4501                	li	a0,0
}
ffffffffc0201614:	6105                	addi	sp,sp,32
ffffffffc0201616:	8082                	ret

ffffffffc0201618 <slub_init>:
    cprintf("slub_init() succeeded!\n");
ffffffffc0201618:	00001517          	auipc	a0,0x1
ffffffffc020161c:	25850513          	addi	a0,a0,600 # ffffffffc0202870 <etext+0xb7e>
ffffffffc0201620:	a9bfe06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0201624 <slub_free>:


void slub_free(void *block)//这段代码实现了 slub_free 函数，用于释放通过 slub_alloc 分配的内存
{

	if (!block)
ffffffffc0201624:	c531                	beqz	a0,ffffffffc0201670 <slub_free+0x4c>
		return;

	if (!((unsigned long)block & (PGSIZE-1))) {//这个条件判断传入的 block 是否为页面对齐的地址（即大块内存）。页面对齐意味着 block 的地址是 PGSIZE（通常为 4KB）的倍数。是提取 block 地址的最低位，判断它是否与 PGSIZE 对齐。这是与号，就是0xFFF与12个0
ffffffffc0201626:	03451793          	slli	a5,a0,0x34
ffffffffc020162a:	e7a1                	bnez	a5,ffffffffc0201672 <slub_free+0x4e>
	        bigblock_t *bb, **last = &bigblocks;
		bb=bigblocks;
ffffffffc020162c:	00005697          	auipc	a3,0x5
ffffffffc0201630:	e6468693          	addi	a3,a3,-412 # ffffffffc0206490 <bigblocks>
ffffffffc0201634:	629c                	ld	a5,0(a3)
	        while(bb){
ffffffffc0201636:	cf95                	beqz	a5,ffffffffc0201672 <slub_free+0x4e>
{
ffffffffc0201638:	1141                	addi	sp,sp,-16
ffffffffc020163a:	e406                	sd	ra,8(sp)
ffffffffc020163c:	e022                	sd	s0,0(sp)
ffffffffc020163e:	a021                	j	ffffffffc0201646 <slub_free+0x22>
				*last = bb->next;
				free_pages((struct Page *)block, bb->order);//调用 free_pages 函数，释放大块内存块，bb->order 指示了分配的页数。
				slob_free(bb, sizeof(bigblock_t));
				return;
			}
	                last=&bb->next;
ffffffffc0201640:	01040693          	addi	a3,s0,16
	        while(bb){
ffffffffc0201644:	c385                	beqz	a5,ffffffffc0201664 <slub_free+0x40>
			if (bb->pages == block) {//如果 bb->pages 指向的内存块与 block 相同，说明找到了对应的大块内存块。
ffffffffc0201646:	6798                	ld	a4,8(a5)
ffffffffc0201648:	843e                	mv	s0,a5
				*last = bb->next;
ffffffffc020164a:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block) {//如果 bb->pages 指向的内存块与 block 相同，说明找到了对应的大块内存块。
ffffffffc020164c:	fea71ae3          	bne	a4,a0,ffffffffc0201640 <slub_free+0x1c>
				free_pages((struct Page *)block, bb->order);//调用 free_pages 函数，释放大块内存块，bb->order 指示了分配的页数。
ffffffffc0201650:	400c                	lw	a1,0(s0)
				*last = bb->next;
ffffffffc0201652:	e29c                	sd	a5,0(a3)
				free_pages((struct Page *)block, bb->order);//调用 free_pages 函数，释放大块内存块，bb->order 指示了分配的页数。
ffffffffc0201654:	c3bff0ef          	jal	ffffffffc020128e <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201658:	8522                	mv	a0,s0
	        }
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc020165a:	6402                	ld	s0,0(sp)
ffffffffc020165c:	60a2                	ld	ra,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc020165e:	45e1                	li	a1,24
}
ffffffffc0201660:	0141                	addi	sp,sp,16
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201662:	b5a9                	j	ffffffffc02014ac <slob_free>
}
ffffffffc0201664:	6402                	ld	s0,0(sp)
ffffffffc0201666:	60a2                	ld	ra,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201668:	4581                	li	a1,0
ffffffffc020166a:	1541                	addi	a0,a0,-16
}
ffffffffc020166c:	0141                	addi	sp,sp,16
	slob_free((slob_t *)block - 1, 0);
ffffffffc020166e:	bd3d                	j	ffffffffc02014ac <slob_free>
ffffffffc0201670:	8082                	ret
ffffffffc0201672:	4581                	li	a1,0
ffffffffc0201674:	1541                	addi	a0,a0,-16
ffffffffc0201676:	bd1d                	j	ffffffffc02014ac <slob_free>

ffffffffc0201678 <slub_check>:
        len ++;
    return len;
}

void slub_check()
{
ffffffffc0201678:	1101                	addi	sp,sp,-32
    cprintf("slub check begin\n");
ffffffffc020167a:	00001517          	auipc	a0,0x1
ffffffffc020167e:	20e50513          	addi	a0,a0,526 # ffffffffc0202888 <etext+0xb96>
{
ffffffffc0201682:	e822                	sd	s0,16(sp)
ffffffffc0201684:	ec06                	sd	ra,24(sp)
ffffffffc0201686:	e426                	sd	s1,8(sp)
ffffffffc0201688:	e04a                	sd	s2,0(sp)
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020168a:	00005417          	auipc	s0,0x5
ffffffffc020168e:	98640413          	addi	s0,s0,-1658 # ffffffffc0206010 <slobfree>
    cprintf("slub check begin\n");
ffffffffc0201692:	a29fe0ef          	jal	ffffffffc02000ba <cprintf>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201696:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc0201698:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020169a:	671c                	ld	a5,8(a4)
ffffffffc020169c:	00f70663          	beq	a4,a5,ffffffffc02016a8 <slub_check+0x30>
ffffffffc02016a0:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc02016a2:	2585                	addiw	a1,a1,1 # 1001 <kern_entry-0xffffffffc01fefff>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02016a4:	fef71ee3          	bne	a4,a5,ffffffffc02016a0 <slub_check+0x28>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc02016a8:	00001517          	auipc	a0,0x1
ffffffffc02016ac:	1f850513          	addi	a0,a0,504 # ffffffffc02028a0 <etext+0xbae>
ffffffffc02016b0:	a0bfe0ef          	jal	ffffffffc02000ba <cprintf>
	if (size < PGSIZE - SLOB_UNIT) {//如果 size 小于 PGSIZE - SLOB_UNIT（页面大小减去一个 slob_t 的大小），则认为这是一个小块内存请求。
ffffffffc02016b4:	6505                	lui	a0,0x1
ffffffffc02016b6:	f11ff0ef          	jal	ffffffffc02015c6 <slub_alloc.part.0>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02016ba:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc02016bc:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02016be:	671c                	ld	a5,8(a4)
ffffffffc02016c0:	00f70663          	beq	a4,a5,ffffffffc02016cc <slub_check+0x54>
ffffffffc02016c4:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc02016c6:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02016c8:	fef71ee3          	bne	a4,a5,ffffffffc02016c4 <slub_check+0x4c>
    void* p1 = slub_alloc(4096);
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc02016cc:	00001517          	auipc	a0,0x1
ffffffffc02016d0:	1d450513          	addi	a0,a0,468 # ffffffffc02028a0 <etext+0xbae>
ffffffffc02016d4:	9e7fe0ef          	jal	ffffffffc02000ba <cprintf>
		m = slob_alloc(size);
ffffffffc02016d8:	4509                	li	a0,2
ffffffffc02016da:	e3bff0ef          	jal	ffffffffc0201514 <slob_alloc>
ffffffffc02016de:	892a                	mv	s2,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc02016e0:	c119                	beqz	a0,ffffffffc02016e6 <slub_check+0x6e>
ffffffffc02016e2:	01050913          	addi	s2,a0,16
		m = slob_alloc(size);
ffffffffc02016e6:	4509                	li	a0,2
ffffffffc02016e8:	e2dff0ef          	jal	ffffffffc0201514 <slob_alloc>
ffffffffc02016ec:	84aa                	mv	s1,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc02016ee:	c119                	beqz	a0,ffffffffc02016f4 <slub_check+0x7c>
ffffffffc02016f0:	01050493          	addi	s1,a0,16
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02016f4:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc02016f6:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02016f8:	671c                	ld	a5,8(a4)
ffffffffc02016fa:	00f70663          	beq	a4,a5,ffffffffc0201706 <slub_check+0x8e>
ffffffffc02016fe:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc0201700:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201702:	fef71ee3          	bne	a4,a5,ffffffffc02016fe <slub_check+0x86>
    void* p2 = slub_alloc(2);
    void* p3 = slub_alloc(2);
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc0201706:	00001517          	auipc	a0,0x1
ffffffffc020170a:	19a50513          	addi	a0,a0,410 # ffffffffc02028a0 <etext+0xbae>
ffffffffc020170e:	9adfe0ef          	jal	ffffffffc02000ba <cprintf>
    slub_free(p2);
ffffffffc0201712:	854a                	mv	a0,s2
ffffffffc0201714:	f11ff0ef          	jal	ffffffffc0201624 <slub_free>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201718:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc020171a:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020171c:	671c                	ld	a5,8(a4)
ffffffffc020171e:	00f70663          	beq	a4,a5,ffffffffc020172a <slub_check+0xb2>
ffffffffc0201722:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc0201724:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201726:	fef71ee3          	bne	a4,a5,ffffffffc0201722 <slub_check+0xaa>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc020172a:	00001517          	auipc	a0,0x1
ffffffffc020172e:	17650513          	addi	a0,a0,374 # ffffffffc02028a0 <etext+0xbae>
ffffffffc0201732:	989fe0ef          	jal	ffffffffc02000ba <cprintf>
    slub_free(p3);
ffffffffc0201736:	8526                	mv	a0,s1
ffffffffc0201738:	eedff0ef          	jal	ffffffffc0201624 <slub_free>
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020173c:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc020173e:	4581                	li	a1,0
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201740:	671c                	ld	a5,8(a4)
ffffffffc0201742:	00e78663          	beq	a5,a4,ffffffffc020174e <slub_check+0xd6>
ffffffffc0201746:	679c                	ld	a5,8(a5)
        len ++;
ffffffffc0201748:	2585                	addiw	a1,a1,1
    for(slob_t* curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020174a:	fef71ee3          	bne	a4,a5,ffffffffc0201746 <slub_check+0xce>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc020174e:	00001517          	auipc	a0,0x1
ffffffffc0201752:	15250513          	addi	a0,a0,338 # ffffffffc02028a0 <etext+0xbae>
ffffffffc0201756:	965fe0ef          	jal	ffffffffc02000ba <cprintf>
    cprintf("slub check end\n");
}
ffffffffc020175a:	6442                	ld	s0,16(sp)
ffffffffc020175c:	60e2                	ld	ra,24(sp)
ffffffffc020175e:	64a2                	ld	s1,8(sp)
ffffffffc0201760:	6902                	ld	s2,0(sp)
    cprintf("slub check end\n");
ffffffffc0201762:	00001517          	auipc	a0,0x1
ffffffffc0201766:	15650513          	addi	a0,a0,342 # ffffffffc02028b8 <etext+0xbc6>
}
ffffffffc020176a:	6105                	addi	sp,sp,32
    cprintf("slub check end\n");
ffffffffc020176c:	94ffe06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0201770 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201770:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201774:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0201776:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020177a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc020177c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201780:	f022                	sd	s0,32(sp)
ffffffffc0201782:	ec26                	sd	s1,24(sp)
ffffffffc0201784:	e84a                	sd	s2,16(sp)
ffffffffc0201786:	f406                	sd	ra,40(sp)
ffffffffc0201788:	84aa                	mv	s1,a0
ffffffffc020178a:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020178c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201790:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0201792:	05067063          	bgeu	a2,a6,ffffffffc02017d2 <printnum+0x62>
ffffffffc0201796:	e44e                	sd	s3,8(sp)
ffffffffc0201798:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020179a:	4785                	li	a5,1
ffffffffc020179c:	00e7d763          	bge	a5,a4,ffffffffc02017aa <printnum+0x3a>
            putch(padc, putdat);
ffffffffc02017a0:	85ca                	mv	a1,s2
ffffffffc02017a2:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc02017a4:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02017a6:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02017a8:	fc65                	bnez	s0,ffffffffc02017a0 <printnum+0x30>
ffffffffc02017aa:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02017ac:	1a02                	slli	s4,s4,0x20
ffffffffc02017ae:	020a5a13          	srli	s4,s4,0x20
ffffffffc02017b2:	00001797          	auipc	a5,0x1
ffffffffc02017b6:	11678793          	addi	a5,a5,278 # ffffffffc02028c8 <etext+0xbd6>
ffffffffc02017ba:	97d2                	add	a5,a5,s4
}
ffffffffc02017bc:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02017be:	0007c503          	lbu	a0,0(a5)
}
ffffffffc02017c2:	70a2                	ld	ra,40(sp)
ffffffffc02017c4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02017c6:	85ca                	mv	a1,s2
ffffffffc02017c8:	87a6                	mv	a5,s1
}
ffffffffc02017ca:	6942                	ld	s2,16(sp)
ffffffffc02017cc:	64e2                	ld	s1,24(sp)
ffffffffc02017ce:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02017d0:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02017d2:	03065633          	divu	a2,a2,a6
ffffffffc02017d6:	8722                	mv	a4,s0
ffffffffc02017d8:	f99ff0ef          	jal	ffffffffc0201770 <printnum>
ffffffffc02017dc:	bfc1                	j	ffffffffc02017ac <printnum+0x3c>

ffffffffc02017de <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02017de:	7119                	addi	sp,sp,-128
ffffffffc02017e0:	f4a6                	sd	s1,104(sp)
ffffffffc02017e2:	f0ca                	sd	s2,96(sp)
ffffffffc02017e4:	ecce                	sd	s3,88(sp)
ffffffffc02017e6:	e8d2                	sd	s4,80(sp)
ffffffffc02017e8:	e4d6                	sd	s5,72(sp)
ffffffffc02017ea:	e0da                	sd	s6,64(sp)
ffffffffc02017ec:	f862                	sd	s8,48(sp)
ffffffffc02017ee:	fc86                	sd	ra,120(sp)
ffffffffc02017f0:	f8a2                	sd	s0,112(sp)
ffffffffc02017f2:	fc5e                	sd	s7,56(sp)
ffffffffc02017f4:	f466                	sd	s9,40(sp)
ffffffffc02017f6:	f06a                	sd	s10,32(sp)
ffffffffc02017f8:	ec6e                	sd	s11,24(sp)
ffffffffc02017fa:	892a                	mv	s2,a0
ffffffffc02017fc:	84ae                	mv	s1,a1
ffffffffc02017fe:	8c32                	mv	s8,a2
ffffffffc0201800:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201802:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201806:	05500b13          	li	s6,85
ffffffffc020180a:	00001a97          	auipc	s5,0x1
ffffffffc020180e:	226a8a93          	addi	s5,s5,550 # ffffffffc0202a30 <best_fit_pmm_manager+0x38>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201812:	000c4503          	lbu	a0,0(s8)
ffffffffc0201816:	001c0413          	addi	s0,s8,1
ffffffffc020181a:	01350a63          	beq	a0,s3,ffffffffc020182e <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc020181e:	cd0d                	beqz	a0,ffffffffc0201858 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0201820:	85a6                	mv	a1,s1
ffffffffc0201822:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201824:	00044503          	lbu	a0,0(s0)
ffffffffc0201828:	0405                	addi	s0,s0,1
ffffffffc020182a:	ff351ae3          	bne	a0,s3,ffffffffc020181e <vprintfmt+0x40>
        char padc = ' ';
ffffffffc020182e:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0201832:	4b81                	li	s7,0
ffffffffc0201834:	4601                	li	a2,0
        width = precision = -1;
ffffffffc0201836:	5d7d                	li	s10,-1
ffffffffc0201838:	5cfd                	li	s9,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020183a:	00044683          	lbu	a3,0(s0)
ffffffffc020183e:	00140c13          	addi	s8,s0,1
ffffffffc0201842:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0201846:	0ff5f593          	zext.b	a1,a1
ffffffffc020184a:	02bb6663          	bltu	s6,a1,ffffffffc0201876 <vprintfmt+0x98>
ffffffffc020184e:	058a                	slli	a1,a1,0x2
ffffffffc0201850:	95d6                	add	a1,a1,s5
ffffffffc0201852:	4198                	lw	a4,0(a1)
ffffffffc0201854:	9756                	add	a4,a4,s5
ffffffffc0201856:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201858:	70e6                	ld	ra,120(sp)
ffffffffc020185a:	7446                	ld	s0,112(sp)
ffffffffc020185c:	74a6                	ld	s1,104(sp)
ffffffffc020185e:	7906                	ld	s2,96(sp)
ffffffffc0201860:	69e6                	ld	s3,88(sp)
ffffffffc0201862:	6a46                	ld	s4,80(sp)
ffffffffc0201864:	6aa6                	ld	s5,72(sp)
ffffffffc0201866:	6b06                	ld	s6,64(sp)
ffffffffc0201868:	7be2                	ld	s7,56(sp)
ffffffffc020186a:	7c42                	ld	s8,48(sp)
ffffffffc020186c:	7ca2                	ld	s9,40(sp)
ffffffffc020186e:	7d02                	ld	s10,32(sp)
ffffffffc0201870:	6de2                	ld	s11,24(sp)
ffffffffc0201872:	6109                	addi	sp,sp,128
ffffffffc0201874:	8082                	ret
            putch('%', putdat);
ffffffffc0201876:	85a6                	mv	a1,s1
ffffffffc0201878:	02500513          	li	a0,37
ffffffffc020187c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020187e:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201882:	02500793          	li	a5,37
ffffffffc0201886:	8c22                	mv	s8,s0
ffffffffc0201888:	f8f705e3          	beq	a4,a5,ffffffffc0201812 <vprintfmt+0x34>
ffffffffc020188c:	02500713          	li	a4,37
ffffffffc0201890:	ffec4783          	lbu	a5,-2(s8)
ffffffffc0201894:	1c7d                	addi	s8,s8,-1
ffffffffc0201896:	fee79de3          	bne	a5,a4,ffffffffc0201890 <vprintfmt+0xb2>
ffffffffc020189a:	bfa5                	j	ffffffffc0201812 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc020189c:	00144783          	lbu	a5,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc02018a0:	4725                	li	a4,9
                precision = precision * 10 + ch - '0';
ffffffffc02018a2:	fd068d1b          	addiw	s10,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc02018a6:	fd07859b          	addiw	a1,a5,-48
                ch = *fmt;
ffffffffc02018aa:	0007869b          	sext.w	a3,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018ae:	8462                	mv	s0,s8
                if (ch < '0' || ch > '9') {
ffffffffc02018b0:	02b76563          	bltu	a4,a1,ffffffffc02018da <vprintfmt+0xfc>
ffffffffc02018b4:	4525                	li	a0,9
                ch = *fmt;
ffffffffc02018b6:	00144783          	lbu	a5,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02018ba:	002d171b          	slliw	a4,s10,0x2
ffffffffc02018be:	01a7073b          	addw	a4,a4,s10
ffffffffc02018c2:	0017171b          	slliw	a4,a4,0x1
ffffffffc02018c6:	9f35                	addw	a4,a4,a3
                if (ch < '0' || ch > '9') {
ffffffffc02018c8:	fd07859b          	addiw	a1,a5,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02018cc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02018ce:	fd070d1b          	addiw	s10,a4,-48
                ch = *fmt;
ffffffffc02018d2:	0007869b          	sext.w	a3,a5
                if (ch < '0' || ch > '9') {
ffffffffc02018d6:	feb570e3          	bgeu	a0,a1,ffffffffc02018b6 <vprintfmt+0xd8>
            if (width < 0)
ffffffffc02018da:	f60cd0e3          	bgez	s9,ffffffffc020183a <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc02018de:	8cea                	mv	s9,s10
ffffffffc02018e0:	5d7d                	li	s10,-1
ffffffffc02018e2:	bfa1                	j	ffffffffc020183a <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02018e4:	8db6                	mv	s11,a3
ffffffffc02018e6:	8462                	mv	s0,s8
ffffffffc02018e8:	bf89                	j	ffffffffc020183a <vprintfmt+0x5c>
ffffffffc02018ea:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc02018ec:	4b85                	li	s7,1
            goto reswitch;
ffffffffc02018ee:	b7b1                	j	ffffffffc020183a <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc02018f0:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc02018f2:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc02018f6:	00c7c463          	blt	a5,a2,ffffffffc02018fe <vprintfmt+0x120>
    else if (lflag) {
ffffffffc02018fa:	1a060163          	beqz	a2,ffffffffc0201a9c <vprintfmt+0x2be>
        return va_arg(*ap, unsigned long);
ffffffffc02018fe:	000a3603          	ld	a2,0(s4)
ffffffffc0201902:	46c1                	li	a3,16
ffffffffc0201904:	8a3a                	mv	s4,a4
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201906:	000d879b          	sext.w	a5,s11
ffffffffc020190a:	8766                	mv	a4,s9
ffffffffc020190c:	85a6                	mv	a1,s1
ffffffffc020190e:	854a                	mv	a0,s2
ffffffffc0201910:	e61ff0ef          	jal	ffffffffc0201770 <printnum>
            break;
ffffffffc0201914:	bdfd                	j	ffffffffc0201812 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc0201916:	000a2503          	lw	a0,0(s4)
ffffffffc020191a:	85a6                	mv	a1,s1
ffffffffc020191c:	0a21                	addi	s4,s4,8
ffffffffc020191e:	9902                	jalr	s2
            break;
ffffffffc0201920:	bdcd                	j	ffffffffc0201812 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0201922:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0201924:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc0201928:	00c7c463          	blt	a5,a2,ffffffffc0201930 <vprintfmt+0x152>
    else if (lflag) {
ffffffffc020192c:	16060363          	beqz	a2,ffffffffc0201a92 <vprintfmt+0x2b4>
        return va_arg(*ap, unsigned long);
ffffffffc0201930:	000a3603          	ld	a2,0(s4)
ffffffffc0201934:	46a9                	li	a3,10
ffffffffc0201936:	8a3a                	mv	s4,a4
ffffffffc0201938:	b7f9                	j	ffffffffc0201906 <vprintfmt+0x128>
            putch('0', putdat);
ffffffffc020193a:	85a6                	mv	a1,s1
ffffffffc020193c:	03000513          	li	a0,48
ffffffffc0201940:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201942:	85a6                	mv	a1,s1
ffffffffc0201944:	07800513          	li	a0,120
ffffffffc0201948:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020194a:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc020194e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201950:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201952:	bf55                	j	ffffffffc0201906 <vprintfmt+0x128>
            putch(ch, putdat);
ffffffffc0201954:	85a6                	mv	a1,s1
ffffffffc0201956:	02500513          	li	a0,37
ffffffffc020195a:	9902                	jalr	s2
            break;
ffffffffc020195c:	bd5d                	j	ffffffffc0201812 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc020195e:	000a2d03          	lw	s10,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201962:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc0201964:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc0201966:	bf95                	j	ffffffffc02018da <vprintfmt+0xfc>
    if (lflag >= 2) {
ffffffffc0201968:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc020196a:	008a0713          	addi	a4,s4,8
    if (lflag >= 2) {
ffffffffc020196e:	00c7c463          	blt	a5,a2,ffffffffc0201976 <vprintfmt+0x198>
    else if (lflag) {
ffffffffc0201972:	10060b63          	beqz	a2,ffffffffc0201a88 <vprintfmt+0x2aa>
        return va_arg(*ap, unsigned long);
ffffffffc0201976:	000a3603          	ld	a2,0(s4)
ffffffffc020197a:	46a1                	li	a3,8
ffffffffc020197c:	8a3a                	mv	s4,a4
ffffffffc020197e:	b761                	j	ffffffffc0201906 <vprintfmt+0x128>
            if (width < 0)
ffffffffc0201980:	fffcc793          	not	a5,s9
ffffffffc0201984:	97fd                	srai	a5,a5,0x3f
ffffffffc0201986:	00fcf7b3          	and	a5,s9,a5
ffffffffc020198a:	00078c9b          	sext.w	s9,a5
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020198e:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0201990:	b56d                	j	ffffffffc020183a <vprintfmt+0x5c>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201992:	000a3403          	ld	s0,0(s4)
ffffffffc0201996:	008a0793          	addi	a5,s4,8
ffffffffc020199a:	e43e                	sd	a5,8(sp)
ffffffffc020199c:	12040063          	beqz	s0,ffffffffc0201abc <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc02019a0:	0d905963          	blez	s9,ffffffffc0201a72 <vprintfmt+0x294>
ffffffffc02019a4:	02d00793          	li	a5,45
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019a8:	00140a13          	addi	s4,s0,1
            if (width > 0 && padc != '-') {
ffffffffc02019ac:	12fd9763          	bne	s11,a5,ffffffffc0201ada <vprintfmt+0x2fc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019b0:	00044783          	lbu	a5,0(s0)
ffffffffc02019b4:	0007851b          	sext.w	a0,a5
ffffffffc02019b8:	cb9d                	beqz	a5,ffffffffc02019ee <vprintfmt+0x210>
ffffffffc02019ba:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02019bc:	05e00d93          	li	s11,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019c0:	000d4563          	bltz	s10,ffffffffc02019ca <vprintfmt+0x1ec>
ffffffffc02019c4:	3d7d                	addiw	s10,s10,-1
ffffffffc02019c6:	028d0263          	beq	s10,s0,ffffffffc02019ea <vprintfmt+0x20c>
                    putch('?', putdat);
ffffffffc02019ca:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02019cc:	0c0b8d63          	beqz	s7,ffffffffc0201aa6 <vprintfmt+0x2c8>
ffffffffc02019d0:	3781                	addiw	a5,a5,-32
ffffffffc02019d2:	0cfdfa63          	bgeu	s11,a5,ffffffffc0201aa6 <vprintfmt+0x2c8>
                    putch('?', putdat);
ffffffffc02019d6:	03f00513          	li	a0,63
ffffffffc02019da:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02019dc:	000a4783          	lbu	a5,0(s4)
ffffffffc02019e0:	3cfd                	addiw	s9,s9,-1
ffffffffc02019e2:	0a05                	addi	s4,s4,1
ffffffffc02019e4:	0007851b          	sext.w	a0,a5
ffffffffc02019e8:	ffe1                	bnez	a5,ffffffffc02019c0 <vprintfmt+0x1e2>
            for (; width > 0; width --) {
ffffffffc02019ea:	01905963          	blez	s9,ffffffffc02019fc <vprintfmt+0x21e>
                putch(' ', putdat);
ffffffffc02019ee:	85a6                	mv	a1,s1
ffffffffc02019f0:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc02019f4:	3cfd                	addiw	s9,s9,-1
                putch(' ', putdat);
ffffffffc02019f6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc02019f8:	fe0c9be3          	bnez	s9,ffffffffc02019ee <vprintfmt+0x210>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02019fc:	6a22                	ld	s4,8(sp)
ffffffffc02019fe:	bd11                	j	ffffffffc0201812 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0201a00:	4785                	li	a5,1
            precision = va_arg(ap, int);
ffffffffc0201a02:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc0201a06:	00c7c363          	blt	a5,a2,ffffffffc0201a0c <vprintfmt+0x22e>
    else if (lflag) {
ffffffffc0201a0a:	ce25                	beqz	a2,ffffffffc0201a82 <vprintfmt+0x2a4>
        return va_arg(*ap, long);
ffffffffc0201a0c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201a10:	08044d63          	bltz	s0,ffffffffc0201aaa <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc0201a14:	8622                	mv	a2,s0
ffffffffc0201a16:	8a5e                	mv	s4,s7
ffffffffc0201a18:	46a9                	li	a3,10
ffffffffc0201a1a:	b5f5                	j	ffffffffc0201906 <vprintfmt+0x128>
            if (err < 0) {
ffffffffc0201a1c:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201a20:	4619                	li	a2,6
            if (err < 0) {
ffffffffc0201a22:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0201a26:	8fb9                	xor	a5,a5,a4
ffffffffc0201a28:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201a2c:	02d64663          	blt	a2,a3,ffffffffc0201a58 <vprintfmt+0x27a>
ffffffffc0201a30:	00369713          	slli	a4,a3,0x3
ffffffffc0201a34:	00001797          	auipc	a5,0x1
ffffffffc0201a38:	15478793          	addi	a5,a5,340 # ffffffffc0202b88 <error_string>
ffffffffc0201a3c:	97ba                	add	a5,a5,a4
ffffffffc0201a3e:	639c                	ld	a5,0(a5)
ffffffffc0201a40:	cf81                	beqz	a5,ffffffffc0201a58 <vprintfmt+0x27a>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201a42:	86be                	mv	a3,a5
ffffffffc0201a44:	00001617          	auipc	a2,0x1
ffffffffc0201a48:	eb460613          	addi	a2,a2,-332 # ffffffffc02028f8 <etext+0xc06>
ffffffffc0201a4c:	85a6                	mv	a1,s1
ffffffffc0201a4e:	854a                	mv	a0,s2
ffffffffc0201a50:	0e8000ef          	jal	ffffffffc0201b38 <printfmt>
            err = va_arg(ap, int);
ffffffffc0201a54:	0a21                	addi	s4,s4,8
ffffffffc0201a56:	bb75                	j	ffffffffc0201812 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201a58:	00001617          	auipc	a2,0x1
ffffffffc0201a5c:	e9060613          	addi	a2,a2,-368 # ffffffffc02028e8 <etext+0xbf6>
ffffffffc0201a60:	85a6                	mv	a1,s1
ffffffffc0201a62:	854a                	mv	a0,s2
ffffffffc0201a64:	0d4000ef          	jal	ffffffffc0201b38 <printfmt>
            err = va_arg(ap, int);
ffffffffc0201a68:	0a21                	addi	s4,s4,8
ffffffffc0201a6a:	b365                	j	ffffffffc0201812 <vprintfmt+0x34>
            lflag ++;
ffffffffc0201a6c:	2605                	addiw	a2,a2,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201a6e:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0201a70:	b3e9                	j	ffffffffc020183a <vprintfmt+0x5c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201a72:	00044783          	lbu	a5,0(s0)
ffffffffc0201a76:	0007851b          	sext.w	a0,a5
ffffffffc0201a7a:	d3c9                	beqz	a5,ffffffffc02019fc <vprintfmt+0x21e>
ffffffffc0201a7c:	00140a13          	addi	s4,s0,1
ffffffffc0201a80:	bf2d                	j	ffffffffc02019ba <vprintfmt+0x1dc>
        return va_arg(*ap, int);
ffffffffc0201a82:	000a2403          	lw	s0,0(s4)
ffffffffc0201a86:	b769                	j	ffffffffc0201a10 <vprintfmt+0x232>
        return va_arg(*ap, unsigned int);
ffffffffc0201a88:	000a6603          	lwu	a2,0(s4)
ffffffffc0201a8c:	46a1                	li	a3,8
ffffffffc0201a8e:	8a3a                	mv	s4,a4
ffffffffc0201a90:	bd9d                	j	ffffffffc0201906 <vprintfmt+0x128>
ffffffffc0201a92:	000a6603          	lwu	a2,0(s4)
ffffffffc0201a96:	46a9                	li	a3,10
ffffffffc0201a98:	8a3a                	mv	s4,a4
ffffffffc0201a9a:	b5b5                	j	ffffffffc0201906 <vprintfmt+0x128>
ffffffffc0201a9c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201aa0:	46c1                	li	a3,16
ffffffffc0201aa2:	8a3a                	mv	s4,a4
ffffffffc0201aa4:	b58d                	j	ffffffffc0201906 <vprintfmt+0x128>
                    putch(ch, putdat);
ffffffffc0201aa6:	9902                	jalr	s2
ffffffffc0201aa8:	bf15                	j	ffffffffc02019dc <vprintfmt+0x1fe>
                putch('-', putdat);
ffffffffc0201aaa:	85a6                	mv	a1,s1
ffffffffc0201aac:	02d00513          	li	a0,45
ffffffffc0201ab0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201ab2:	40800633          	neg	a2,s0
ffffffffc0201ab6:	8a5e                	mv	s4,s7
ffffffffc0201ab8:	46a9                	li	a3,10
ffffffffc0201aba:	b5b1                	j	ffffffffc0201906 <vprintfmt+0x128>
            if (width > 0 && padc != '-') {
ffffffffc0201abc:	01905663          	blez	s9,ffffffffc0201ac8 <vprintfmt+0x2ea>
ffffffffc0201ac0:	02d00793          	li	a5,45
ffffffffc0201ac4:	04fd9263          	bne	s11,a5,ffffffffc0201b08 <vprintfmt+0x32a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201ac8:	02800793          	li	a5,40
ffffffffc0201acc:	00001a17          	auipc	s4,0x1
ffffffffc0201ad0:	e15a0a13          	addi	s4,s4,-491 # ffffffffc02028e1 <etext+0xbef>
ffffffffc0201ad4:	02800513          	li	a0,40
ffffffffc0201ad8:	b5cd                	j	ffffffffc02019ba <vprintfmt+0x1dc>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201ada:	85ea                	mv	a1,s10
ffffffffc0201adc:	8522                	mv	a0,s0
ffffffffc0201ade:	198000ef          	jal	ffffffffc0201c76 <strnlen>
ffffffffc0201ae2:	40ac8cbb          	subw	s9,s9,a0
ffffffffc0201ae6:	01905963          	blez	s9,ffffffffc0201af8 <vprintfmt+0x31a>
                    putch(padc, putdat);
ffffffffc0201aea:	2d81                	sext.w	s11,s11
ffffffffc0201aec:	85a6                	mv	a1,s1
ffffffffc0201aee:	856e                	mv	a0,s11
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201af0:	3cfd                	addiw	s9,s9,-1
                    putch(padc, putdat);
ffffffffc0201af2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201af4:	fe0c9ce3          	bnez	s9,ffffffffc0201aec <vprintfmt+0x30e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201af8:	00044783          	lbu	a5,0(s0)
ffffffffc0201afc:	0007851b          	sext.w	a0,a5
ffffffffc0201b00:	ea079de3          	bnez	a5,ffffffffc02019ba <vprintfmt+0x1dc>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201b04:	6a22                	ld	s4,8(sp)
ffffffffc0201b06:	b331                	j	ffffffffc0201812 <vprintfmt+0x34>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b08:	85ea                	mv	a1,s10
ffffffffc0201b0a:	00001517          	auipc	a0,0x1
ffffffffc0201b0e:	dd650513          	addi	a0,a0,-554 # ffffffffc02028e0 <etext+0xbee>
ffffffffc0201b12:	164000ef          	jal	ffffffffc0201c76 <strnlen>
ffffffffc0201b16:	40ac8cbb          	subw	s9,s9,a0
                p = "(null)";
ffffffffc0201b1a:	00001417          	auipc	s0,0x1
ffffffffc0201b1e:	dc640413          	addi	s0,s0,-570 # ffffffffc02028e0 <etext+0xbee>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201b22:	00001a17          	auipc	s4,0x1
ffffffffc0201b26:	dbfa0a13          	addi	s4,s4,-577 # ffffffffc02028e1 <etext+0xbef>
ffffffffc0201b2a:	02800793          	li	a5,40
ffffffffc0201b2e:	02800513          	li	a0,40
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201b32:	fb904ce3          	bgtz	s9,ffffffffc0201aea <vprintfmt+0x30c>
ffffffffc0201b36:	b551                	j	ffffffffc02019ba <vprintfmt+0x1dc>

ffffffffc0201b38 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201b38:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201b3a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201b3e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201b40:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201b42:	ec06                	sd	ra,24(sp)
ffffffffc0201b44:	f83a                	sd	a4,48(sp)
ffffffffc0201b46:	fc3e                	sd	a5,56(sp)
ffffffffc0201b48:	e0c2                	sd	a6,64(sp)
ffffffffc0201b4a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201b4c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201b4e:	c91ff0ef          	jal	ffffffffc02017de <vprintfmt>
}
ffffffffc0201b52:	60e2                	ld	ra,24(sp)
ffffffffc0201b54:	6161                	addi	sp,sp,80
ffffffffc0201b56:	8082                	ret

ffffffffc0201b58 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201b58:	715d                	addi	sp,sp,-80
ffffffffc0201b5a:	e486                	sd	ra,72(sp)
ffffffffc0201b5c:	e0a2                	sd	s0,64(sp)
ffffffffc0201b5e:	fc26                	sd	s1,56(sp)
ffffffffc0201b60:	f84a                	sd	s2,48(sp)
ffffffffc0201b62:	f44e                	sd	s3,40(sp)
ffffffffc0201b64:	f052                	sd	s4,32(sp)
ffffffffc0201b66:	ec56                	sd	s5,24(sp)
ffffffffc0201b68:	e85a                	sd	s6,16(sp)
    if (prompt != NULL) {
ffffffffc0201b6a:	c901                	beqz	a0,ffffffffc0201b7a <readline+0x22>
ffffffffc0201b6c:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201b6e:	00001517          	auipc	a0,0x1
ffffffffc0201b72:	d8a50513          	addi	a0,a0,-630 # ffffffffc02028f8 <etext+0xc06>
ffffffffc0201b76:	d44fe0ef          	jal	ffffffffc02000ba <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc0201b7a:	4401                	li	s0,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201b7c:	44fd                	li	s1,31
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201b7e:	4921                	li	s2,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201b80:	4a29                	li	s4,10
ffffffffc0201b82:	4ab5                	li	s5,13
            buf[i ++] = c;
ffffffffc0201b84:	00004b17          	auipc	s6,0x4
ffffffffc0201b88:	4c4b0b13          	addi	s6,s6,1220 # ffffffffc0206048 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201b8c:	3fe00993          	li	s3,1022
        c = getchar();
ffffffffc0201b90:	daefe0ef          	jal	ffffffffc020013e <getchar>
        if (c < 0) {
ffffffffc0201b94:	00054a63          	bltz	a0,ffffffffc0201ba8 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201b98:	00a4da63          	bge	s1,a0,ffffffffc0201bac <readline+0x54>
ffffffffc0201b9c:	0289d263          	bge	s3,s0,ffffffffc0201bc0 <readline+0x68>
        c = getchar();
ffffffffc0201ba0:	d9efe0ef          	jal	ffffffffc020013e <getchar>
        if (c < 0) {
ffffffffc0201ba4:	fe055ae3          	bgez	a0,ffffffffc0201b98 <readline+0x40>
            return NULL;
ffffffffc0201ba8:	4501                	li	a0,0
ffffffffc0201baa:	a091                	j	ffffffffc0201bee <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201bac:	03251463          	bne	a0,s2,ffffffffc0201bd4 <readline+0x7c>
ffffffffc0201bb0:	04804963          	bgtz	s0,ffffffffc0201c02 <readline+0xaa>
        c = getchar();
ffffffffc0201bb4:	d8afe0ef          	jal	ffffffffc020013e <getchar>
        if (c < 0) {
ffffffffc0201bb8:	fe0548e3          	bltz	a0,ffffffffc0201ba8 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201bbc:	fea4d8e3          	bge	s1,a0,ffffffffc0201bac <readline+0x54>
            cputchar(c);
ffffffffc0201bc0:	e42a                	sd	a0,8(sp)
ffffffffc0201bc2:	d2cfe0ef          	jal	ffffffffc02000ee <cputchar>
            buf[i ++] = c;
ffffffffc0201bc6:	6522                	ld	a0,8(sp)
ffffffffc0201bc8:	008b07b3          	add	a5,s6,s0
ffffffffc0201bcc:	2405                	addiw	s0,s0,1
ffffffffc0201bce:	00a78023          	sb	a0,0(a5)
ffffffffc0201bd2:	bf7d                	j	ffffffffc0201b90 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0201bd4:	01450463          	beq	a0,s4,ffffffffc0201bdc <readline+0x84>
ffffffffc0201bd8:	fb551ce3          	bne	a0,s5,ffffffffc0201b90 <readline+0x38>
            cputchar(c);
ffffffffc0201bdc:	d12fe0ef          	jal	ffffffffc02000ee <cputchar>
            buf[i] = '\0';
ffffffffc0201be0:	00004517          	auipc	a0,0x4
ffffffffc0201be4:	46850513          	addi	a0,a0,1128 # ffffffffc0206048 <buf>
ffffffffc0201be8:	942a                	add	s0,s0,a0
ffffffffc0201bea:	00040023          	sb	zero,0(s0)
            return buf;
        }
    }
}
ffffffffc0201bee:	60a6                	ld	ra,72(sp)
ffffffffc0201bf0:	6406                	ld	s0,64(sp)
ffffffffc0201bf2:	74e2                	ld	s1,56(sp)
ffffffffc0201bf4:	7942                	ld	s2,48(sp)
ffffffffc0201bf6:	79a2                	ld	s3,40(sp)
ffffffffc0201bf8:	7a02                	ld	s4,32(sp)
ffffffffc0201bfa:	6ae2                	ld	s5,24(sp)
ffffffffc0201bfc:	6b42                	ld	s6,16(sp)
ffffffffc0201bfe:	6161                	addi	sp,sp,80
ffffffffc0201c00:	8082                	ret
            cputchar(c);
ffffffffc0201c02:	4521                	li	a0,8
ffffffffc0201c04:	ceafe0ef          	jal	ffffffffc02000ee <cputchar>
            i --;
ffffffffc0201c08:	347d                	addiw	s0,s0,-1
ffffffffc0201c0a:	b759                	j	ffffffffc0201b90 <readline+0x38>

ffffffffc0201c0c <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201c0c:	4781                	li	a5,0
ffffffffc0201c0e:	00004717          	auipc	a4,0x4
ffffffffc0201c12:	41a73703          	ld	a4,1050(a4) # ffffffffc0206028 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201c16:	88ba                	mv	a7,a4
ffffffffc0201c18:	852a                	mv	a0,a0
ffffffffc0201c1a:	85be                	mv	a1,a5
ffffffffc0201c1c:	863e                	mv	a2,a5
ffffffffc0201c1e:	00000073          	ecall
ffffffffc0201c22:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201c24:	8082                	ret

ffffffffc0201c26 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201c26:	4781                	li	a5,0
ffffffffc0201c28:	00005717          	auipc	a4,0x5
ffffffffc0201c2c:	87073703          	ld	a4,-1936(a4) # ffffffffc0206498 <SBI_SET_TIMER>
ffffffffc0201c30:	88ba                	mv	a7,a4
ffffffffc0201c32:	852a                	mv	a0,a0
ffffffffc0201c34:	85be                	mv	a1,a5
ffffffffc0201c36:	863e                	mv	a2,a5
ffffffffc0201c38:	00000073          	ecall
ffffffffc0201c3c:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201c3e:	8082                	ret

ffffffffc0201c40 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201c40:	4501                	li	a0,0
ffffffffc0201c42:	00004797          	auipc	a5,0x4
ffffffffc0201c46:	3de7b783          	ld	a5,990(a5) # ffffffffc0206020 <SBI_CONSOLE_GETCHAR>
ffffffffc0201c4a:	88be                	mv	a7,a5
ffffffffc0201c4c:	852a                	mv	a0,a0
ffffffffc0201c4e:	85aa                	mv	a1,a0
ffffffffc0201c50:	862a                	mv	a2,a0
ffffffffc0201c52:	00000073          	ecall
ffffffffc0201c56:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201c58:	2501                	sext.w	a0,a0
ffffffffc0201c5a:	8082                	ret

ffffffffc0201c5c <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201c5c:	4781                	li	a5,0
ffffffffc0201c5e:	00004717          	auipc	a4,0x4
ffffffffc0201c62:	3ba73703          	ld	a4,954(a4) # ffffffffc0206018 <SBI_SHUTDOWN>
ffffffffc0201c66:	88ba                	mv	a7,a4
ffffffffc0201c68:	853e                	mv	a0,a5
ffffffffc0201c6a:	85be                	mv	a1,a5
ffffffffc0201c6c:	863e                	mv	a2,a5
ffffffffc0201c6e:	00000073          	ecall
ffffffffc0201c72:	87aa                	mv	a5,a0
void sbi_shutdown(void)
{
  //  __asm__ volatile(".word 0xFFFFFFFF");  // 触发非法指令异常
   //__asm__ volatile("ebreak");  // 触发断点异常
    sbi_call(SBI_SHUTDOWN,0,0,0);
ffffffffc0201c74:	8082                	ret

ffffffffc0201c76 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201c76:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201c78:	e589                	bnez	a1,ffffffffc0201c82 <strnlen+0xc>
ffffffffc0201c7a:	a811                	j	ffffffffc0201c8e <strnlen+0x18>
        cnt ++;
ffffffffc0201c7c:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201c7e:	00f58863          	beq	a1,a5,ffffffffc0201c8e <strnlen+0x18>
ffffffffc0201c82:	00f50733          	add	a4,a0,a5
ffffffffc0201c86:	00074703          	lbu	a4,0(a4)
ffffffffc0201c8a:	fb6d                	bnez	a4,ffffffffc0201c7c <strnlen+0x6>
ffffffffc0201c8c:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201c8e:	852e                	mv	a0,a1
ffffffffc0201c90:	8082                	ret

ffffffffc0201c92 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201c92:	00054783          	lbu	a5,0(a0)
ffffffffc0201c96:	e791                	bnez	a5,ffffffffc0201ca2 <strcmp+0x10>
ffffffffc0201c98:	a02d                	j	ffffffffc0201cc2 <strcmp+0x30>
ffffffffc0201c9a:	00054783          	lbu	a5,0(a0)
ffffffffc0201c9e:	cf89                	beqz	a5,ffffffffc0201cb8 <strcmp+0x26>
ffffffffc0201ca0:	85b6                	mv	a1,a3
ffffffffc0201ca2:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc0201ca6:	0505                	addi	a0,a0,1
ffffffffc0201ca8:	00158693          	addi	a3,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201cac:	fef707e3          	beq	a4,a5,ffffffffc0201c9a <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201cb0:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201cb4:	9d19                	subw	a0,a0,a4
ffffffffc0201cb6:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201cb8:	0015c703          	lbu	a4,1(a1)
ffffffffc0201cbc:	4501                	li	a0,0
}
ffffffffc0201cbe:	9d19                	subw	a0,a0,a4
ffffffffc0201cc0:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201cc2:	0005c703          	lbu	a4,0(a1)
ffffffffc0201cc6:	4501                	li	a0,0
ffffffffc0201cc8:	b7f5                	j	ffffffffc0201cb4 <strcmp+0x22>

ffffffffc0201cca <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201cca:	00054783          	lbu	a5,0(a0)
ffffffffc0201cce:	c799                	beqz	a5,ffffffffc0201cdc <strchr+0x12>
        if (*s == c) {
ffffffffc0201cd0:	00f58763          	beq	a1,a5,ffffffffc0201cde <strchr+0x14>
    while (*s != '\0') {
ffffffffc0201cd4:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc0201cd8:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201cda:	fbfd                	bnez	a5,ffffffffc0201cd0 <strchr+0x6>
    }
    return NULL;
ffffffffc0201cdc:	4501                	li	a0,0
}
ffffffffc0201cde:	8082                	ret

ffffffffc0201ce0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201ce0:	ca01                	beqz	a2,ffffffffc0201cf0 <memset+0x10>
ffffffffc0201ce2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201ce4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201ce6:	0785                	addi	a5,a5,1
ffffffffc0201ce8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201cec:	fef61de3          	bne	a2,a5,ffffffffc0201ce6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201cf0:	8082                	ret
