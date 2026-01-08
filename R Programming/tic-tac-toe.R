#!/usr/bin/env Rscript

# --- Setup Input Handling ---
if (interactive()) {
  con <- stdin()
} else {
  con <- "stdin"
}

# --- Global Constants ---
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

# --- Main Game Function ---

play_game <- function() {
  cat("\n--- NEW MATCH ---")
  player_sym <- get_valid_input("\nDo you want to be X or O? ", c("X", "O"))
  comp_sym <- if (player_sym == "X") "O" else "X"
  
  board <- rep(NA, 9)
  current_turn <- "X" # X always starts
  winner_sym <- NULL
  
  while (is.null(winner_sym)) {
    display_board(board)
    
    if (current_turn == player_sym) {
      cat("Your turn!\n")
      available_moves <- as.character(which(is.na(board)))
      move_input <- get_valid_input("Choose a position (1-9): ", available_moves)
      board[as.numeric(move_input)] <- player_sym
    } else {
      cat("Computer is thinking...\n")
      Sys.sleep(0.8)
      available_moves <- which(is.na(board))
      move <- NULL
      
      # AI Strategy
      if (sum(!is.na(board)) <= 1) {
        move <- if(length(available_moves) > 1) sample(available_moves, 1) else available_moves
      } else {
        # 1. Win
        for (combo in wins) {
          line <- board[combo]
          if (sum(line == comp_sym, na.rm = TRUE) == 2 && sum(is.na(line)) == 1) {
            move <- combo[is.na(line)]; break
          }
        }
        # 2. Attack
        if (is.null(move)) {
          for (combo in wins) {
            line <- board[combo]
            if (sum(line == comp_sym, na.rm = TRUE) >= 1 && sum(line == player_sym, na.rm = TRUE) == 0) {
              potential <- combo[is.na(line)]
              move <- if(length(potential) > 1) sample(potential, 1) else potential; break
            }
          }
        }
        # 3. Block
        if (is.null(move)) {
          for (combo in wins) {
            line <- board[combo]
            if (sum(line == player_sym, na.rm = TRUE) == 2 && sum(is.na(line)) == 1) {
              move <- combo[is.na(line)]; break
            }
          }
        }
      }
      if (is.null(move)) move <- if(length(available_moves) > 1) sample(available_moves, 1) else available_moves
      board[move] <- comp_sym
    }
    winner_sym <- check_winner(board)
    current_turn <- if (current_turn == "X") "O" else "X"
  }
  
  display_board(board)
  
  # Determine the result for the scoreboard
  if (winner_sym == "Tie") {
    cat("Result: It's a draw!\n")
    return("tie")
  } else if (winner_sym == player_sym) {
    cat("Result: You won this round!\n")
    return("human")
  } else {
    cat("Result: Computer won this round.\n")
    return("computer")
  }
}

# --- Session Management ---

score <- list(human = 0, computer = 0, ties = 0)

cat("=== Welcome to R Tic-Tac-Toe! ===\n")

while (TRUE) {
  result <- play_game()
  
  # Update internal score list
  if (result == "human") score$human <- score$human + 1
  if (result == "computer") score$computer <- score$computer + 1
  if (result == "tie") score$ties <- score$ties + 1
  
  # Ask to continue
  choice <- get_valid_input("\nWould you like to play another match? (Y/N): ", c("Y", "N"))
  
  if (choice == "N") {
    cat("\n" , paste(rep("=", 20), collapse = ""), "\n")
    cat("      FINAL SCORE\n")
    cat(paste(rep("-", 20), collapse = ""), "\n")
    cat(sprintf("  Human:    %d\n", score$human))
    cat(sprintf("  Computer: %d\n", score$computer))
    cat(sprintf("  Ties:     %d\n", score$ties))
    cat(paste(rep("=", 20), collapse = ""), "\n")
    cat("Thank you for playing! Goodbye.\n")
    break
  }
}