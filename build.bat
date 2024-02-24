@echo off
setlocal
cd /D "%~dp0"

:: --- Unpack Arguments -------------------------------------------------------
for %%a in (%*) do      set "%%a=1"
if not "%release%"=="1" set debug=1
if "%debug%"=="1"       set release=0 && echo [debug mode]
if "%release%"=="1"     set debug=0 && echo [release mode]
if "%~1"==""            echo [default mode, assuming `sample` build] && set sample=1

:: --- Compile/Link Line Definitions ------------------------------------------
set cl_common=    /I..\src\ /I..\local\ /nologo /FC /Z7
set clang_common= -I..\src\ -I..\local\ -gcodeview -fdiagnostics-absolute-paths -Wall -Wno-unknown-warning-option -Wno-missing-braces -Wno-unused-function -Wno-writable-strings -Wno-unused-value -Wno-unused-variable -Wno-unused-local-typedef -Wno-deprecated-register -Wno-deprecated-declarations -Wno-unused-but-set-variable -Wno-single-bit-bitfield-constant-conversion -Xclang -flto-visibility-public-std -D_USE_MATH_DEFINES -Dstrdup=_strdup -Dgnu_printf=printf
set cl_debug=     call cl /Od %cl_common% %auto_compile_flags%
set cl_release=   call cl /O2 /DNDEBUG %cl_common% %auto_compile_flags%
set clang_debug=  call clang -g -O0 %clang_common% %auto_compile_flags%
set clang_release=call clang -g -O2 -DNDEBUG %clang_common% %auto_compile_flags%
set cl_link=      /link /MANIFEST:EMBED /INCREMENTAL:NO
set clang_link=   -fuse-ld=lld -Xlinker /MANIFEST:EMBED -Xlinker
set cl_out=       /out:
set clang_out=     -o

:: --- Per-Build Settings -----------------------------------------------------
if "%msvc%"=="1"  set only_compile=/c
if "%clang%"=="1" set only_compile=-c
if "%msvc%"=="1"  set EHsc=        /EHsc
if "%clang%"=="1" set EHsc=

:: --- Choose Compile/Link Lines ----------------------------------------------
if "%msvc%"=="1"    set compile_debug=  %cl_debug%
if "%msvc%"=="1"    set compile_release=%cl_release%
if "%msvc%"=="1"    set compile_link=   %cl_link%
if "%msvc%"=="1"    set out=            %cl_out%
if "%clang%"=="1"   set compile_debug=  %clang_debug%
if "%clang%"=="1"   set compile_release=%clang_release%
if "%clang%"=="1"   set compile_link=   %clang_link%
if "%clang%"=="1"   set out=            %clang_out%
if "%debug%"=="1"   set compile=        %compile_debug%
if "%release%"=="1" set compile=        %compile_release%

:: --- Prep Directories -------------------------------------------------------
if not exist build mkdir build
if not exist local mkdir local

:: --- Build Everything -------------------------------------------------------
pushd build
if "%sample%"=="1" %compile% ..\src\sample\sample_main.cpp %compile_link% %out%sample.exe || exit /b 1
popd

for %%a in (%*) do set "%%a=0"
