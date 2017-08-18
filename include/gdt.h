#ifndef GDT_H
#define GDT_H 1

#define GDT_TABLE_SIZE 5

#define GDT_ACCESS_PR(x)          ((x) << 7)        // http://wiki.osdev.org/GDT
#define GDT_ACCESS_PRIV(x)        ((x) << 5)
#define GDT_ACCESS_1(x)           ((x) << 4)
#define GDT_ACCESS_EX(x)          ((x) << 3)
#define GDT_ACCESS_DC(x)          ((x) << 2)
#define GDT_ACCESS_RW(x)          ((x) << 1)
#define GDT_ACCESS_AC(x)          ((x) << 0)

#define GDT_FLAGS_GR(x)           ((x) << 3)
#define GDT_FLAGS_SZ(x)           ((x) << 2)

#define GDT_ACCESS_CODE_PL0 GDT_ACCESS_PR(1) | GDT_ACCESS_PRIV(0) | GDT_ACCESS_1(1) | GDT_ACCESS_EX(1) | GDT_ACCESS_DC(0) | GDT_ACCESS_RW(1) | GDT_ACCESS_AC(0)
#define GDT_ACCESS_DATA_PL0 GDT_ACCESS_PR(1) | GDT_ACCESS_PRIV(0) | GDT_ACCESS_1(1) | GDT_ACCESS_EX(0) | GDT_ACCESS_DC(0) | GDT_ACCESS_RW(1) | GDT_ACCESS_AC(0)
#define GDT_ACCESS_CODE_PL3 GDT_ACCESS_PR(1) | GDT_ACCESS_PRIV(3) | GDT_ACCESS_1(1) | GDT_ACCESS_EX(1) | GDT_ACCESS_DC(0) | GDT_ACCESS_RW(1) | GDT_ACCESS_AC(0)
#define GDT_ACCESS_DATA_PL3 GDT_ACCESS_PR(1) | GDT_ACCESS_PRIV(3) | GDT_ACCESS_1(1) | GDT_ACCESS_EX(0) | GDT_ACCESS_DC(0) | GDT_ACCESS_RW(1) | GDT_ACCESS_AC(0)

#define GDT_FLAGS (GDT_FLAGS_GR(1) | GDT_FLAGS_SZ(1))

#define GDT_FLAG_LIMIT_BYTE GDT_FLAGS | 0XF0    // assumes 0xFFFFFF limit

#endif
