@echo off
REM ============================================================================
REM Build script for Poker Solitaire (Windows)
REM Requires GNAT (GNU Ada compiler) to be installed
REM ============================================================================

echo === Building Poker Solitaire ===
echo.

REM Create output directories
if not exist "obj" mkdir obj
if not exist "bin" mkdir bin

REM Try gprbuild first
where gprbuild >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Using gprbuild...
    gprbuild -P poker_solitaire.gpr -j0
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo Build successful!
        echo Run with: bin\poker_solitaire.exe
        goto :end
    ) else (
        echo Build failed!
        goto :error
    )
)

REM Fall back to gnatmake
where gnatmake >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Using gnatmake...
    cd src
    gnatmake -gnat2012 -gnatwa -gnato -o ..\bin\poker_solitaire.exe poker_solitaire.adb -D ..\obj
    cd ..
    if %ERRORLEVEL% EQU 0 (
        echo.
        echo Build successful!
        echo Run with: bin\poker_solitaire.exe
        goto :end
    ) else (
        echo Build failed!
        goto :error
    )
)

echo ERROR: GNAT compiler not found!
echo.
echo Please install GNAT Ada compiler:
echo   - Download from: https://www.adacore.com/download
echo   - Or use MSYS2: pacman -S mingw-w64-x86_64-gcc-ada
goto :error

:error
exit /b 1

:end
echo.
echo === Build Complete ===
