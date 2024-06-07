#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"

RANDOM_NUMBER=$(( 1 + RANDOM % 1000 ))
NUMBER_ATTEMPTS=0

MAIN_MENU() {

  echo "Enter your username:"
  read USERNAME

  if [[ $USERNAME ]]
  then
    USER_NAME_DATA=$($PSQL "SELECT * FROM guess_data WHERE username = '$USERNAME'")

    if [[ -z $USER_NAME_DATA ]]
    then  
      echo "Welcome, $USERNAME! It looks like this is your first time here."    
      echo "Guess the secret number between 1 and 1000:"
      ATTEMPTS  

    else    
      USER_GAMES_PLAYED=$($PSQL "SELECT COUNT(username) FROM guess_data WHERE username = '$USERNAME'")
      USER_BEST_GAME=$($PSQL "SELECT MIN(games) FROM guess_data WHERE username = '$USERNAME'")
     
      echo $USER_NAME_DATA | while read username BAR games
      do
        echo "Welcome back, $username! You have played $USER_GAMES_PLAYED games, and your best game took $USER_BEST_GAME guesses."
      done

      echo "Guess the secret number between 1 and 1000:"
      ATTEMPTS
    
    fi
  fi

}

ATTEMPTS() {  
  
  read GUESS_NUMBER  

  if ! [[ $GUESS_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    ATTEMPTS
  else
    if [[ $GUESS_NUMBER > $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:" 
      ((NUMBER_ATTEMPTS += 1))      
      ATTEMPTS

    elif [[ $GUESS_NUMBER < $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"  
      ((NUMBER_ATTEMPTS += 1))      
      ATTEMPTS

    elif [[ $GUESS_NUMBER == $RANDOM_NUMBER ]]
    then
      ((NUMBER_ATTEMPTS += 1))
      echo "You guessed it in $NUMBER_ATTEMPTS tries. The secret number was $RANDOM_NUMBER. Nice job!"
      
      INSERT_RESULT=$($PSQL "INSERT INTO guess_data(username, games) VALUES ('$USERNAME', $NUMBER_ATTEMPTS)")
    fi      
  fi 

}

MAIN_MENU