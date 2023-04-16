#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?"

MENU() {
  

  SERVICES=$($PSQL "SELECT * FROM services")
  # show services
  echo "$SERVICES" | while read SERVICE_ID SERVICE_NAME
  do
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ *| *//')
    echo "$SERVICE_ID) $SERVICE_NAME_FORMATTED"
  done
  
  
  # read input from user
  read SERVICE_ID_SELECTED

  # read service name selected
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # # if input is not a number
  # if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  # then
  #   echo "That is not a valid bike number."
  #   MENU
  # fi

  # check service availability
  SERVICE_AVAILABILITY=$($PSQL "SELECT * FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # if service id is not found
  if [[ -z $SERVICE_AVAILABILITY ]]
  then
    echo "I could not find that service. What would you like today?"
    MENU
  else
    # get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')") 
    fi

    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # get service time
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    read SERVICE_TIME

    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

    echo "I have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}
MENU