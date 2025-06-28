#!/usr/bin/env bash
set -euo pipefail

get_consolidated() {
    local temp_folder=$1
    local backup_folder=$2
    local consolidated_file_name_path=$3

    mapfile -d '' log_files < <(find "$1" -maxdepth 1 -type f -name "APL *.log" -print0)
    local consolidated=$(csvstack -t "${log_files[@]}" | csvsort -c 1)

    mv "${temp_folder}" "${backup_folder}"
    
    echo "$consolidated" > "$consolidated_file_name_path"
}

normalize_string(){
    local input=$1

    local normalized=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    normalized=$(echo "$normalized" |
    sed -e 's/á/a/g' \
        -e 's/é/e/g' \
        -e 's/í/i/g' \
        -e 's/ó/o/g' \
        -e 's/ú/u/g' \
        -e 's/ñ/n/g')

    echo "$normalized"
}

query_report() {
    local report=$(normalize_string $1)
    local file_name=$2

    local report_query="${report}.sql"
    
    #Calling the function dynamically and save its return value
    echo "$(execute_query $report_query)" > "${file_name/report/$report}"
}

execute_query() {
    local query=$1

    csvsql --query "$(cat "${SCRIPT_DIR}/queries/$query")"  ${CONSOLIDATED_FILE_PATH} --tables events  
}

get_stats() {

    # Create consolidated logs file and backup source files
    $(get_consolidated $TEMP_FOLDER $BACKUP_FOLDER $CONSOLIDATED_FILE_PATH)

    for report in "${stats_reports[@]}"; do    
        $(query_report $report "${STATS_FOLDER_FILE_PATH/date/$FORMATED_DATE}")
    done

}

FORMATED_DATE=$1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_PATH="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE=${PROJECT_PATH}/variables.config

# Load env variables
source ${CONFIG_FILE}

TEMP_FOLDER=${PROJECT_PATH}/$temp_folder/${FORMATED_DATE}
BACKUP_FOLDER=${PROJECT_PATH}/$backup_folder
STATS_FOLDER=${PROJECT_PATH}/$stats_folder
STATS_FOLDER_FILE_PATH=${STATS_FOLDER}/${FORMATED_DATE}/$stats_file_name
CONSOLIDATED_FILE_PATH=${STATS_FOLDER}/${FORMATED_DATE}/"${consolidated_file_name/fdate/$FORMATED_DATE}"

mkdir -p ${STATS_FOLDER}/${FORMATED_DATE} > /dev/null

echo "$(get_stats)"