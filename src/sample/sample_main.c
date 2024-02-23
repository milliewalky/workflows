#include "windows.h"

int
main()
{
 HANDLE console_output = GetStdHandle(STD_OUTPUT_HANDLE);
 char cstr[] = "Hello, Sailor!";
 DWORD written_count;
 WriteConsoleA(console_output, cstr, sizeof(cstr) / sizeof((cstr)[0]), &written_count, 0);
 return 0;
}
