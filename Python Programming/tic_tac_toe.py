# 1. Create a board dimensions
board = [[" " for _ in range(3)] for _ in range(3)]

# 2. Doard visibility
def print_board(board):
    print("\n" + "-" * 13)
    for row in board:
        print(f"| {row[0]} | {row[1]} | {row[2]} |")
        print("-" * 13)

# 3. Main game cycle
current_player = "X"

while True:
    print_board(board)
    
    print(f"Зараз ходить: {current_player}")
    
    # Ask the coordinates for input
    try:
        row = int(input("Choose the row (1, 2, 3): ")) - 1
        col = int(input("Choose the column (1, 2, 3): ")) - 1
        
        # Validation of input
        if 0 <= row < 3 and 0 <= col < 3:
            if board[row][col] == " ":
                board[row][col] = current_player
                
                # Next move
                current_player = "O" if current_player == "X" else "X"
            else:
                print("\nchoose the empty cell")
        else:
            print("\nchoosse a number from 1 to 3")
            
    except ValueError:
        print("\nOnly numbers are valid")

    # The cycle is continious and can be interrupted with Ctrl+C 