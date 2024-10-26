#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <defs.h>
#include <intr.h>
#include <riscv.h>
//表示中断是使能的”指的是允许 CPU 响应和处理外部或内部的中断。
//如果中断使能（SSTATUS_SIE 位为 1），则调用 intr_disable() 函数禁用中断，并返回 1 表示中断原本是开启的。如果中断未使能，则返回 0，表示无需更改中断状态。
static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
        intr_disable();
        return 1;
    }
    return 0;
}
//如果 flag 为 1，表示之前的中断是开启的，那么调用 intr_enable() 来重新使能中断。如果 flag 为 0，则不做任何操作。
static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

#define local_intr_save(x) \
    do {                   \
        x = __intr_save(); \
    } while (0)
#define local_intr_restore(x) __intr_restore(x);

#endif /* !__KERN_SYNC_SYNC_H__ */
