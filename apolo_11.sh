#!/usr/bin/env bash

echo "-------- Starting Apolo 11 script... --------"
ABS_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" #$(pwd)
CONFIG_SH=${ABS_PATH}/scripts/config.sh
CONFIG_FILE=${ABS_PATH}/variables.config

bash ${CONFIG_SH} > ${CONFIG_FILE}
source ${CONFIG_FILE}

mkdir -p ${ABS_PATH}/${temp_folder} > /dev/null
mkdir -p ${ABS_PATH}/${backup_folder} > /dev/null
mkdir -p ${ABS_PATH}/${stats_folder} > /dev/null

echo "-------- Creating consolidated file... --------"
bash ${ABS_PATH}/scripts/create_logs.sh

echo "-------- Generating statistics reports... --------"
bash ${ABS_PATH}/scripts/get_stats.sh

rm -rf variables.config

echo "-------- Apolo 11 script completed successfully. --------"