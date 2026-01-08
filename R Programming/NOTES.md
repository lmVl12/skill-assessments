# Technical Notes: Tic-Tac-Toe (R Implementation)

## Input/Output Handling
- **Universal Compatibility**: Implemented a robust input handling system that detects the execution environment. Using `interactive()`, the script switches between `stdin()` for RStudio and `"stdin"` for terminal-based execution (via `Rscript`).
- **Screen Management**: Integrated clean UI transitions by handling terminal escape sequences to prevent visual artifacts across different consoles.

## Game Logic & Strategy
- **AI Strategy**: Developed a "Suboptimal" AI move logic. Instead of pure randomness, the AI prioritizes certain positions while still allowing for player victory, ensuring an engaging user experience.
- **Session Management**: Implemented a match-loop system that supports multiple consecutive rounds. 
- **Scoring System**: Global variables track Wins, Losses, and Ties across the entire session, displaying a final scorecard upon exit.

## Architecture
- **Code Structure**: The project follows a modular functional approach, separating the game engine (logic) from the UI (rendering the board and scores).
