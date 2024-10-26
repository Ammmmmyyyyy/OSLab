/*
一个用于定义一些基础数据类型、常用宏和属性的头文件，主要用于操作系统或者嵌入式系统开发中的低级编程。它提供了基本的类型定义和便捷的宏，来支持内核开发或其他需要直接操作内存、地址和高效代码的场景
*/
#ifndef __LIBS_DEFS_H__
#define __LIBS_DEFS_H__

#ifndef NULL
#define NULL ((void *)0) //定义 NULL 为空指针（void* 类型的 0），用于指代无效或未初始化的指针。
#endif

/*
__always_inline 强制内联函数，即使在编译器通常不愿意内联的情况下。
__noinline 防止函数内联，强制函数始终以函数调用的方式执行。
__noreturn 用于标识永不返回的函数，表示调用该函数后不会继续执行后续代码。
*/
#define __always_inline inline __attribute__((always_inline))
#define __noinline __attribute__((noinline))
#define __noreturn __attribute__((noreturn))

/* Represents true-or-false values */
typedef int bool;

/* Explicitly-sized versions of integer types */
typedef char int8_t;
typedef unsigned char uint8_t;
typedef short int16_t;
typedef unsigned short uint16_t;
typedef int int32_t;
typedef unsigned int uint32_t;
typedef long long int64_t;
typedef unsigned long long uint64_t;

/* Add fast types */
typedef signed char int_fast8_t;
typedef short int_fast16_t;
typedef long int_fast32_t;
typedef long long int_fast64_t;

typedef unsigned char uint_fast8_t;
typedef unsigned short uint_fast16_t;
typedef unsigned long uint_fast32_t;
typedef unsigned long long uint_fast64_t;

/* *
 * Pointers and addresses are 64 bits long.
 * We use pointer types to represent addresses,
 * uintptr_t to represent the numerical values of addresses.
 * */
typedef int64_t intptr_t;
typedef uint64_t uintptr_t;

/* size_t is used for memory object sizes */
typedef uintptr_t size_t;

/* used for page numbers */
typedef size_t ppn_t;

/* *
 * Rounding operations (efficient when n is a power of 2)
 * Round down to the nearest multiple of n
 * */
 /*
 内存对齐的四舍五入操作
 */
#define ROUNDDOWN(a, n) ({                                          \
            size_t __a = (size_t)(a);                               \
            (typeof(a))(__a - __a % (n));                           \
        })

/* Round up to the nearest multiple of n */
#define ROUNDUP(a, n) ({                                            \
            size_t __n = (size_t)(n);                               \
            (typeof(a))(ROUNDDOWN((size_t)(a) + __n - 1, __n));     \
        })

/* Return the offset of 'member' relative to the beginning of a struct type */
//这个宏用于计算结构体中某个成员相对于结构体起始地址的偏移量，常用于实现通用的宏或数据结构遍历。
#define offsetof(type, member)                                      \
    ((size_t)(&((type *)0)->member))

/* *
 * to_struct - get the struct from a ptr
 * @ptr:    a struct pointer of member
 * @type:   the type of the struct this is embedded in
 * @member: the name of the member within the struct
 * */
 //从成员指针获取结构体指针
#define to_struct(ptr, type, member)                               \
    ((type *)((char *)(ptr) - offsetof(type, member)))

#endif /* !__LIBS_DEFS_H__ */

