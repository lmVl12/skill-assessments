## Project: Tic-Tac-Toe (Python)

### Overview

This project is an advanced Python implementation of the classic Tic-Tac-Toe game. While the core logic was developed with **AI assistance**, the final product focuses on fine-tuning the gameplay experience. 

### Project Evolution: AI-Assisted Architecture

The program's architecture was designed using AI-assisted development, allowing for a more sophisticated structure. The main effort was directed towards high-level customization and UX (User Experience) improvements:

-   **Granular Difficulty Levels:** Three distinct modes (Easy, Medium, Hard) were implemented. Unlike the random-move logic in the R version, the AI here simulates human-like errors or plays flawlessly depending on the selection.
    
-   **Enhanced Visual Grid:** Instead of plain text, the UI uses ANSI escape codes for colors and symbols, creating the feel of a dedicated console application.
    
-   **Strategic Heuristics:** The decision-making engine was refined to prioritize tactical moves (center control, blocking the player's win).
    
### Key Technical Features

-   **Early Draw Detection:** An optimized algorithm ends the round prematurely if a draw becomes mathematically inevitable, saving the player's time.
    
-   **Crash Prevention:** Robust input validation is integrated to ensure the program handles invalid characters or occupied cells without breaking the execution flow.
    
-   **State Persistence:** Match scores and difficulty settings are maintained throughout the entire gaming session.

### Launch

Since the project relies strictly on the **Python Standard Library**, no external dependencies (like `pip install`) are required.
*  **Command Line:** Navigate to the project directory and execute the following:
```bash 
# Depending on your system configuration, use 'python' or 'python3' 
python tic_tac_toe.py
```
* **IDE / Code Editor:** Open `tic_tac_toe.py` in your preferred editor and use the **"Run Code"** or **"Run Python File"** command.