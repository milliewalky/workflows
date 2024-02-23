@echo off

for %%a in (%*) do set "%%a=1"

set compiler=cl
set cl_flags=/Zi /nologo /FC /I..\src\ /I..\local\ /EHsc

if not exist build mkdir build
xcopy /y /q /s /e /i data .\build\data

if not exist local mkdir local

pushd build
if "%sample%"=="1" %compiler% %cl_flags% ..\src\sample\sample_main.c /link /out:sample.exe
popd

for %%a in (%*) do set "%%a=0"
