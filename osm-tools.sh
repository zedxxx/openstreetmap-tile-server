#!/bin/bash

set -euox pipefail

WORK_DIR=/osm
DATA_DIR=/mnt/data

if [ "$1" == "up" ]; then
    cd "${WORK_DIR}"
    docker compose up --detach --pull missing
    exit 0
fi

if [ "$1" == "down" ]; then
    cd "${WORK_DIR}"
    docker compose down
    exit 0
fi

function download_region() {
    local REGION="$1"
    rm -fv "${DATA_DIR}/region.osm.pbf" "${DATA_DIR}/region.poly"
    URL="https://download.geofabrik.de/${REGION}"
    echo "Downloading region data..."
    wget -O "${DATA_DIR}/region.osm.pbf" "${URL}-latest.osm.pbf"
    if ! wget -O "${DATA_DIR}/region.poly" "${URL}.poly"; then
        echo "No .poly file found for ${REGION}, continuing without it..."
    fi
}

if [ "$1" == "import" ]; then
    
    if [ -n "$2" ]; then
        download_region "$2"
    fi

    cd "${WORK_DIR}"

    docker compose down
   
    rm -rf "${DATA_DIR}/database"
    rm -rf "${DATA_DIR}/tiles"

    docker compose run --rm --name osm-import osm import
fi

if [ "$1" == "get" ]; then
    cd "${WORK_DIR}"
    if [ -n "$2" ]; then
        download_region "$2"
    else
        echo "Provide region name! Examples: europe/belarus, russia/kaliningrad, russia"
    fi
fi

if [ "$1" == "logs" ]; then
    cd "${WORK_DIR}"
    docker compose logs --follow
    exit 0
fi

# PostgreSQL

PG_DB=gis
PG_USER=postgis
PG_CONTAINER_NAME=osm-pg

function pg_check_running() {
    docker ps --filter "name=${PG_CONTAINER_NAME}" --filter "status=running" | grep -q "${PG_CONTAINER_NAME}"
}

function pg_run_psql() {
    local sql="$1"
    docker exec -it "${PG_CONTAINER_NAME}" psql -h localhost -U "${PG_USER}" -d "${PG_DB}" -c "${sql}"
}

function pg_run_convert() {
    docker cp ./convert-names.sql "${PG_CONTAINER_NAME}":/convert.sql
    docker exec -it "${PG_CONTAINER_NAME}" psql -h localhost -U "${PG_USER}" -d "${PG_DB}" -f /convert.sql
}

function pg_error_not_running() {
    echo "${PG_CONTAINER_NAME} container isn't running!"
    echo "Type \"osm pg run\" to run container"
    exit 1
}

if [ "$1" == "pg" ]; then
    
    cd "${WORK_DIR}"

    case "$2" in
    "run")
        docker compose run --rm --name "${PG_CONTAINER_NAME}" osm run-pg
        exit 0
        ;;

    "analyze")
        if pg_check_running; then
            pg_run_psql "ANALYZE;"
            exit 0
        else
            pg_error_not_running
        fi
        ;;
        
    "vacuum")
        if pg_check_running; then
            pg_run_psql "VACUUM;"
            exit 0
        else
            pg_error_not_running
        fi
        ;;
    
    "vacuum-full")
        if pg_check_running; then
            pg_run_psql "VACUUM FULL;"
            exit 0
        else
            pg_error_not_running
        fi
        ;;
    
    "convert")
        if pg_check_running; then
            pg_run_convert            
            exit 0
        else
            pg_error_not_running
        fi
        ;;
    
    *)
        echo "Usage: $0 pg {run|convert|vacuum|vacuum-full|analyze}"
        exit 1
        ;;
    esac
fi
