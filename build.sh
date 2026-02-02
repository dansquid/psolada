#!/bin/bash
#===============================================================================
# Build script for Poker Solitaire (Linux/Unix)
# Requires GNAT (GNU Ada compiler) and X11 development libraries
#===============================================================================

set -e

echo "=== Building Poker Solitaire ==="
echo ""

# Check for X11 development headers
if [ ! -f /usr/include/X11/Xlib.h ] && [ ! -f /usr/local/include/X11/Xlib.h ]; then
    echo "WARNING: X11 development headers may not be installed."
    echo "  Ubuntu/Debian: sudo apt install libx11-dev"
    echo "  Fedora: sudo dnf install libX11-devel"
    echo "  Arch: sudo pacman -S libx11"
    echo ""
fi

# Create output directories
mkdir -p obj bin

# Check for gprbuild (preferred)
if command -v gprbuild &> /dev/null; then
    echo "Using gprbuild..."
    gprbuild -P poker_solitaire.gpr -j0
    echo ""
    echo "Build successful!"
    echo "Run with: ./bin/poker_solitaire"
# Fall back to gnatmake
elif command -v gnatmake &> /dev/null; then
    echo "Using gnatmake..."
    cd src
    gnatmake -gnat2012 -gnatwa -gnato poker_solitaire.adb \
        -o ../bin/poker_solitaire -D ../obj \
        -largs -lX11
    cd ..
    echo ""
    echo "Build successful!"
    echo "Run with: ./bin/poker_solitaire"
else
    echo "ERROR: GNAT compiler not found!"
    echo ""
    echo "Please install GNAT Ada compiler:"
    echo "  Ubuntu/Debian: sudo apt install gnat gprbuild"
    echo "  Fedora: sudo dnf install gcc-gnat gprbuild"
    echo "  Arch: sudo pacman -S gcc-ada"
    echo "  macOS: brew install gnat"
    exit 1
fi

echo ""
echo "=== Build Complete ==="
