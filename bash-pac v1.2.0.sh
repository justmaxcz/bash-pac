#!/bin/bash

# Function to display the animation
function display_animation() {
  clear
  echo "G    C"
  sleep 0.3
  clear
  echo "G   C"
  sleep 0.3
  clear
  echo "G  C"
  sleep 0.3
  clear
  echo "G  C"
  sleep 0.3
  clear
  echo "G C"
  sleep 0.3
  clear
  echo "GC"
  sleep 0.3
  clear
  echo "GC."
  sleep 0.3
  clear
  echo -e "\e[91mbash-pac v1.1.5 B\e[0m"
  sleep 0.4
  clear
}

# Start the animation
display_animation

# Function to spawn additional enemies when the player collects food
function spawn_enemy() {
  ghost_row=$((RANDOM % (${#board[@]} - 2) + 1))
  ghost_col=$((RANDOM % (${#board[0]} - 2) + 1))
  board[$ghost_row]=${board[$ghost_row]:0:$ghost_col}$ghost${board[$ghost_row]:$((ghost_col + 1))}
}

# Function to start the game
function start_game() {
  # Pac-Man clone in Bash

  # Initialize variables
  player="C"
  ghost="G"
  empty=" "
  wall="#"
  food="."
  score=0
  food_collected=0  # Variable to track the number of food items collected by the player

  # Define the game board
  declare -a board=(
    "####################################"
    "#C                                 #"
    "#                                  #"
    "#                                  #"
    "#                                  #"
    "#                                  #"
    "#                                  #"
    "#                                  #"
    "#                                  #"
    "#                                  #"
    "####################################"
  )

  # Function to print the game board
  function print_board() {
    clear
    for row in "${board[@]}"; do
      echo "$row"
    done
    echo "Score: $score"
  }

  # Function to check if a given position is valid on the board
  function is_valid_position() {
    local row=$1
    local col=$2
    [[ $row -ge 0 && $row -lt ${#board[@]} && $col -ge 0 && $col -lt ${#board[0]} ]]
  }

  # Function to move the player
  function move_player() {
    local new_row=$((player_row + $1))
    local new_col=$((player_col + $2))

    if is_valid_position $new_row $new_col && [[ ${board[$new_row]:$new_col:1} != "$wall" ]]; then
      if [[ ${board[$new_row]:$new_col:1} == "$food" ]]; then
        ((score++))
        ((food_collected++))
        if ((food_collected == 2)); then
          spawn_enemy  # Spawn enemy when the player collects 2 food items
          food_collected=0  # Reset the food collected counter
        fi
      fi
      board[$player_row]=${board[$player_row]:0:$player_col}$empty${board[$player_row]:$((player_col + 1))}
      player_row=$new_row
      player_col=$new_col
      board[$player_row]=${board[$player_row]:0:$player_col}$player${board[$player_row]:$((player_col + 1))}
    fi
  }

  # Function to move the ghosts
  function move_ghosts() {
    for ((i = 0; i < ${#board[@]}; i++)); do
      for ((j = 0; j < ${#board[0]}; j++)); do
        if [[ ${board[$i]:$j:1} == "$ghost" ]]; then
          local player_distance=1000
          local next_row=$i
          local next_col=$j

          local dirs=(-1 0 1 0 0 -1 0 1)

          # Find the direction that minimizes distance to the player
          for ((dir = 0; dir < 4; dir++)); do
            local dr=$((i + dirs[dir * 2]))
            local dc=$((j + dirs[dir * 2 + 1]))
            local dist=$(( (player_row - dr) ** 2 + (player_col - dc) ** 2 ))
            if [[ $dist -lt $player_distance ]]; then
              player_distance=$dist
              next_row=$dr
              next_col=$dc
            fi
          done

          # Move the ghost
          if is_valid_position $next_row $next_col && [[ ${board[$next_row]:$next_col:1} != "$wall" ]]; then
            board[$i]=${board[$i]:0:$j}$empty${board[$i]:$((j + 1))}
            board[$next_row]=${board[$next_row]:0:$next_col}$ghost${board[$next_row]:$((next_col + 1))}
          fi
        fi
      done
    done
  }

  # Function to spawn ghosts at random positions
  function spawn_ghosts() {
    ghost_row=$((RANDOM % (${#board[@]} - 2) + 1))
    ghost_col=$((RANDOM % (${#board[0]} - 2) + 1))
    board[$ghost_row]=${board[$ghost_row]:0:$ghost_col}$ghost${board[$ghost_row]:$((ghost_col + 1))}
  }

  # Function to spawn food at random positions
  function spawn_food() {
    local row
    local col
    local num_food=20  # Adjust the number of food items here
    for ((i = 0; i < num_food; i++)); do
      row=$((RANDOM % (${#board[@]} - 2) + 1))
      col=$((RANDOM % (${#board[0]} - 2) + 1))
      if [[ ${board[$row]:$col:1} == "$empty" ]]; then
        board[$row]=${board[$row]:0:$col}$food${board[$row]:$((col + 1))}
      fi
    done
  }

  # Function to check if the game is over with a timer
  function game_over_with_timer() {
    print_board
    local answer
    while true; do
      read -p "You died! Do you want to restart? (yes/no): " answer
      if [[ "$answer" == "yes" || "$answer" == "no" ]]; then
        break
      else
        echo "Please type 'yes' or 'no'"
      fi
    done

    if [ "$answer" == "yes" ]; then
      reset_game
    else
      echo "Goodbye!"
      exit
    fi
  }

  # Function to display the victory message
  function game_over_with_victory() {
    print_board
    echo "Congratulations! You collected all the food. You win!"
    read -p "Press Enter to return to the main menu or type 'exit' to quit: " answer
    if [ "$answer" == "" ]; then
      main_menu
    elif [ "$answer" == "exit" ]; then
      echo "Goodbye!"
      exit
    else
      echo "Invalid input. Returning to the main menu."
      main_menu
    fi
  }

  # Function to reset the game
  function reset_game() {
    player_row=1
    player_col=1
    score=0
    food_collected=0
    board=(
    "####################################"
    "#C                                 #"
    "#                                  #"
    "#                                  #"
    "#                                  #"
    "#                                  #"
    "#                                  #"
    "#                                  #"
    "#                                  #"
    "#                                  #"
    "####################################"
    )
    spawn_ghosts
    spawn_food
    player_died=false  # Reset the player_died flag
  }

  # Initialize player position
  player_row=1
  player_col=1

  # Initialize enemy directions
  dirs=(-1 0 1 0 0 -1 0 1)

  # Spawn ghosts
  spawn_ghosts

  # Spawn food
  spawn_food

  # Flag to track if the player has died
  player_died=false

  # Main game loop
  while true; do
    print_board

    # Read user input
    read -rsn1 direction

    # Move player based on input
    case $direction in
      "w") move_player -1 0 ;;
      "s") move_player 1 0 ;;
      "a") move_player 0 -1 ;;
      "d") move_player 0 1 ;;
      "q") echo "Goodbye!"; exit ;;
      "o") main_menu ;;
      *) ;;
    esac

    # Move ghosts
    move_ghosts

    # Check if the player is dead
    if $player_died; then
      game_over_with_timer
    fi

    # Check if the player is dead after the move
    if [[ ${board[$player_row]:$player_col:1} == "$ghost" ]]; then
      player_died=true
    fi

    # Check if all food is collected
    if [[ $(grep -o "$food" <<< "${board[*]}") == "" ]]; then
      game_over_with_victory
    fi
  done
}

# Function to display help information
function display_help() {
  clear
  
  echo "made by stuffbymax"
  echo "------------------"
  echo -e "\e[91mversion\e[0m"
  echo -e "\e[91mbash-pac v1.1.5 B\e[0m"
  echo "-------------------"
  echo "Game Instructions"
  echo "------------------"
  echo "Player character: (C)"
  echo
  echo "Avoid the ghost (G) while collecting food (.) to increase your score."
  echo
  echo "Controls:"
  echo "------------------"
  echo "W: Move Up"
  echo "A: Move Left"
  echo "S: Move Down"
  echo "D: Move Right"
  echo
  echo "In-game shortcuts:"
  echo "------------------"
  echo "Q: Exit bash-pac"
  echo "o: Return to the main menu"
  echo "--------------------------"
  echo -e "\e[42mGreen thanks you for downloading\e[0m"
  echo "--------------------------"
  echo "Press Enter to continue..."
  read -r
}

# Function to exit the script
function exit_game() {
  echo "Goodbye!"
  exit
}

# Function to display the main menu
function main_menu() {
  while true; do
    # Main menu
    clear
    echo "Options:"
    echo "1. Start"
    echo "2. Help"
    echo "3. Exit"

    # Wait for any key press
    read -n 1 key

    # Read user input for option
    read -n 1 option

    case $option in
      "1") start_game ;;
      "2") display_help ;;
      "3") exit_game ;;
      *) ;;
    esac
  done
}

# Start the main menu
main_menu
