# Multiplication Match Game in MIPS Assembly

A memory card game implemented in MIPS Assembly language using the MARS simulator. The game challenges players to match multiplication equations with their results.

## 🎮 Game Description

This is a 4x4 memory card game where players need to match multiplication equations with their corresponding answers. The game features:

- 16 cards arranged in a 4x4 grid
- Multiplication equations and their results
- Move counter to track progress
- Interactive command-line interface
- Card reveal and match mechanics

## 🚀 Getting Started

### Prerequisites

- MARS MIPS simulator
- Java Runtime Environment (JRE)

### Installation

1. Download MARS MIPS simulator from [here](https://dpetersanderson.github.io/)
2. Save the downloaded `mars.jar` file to your computer
3. Make sure Java is installed on your system

### Running the Game

1. Launch MARS:
   ```bash
   java -jar mars.jar
   ```
2. Open `game.asm` in MARS
3. Assemble and run the program using the MARS interface

## 🎯 How to Play

1. The game starts with all cards face down (marked with *)
2. Enter a number between 1-16 to reveal a card
3. Match equations with their results
4. Try to find all matches in the minimum number of moves
5. The game ends when all pairs are matched

## 📁 Project Structure

- `game.asm` - Main game implementation
- `board.asm` - Board display and management
- `main.asm` - Program entry point
- `MARS_instructions.txt` - Detailed instructions for MARS setup
- `User_Manual.txt` - Game instructions and documentation

## 🛠️ Technical Details

The game is implemented using:
- MIPS Assembly language
- Data segment for game state management
- Procedural programming with subroutines
- Memory management for game state
- Input/output system calls

## 📝 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.
