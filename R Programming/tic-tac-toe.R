#!/usr/bin/env Rscript

# --- Setup Input Handling ---
if (interactive()) {
  con <- stdin()
} else {
  con <- "stdin"
}

# --- Global Constants ---
# Global 'wins' accessible by all functions
wins <- list(
  c(1, 2, 3), c(4, 5, 6), c(7, 8, 9), # Rows
  c(1, 4, 7), c(2, 5, 8), c(3, 6, 9), # Cols
  c(1, 5, 9), c(3, 5, 7)              # Diagonals
)

# --- Helper Functions ---

display_board <- function(board) {
  cat("\n")
  for (i in 1:3) {
    row_idx <- ((i - 1) * 3 + 1):(i * 3)
    display_row <- ifelse(is.na(board[row_idx]), as.character(row_idx), board[row_idx])
    cat(" ", display_row[1], " | ", display_row[2], " | ", display_row[3], "\n")
    if (i < 3) cat("----------- \n")
  }
  cat("\n")
}

check_winner <- function(board) {
  for (combo in wins) {
    line <- board[combo]
    if (!any(is.na(line)) && length(unique(line)) == 1) {
      return(line[1])
    }
  }
  if (all(!is.na(board))) return("Tie")
  return(NULL)
}

get_valid_input <- function(prompt_msg, valid_options) {
  while (TRUE) {
    cat(prompt_msg)
    user_input <- trimws(toupper(readLines(con = con, n = 1)))
    if (user_input %in% valid_options) {
      return(user_input)
    } else {
      cat("Invalid input. Please try again.\n")
    }
  }
}

# --- Main Game Loop ---

play_game <- function() {
  cat("=== Welcome to R Tic-Tac-Toe! ===\n")
  Sys.sleep(0.5)
  
  player_sym <- get_valid_input("Do you want to be X or O? ", c("X", "O"))
  comp_sym <- if (player_sym == "X") "O" else "X"
  
  board <- rep(NA, 9)
  current_turn <- "X" # X always goes first
  winner <- NULL
  
  cat(sprintf("\nGame Start! You are %s. Computer is %s.\n", player_sym, comp_sym))
  
  while (is.null(winner)) {
    display_board(board)
    
    if (current_turn == player_sym) {
      # --- Player Turn ---
      cat("Your turn!\n")
      available_moves <- as.character(which(is.na(board)))
      move_input <- get_valid_input("Choose a position (1-9): ", available_moves)
      board[as.numeric(move_input)] <- player_sym
    } else {
      # --- Computer Turn (Aggressive AI) ---
      cat("Computer is thinking...\n")
      Sys.sleep(1)
      
      available_moves <- which(is.na(board))
      move <- NULL
      
      # 1. First Move Randomness
      if (sum(!is.na(board)) <= 1) {
        move <- if(length(available_moves) > 1) sample(available_moves, 1) else available_moves
      } else {
        # 2. IMMEDIATE WIN
        for (combo in wins) {
          line <- board[combo]
          if (sum(line == comp_sym, na.rm = TRUE) == 2 && sum(is.na(line)) == 1) {
            move <- combo[is.na(line)]
            break
          }
        }
        
        # 3. STRATEGIC ATTACK (Open Road)
        if (is.null(move)) {
          for (combo in wins) {
            line <- board[combo]
            if (sum(line == comp_sym, na.rm = TRUE) >= 1 && sum(line == player_sym, na.rm = TRUE) == 0) {
              potential <- combo[is.na(line)]
              move <- if(length(potential) > 1) sample(potential, 1) else potential
              break
            }
          }
        }
        
        # 4. DEFENSIVE BLOCK
        if (is.null(move)) {
          for (combo in wins) {
            line <- board[combo]
            if (sum(line == player_sym, na.rm = TRUE) == 2 && sum(is.na(line)) == 1) {
              move <- combo[is.na(line)]
              break
            }
          }
        }
      }
      
      # 5. Fallback
      if (is.null(move)) {
        move <- if(length(available_moves) > 1) sample(available_moves, 1) else available_moves
      }
      
      board[move] <- comp_sym
      cat(sprintf("Computer chose position %d\n", move))
    }
    
    winner <- check_winner(board)
    current_turn <- if (current_turn == "X") "O" else "X"
  }
  
  # --- Game Over ---
  display_board(board)
  if (winner == "Tie") {
    cat("It's a draw! Well played.\n")
  } else if (winner == player_sym) {
    cat("Congratulations! You won!\n")
  } else {
    cat("The computer won. Better luck next time!\n")
  }
}

play_game()