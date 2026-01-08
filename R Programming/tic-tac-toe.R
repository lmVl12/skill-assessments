#!/usr/bin/env Rscript

# --- Setup ---
if (interactive()) { con <- stdin() } else { con <- "stdin" }

wins <- list(
  c(1, 2, 3), c(4, 5, 6), c(7, 8, 9),
  c(1, 4, 7), c(2, 5, 8), c(3, 6, 9),
  c(1, 5, 9), c(3, 5, 7)
)

# --- Universal Clear (Fixed for Windows CMD) ---
clear_screen <- function() {
  # 1. Handle RStudio Console
  if (.Platform$GUI == "RStudio" || exists("utils::menu")) {
    cat("\014")
  }
  
  # 2. Handle Windows Command Prompt / PowerShell
  if (.Platform$OS.type == "windows") {
    # This is the most reliable way to clear a Windows terminal in R
    shell("cls")
  } else {
    # 3. Handle Linux / Mac Terminals
    system("clear")
  }
}

display_board <- function(board, score) {
  clear_screen()
  cat(" ===================================\n")
  cat(sprintf(" SCORE | Human: %d | Computer: %d | Ties: %d\n", 
              score$human, score$computer, score$ties))
  cat(" ===================================\n\n")
  
  for (i in 1:3) {
    row_idx <- ((i - 1) * 3 + 1):(i * 3)
    display_row <- ifelse(is.na(board[row_idx]), as.character(row_idx), board[row_idx])
    cat("      ", display_row[1], " | ", display_row[2], " | ", display_row[3], "\n")
    if (i < 3) cat("     ----------- \n")
  }
  cat("\n")
}

check_winner <- function(board) {
  for (combo in wins) {
    line <- board[combo]
    if (!any(is.na(line)) && length(unique(line)) == 1) return(line[1])
  }
  if (all(!is.na(board))) return("Tie")
  return(NULL)
}

get_valid_input <- function(prompt_msg, valid_options) {
  while (TRUE) {
    cat(prompt_msg)
    user_input <- trimws(toupper(readLines(con = con, n = 1)))
    if (length(user_input) > 0 && user_input %in% valid_options) return(user_input)
    cat(" ! Invalid input. Try again.\n")
  }
}

# --- Main Game ---
play_game <- function(current_score) {
  clear_screen()
  cat(" ===================================\n")
  cat(sprintf(" SCORE | Human: %d | Computer: %d | Ties: %d\n", 
              current_score$human, current_score$computer, current_score$ties))
  cat(" ===================================\n\n")
  
  player_sym <- get_valid_input(" >> Choose your symbol (X/O): ", c("X", "O"))
  comp_sym <- if (player_sym == "X") "O" else "X"
  
  board <- rep(NA, 9)
  current_turn <- "X"
  winner_sym <- NULL
  
  while (is.null(winner_sym)) {
    display_board(board, current_score)
    
    if (current_turn == player_sym) {
      cat(" >> Your turn!\n")
      available_moves <- as.character(which(is.na(board)))
      move_input <- get_valid_input(" Choose (1-9): ", available_moves)
      board[as.numeric(move_input)] <- player_sym
    } else {
      cat(" >> Computer is thinking...\n")
      Sys.sleep(0.8)
      
      available_moves <- which(is.na(board))
      move <- NULL
      # AI Logic
      for (sym in c(comp_sym, player_sym)) {
        if (!is.null(move)) break
        for (combo in wins) {
          line <- board[combo]
          if (sum(line == sym, na.rm = TRUE) == 2 && sum(is.na(line)) == 1) {
            move <- combo[is.na(line)]; break
          }
        }
      }
      if (is.null(move)) move <- if(length(available_moves) > 1) sample(available_moves, 1) else available_moves
      board[move] <- comp_sym
    }
    winner_sym <- check_winner(board)
    current_turn <- if (current_turn == "X") "O" else "X"
  }
  
  display_board(board, current_score)
  if (winner_sym == "Tie") return("tie")
  return(if (winner_sym == player_sym) "human" else "computer")
}

# --- Execution ---
score_tracker <- list(human = 0, computer = 0, ties = 0)

while (TRUE) {
  result <- play_game(score_tracker)
  
  if (result == "human") score_tracker$human <- score_tracker$human + 1
  else if (result == "computer") score_tracker$computer <- score_tracker$computer + 1
  else score_tracker$ties <- score_tracker$ties + 1
  
  if (result == "human") cat(" *** YOU WON! ***\n")
  else if (result == "computer") cat(" --- COMPUTER WON ---\n")
  else cat(" --- TIE GAME ---\n")
  
  choice <- get_valid_input(" >> Play another match? (Y/N): ", c("Y", "N"))
  if (choice == "N") break
}

clear_screen()
cat("\n FINAL SESSION SCORE\n Human:", score_tracker$human, "| Computer:", score_tracker$computer, "| Ties:", score_tracker$ties, "\n Goodbye!\n")