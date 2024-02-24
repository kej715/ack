#ifndef _SYS_TYPES_H
#define _SYS_TYPES_H

#define COS_SECTOR_SIZE    512
#define COS_CIO_BUF_SIZE   (COS_SECTOR_SIZE * 2)
#define COS_MAX_OPEN_FILES FOPEN_MAX
#define COS_UDA_SIZE       128
#define COS_UDA_SIZE_BYTES (8 * COS_UDA_SIZE)

typedef unsigned char  u8;
typedef unsigned short u16;
typedef unsigned long  u64;

typedef int pid_t;
typedef int mode_t;
typedef long time_t;
typedef long suseconds_t;

#endif
