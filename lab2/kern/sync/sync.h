#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    /*
    read_csr(sstatus)：读取RISC-V的 sstatus 寄存器，这个寄存器保存了内核当前的状态。
    SSTATUS_SIE 是 sstatus 中的一个位，表示当前系统是否允许中断。如果该位被设置，意味着当前中断是启用的。
    if (read_csr(sstatus) & SSTATUS_SIE)：检查当前中断状态，如果中断是开启的，就执行下一步操作。
    intr_disable()：禁用中断，确保接下来的临界区代码不会被中断打断。
    返回值：函数返回 1 表示中断原本是开启的；返回 0 表示中断原本是关闭的。这个返回值用于后续恢复中断状态时判断之前是否应该启用中断。
    */
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    /*
    if (flag)：如果 flag 是 1，则说明中断在进入临界区之前是启用的，所以在离开临界区时需要重新启用中断。
    */
    if (flag) {
        intr_enable();
    }
}
//local_intr_save(x)：这个宏用于保存当前中断状态并禁用中断。宏内部调用 __intr_save()，并将返回的中断状态保存到变量 x 中。这样可以在之后通过 x 知道之前的中断状态，以便离开临界区时恢复
#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
#define local_intr_restore(x) __intr_restore(x);

#endif /* !__KERN_SYNC_SYNC_H__ */
