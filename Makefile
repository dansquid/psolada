#===============================================================================
# Makefile for Poker Solitaire
# Works on Linux, macOS, and Windows (with MinGW/MSYS2)
#===============================================================================

# Directories
SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin

# Compiler settings
ADA_COMPILER = gnatmake
ADA_FLAGS = -gnat2012 -gnatwa -gnato -fstack-check -g

# Main target name
TARGET = poker_solitaire

# Detect OS for proper executable extension
ifeq ($(OS),Windows_NT)
    EXE = .exe
    RM = del /Q
    MKDIR = if not exist "$(1)" mkdir "$(1)"
else
    EXE =
    RM = rm -f
    MKDIR = mkdir -p $(1)
endif

# Full path to executable
EXECUTABLE = $(BIN_DIR)/$(TARGET)$(EXE)

#-------------------------------------------------------------------------------
# Targets
#-------------------------------------------------------------------------------

.PHONY: all clean run dirs gprbuild

# Default target: build using gprbuild if available, otherwise gnatmake
all: dirs
	@if command -v gprbuild >/dev/null 2>&1; then \
		echo "Building with gprbuild..."; \
		gprbuild -P poker_solitaire.gpr -j0; \
	else \
		echo "Building with gnatmake..."; \
		cd $(SRC_DIR) && $(ADA_COMPILER) $(ADA_FLAGS) -o ../$(EXECUTABLE) $(TARGET).adb -D ../$(OBJ_DIR); \
	fi
	@echo ""
	@echo "Build successful! Run with: $(EXECUTABLE)"

# Build using gprbuild (preferred)
gprbuild: dirs
	gprbuild -P poker_solitaire.gpr -j0

# Create directories
dirs:
	@$(call MKDIR,$(OBJ_DIR))
	@$(call MKDIR,$(BIN_DIR))

# Clean build artifacts
clean:
	$(RM) $(OBJ_DIR)/*
	$(RM) $(BIN_DIR)/*
	$(RM) $(SRC_DIR)/*.ali
	$(RM) $(SRC_DIR)/*.o

# Run the game
run: all
	./$(EXECUTABLE)

# Help
help:
	@echo "Poker Solitaire - Build Targets:"
	@echo "  make        - Build the game"
	@echo "  make clean  - Remove build artifacts"
	@echo "  make run    - Build and run the game"
	@echo "  make help   - Show this help message"
	@echo ""
	@echo "Requirements: GNAT Ada compiler (gprbuild or gnatmake)"
