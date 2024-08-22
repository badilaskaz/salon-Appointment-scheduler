#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ My Salon ~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "select * from services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  
  SERVICE_ID=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")

  # if service not found
  if [[ -z $SERVICE_ID ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    
    # if customer not found
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      # insert new customer
      INSERT_CUSTOMER=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    GET_SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID")
    GET_CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")

    # get new customer id
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")


    echo -e "\nWhat time would you like your $(echo "$GET_SERVICE_NAME" | sed -E 's/^ *//g'), $(echo $GET_CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"
    read SERVICE_TIME

    INSERT_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $(echo "$GET_SERVICE_NAME" | sed -E 's/^ *//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $(echo $GET_CUSTOMER_NAME | sed -E 's/^ *| *$//g')".
  fi

}

MAIN_MENU