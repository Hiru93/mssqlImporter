#!/bin/bash

##
# Color Functions
##
green='\033[0;32m'
blue='\033[0;34m'
yellow='\033[0;33m'
red='\033[0;31m'
clear='\033[0m'

ColorGreen(){
    echo -ne $green$1$clear
}
ColorBlue(){
    echo -ne $blue$1$clear
}
ColorYellow(){
    echo -ne $yellow$1$clear
}
ColorRed(){
    echo -ne $red$1$clear
}

# Function to display the menu
display_menu() {
  for i in {1..15}; do
    if [[ " ${selected_options[@]} " =~ " $i " ]]; then
      color=$yellow
    else
      color=$clear
    fi
    case $i in
      1) echo -e "${color}1- acconti${clear}" ;;
      2) echo -e "${color}2- anamnesi${clear}" ;;
      3) echo -e "${color}3- appuntamenti${clear}" ;;
      4) echo -e "${color}4- diario clinico${clear}" ;;
      5) echo -e "${color}5- fatture${clear}" ;;
      6) echo -e "${color}6- mov 730${clear}" ;;
      7) echo -e "${color}7- note denti${clear}" ;;
      8) echo -e "${color}8- pazienti${clear}" ;;
      9) echo -e "${color}9- piani di trattamento${clear}" ;;
      10) echo -e "${color}10- prima nota${clear}" ;;
      11) echo -e "${color}11- richiami${clear}" ;;
      12) echo -e "${color}12- immagini${clear}" ;;
      13) echo -e "${color}13- piani di trattamento righe${clear}" ;;
      14) echo -e "${color}14- piani di trattamento righe denti${clear}" ;;
    esac
  done
  echo ""
}

# Initialize an empty array to store selected options
selected_options=()

# Create an associative array to map option numbers to labels
declare -A option_labels=(
  [1]="acconti"
  [2]="anamnesi"
  [3]="appuntamenti"
  [4]="diario_clinico"
  [5]="fatture"
  [6]="mov_730"
  [7]="note_denti"
  [8]="pazienti"
  [9]="piani_trattamento"
  [10]="primanota"
  [11]="richiami"
  [12]="immagini"
  [13]="piani_trattamento_righe"
  [14]="piani_trattamento_righe_denti"
)

# Present the operational menu
echo -ne "
    $(ColorGreen '############################################')
    $(ColorGreen '#') Default merging strategy: $(ColorBlue 'all')            $(ColorGreen '#')
    $(ColorGreen '############################################')
"
echo -ne "
    $(ColorBlue 'write "done" to confirm selection, press enter without writing anything to proceed with the default strategy')
    
"
# Loop to allow multiple selections
while true; do
  display_menu
  read -p "Enter the merging strategy number: " input

   if [[ -z $input ]]; then
    # Default option if Enter is pressed without input
    selected_options=({1..14})
    break
  elif [[ $input == "done" ]]; then
    break
  elif [[ $input =~ ^[0-9]+$ ]] && [ $input -ge 1 ] && [ $input -le 15 ]; then
    if [[ ! " ${selected_options[@]} " =~ " ${input} " ]]; then
      selected_options+=($input)
    else
      echo -e "$(ColorRed 'Option $input is already selected.')"
    fi
  else
    echo "$(ColorRed 'Invalid input. Please press "enter" to select all the merging strategy, a number between 1 and 14, or "done" to finish.')"
  fi
done

# Display the selected options
echo "You selected:"
for option in "${selected_options[@]}"; do
  echo "- ${option_labels[$option]}"
done

# Create a string with the selected options
selected_options_string=$(IFS=, ; echo "${selected_options[*]}")

# Start the Docker containers
echo "@@@@@@@@@@@@@@@@@@@ Starting the Docker containers"
SELECTED_OPTIONS=$selected_options_string docker-compose up --build --force-recreate --no-deps -d csv-parser

echo "@@@@@@@@@@@@@@@@@@@ Now parsing the files"
# Wait for the parsing to finish
while ! docker-compose logs | grep -Fq "+++++++++++++++++++++++ CSV FILES READY TO BE USED +++++++++++++++++++++++"
do
    sleep 1
done
echo "@@@@@@@@@@@@@@@@@@@ CSV parsing finished"

echo "@@@@@@@@@@@@@@@@@@@ Files and directories cleaned up, shutting down docker containers"
# Stop the Docker containers and remove all the images
docker-compose down --rmi all
