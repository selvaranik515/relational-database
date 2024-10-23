#!/bin/bash

# Variable to query database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt user for username
echo "Enter your username:"
read USERNAME

# Check if the user exists in the database
USER_INFO=$($PSQL "SELECT user_id, username FROM users WHERE username='$USERNAME'")
USER_ID=$(echo $USER_INFO | cut -d '|' -f1)

# If the user doesn't exist, insert the user into the database
if [[ -z $USER_INFO ]]; then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # Fetch games played and best game
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_guess) FROM games WHERE user_id = $USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate random number between 1 and 1000
RANDOM_NUM=$((1 + $RANDOM % 1000))
GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"

# Guessing loop
while read GUESS; do
  # Check if the input is a valid integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  else
    # Increment guess count
    GUESS_COUNT=$((GUESS_COUNT + 1))

    # Check if the guess is correct
    if [[ $GUESS -eq $RANDOM_NUM ]]; then
      echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUM. Nice job!"
      break
    elif [[ $GUESS -gt $RANDOM_NUM ]]; then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  fi
done

# Insert the game result into the database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
INSERT_GAME=$($PSQL "INSERT INTO games(number_guess, user_id) VALUES($GUESS_COUNT, $USER_ID)")