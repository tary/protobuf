rem @echo off

@REM 
@REM Please make sure the following environment variables are set before calling this script:
@REM PROTOBUF_UE4_VERSION - Release version string.
@REM PROTOBUF_UE4_PREFIX  - Absolute install path prefix string.
@REM 

@SET PROTOBUF_UE4_VERSION=3.6.1.3
@SET PROTOBUF_UE4_PREFIX=H:\protobuf\build

@if "%PROTOBUF_UE4_VERSION%"=="" (
    echo PROTOBUF_UE4_VERSION is not set, exit.
    exit /b 1
)

@if "%PROTOBUF_UE4_PREFIX%"=="" (
    echo PROTOBUF_UE4_PREFIX is not set, exit.
    exit /b 1
)

set CURRENT_DIR=%cd%
cd ..
set PROTOBUF_DIR=%cd%

git reset HEAD --hard
rem git checkout %PROTOBUF_UE4_VERSION%
git submodule update --init --recursive

@REM We only need x64 (VsDevCmd.bat defaults arch to x86, pass -help to see all available options)
set PROTOBUF_ARCH=x64
@REM Tell CMake to use dynamic CRT (/MD) instead of static CRT (/MT)
set PROTOBUF_CMAKE_OPTIONS=-Dprotobuf_MSVC_STATIC_RUNTIME=OFF

@REM -----------------------------------------------------------------------
@REM Set Environment Variables for the Visual Studio 2017 Command Line
set VS2017DEVCMD=C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\Tools\VsDevCmd.bat
if exist "%VS2017DEVCMD%" (
    @REM Tell VsDevCmd.bat to set the current directory, in case [USERPROFILE]\source exists. See:
    @REM C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\vsdevcmd\core\vsdevcmd_end.bat
     set VSCMD_START_DIR=%CD%
     call "%VS2017DEVCMD%" -arch=%PROTOBUF_ARCH%
      ) else (
     echo ERROR: Cannot find Visual Studio 2017
     exit /b 2
)

set FIX_FILE=%CURRENT_DIR%\Fix-3.6.1.3.bat
if exist "%FIX_FILE%" (
    call %FIX_FILE%
) else (
    echo protobuf has not been modified
)

set OUT_PATH=%PROTOBUF_DIR%\temp\static
rd %OUT_PATH%
mkdir %OUT_PATH%

cd %PROTOBUF_DIR%\cmake
mkdir build & cd build

echo ########## static build ##########
mkdir static
pushd static
    cmake -G "NMake Makefiles" ^
        -DCMAKE_BUILD_TYPE=Release ^
		-DCMAKE_INSTALL_PREFIX="%OUT_PATH:\=/%" ^
        %PROTOBUF_CMAKE_OPTIONS% ../..
    nmake
	nmake install
popd

mkdir %PROTOBUF_UE4_PREFIX%\windows\bin
mkdir %PROTOBUF_UE4_PREFIX%\windows\lib

move %OUT_PATH%\lib\libprotobuf.lib %PROTOBUF_UE4_PREFIX%\windows\lib\libprotobuf.lib
move %OUT_PATH%\bin\protoc.exe %PROTOBUF_UE4_PREFIX%\windows\bin\protoc.exe
move %OUT_PATH%\include %PROTOBUF_UE4_PREFIX%\windows\include

rd /S /Q %PROTOBUF_UE4_PREFIX%\static

CD /D %CURRENT_DIR%




