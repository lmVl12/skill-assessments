import random
import logging

# Logging configuration for warnings
logging.basicConfig(format='%(levelname)s: %(message)s')
logger = logging.getLogger()

def print_board(board):
    print("\n" + "-" * 13)
    for row in board:
        print(f"| {row[0]} | {row[1]} | {row[2]} |")
        print("-" * 13)

def check_winner(board):
    # All possible winning combinations
    win_coords = [
        [(0,0), (0,1), (0,2)], [(1,0), (1,1), (1,2)], [(2,0), (2,1), (2,2)], # Rows
        [(0,0), (1,0), (2,0)], [(0,1), (1,1), (2,1)], [(0,2), (1,2), (2,2)], # Columns
        [(0,0), (1,1), (2,2)], [(0,2), (1,1), (2,0)]                         # Diagonals
    ]
    for coord in win_coords:
        symbols = [board[r][c] for r, c in coord]
        if symbols[0] == symbols[1] == symbols[2] and symbols[0] in ["X", "O"]:
            return symbols[0]
    return None

def main():
    board = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]
    
    # 1. Symbol selection with validation
    user_sym = ""
    while user_sym not in ["X", "O"]:
        user_sym = input("Choose your symbol (X or O): ").upper()
        if user_sym not in ["X", "O"]:
            logger.warning("Invalid choice! Please enter only X or O.")

    comp_sym = "O" if user_sym == "X" else "X"
    current_turn = "X"  # X always goes first by the rules
    
    print(f"\nGame started! You: {user_sym}, Computer: {comp_sym}")
    print("X moves first.")

    while True:
        print_board(board)
        
        # Check for winner or draw
        winner = check_winner(board)
        available_moves = [item for row in board for item in row if item not in ["X", "O"]]
        
        if winner:
            print(f"Game over! {winner} wins!")
            break
        if not available_moves:
            print("Game over! It's a draw!")
            break

        # 2. Turn logic
        if current_turn == user_sym:
            # Human turn
            move = input(f"Your turn ({user_sym}), choose a cell number: ")
            found = False
            for r in range(3):
                for c in range(3):
                    if board[r][c] == move:
                        board[r][c] = user_sym
                        found = True
            
            if not found:
                logger.warning("This cell is occupied or doesn't exist. Try again.")
                continue # Don't switch turns, let the human try again
        else:
            # Computer turn
            comp_choice = random.choice(available_moves)
            for r in range(3):
                for c in range(3):
                    if board[r][c] == comp_choice:
                        board[r][c] = comp_sym
            print(f"Computer ({comp_sym}) chose cell: {comp_choice}")

        # Switch turns
        current_turn = "O" if current_turn == "X" else "X"

if __name__ == "__main__":
    main()

