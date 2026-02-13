import random
import logging
import os

# Logging configuration for warnings
logging.basicConfig(format='%(levelname)s: %(message)s')
logger = logging.getLogger()

def clear_screen():
    """Clears the terminal screen based on the operating system"""
    os.system('cls' if os.name == 'nt' else 'clear')

def print_ui(board, score, user_sym, comp_sym):
    """Displays the scoreboard and the game board"""
    clear_screen()
    print("=" * 30)
    print(f" SCORE: You ({user_sym}) {score['user']} : {score['comp']} Comp ({comp_sym})")
    print(f" Draws: {score['draw']}")
    print("=" * 30)
    print("\n" + " " * 8 + "-" * 13)
    for row in board:
        print(" " * 8 + f"| {row[0]} | {row[1]} | {row[2]} |")
        print(" " * 8 + "-" * 13)
    print("\n")

def check_winner(board):
    """Checks the board for all possible winning combinations"""
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

def is_draw_guaranteed(board, current_sym):
    """Checks if a draw is inevitable when only 1 move remains"""
    available = [item for row in board for item in row if item not in ["X", "O"]]
    
    if len(available) == 1:
        move = available[0]
        idx = int(move) - 1
        r, c = idx // 3, idx % 3
        
        # Simulate the final move
        board[r][c] = current_sym
        winner = check_winner(board)
        board[r][c] = move # Rollback
        
        # If no winner even after the last move, it's a guaranteed draw
        return winner is None
    return False

def get_computer_move(board, comp_sym, user_sym):
    """Computer AI logic: 80% IQ level (tries to win or block)"""
    available = [item for row in board for item in row if item not in ["X", "O"]]
    if random.random() > 0.8: return random.choice(available)

    for sym in [comp_sym, user_sym]:
        for move in available:
            idx = int(move) - 1
            r, c = idx // 3, idx % 3
            board[r][c] = sym
            if check_winner(board) == sym:
                board[r][c] = move 
                return move
            board[r][c] = move 
    
    if "5" in available: return "5"
    return random.choice(available)

def play_round(score):
    """Handles a single game round"""
    board = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]
    user_sym = ""
    while user_sym not in ["X", "O"]:
        user_sym = input("Pick your symbol (X / O): ").upper()

    comp_sym = "O" if user_sym == "X" else "X"
    current_turn = "X"

    while True:
        print_ui(board, score, user_sym, comp_sym)
        
        winner = check_winner(board)
        available = [item for row in board for item in row if item not in ["X", "O"]]
        
        # Win check
        if winner:
            if winner == user_sym:
                score['user'] += 1
                print("🎉 CONGRATULATIONS! YOU WON!")
            else:
                score['comp'] += 1
                print("🤖 COMPUTER WON!")
            break

        # Premature draw check
        if is_draw_guaranteed(board, current_turn) or not available:
            score['draw'] += 1
            print("🤝 DRAW! (The outcome is already determined)")
            break

        if current_turn == user_sym:
            move = input(f"Your turn ({user_sym}), enter cell number: ")
            found = False
            for r in range(3):
                for c in range(3):
                    if board[r][c] == move:
                        board[r][c] = user_sym
                        found = True
            if not found:
                logger.warning("Invalid move!"); input("Press Enter to continue..."); continue
        else:
            move = get_computer_move(board, comp_sym, user_sym)
            for r in range(3):
                for c in range(3):
                    if board[r][c] == move:
                        board[r][c] = comp_sym
        
        current_turn = "O" if current_turn == "X" else "X"

def main():
    score = {'user': 0, 'comp': 0, 'draw': 0}
    while True:
        play_round(score)
        print("\n" + "=" * 30)
        ans = input("Start a new round? (yes/no): ").lower().strip()
        if ans in ['no', 'n', 'ні', 'naw']:
            clear_screen()
            print(f"FINAL SCORE: You {score['user']} | Computer {score['comp']}\nGoodbye!")
            break

if __name__ == "__main__":
    main()