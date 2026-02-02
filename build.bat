@echo off
REM ============================================================================
REM Build script for Poker Solitaire (Windows)
REM Requires GNAT and an X11 server (like VcXsrv or Xming) on Windows
REM Or alternatively, use WSL2 with X11 forwarding
REM ============================================================================

echo === Building Poker Solitaire ===
echo.
echo NOTE: This version uses X11 graphics.
echo For Windows, you need:
echo   1. MSYS2 with mingw-w64-x86_64-gcc-ada and mingw-w64-x86_64-libx11
echo   2. An X11 server (VcXsrv, Xming, or WSL2 with WSLg)
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
    gnatmake -gnat2012 -gnatwa -gnato poker_solitaire.adb -o ..\bin\poker_solitaire.exe -D ..\obj -largs -lX11
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
echo Please install GNAT Ada compiler via MSYS2:
echo   pacman -S mingw-w64-x86_64-gcc-ada mingw-w64-x86_64-libx11
echo.
echo Or download from: https://www.adacore.com/download
goto :error

:error
exit /b 1

:end
echo.
echo === Build Complete ===
