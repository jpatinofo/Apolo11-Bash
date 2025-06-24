#!/usr/bin/env bash
set -euo pipefail
# get random number between min and max
get_random(){
	local min=$1
	local max=$2

	if (( min > max )); then
		echo "Error: min should be less than or equal to max"
		return 1
	fi

	echo $((RANDOM % (max - min + 1) + min))
}

# Get the random element from the array
get_element(){
	local array_name=$1

	local count=$(eval "echo \${#${array_name}[@]}")
	local index=$(get_random 0 $(( count - 1 )))
	local element=$(eval "echo \${${array_name}[$index]}")

	echo $element
}

# Generate file
create_file(){
	local mission_name=$(get_element $1)
	local device_status=$(get_element $2)
	local device_type=$(get_element $3)
	local formated_date=$(date $4)
	local separator=$5
	local filename=$6

	local hash=$(echo "${formated_date}${mission_name}${device_type}${device_status}" | base64)

	if [ "$mission_name" == 'UNKN' ]; then
		local hash=""
		device_status="unknown"
		device_type="unknown"
	fi
		
	local header="date${separator}mission${separator}device_type${separator}device_status${separator}hash"
	local value="${formated_date}${separator}${mission_name}${separator}${device_type}${separator}${device_status}${separator}${hash}"
	local file="${filename/mission_name/$mission_name}"

	if [ ! -f  "$file" ]; then
	echo -e $header > "$file"
	fi

	echo -e $value >> "$file"
}

# Create logs
create_logs(){
	
	for cicle in $(seq 1 $num_cicle); do
		# Number of files to create per cicle
		FILES_PER_CICLE=$(get_random $min_files $max_files)
		#Creating n files per cicles
		for index_file in $(seq 1 ${FILES_PER_CICLE}); do
			$(create_file missions device_statuses device_types $date_format $file_sep "${TEMP_FOLDER_FILE_PATH/file_number/$index_file}")
		done
	# Wait until cicle time expires

	printf "Cicle %s completed. Waiting for next cicle in %ss...\n" "$cicle" "$cicle_duration"
		# Sleep for the duration of the cicle
	sleep $cicle_duration
	done

	echo "$(ls devices/*.log | wc -l) .log files created in ${PROJECT_PATH}/${temp_folder}"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_PATH="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE=${PROJECT_PATH}/variables.config
#Load env variables
source ${CONFIG_FILE}

TEMP_FOLDER_FILE_PATH=${PROJECT_PATH}/$temp_folder/$file_name

echo "$(create_logs)"
