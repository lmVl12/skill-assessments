import random
import logging
import os

# Logging configuration
logging.basicConfig(format='%(levelname)s: %(message)s')
logger = logging.getLogger()

def clear_screen():
    """Clears the terminal screen based on the operating system"""
    os.system('cls' if os.name == 'nt' else 'clear')

def print_ui(board, score, user_sym, comp_sym):
    """Displays the scoreboard and the static game board"""
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
    """Checks the board for any winning combinations"""
    win_coords = [
        [(0,0), (0,1), (0,2)], [(1,0), (1,1), (1,2)], [(2,0), (2,1), (2,2)],
        [(0,0), (1,0), (2,0)], [(0,1), (1,1), (2,1)], [(0,2), (1,2), (2,2)],
        [(0,0), (1,1), (2,2)], [(0,2), (1,1), (2,0)]
    ]
    for coord in win_coords:
        symbols = [board[r][c] for r, c in coord]
        if symbols[0] == symbols[1] == symbols[2] and symbols[0] in ["X", "O"]:
            return symbols[0]
    return None

def is_draw_guaranteed(board, current_sym):
    """Predicts a draw if only one move remains and it won't result in a win"""
    available = [item for row in board for item in row if item not in ["X", "O"]]
    if len(available) == 1:
        move = available[0]
        idx = int(move) - 1
        r, c = idx // 3, idx % 3
        
        # Simulate the final move
        board[r][c] = current_sym
        winner = check_winner(board)
        board[r][c] = move  # Rollback
        
        return winner is None
    return False

def get_computer_move(board, comp_sym, user_sym):
    """Computer AI logic: 80% IQ (prioritizes winning or blocking)"""
    available = [item for row in board for item in row if item not in ["X", "O"]]
    
    # 20% chance of a random move for variety
    if random.random() > 0.8: 
        return random.choice(available)

    # Check for immediate win or necessary block
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

def play_round(score, last_winner):
    """Handles logic for a single game round"""
    board = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]
    
    # Assign symbols based on the previous round's winner
    if last_winner == "user":
        print("You won last time, so you play as X!")
        user_sym, comp_sym = "X", "O"
    elif last_winner == "comp":
        print("Computer won last time and takes X!")
        user_sym, comp_sym = "O", "X"
    else:
        user_sym = ""
        while user_sym not in ["X", "O"]:
            user_sym = input("Last round was a draw (or first game). Choose your symbol (X / O): ").upper()
        comp_sym = "O" if user_sym == "X" else "X"

    current_turn = "X"
    round_winner_key = None

    while True:
        print_ui(board, score, user_sym, comp_sym)
        winner_sym = check_winner(board)
        available = [item for row in board for item in row if item not in ["X", "O"]]
        
        if winner_sym:
            if winner_sym == user_sym:
                score['user'] += 1
                round_winner_key = "user"
                print("🎉 CONGRATULATIONS! YOU WON!")
            else:
                score['comp'] += 1
                round_winner_key = "comp"
                print("🤖 COMPUTER WON!")
            break

        if is_draw_guaranteed(board, current_turn) or not available:
            score['draw'] += 1
            round_winner_key = "draw"
            print("🤝 IT'S A DRAW!")
            break

        if current_turn == user_sym:
            move = input(f"Your turn ({user_sym}): ")
            found = False
            for r in range(3):
                for c in range(3):
                    if board[r][c] == move:
                        board[r][c] = user_sym
                        found = True
            if not found:
                logger.warning("Invalid move!"); input("Press Enter..."); continue
        else:
            move = get_computer_move(board, comp_sym, user_sym)
            for r in range(3):
                for c in range(3):
                    if board[r][c] == move:
                        board[r][c] = comp_sym
        
        current_turn = "O" if current_turn == "X" else "X"
    
    return round_winner_key

def main():
    """Main game loop and permanent score tracking"""
    score = {'user': 0, 'comp': 0, 'draw': 0}
    last_winner = None 
    
    while True:
        last_winner = play_round(score, last_winner)
        print("\n" + "=" * 30)
        ans = input("Start another round? (yes/no): ").lower().strip()
        if ans in ['no', 'n', 'ні']:
            print(f"Final Score: You {score['user']} | Computer {score['comp']}. Goodbye!")
            break

if __name__ == "__main__":
    main()