<header style="display: flex; align-items: center; justify-content: center; height: 200px; background-color: transparent;">
  <div style="display: flex; align-items: center;">
    <div style="margin-right: 20px;">
      <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzgURBB21syaW6tNpW1-wjaKppJIYXzb_EFg&s" alt="Logo o Imagen" style="height: 150px;">
    </div>
    <div style="text-align: left; line-height: 1.4;">
      <div style="font-size: 30px; font-weight: bold;">
          Introducción a Linux (Evaluación #1)
        </div>
      <div style="font-size: 20px; font-style: italic;font-weight: bold">
          Juan Esteban Patiño Forero
        </div>
      <div style="font-size: 16px;">
          Departamento de Ciencias de la Computación
        </div>
        <div style="font-size: 15px;">
          Facultad de Minas
        </div>
      <div style="font-size: 14px; color: #555;">
          23/06/2025
        </div>
    </div>
  </div>
</header>

***
# Apolo 11
Apolo 11 es un proyecto funcional mediante el cual se busca poner en practica las capacidades de analísis y aplicación de problemas del mundo real en un contexto educativo. En este caso, se buscará desarrollar una herramienta de línea de comandos *(CLI)* que permita generar **n** cantidad de archivos *(.log)*, procesarlos y generar estádisticas a partir de los mismos siguiendo los criterios definidos en el archivo **[Guia Evaluación #1 - Intro Linux](./intro.linux.html)** 


## Ejecución
Para la correcta ejecución de esta herramienta de línea de comandos, en cualquier sistema operativo basado en Unix, se debe garantizar que los archivos `.sh` presentes en este proyecto cuenten con permisos de ejecución.


> [!NOTE] 
> Los archivos `.sh` deben con los permisos **-rwxrw-r--**
>```bash
>   ls -lRrt
>    ```
> Para asignar los permisos de ejecución a todos los archivos `.sh`.
>```bash 
>find . -type f -name "*.sh" -exec chmod +x {} \;
>```

La ejecución de la herramienta de línea de comando desarrollada para el proyecto **Apolo11** se realiza de la manera, si se esta en la raiz del proyecto:

```bash=
bash apolo_11.sh
```

>[!IMPORTANT]
> Para ejecutar las estadisticas del proyecto es necesario contar con `csvkit` en el entorno.
> ```bash
> sudo apt install csvkit
> ```

## Estructuración de la herramienta
Teniendo presente los criterios mínimos establecidos para el desarrollo de la herramienta de línea de comandos, se definió una estructura de proyecto que fuese escalable y de facil soporte, basandose en el **principio de responsabilidad única - (SRP)** como se presenta a continuación: 

```plaintext
├── apolo_11.sh
└── scripts
    ├── config.sh
    ├── create_logs.sh
    ├── get_stats.sh
    └── queries
        ├── analisis_eventos.sql
        ├── calculo_porcentajes.sql
        ├── consolidacion_misiones.sql
        └── gestion_desconexiones.sql
```

### apolo_11.sh
Herramienta de línea de comandos principal del proyecto **Apolo 11**, con la responsabilidad de generar los directorios adicionales necesarios (*backup*,*devices*,*stats*), el archivo de configuración y la orquestación de las sub-herramientas de línea de comandos para la generación de archivos de logs y reportes estadisticos.
```bash=
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
```

>[!Important]
> Según la guía de evaluación, los ciclos de ejecución de la herramienta deben ocurrir cada 20 segundos. Aunque este comportamiento puede implementarse fácilmente en entornos locales utilizando `cron` en sistemas Unix o un ciclo iterativo dentro del script principal (como se muestra en las líneas comentadas), no es una práctica recomendada, especialmente en entornos de nube. Esto se debe a que mantener procesos activos continuamente puede derivar en un uso ineficiente de recursos y generar costos innecesarios entre cada ciclo de ejecución.


La estructura resultante tras ejecutar esta herramienta de línea de comandos es la siguiente:

```plaintext=
├── apolo_11.sh
├── backup
│   └── 23062518064734
        └── APL CLNM-00003.log
├── devices
│   └── 23062518064734
        └── APL CLNM-00003.log
├── scripts
│   ├── config.sh
│   ├── create_logs.sh
│   ├── get_stats.sh
│   └── queries
│       ├── analisis_eventos.sql
│       ├── calculo_porcentajes.sql
│       ├── consolidacion_misiones.sql
│       └── gestion_desconexiones.sql
└── stats
    ├── 23062518064734
        ├── APLSTATS-analisis_eventos-23062518064734.log
        ├── APLSTATS-calculo_porcentajes-23062518064734.log
        ├── APLSTATS-consolidacion_misiones-23062518064734.log
        ├── APLSTATS-gestion_desconexiones-23062518064734.log
        └── consolidated_logs_23062518064734.log
```

### Scripts Directory
Contiene las "sub-herramientas" de línea de comandos e insumos necesarios (*queries*) para dar cumplimiento a los criterios de acpetación definidos en la guia de evaluación.

#### config.sh
Entre las buenas practicas de desarrollo, es recomendable emplear achivos independientes que cuenten con las variables de configuración de una solución, esto permite que la misma sea escalable de manera sencilla sin la necesidad de entrar a modificar la lógica implementada.

En el caso de este proyecto, archivo `config.sh` tiene la responsabilidad de generar el archivo de configuración, `variables.config`, con los siguientes valores, los cuales pueden ser modificables si se desean:

``` bash
date_format='+%d%m%y%H%I%M%S' # Fomato de fecha
# num_cicle=1 # Número de ciclos a ejecutar
# cicle_duration=1 # Tiempo en segundos de la duración del ciclo
min_files=1 # Número mínimo de archivos a generar por ciclo
max_files=100 # Número máximo de archivos a generar por ciclo
file_name='APLmission_name-0000file_number.log' # Formato de nombre del archivo de logs
consolidated_file_name='consolidated_logs_fdate.log' # Formato de nombre del arhivo de consolidado de logs
stats_file_name='APLSTATS-report-date.log' # Formato de nombre del archivo de reportes
file_sep='\t' # Separador para el archivo de logs
temp_folder='devices' # Directorio temporal
backup_folder='backup' # Directorio de Backup
stats_folder='stats' # Directorio de reportes
missions=(ORBONE CLNM TMRS GALXONE UNKN) # Listado de misiones
device_statuses=(excellent good warning faulty killed unknown) # Listado de estados
device_types=(satellites spaceships space_vehicles spacial_suit other_components) # Listado de dispositivos
stats_reports=(analisis_eventos gestion_desconexiones consolidacion_misiones calculo_porcentajes) # Listado de reportes
```
> [!IMPORTANT]
> * Con el fin de garantizar el correcto funcionamiento, los elementos de las variables definidas como arreglos, no pueden contener espacios entre palabras.
> * A partir de las implicaciones que conllevaría mantener procesos activos en entornos de nube. No se considerará las variables de configuración `num_cicles` y `cicle_duration`.

#### create_logs.sh
Esta herramienda de línea de comandos tiene la responsabilidad de simular la recepción de los logs de los diferentes dispositivos y almacenarlos en archivos estructurados. 

Este script cuenta con 4 funciones principales, (`get_random`, `get_element`, `create_file`, `create_logs`) que se explicarán más adelante:

Los archivos resultantes tras ejecutar esta herramienta de línea de comandos son almacenados en el directorio **devices** con la siguiente estructura:
```text    
date	mission	device_type	device_status	hash
23062519070700	CLNM	spacial_suit	warning	MjMwNjI1MTkwNzA3MDBDTE5Nc3BhY2lhbF9zdWl0d2FybmluZwo=
23062519070703	CLNM	other_components	good	MjMwNjI1MTkwNzA3MDNDTE5Nb3RoZXJfY29tcG9uZW50c2dvb2QK
```

##### get_random
Función que recibe como argumento 2 números enteros (*min*, *max*) y retorna un valor aleatorio entre el rango de estos 2 números.
```bash=
get_random(){
    local min=$1
    local max=$2

    if (( min > max )); then
        echo "Error: min should be less than or equal to max"
        return 1
    fi

    echo $((RANDOM % (max - min + 1) + min))
}
```
##### get_element
Función que recibe un arreglo como argumento y retorna un elemento del arreglo de manera aleatoria, se emplea para obtener las misiones, estados y dispositivos del proyecto **Apolo 11**.
```bash=
get_element(){
    local array_name=$1

    local count=$(eval "echo \${#${array_name}[@]}")
    local index=$(get_random 0 $(( count - 1 )))
    local element=$(eval "echo \${${array_name}[$index]}")

    echo $element
}
```

#####  craete_file
Función con la responsabilidad de generar los archivos de logs de las diferentes misiones definidas en el proyecto **Apolo 11**. Recibe como argumentos el nombre del archivo resultante y la información de la misión.
```bash=
create_file(){
    local mission_name=$(get_element $1)
    local device_status=$(get_element $2)
    local device_type=$(get_element $3)
    local timestamp=$4
    local separator=$5
    local filename=$6

    local hash=$(echo "${timestamp}${mission_name}${device_type}${device_status}" | base64)

    if [ "$mission_name" == 'UNKN' ]; then
        local hash=""
        device_status="unknown"
        device_type="unknown"
    fi

    local header="date${separator}mission${separator}device_type${separator}device_status${separator}hash"
    local value="${timestamp}${separator}${mission_name}${separator}${device_type}${separator}${device_status}${separator}${hash}"
    local file="${filename/mission_name/$mission_name}"

    if [ ! -f  "$file" ]; then
        echo -e $header > "$file"
    fi

    echo -e $value >> "$file"
}
```

##### create_logs
Función orquestadora encargada de procesar los ciclos de ejecución de cada mision del proyecto **Apolo 11**.
```bash=
create_logs(){
	
    # Number of files to create per cicle
    local files_per_cicle=$(get_random $min_files $max_files)

    #Creating n files per cicles
    for index_file in $(seq 1 ${files_per_cicle}); do
        $(create_file missions device_statuses device_types ${FORMATED_DATE} $file_sep "${TEMP_FOLDER_FILE_PATH/file_number/$index_file}")
    done
}
```

#### get_stats.sh
Esta herramienda de línea de comandos tiene la responsabilidad generar los resportes estadisticos solicitados en archivos estructurados y realizar el backup de los logs de cada misión del proyecto **Apolo 11**.

Este script cuenta con 4 funciones principales, (`get_consolidated`,`query_report`, `execute_query`,`get_stats`) que se explicarán más adelante.

Los archivos resultantes tras ejecutar esta herramienta de línea de comandos son almacenados en el directorio **stats** con la siguiente estructura para cada reporte:

```csv
mission,device_type,device_status,total_events
CLNM,other_components,excellent,1
CLNM,other_components,good,2
```

##### get_consolidated
Funcion con la responsabilidad de consolidar en un solo archivo los diferentes logs de las misiones del proyecto **Apolo 11** y efectuar el Backup de los logs correspondientes. Recibe como argumento el directorio temporal de los logs (*temp_folder*), el directorio donde se realiza el backup (*backup_folder*) y el nombre del archivo consolidado (*consolidated_file_name*).
```bash=
get_consolidated() {
    local temp_folder=$1
    local backup_folder=$2
    local consolidated_file_name_path=$3

    local log_files=$(ls "$temp_folder"/APL*.log 2>/dev/null)

    local consolidated=$(csvstack -t $log_files | csvsort -c 1)

    mv "${temp_folder}" "${backup_folder}"

    echo "$consolidated" > "$consolidated_file_name_path"
}
```

##### query_report
Función encargada de generar el archivo reporte con las estadisticas definidas en la guia de evaluación del proyecto **Apolo 11** en el directorio correspondiente. Recibe como argumento el nombre del reporte a ejecutar (*report*), y el nombre del archivo a generar con el reporte (*file_name*).
```bash=
query_report() {
    local report=$1
    local file_name=$2

    local report_query="${report}.sql"
    
    #Calling the function dynamically and save its return value
    echo "$(execute_query $report_query)" > "${file_name/report/$report}"
}
```

##### execute_query
Función encargada de leer las consultas `.sql` del directorio **queries** y ejecutarlas sobre el consolidado de archivos. Recibe como argumento el nombre del query (*query*) y retorna el resultado del mismo.
```bash=
execute_query(){
    local query=$1

    csvsql --query "$(cat "${PROJECT_PATH}/scripts/queries/$query")"  ${CONSOLIDATED_FILE_PATH} --tables events  
}
```

##### get_stats
Función orquestadora encargada de generar los reportes estadisticos del proyecto **Apolo 11** según los criterios definidos en la guía de evaluación.
```bash=
get_stats() {
    # Create consolidated logs file and backup source files

    $(get_consolidated $TEMP_FOLDER $BACKUP_FOLDER $CONSOLIDATED_FILE_PATH)

    for report in "${stats_reports[@]}"; do            
        $(query_report $report "${STATS_FOLDER_FILE_PATH/date/$FORMATED_DATE}")
    done
}
```

#### Queries Directory
Lista las consultas a ser ejecutadas en la etapa de generación de reportes a partir de los criterios definidos en la guia de evaluación.

> [!NOTE] 
> Los archivos `.sql` debe estar nombrados en lowercase, sin espacios y caracteres especiales.
