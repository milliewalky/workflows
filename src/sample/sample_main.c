#include "windows.h"

#define global         static
#define function       static
#define local_persist  static

#include "stdint.h"

typedef int8_t   S8;
typedef int16_t  S16;
typedef int32_t  S32;
typedef int64_t  S64;

typedef uint8_t  U8;
typedef uint16_t U16;
typedef uint32_t U32;
typedef uint64_t U64;

typedef S8       B8;
typedef S16      B16;
typedef S32      B32;
typedef S64      B64;

typedef float    F32;
typedef double   F64;

typedef struct String8 String8;
struct String8
{
 U8 *str;
 U64 size;
};

#define STB_SPRINTF_IMPLEMENTATION
#include "third_party/stb/stb_sprintf.h"

function String8
Str8(U8 *str, U64 size)
{
 String8 string;
 string.str = str;
 string.size = size;
 return string;
}

#define Str8Lit(s) Str8((U8 *)(s), sizeof(s)-1)

function String8
Str8FV(char *fmt, va_list args)
{
 String8 result = {0};
 va_list args2;
 va_copy(args2, args);
 U64 needed_bytes = stbsp_vsnprintf(0, 0, fmt, args)+1;
 result.str = VirtualAlloc(0, sizeof(U8)*needed_bytes, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
 result.size = needed_bytes-1;
 stbsp_vsnprintf((char *)result.str, needed_bytes, fmt, args2);
 return result;
}

function String8
Str8F(char *fmt, ...)
{
 String8 result = {0};
 va_list args;
 va_start(args, fmt);
 result = Str8FV(fmt, args);
 va_end(args);
 return result;
}

global HANDLE os_stdout = 0;

function void
PrintF(char *fmt, ...)
{
 String8 result = {0};
 va_list args;
 va_start(args, fmt);
 result = Str8FV(fmt, args);
 va_end(args);
 if (os_stdout == 0) os_stdout = GetStdHandle(STD_OUTPUT_HANDLE);
 WriteConsoleA(os_stdout, result.str, result.size, 0, 0);
}

int
main()
{
 PrintF("Hello, world!\n");
 PrintF("%s\n", "Hello, Sailor!");

 String8 str = Str8F("%S %s",
                     Str8Lit("Dost thou know the magnitude of thy sin before the gods?"),
                     "Yea, verily, thou shalt be ground between two stones.");

 PrintF("%S\n", str);
 return 0;
}
