import random
import os

# ANSI escape codes for a professional terminal UI experience
GREEN = "\033[92m"
RED = "\033[91m"
CYAN = "\033[96m"
YELLOW = "\033[93m"
RESET = "\033[0m"
BOLD = "\033[1m"


def clear_screen():
    """Clears terminal for a clean, static-screen game feel."""
    os.system("cls" if os.name == "nt" else "clear")


def colorize(sym):
    """Dynamic symbol styling: X is Green, O is Red, numbers are subtle Grey."""
    if sym == "X":
        return f"{GREEN}{BOLD}X{RESET}"
    if sym == "O":
        return f"{RED}{BOLD}O{RESET}"
    return f"\033[90m{sym}{RESET}"


def print_ui(board, score, user_sym, comp_sym):
    """Main Render Engine: Combines a styled Scoreboard with a framed Grid."""
    clear_screen()
    print(f"{CYAN}┌──────────────────────────────────┐")
    print(f"│ {BOLD}TIC-TAC-TOE{RESET}{CYAN}                      │")
    print(f"├──────────────────────────────────┤")
    u_info = f"You ({user_sym}): {score['user']}"
    c_info = f"Comp ({comp_sym}): {score['comp']}"
    print(f"│ {u_info:<16} │ {c_info:<13} │")
    print(f"│ Draws: {score['draw']:<25} │")
    print(f"└──────────────────────────────────┘{RESET}")

    print("\n          ┌─────┬─────┬─────┐")
    for i, row in enumerate(board):
        c1, c2, c3 = [colorize(s) for s in row]
        print(f"          │  {c1}  │  {c2}  │  {c3}  │")
        if i < 2:
            print("          ├─────┼─────┼─────┤")
    print("          └─────┴─────┴─────┘\n")


def check_winner(board):
    """Scan winning coordinates to determine the round's victor."""
    win_coords = [
        [(0, 0), (0, 1), (0, 2)],
        [(1, 0), (1, 1), (1, 2)],
        [(2, 0), (2, 1), (2, 2)],
        [(0, 0), (1, 0), (2, 0)],
        [(0, 1), (1, 1), (2, 1)],
        [(0, 2), (1, 2), (2, 2)],
        [(0, 0), (1, 1), (2, 2)],
        [(0, 2), (1, 1), (2, 0)],
    ]
    for coord in win_coords:
        symbols = [board[r][c] for r, c in coord]
        if symbols[0] == symbols[1] == symbols[2] and symbols[0] in ["X", "O"]:
            return symbols[0]
    return None


def is_draw_inevitable(board):
    """
    Early Draw Detection: Ends the game if no winning lines are possible.
    This saves players from finishing obvious dead-end rounds.
    """
    win_coords = [
        [(0, 0), (0, 1), (0, 2)],
        [(1, 0), (1, 1), (1, 2)],
        [(2, 0), (2, 1), (2, 2)],
        [(0, 0), (1, 0), (2, 0)],
        [(0, 1), (1, 1), (2, 1)],
        [(0, 2), (1, 2), (2, 2)],
        [(0, 0), (1, 1), (2, 2)],
        [(0, 2), (1, 1), (2, 0)],
    ]
    dead_lines = 0
    for coord in win_coords:
        line = [board[r][c] for r, c in coord]
        # If both X and O are in a line, nobody can ever win that line.
        if "X" in line and "O" in line:
            dead_lines += 1
    return dead_lines == 8


def get_computer_move(board, comp_sym, user_sym, diff="2"):
    """
    Simulated Intelligence: Mimics human behavior by adding error probability.
    Higher difficulty reduces the chance of the AI making a random mistake.
    """
    error_rates = {"1": 0.5, "2": 0.2, "3": 0.0}
    difficulty = error_rates.get(diff, 0.2)

    available = [item for row in board for item in row if item not in ["X", "O"]]

    # Random chance for the AI to "miss" a perfect move
    if random.random() < difficulty:
        return random.choice(available)

    # Tactical Thinking: First, check if AI can win; then, block user's win.
    for sym in [comp_sym, user_sym]:
        for move in available:
            idx = int(move) - 1
            r, c = idx // 3, idx % 3
            board[r][c] = sym
            if check_winner(board) == sym:
                board[r][c] = move
                return move
            board[r][c] = move

    # Priority move: Center (5) is strategically superior.
    if "5" in available:
        return "5"
    return random.choice(available)


def play_round(score, last_winner):
    """Handles a single round cycle: Settings -> Game Loop -> Result."""
    board = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]]

    print(f"{CYAN}Select Difficulty: 1-Easy, 2-Medium, 3-Hard{RESET}")
    diff = input("Choice (1/2/3): ").strip()
    if diff not in ["1", "2", "3"]:
        diff = "2"

    # Persistence: Winner of the previous round keeps their symbol to maintain flow.
    if last_winner == "user":
        user_sym, comp_sym = "X", "O"
    elif last_winner == "comp":
        user_sym, comp_sym = "O", "X"
    else:
        user_sym = ""
        while user_sym not in ["X", "O"]:
            user_sym = input(f"{YELLOW}Choose symbol (X/O): {RESET}").upper()
        comp_sym = "O" if user_sym == "X" else "X"

    current_turn = "X"  # X always starts the match
    while True:
        print_ui(board, score, user_sym, comp_sym)
        winner_sym = check_winner(board)

        if winner_sym:
            if winner_sym == user_sym:
                score["user"] += 1
                print(f"{GREEN}🎉 YOU WON!{RESET}")
                return "user"
            else:
                score["comp"] += 1
                print(f"{RED}🤖 COMPUTER WON!{RESET}")
                return "comp"

        if is_draw_inevitable(board):
            score["draw"] += 1
            print(f"{YELLOW}🤝 DRAW!{RESET}")
            return "draw"

        if current_turn == user_sym:
            move = input(f"Your turn ({user_sym}): ").strip()

            # Crash prevention: Strictly validate user input for non-digits and out-of-bounds.
            if not move.isdigit() or int(move) not in range(1, 10):
                input(f"{RED}Invalid input! Enter 1-9. (Press Enter){RESET}")
                continue

            found = False
            for r in range(3):
                for c in range(3):
                    if board[r][c] == move:
                        board[r][c] = user_sym
                        found = True

            if not found:
                input(f"{RED}Cell already taken! Try again. (Press Enter){RESET}")
                continue
        else:
            move = get_computer_move(board, comp_sym, user_sym, diff)
            for r in range(3):
                for c in range(3):
                    if board[r][c] == move:
                        board[r][c] = comp_sym

        current_turn = "O" if current_turn == "X" else "X"


def main():
    """Application Entry Point: Maintains persistent score across multiple rounds."""
    score = {"user": 0, "comp": 0, "draw": 0}
    last_winner = None
    while True:
        last_winner = play_round(score, last_winner)
        ans = input(f"\n{CYAN}Another round? (y/n): {RESET}").lower().strip()

        if ans not in ["y", "yes"]:
            print(
                f"\n{BOLD}Final Score: You {score['user']} | Computer {score['comp']} | Draws {score['draw']}{RESET}"
            )
            print(f"{GREEN}Goodbye! Thanks for the game!{RESET}")
            break


if __name__ == "__main__":
    main()
