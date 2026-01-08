#!/usr/bin/env Rscript



# --- Setup Input Handling ---

if (interactive()) {
  
  con <- stdin()
  
} else {
  
  con <- "stdin"
  
}



# --- helper Functions ---



# Display the board aesthetically

display_board <- function(board) {
  
  cat("\n")
  
  for (i in 1:3) {
    
    row_idx <- ((i - 1) * 3 + 1):(i * 3)
    
    # Replace NA with position numbers for easier choice
    
    display_row <- ifelse(is.na(board[row_idx]), as.character(row_idx), board[row_idx])
    
    cat(" ", display_row[1], " | ", display_row[2], " | ", display_row[3], "\n")
    
    if (i < 3) cat("----------- \n")
    
  }
  
  cat("\n")
  
}



# Check for a winner

check_winner <- function(board) {
  
  # Winning combinations
  
  wins <- list(
    
    c(1, 2, 3), c(4, 5, 6), c(7, 8, 9), # Rows
    
    c(1, 4, 7), c(2, 5, 8), c(3, 6, 9), # Cols
    
    c(1, 5, 9), c(3, 5, 7)             # Diagonals
    
  )
  
  
  
  for (combo in wins) {
    
    line <- board[combo]
    
    if (!any(is.na(line)) && length(unique(line)) == 1) {
      
      return(line[1])
      
    }
    
  }
  
  
  
  if (all(!is.na(board))) return("Tie")
  
  return(NULL)
  
}



# Validate user input

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
  
  
  
  # 1. Choose Symbol
  
  player_sym <- get_valid_input("Do you want to be X or O? ", c("X", "O"))
  
  comp_sym <- if (player_sym == "X") "O" else "X"
  
  
  
  board <- rep(NA, 9)
  
  current_turn <- "X" # X always goes firstЧ
  
  winner <- NULL
  
  
  
  cat(sprintf("\nGame Start! You are %s. Computer is %s.\n", player_sym, comp_sym))
  
  
  
  while (is.null(winner)) {
    
    display_board(board)
    
    
    
    if (current_turn == player_sym) {
      
      # Player Turn
      
      cat("Your turn!\n")
      
      available_moves <- as.character(which(is.na(board)))
      
      move <- get_valid_input("Choose a position (1-9): ", available_moves)
      
      board[as.numeric(move)] <- player_sym
      
    } else {
      
      # Computer Turn
      
      cat("Computer is thinking...")
      
      Sys.sleep(1)
      
      available_moves <- which(is.na(board))
      
      # Simple AI: Pick random available spot
      
      move <- sample(available_moves, 1)
      
      board[move] <- comp_sym
      
      cat(sprintf("\nComputer chose position %d\n", move))
      
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



# Run the game

play_game()