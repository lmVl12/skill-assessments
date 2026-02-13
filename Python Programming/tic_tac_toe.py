import random
import logging

# Logging configuration for warnings
logging.basicConfig(format='%(levelname)s: %(message)s')
logger = logging.getLogger()

def print_board(board):
    """Prints the game board in a readable format"""
    print("\n" + "-" * 13)
    for row in board:
        print(f"| {row[0]} | {row[1]} | {row[2]} |")
        print("-" * 13)

def check_winner(board):
    """Checks all combinations for a winner"""
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

def simulate_move_and_check(board, move, sym):
    """Temporary check: what happens if a symbol is placed in this cell"""
    idx = int(move) - 1
    r, c = idx // 3, idx % 3
    original = board[r][c]
    board[r][c] = sym
    is_win = (check_winner(board) == sym)
    board[r][c] = original # Revert changes
    return is_win

def get_computer_move(board, comp_sym, user_sym):
    """Computer logic: 70% IQ (sees win/threat), 30% random"""
    available_moves = [item for row in board for item in row if item not in ["X", "O"]]
    
    # "Human-like" error (30% probability of a random move)
    if random.random() > 0.7:
        return random.choice(available_moves)

    # 1. Try to win immediately
    for move in available_moves:
        if simulate_move_and_check(board, move, comp_sym):
            return move
            
    # 2. Block the player
    for move in available_moves:
        if simulate_move_and_check(board, move, user_sym):
            return move
            
    # 3. Strategic center
    if "5" in available_moves:
        return "5"
        
    # 4. Random choice from remaining moves
    return random.choice(available_moves)

def main():
    board = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]
    
    print("Welcome to Tic-Tac-Toe!")
    
    # Symbol selection
    user_sym = ""
    while user_sym not in ["X", "O"]:
        user_sym = input("Do you want to play as X or O?: ").upper()
        if user_sym not in ["X", "O"]:
            logger.warning("Invalid choice! Please enter only X or O.")

    comp_sym = "O" if user_sym == "X" else "X"
    current_turn = "X" # By the rules, X always goes first
    
    print(f"\nYou are playing as {user_sym}, computer is {comp_sym}.")
    print("X moves first.")

    while True:
        print_board(board)
        
        # Check game end
        winner = check_winner(board)
        available_moves = [item for row in board for item in row if item not in ["X", "O"]]
        
        if winner:
            print(f"GAME OVER! Winner: {winner}")
            break
        if not available_moves:
            print("GAME OVER! It's a draw!")
            break

        # Player or Computer turn
        if current_turn == user_sym:
            move = input(f"Your turn ({user_sym}), enter a number 1-9: ")
            
            # Move validation
            found = False
            for r in range(3):
                for c in range(3):
                    if board[r][c] == move:
                        board[r][c] = user_sym
                        found = True
            
            if not found:
                logger.warning("This cell is unavailable. Choose another number from the board.")
                continue # Don't switch turns until valid input is provided
        else:
            # Computer turn
            move = get_computer_move(board, comp_sym, user_sym)
            for r in range(3):
                for c in range(3):
                    if board[r][c] == move:
                        board[r][c] = comp_sym
            print(f"Computer ({comp_sym}) chose cell: {move}")

        # Switch turn
        current_turn = "O" if current_turn == "X" else "X"

if __name__ == "__main__":
    main()