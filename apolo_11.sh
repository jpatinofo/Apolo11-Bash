#!/usr/bin/env bash

echo "-------- Starting Apolo 11 script... --------"
ABS_PATH="$(pwd)"
CONFIG_SH=${ABS_PATH}/scripts/config.sh
CONFIG_FILE=${ABS_PATH}/variables.config

bash ${CONFIG_SH} > ${CONFIG_FILE}
source ${CONFIG_FILE}

mkdir -p ${ABS_PATH}/${temp_folder} > /dev/null
mkdir -p ${ABS_PATH}/${backup_folder} > /dev/null
mkdir -p ${ABS_PATH}/${stats_folder} > /dev/null


# for cicle in $(seq 1 $num_cicle); do

    timestamp=$(date $date_format)

    source ${ABS_PATH}/scripts/create_logs.sh ${timestamp}

    source ${ABS_PATH}/scripts/get_stats.sh ${timestamp}

	# Sleep for the duration of the cicle
# 	sleep $cicle_duration
# done

rm -rf variables.config

echo "-------- Apolo 11 script completed successfully. --------"