import random
import logging
import os

# Logging configuration
logging.basicConfig(format='%(levelname)s: %(message)s')
logger = logging.getLogger()

def clear_screen():
    """Clears the terminal screen depending on the operating system"""
    os.system('cls' if os.name == 'nt' else 'clear')

def print_ui(board, score, user_sym, comp_sym):
    """Displays the current score and the game board"""
    clear_screen()
    print("=" * 25)
    print(f" SCORE: You ({user_sym}) {score['user']} : {score['comp']} Comp ({comp_sym})")
    print(f" Draws: {score['draw']}")
    print("=" * 25)
    
    print("\n" + " " * 6 + "-" * 13)
    for row in board:
        print(" " * 6 + f"| {row[0]} | {row[1]} | {row[2]} |")
        print(" " * 6 + "-" * 13)
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

def get_computer_move(board, comp_sym, user_sym):
    """Computer AI logic: 80% IQ level (looks for win/block)"""
    available_moves = [item for row in board for item in row if item not in ["X", "O"]]
    
    # 20% chance of making a random move for 'human-like' gameplay
    if random.random() > 0.8:
        return random.choice(available_moves)

    # Win or Block logic
    for sym in [comp_sym, user_sym]:
        for move in available_moves:
            idx = int(move) - 1
            r, c = idx // 3, idx % 3
            board[r][c] = sym
            is_win = (check_winner(board) == sym)
            board[r][c] = move # Rollback
            if is_win:
                return move
    
    # Take center if available
    if "5" in available_moves: return "5"
    return random.choice(available_moves)

def play_round(score):
    """Handles a single round of the game"""
    board = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]
    
    user_sym = ""
    while user_sym not in ["X", "O"]:
        user_sym = input("Choose your symbol (X / O): ").upper()
        if user_sym not in ["X", "O"]:
            logger.warning("Please enter only X or O")

    comp_sym = "O" if user_sym == "X" else "X"
    current_turn = "X"

    while True:
        print_ui(board, score, user_sym, comp_sym)
        
        winner = check_winner(board)
        available = [item for row in board for item in row if item not in ["X", "O"]]
        
        if winner:
            if winner == user_sym:
                score['user'] += 1
                print("🎉 You won!")
            else:
                score['comp'] += 1
                print("🤖 Computer won!")
            break
        
        if not available:
            score['draw'] += 1
            print("🤝 It's a draw!")
            break

        if current_turn == user_sym:
            move = input(f"Your turn ({user_sym}), enter number: ")
            found = False
            for r in range(3):
                for c in range(3):
                    if board[r][c] == move:
                        board[r][c] = user_sym
                        found = True
            if not found:
                logger.warning("Invalid move!")
                input("Press Enter to continue...")
                continue
        else:
            move = get_computer_move(board, comp_sym, user_sym)
            for r in range(3):
                for c in range(3):
                    if board[r][c] == move:
                        board[r][c] = comp_sym
        
        current_turn = "O" if current_turn == "X" else "X"

def main():
    # Overall score tracker across all games
    score = {'user': 0, 'comp': 0, 'draw': 0}
    
    while True:
        play_round(score)
        
        print("\n" + "=" * 25)
        again = input("Play another round? (yes/no): ").lower()
        if again not in ['yes', 'y']:
            print(f"\nFinal Score - You {score['user']} : {score['comp']} Computer")
            print("Thanks for playing!")
            break

if __name__ == "__main__":
    main()