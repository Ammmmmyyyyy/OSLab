#ifndef __LIBS_DEFS_H__
#define __LIBS_DEFS_H__

#ifndef NULL
#define NULL ((void *)0)
#endif

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
//计算结构体成员相对于结构体开头的偏移量
/*
(type *)0：将0强制转换为指向类型 type 的指针，虽然这个地址是非法的，但因为我们不会实际访问它，只是用来计算偏移量，所以是安全的。
&((type *)0)->member：通过伪造的指针 0 来获取 member 的地址，这实际上是获取了成员 member 在结构体 type 中的相对位置（偏移量）。
(size_t)：将结果转换为 size_t 类型，表示这是一个无符号的偏移量值
*/
#define offsetof(type, member)                                      \
    ((size_t)(&((type *)0)->member))

/* *
 * to_struct - get the struct from a ptr
 * @ptr:    a struct pointer of member
 * @type:   the type of the struct this is embedded in
 * @member: the name of the member within the struct
 * */
#define to_struct(ptr, type, member)                               \
    ((type *)((char *)(ptr) - offsetof(type, member)))//le指向的就是page->page_link，offset算的是page_link这个成员在page这个结构体中的偏移量，因此减去偏移量就能得到le当前在的这个page中的page的地址
/*ptr：这是一个指向链表节点的指针。
type：这是包含该成员的结构体的类型。例如，如果 member 是 struct Page 中的一个成员变量，则 type 是 struct Page。
member：这是结构体中的某个成员的名称（即字段名）。宏的目的是从这个成员的指针 ptr 回到包含它的结构体。
offsetof(type, member)：这个标准宏用于获取 member 在 type 结构体中的偏移量（相对于结构体起始地址的字节数）。
(char *)(ptr) - offsetof(type, member)：先将 ptr（指向成员的指针）转换为 char * 类型，以便按字节进行地址运算。然后通过减去该成员在结构体中的偏移量 offsetof(type, member)，我们就可以得到整个结构体的起始地址。
(type *)：最后，将计算出的结构体起始地址转换为指向 type 类型（即整个结构体）的指针。
*/

#endif /* !__LIBS_DEFS_H__ */

