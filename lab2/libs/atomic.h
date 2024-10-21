#ifndef __LIBS_ATOMIC_H__
#define __LIBS_ATOMIC_H__

/* Atomic operations that C can't guarantee us. Useful for resource counting
 * etc.. */

static inline void set_bit(int nr, volatile void *addr)
    __attribute__((always_inline));
static inline void clear_bit(int nr, volatile void *addr)
    __attribute__((always_inline));
static inline void change_bit(int nr, volatile void *addr)
    __attribute__((always_inline));
static inline bool test_bit(int nr, volatile void *addr)
    __attribute__((always_inline));
static inline bool test_and_set_bit(int nr, volatile void *addr)
    __attribute__((always_inline));
static inline bool test_and_clear_bit(int nr, volatile void *addr)
    __attribute__((always_inline));

#define BITS_PER_LONG __riscv_xlen
//__riscv_xlen 是 RISC-V 架构的位宽，取决于处理器配置。BITS_PER_LONG 表示在该平台上 unsigned long 的位宽
//__AMO(op) 宏用于根据位宽生成原子操作的汇编指令（amo 是 RISC-V 的原子内存操作）。如果是 64 位，则操作会生成以 .d 结尾的指令，表示操作 64 位的数据；如果是 32 位，则操作会生成以 .w 结尾的指令，表示操作 32 位的数据。
#if (BITS_PER_LONG == 64)
#define __AMO(op) "amo" #op ".d"
#elif (BITS_PER_LONG == 32)
#define __AMO(op) "amo" #op ".w"
#else
#error "Unexpected BITS_PER_LONG"
#endif
//BIT_MASK(nr)：生成一个掩码，用于获取位 nr。它通过移位操作生成一个 1，掩码的位置是 nr % BITS_PER_LONG，即该位在一个 unsigned long 中的相对位置。
//BIT_WORD(nr)：计算位 nr 所在的 unsigned long 数组中的索引。
#define BIT_MASK(nr) (1UL << ((nr) % BITS_PER_LONG))
#define BIT_WORD(nr) ((nr) / BITS_PER_LONG)
/*
这是一个原子测试并修改位的宏：
nr：要操作的位。
addr：内存地址。
它使用 RISC-V 的 amo 指令（通过 __AMO(op) 宏生成），操作 addr 数组中的 nr 位。
返回修改前该位的值。
*/
#define __test_and_op_bit(op, mod, nr, addr)                         \
    ({                                                               \
        unsigned long __res, __mask;                                 \
        __mask = BIT_MASK(nr);                                       \
        __asm__ __volatile__(__AMO(op) " %0, %2, %1"                 \
                             : "=r"(__res), "+A"(addr[BIT_WORD(nr)]) \
                             : "r"(mod(__mask)));                    \
        ((__res & __mask) != 0);                                     \
    })
/*
这是另一个原子操作宏，直接修改指定位：
op：操作类型（如 or, and, xor）。
mod：掩码修改操作（NOP 或 NOT）。
不返回值，直接修改内存中该位。
*/
#define __op_bit(op, mod, nr, addr)                 \
    __asm__ __volatile__(__AMO(op) " zero, %1, %0"  \
                         : "+A"(addr[BIT_WORD(nr)]) \
                         : "r"(mod(BIT_MASK(nr))))

/* Bitmask modifiers */
#define __NOP(x) (x)
#define __NOT(x) (~(x))

/* *
 * set_bit - Atomically set a bit in memory
 * @nr:     the bit to set
 * @addr:   the address to start counting from
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
}

/* *
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
}

/* *
 * change_bit - Atomically toggle a bit in memory
 * @nr:     the bit to change
 * @addr:   the address to start counting from
 * */
static inline void change_bit(int nr, volatile void *addr) {
    __op_bit (xor, __NOP, nr, ((volatile unsigned long *)addr));
}

/* *
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
}

/* *
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
}

/* *
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
}

#endif /* !__LIBS_ATOMIC_H__ */
