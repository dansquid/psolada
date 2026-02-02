# Poker Solitaire

A classic card game written in Ada with graphical display using X11. Features proper card rendering with suit symbols and colors.

## Game Description

Poker Solitaire is a patience/solitaire card game where you place 25 cards from a shuffled deck into a 5x5 grid. The objective is to maximize your score by creating the best possible poker hands in each row and column (10 hands total).

### Scoring (American System)

| Hand            | Points |
|-----------------|--------|
| Royal Flush     | 100    |
| Straight Flush  | 75     |
| Four of a Kind  | 50     |
| Full House      | 25     |
| Flush           | 20     |
| Straight        | 15     |
| Three of a Kind | 10     |
| Two Pair        | 5      |
| One Pair        | 2      |
| No Hand         | 0      |

**Theoretical Maximum Score:** 200 points (practically impossible)
**Good Score:** 60-80 points
**Expert Score:** 100+ points

## Screenshots

The game features:
- Graphical card display with proper suit symbols (Hearts, Diamonds, Clubs, Spades)
- Red suits (Hearts, Diamonds) and black suits (Clubs, Spades)
- Green card table background
- Real-time score display
- Mouse click or keyboard input for card placement

## Requirements

### Linux

- GNAT Ada compiler (part of GCC or available from AdaCore)
- X11 development libraries
- An X11 display server (standard on most Linux desktops)

**Ubuntu/Debian:**
```bash
sudo apt install gnat gprbuild libx11-dev
```

**Fedora:**
```bash
sudo dnf install gcc-gnat gprbuild libX11-devel
```

**Arch Linux:**
```bash
sudo pacman -S gcc-ada libx11
```

### Windows

On Windows, you need an X11 server:
- **WSL2 with WSLg** (recommended) - Graphics work automatically
- **MSYS2** with X11 packages and VcXsrv/Xming
- Or use WSL2 and run the Linux version

**Using MSYS2:**
```bash
pacman -S mingw-w64-x86_64-gcc-ada mingw-w64-x86_64-libx11
```

### macOS

```bash
brew install gnat
# X11 via XQuartz: brew install --cask xquartz
```

## Building

### Using the build script (recommended)

**Linux/macOS:**
```bash
chmod +x build.sh
./build.sh
```

**Windows (MSYS2):**
```cmd
build.bat
```

### Using gprbuild directly
```bash
mkdir -p obj bin
gprbuild -P poker_solitaire.gpr
```

### Using gnatmake directly
```bash
mkdir -p obj bin
cd src
gnatmake -gnat2012 -gnatwa -gnato poker_solitaire.adb \
    -o ../bin/poker_solitaire -D ../obj \
    -largs -lX11
```

## Running the Game

**Linux/macOS:**
```bash
./bin/poker_solitaire
```

**Windows (with X11 server running):**
```cmd
bin\poker_solitaire.exe
```

## How to Play

1. Start a new game from the main menu (press '1')
2. A card will be displayed - this is the card to place
3. **Click on an empty slot** to place the card there
4. Or **type row and column numbers** (1-5 each)
5. Once placed, cards cannot be moved
6. After placing all 25 cards, your hands are scored
7. Try to beat your high score!

### Controls

| Input | Action |
|-------|--------|
| Mouse Click | Place card in clicked slot |
| 1-5, 1-5 | Type row then column number |
| H | Show help screen |
| Q | Quit game |

## Project Structure

```
poker_solitaire/
├── src/
│   ├── adagraph.ads       # Graphics library interface
│   ├── adagraph.adb       # X11 graphics implementation
│   ├── cards.ads/adb      # Card type definitions
│   ├── deck.ads/adb       # Deck management with RNG
│   ├── poker_hands.ads/adb # Hand evaluation logic
│   ├── game_board.ads/adb # 5x5 grid management
│   ├── display.ads/adb    # Graphical display using AdaGraph
│   ├── high_scores.ads/adb # Score file operations
│   └── poker_solitaire.adb # Main program
├── obj/                   # Compiled objects (created by build)
├── bin/                   # Executable output (created by build)
├── poker_solitaire.gpr    # GNAT project file
├── Makefile               # Make build file
├── build.sh               # Linux/macOS build script
├── build.bat              # Windows build script
└── README.md              # This file
```

## Technical Details

- **Language:** Ada 2012
- **Graphics:** Custom AdaGraph library using X11 (Xlib)
- **External Dependencies:** libX11 (X Window System)
- **Random Number Generator:** Custom Linear Congruential Generator seeded with system time
- **High Scores:** Stored in `poker_solitaire_scores.dat`
- **Window Size:** 900x700 pixels
- **Card Rendering:** Graphical suit symbols with proper colors

## AdaGraph Library

This project includes a custom AdaGraph implementation that provides:
- Window creation and management
- Basic drawing primitives (lines, boxes, circles)
- Color support (16-color palette)
- Text output
- Mouse and keyboard input
- Cross-platform potential (currently X11)

## License

This project is provided as-is for educational purposes.

## Tips for High Scores

1. **Plan ahead:** Look at the current card and think about which row/column would benefit most
2. **Build flushes early:** Placing suited cards in the same row/column early gives you flexibility
3. **Watch for straights:** Keep track of card ranks to build sequential hands
4. **Sacrifice low-value hands:** Sometimes it's better to "bust" one hand to save better cards for others
5. **Corner positions are key:** Cards in corners contribute to both a row and column hand
