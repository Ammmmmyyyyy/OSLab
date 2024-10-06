#ifndef __KERN_MM_BEST_FIT_PMM_H__
#define  __KERN_MM_BEST_FIT_PMM_H__

#include <pmm.h>

#define IS_POWER_OF_2(x) ((x) > 0 && ((x) & ((x) - 1)) == 0)//对于任意一个2的幂（如1, 2, 4, 8等），它们的二进制表示中只有一位是1，因此与其减去1后的结果按位与运算将为0
#define LEFT_LEAF(index) (2 * (index) + 1)   // 左子节点的索引
#define RIGHT_LEAF(index) (2 * (index) + 2)  // 右子节点的索引
#define PARENT(index) ((index - 1) / 2)           // 父节点的索引
#define MAX(a, b) ((a) > (b) ? (a) : (b))


extern const struct pmm_manager default_pmm_manager;

#endif /* ! __KERN_MM_DEFAULT_PMM_H__ */