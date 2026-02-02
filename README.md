# Poker Solitaire

A classic card game written entirely in Ada with ASCII graphics. Works on both Windows and Linux terminals.

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

## Requirements

- GNAT Ada compiler (part of GCC or available from AdaCore)
- A terminal that supports ANSI escape codes (most modern terminals)

### Installing GNAT

**Ubuntu/Debian:**
```bash
sudo apt install gnat gprbuild
```

**Fedora:**
```bash
sudo dnf install gcc-gnat gprbuild
```

**Arch Linux:**
```bash
sudo pacman -S gcc-ada
```

**macOS (Homebrew):**
```bash
brew install gnat
```

**Windows:**
- Download from [AdaCore](https://www.adacore.com/download)
- Or use MSYS2: `pacman -S mingw-w64-x86_64-gcc-ada`

## Building

### Using the build script (recommended)

**Linux/macOS:**
```bash
chmod +x build.sh
./build.sh
```

**Windows:**
```cmd
build.bat
```

### Using Make
```bash
make
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
gnatmake -gnat2012 -gnatwa -o ../bin/poker_solitaire poker_solitaire.adb -D ../obj
```

## Running the Game

**Linux/macOS:**
```bash
./bin/poker_solitaire
```

**Windows:**
```cmd
bin\poker_solitaire.exe
```

## How to Play

1. Start a new game from the main menu
2. A card will be dealt from the shuffled deck
3. Enter a position to place the card (e.g., `2 3` for row 2, column 3)
4. Positions are numbered 1-5 for both rows and columns
5. Once placed, cards cannot be moved
6. After placing all 25 cards, your hands are scored
7. Try to beat your high score!

### Commands During Play

- `row col` - Place card at position (e.g., `2 3`)
- `h` - Show help
- `q` - Quit game

## Project Structure

```
poker_solitaire/
├── src/
│   ├── cards.ads          # Card type definitions
│   ├── cards.adb          # Card operations
│   ├── deck.ads           # Deck management interface
│   ├── deck.adb           # Deck with RNG implementation
│   ├── poker_hands.ads    # Hand evaluation interface
│   ├── poker_hands.adb    # Poker hand evaluation logic
│   ├── game_board.ads     # 5x5 grid interface
│   ├── game_board.adb     # Game board operations
│   ├── display.ads        # ASCII display interface
│   ├── display.adb        # Terminal display implementation
│   ├── high_scores.ads    # High score management interface
│   ├── high_scores.adb    # Score file operations
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
- **External Dependencies:** None (pure standard Ada)
- **Graphics:** ASCII art using ANSI escape codes
- **Random Number Generator:** Custom Linear Congruential Generator seeded with system time
- **High Scores:** Stored in `poker_solitaire_scores.dat`

## License

This project is provided as-is for educational purposes.

## Tips for High Scores

1. **Plan ahead:** Look at the current card and think about which row/column would benefit most
2. **Build flushes early:** Placing suited cards in the same row/column early gives you flexibility
3. **Watch for straights:** Keep track of card ranks to build sequential hands
4. **Sacrifice low-value hands:** Sometimes it's better to "bust" one hand to save better cards for others
5. **Corner positions are key:** Cards in corners contribute to both a row and column hand
