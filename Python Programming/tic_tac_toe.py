# Create a board with numbers from 1 to 9
board = [
    ["1", "2", "3"],
    ["4", "5", "6"],
    ["7", "8", "9"]
]

def print_board(board):
    print("\n" + "-" * 13)
    for row in board:
        print(f"| {row[0]} | {row[1]} | {row[2]} |")
        print("-" * 13)

current_player = "X"

while True:
    print_board(board)
    choice = input(f"Player {current_player}, choose a number (1-9): ")

    # Look for the entered number on the board and replace it
    found = False
    for row in range(3):
        for col in range(3):
            if board[row][col] == choice:
                board[row][col] = current_player
                found = True
                break
        if found: break # Exit the outer loop once the number is found
    
    if found:
        # Switch the player
        current_player = "O" if current_player == "X" else "X"
    else:
        print("\nError! Choose an available number that is on the board.")

