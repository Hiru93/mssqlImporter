#!/bin/bash

# Saving project root path
PROJECT_ROOT=$(pwd)

# Check to allow docker to correctly handle directories paths
if [[ $(pwd) == "/app" ]]; then
    # Changing umask to allow docker to create fileswith 666 permissions
    umask 0000
    PROJECT_ROOT="/usr/src/app"
fi

echo "Project root: $PROJECT_ROOT"

# Extract .zip content
find ./archives/ -type f -iname "*.zip" -exec unzip {} -d ./archives/extraction-folder \;
# find ./archives/ -type f -iname "*.rar" -exec unrar e {} -d ./archives/extraction-folder \;

# Move inside the extraction folder
cd ./archives/extraction-folder
echo "Moved inside the extraction folder"
echo "Parent directory: $(pwd)"
extractedDir=`ls -d */ | grep -v "__MACOSX"`;
echo "Extracted dir: $extractedDir"
cd "$extractedDir"
echo "Currently inside: $(pwd)"
echo "List of available directories: $(ls -d */)"
directories=`ls -d */`;
readarray -d '' -t directories < <(ls -d */)

# List of directories which prefix has multiple occurencies
recurringDirectories=`ls -d */`
readarray -d '' -t directoriesArray < <(printf '%s\0' $recurringDirectories)

# Extract prefixes and find duplicates
character="_"
prefixes=($(for dir in "${directoriesArray[@]}"; do echo "${dir%%$character*}"; done | sort | uniq -d))

dataInformationList=("acconti" "anamnesi" "appuntamenti" "diario_clinico" "fatture" "mov_730" "note_denti" "pazienti" "piani_trattamento" "primanota" "richiami" "immagini" "piani_trattamento_righe" "piani_trattamento_righe_denti")

# Access the SELECTED_OPTIONS environment variable
IFS=',' read -r -a selectedOptionsArray <<< "$SELECTED_OPTIONS"

# Filter the dataInformationList array based on the selected options
filteredDataInformationList=()
for option in "${selectedOptionsArray[@]}"; do
  case $option in
    1) filteredDataInformationList+=("acconti") ;;
    2) filteredDataInformationList+=("anamnesi") ;;
    3) filteredDataInformationList+=("appuntamenti") ;;
    4) filteredDataInformationList+=("diario_clinico") ;;
    5) filteredDataInformationList+=("fatture") ;;
    6) filteredDataInformationList+=("mov_730") ;;
    7) filteredDataInformationList+=("note_denti") ;;
    8) filteredDataInformationList+=("pazienti") ;;
    9) filteredDataInformationList+=("piani_trattamento") ;;
    10) filteredDataInformationList+=("primanota") ;;
    11) filteredDataInformationList+=("richiami") ;;
    12) filteredDataInformationList+=("immagini") ;;
    13) filteredDataInformationList+=("piani_trattamento_righe") ;;
    14) filteredDataInformationList+=("piani_trattamento_righe_denti") ;;
  esac
done

# Print the filtered array
echo "Filtered data information list: ${filteredDataInformationList[@]}"

# Overwrite dataInformationList with filteredDataInformationList
dataInformationList=("${filteredDataInformationList[@]}")

# Initialize a flag to indicate whether it's the first file for the current dataContext
declare -A first_file_flags

# Create a logs file
touch "$PROJECT_ROOT"/parsed-files/logs.txt
echo "[INFO][$(date "+%F||%T")] Date: $(date "+%F||%T")" >> "$PROJECT_ROOT"/parsed-files/logs.txt
echo "[INFO][$(date "+%F||%T")] Selected directories ${dataInformationList[@]}" >> "$PROJECT_ROOT"/parsed-files/logs.txt

#Listing all the directories with multiple prefix occurrencies
echo "[INFO][$(date "+%F||%T")] Prefixes with multiple occurrencies: ${prefixes[@]}" >> "$PROJECT_ROOT"/parsed-files/logs.txt

for dir in ${directories[@]}
do
    echo "[INFO][$(date "+%F||%T")] --------------------------------------------" >> "$PROJECT_ROOT"/parsed-files/logs.txt
    # Extract the prefix of the directory
    prefix="${dir%%$character*}"
    echo "[INFO][$(date "+%F||%T")] Prefix: $prefix" >> "$PROJECT_ROOT"/parsed-files/logs.txt
    # Check if the prefix appears inside the multiple occurrencies list
    if [[ ! " ${prefixes[@]} " =~ " ${prefix} " ]]; then
        cd "$dir"
        echo "[INFO][$(date "+%F||%T")] Currently inside: $(pwd)" >> "$PROJECT_ROOT"/parsed-files/logs.txt
        echo "[INFO][$(date "+%F||%T")] Directory: $dir" >> "$PROJECT_ROOT"/parsed-files/logs.txt
        for dataContext in ${dataInformationList[@]}
        do
            echo "[INFO][$(date "+%F||%T")] @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> "$PROJECT_ROOT"/parsed-files/logs.txt
            echo "[INFO][$(date "+%F||%T")] Data context: $dataContext" >> "$PROJECT_ROOT"/parsed-files/logs.txt
            if [[ -f "$dataContext.csv" ]]; then
                echo "[INFO][$(date "+%F||%T")] File exists" >> "$PROJECT_ROOT"/parsed-files/logs.txt
                if [[ -r "$dataContext.csv" && -s "$dataContext.csv" ]]; then
                    # Remove carriage return characters
                    sed 's/\r$//' $dataContext.csv > acconti_no_cr.csv
                    mv acconti_no_cr.csv $dataContext.csv

                    # Defined list of possible delimiters
                    IFS_list=("," ";" "|" $'\t')
                    CURRENT_DELIMITER=""

                    # Check which delimiter is used in the file
                    for delimiter in "${IFS_list[@]}"; do
                        first_line=$(tr '\r' '\n' < $dataContext.csv | head -n 1)
                        if echo "$first_line" | grep -q "$delimiter"; then
                            CURRENT_DELIMITER=$delimiter
                            echo "[INFO][$(date "+%F||%T")] First line: $first_line" >> "$PROJECT_ROOT"/parsed-files/logs.txt
                            echo "[INFO][$(date "+%F||%T")] The file $dataContext.csv uses $delimiter as the delimiter." >> "$PROJECT_ROOT"/parsed-files/logs.txt
                            break
                        fi
                    done

                    # Get the current encoding of the file
                    # file_encoding=$(file -bi $dataContext.csv | awk -F "=" '{print $2}')
                    file_encoding=$(uchardet $dataContext.csv)

                    # Convert the file to UTF-8 encoding if it's not already
                    # The check for binary encoding is necessary because the file command 
                    # returns binary for some files (those exported containing ascii characters)
                    if [[ "$file_encoding" != "utf-8" && "$file_encoding" != "unknown" ]]; then
                        iconv -f "$file_encoding" -t utf-8 $dataContext.csv > $dataContext-utf8.csv
                        mv $dataContext-utf8.csv $dataContext.csv
                    elif [ "$file_encoding" == "unknown" ]; then
                        iconv -f ISO-8859-1 -t utf-8 $dataContext.csv > $dataContext-utf8.csv
                        mv $dataContext-utf8.csv $dataContext.csv
                    fi

                    echo "[INFO][$(date "+%F||%T")] Current file encoding: $(uchardet $dataContext.csv)" >> "$PROJECT_ROOT"/parsed-files/logs.txt
                    
                    awk -F';' -v OFS=';' '{ for(i=1; i<=NF; i++) gsub(",", ".", $i) } 1' $dataContext.csv > $dataContext-escaped.csv
                    mv $dataContext-escaped.csv $dataContext.csv

                    # NEW 
                    # - using csvcut to cut the header of the file
                    # - using csvstack to stack the rows of the file in a newly created CSV
                    # - using csvformat to format the CSV file with the correct delimiter for the output file

                    # If it's the first file, include the header
                    if [ -z "${first_file_flags[$dataContext]}" ]; then
                        if [ -f "$PROJECT_ROOT"/parsed-files/$dataContext.csv ]; then
                            csvformat -D ";" -U 0 $dataContext.csv | sed 's/"//g' >> "$PROJECT_ROOT"/parsed-files/$dataContext.csv
                        else
                            csvformat -D ";" -U 0 $dataContext.csv | sed 's/"//g' > "$PROJECT_ROOT"/parsed-files/$dataContext.csv
                        fi
                        first_file_flags[$dataContext]=0
                    else
                        # If it's not the first file, merge
                        csvformat -D ";" -U 0 $dataContext.csv | sed 's/"//g' > "$PROJECT_ROOT"/parsed-files/$dataContext-temp.csv
                        csvstack -d ";" "$PROJECT_ROOT"/parsed-files/$dataContext.csv "$PROJECT_ROOT"/parsed-files/$dataContext-temp.csv | csvformat -D ";" -U 0 | sed 's/"//g' > "$PROJECT_ROOT"/parsed-files/$dataContext-temp-join.csv
                        csvstack -d ";" "$PROJECT_ROOT"/parsed-files/$dataContext-temp-join.csv | csvformat -D ";" -U 0 | sed 's/"//g' > "$PROJECT_ROOT"/parsed-files/$dataContext.csv
                        rm "$PROJECT_ROOT"/parsed-files/$dataContext-temp.csv
                        rm "$PROJECT_ROOT"/parsed-files/$dataContext-temp-join.csv
                    fi
                else
                    echo "[WARN][$(date "+%F||%T")] File is not readable or is empty" >> "$PROJECT_ROOT"/parsed-files/logs.txt
                fi
            else
                echo "[WARN][$(date "+%F||%T")] File $dataContext.csv does not exist" >> "$PROJECT_ROOT"/parsed-files/logs.txt
            fi
            echo "[INFO][$(date "+%F||%T")] @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" >> "$PROJECT_ROOT"/parsed-files/logs.txt
        done
        cd ..
    else
        echo "[DUPLICATE][$(date "+%F||%T")] Prefix $prefix is in the list of prefixes with multiple occurrencies" >> "$PROJECT_ROOT"/parsed-files/logs.txt
    fi
done

echo "[INFO][$(date "+%F||%T")] Parsing merged files" >> "$PROJECT_ROOT"/parsed-files/logs.txt
for dataContext in ${dataInformationList[@]}
do
    if [ -f "$PROJECT_ROOT"/parsed-files/$dataContext.csv ]; then
        sed 's/"//g' "$PROJECT_ROOT"/parsed-files/$dataContext.csv > "$PROJECT_ROOT"/parsed-files/$dataContext-seded.csv
        mv "$PROJECT_ROOT"/parsed-files/$dataContext-seded.csv "$PROJECT_ROOT"/parsed-files/$dataContext.csv
    fi
done
echo "[INFO][$(date "+%F||%T")] Done" >> "$PROJECT_ROOT"/parsed-files/logs.txt

echo "+++++++++++++++++++++++ CSV FILES READY TO BE USED +++++++++++++++++++++++" >> "$PROJECT_ROOT"/parsed-files/logs.txt
echo "+++++++++++++++++++++++ CSV FILES READY TO BE USED +++++++++++++++++++++++"