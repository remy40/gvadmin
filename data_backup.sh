#!/bin/bash

source ./config.sh

test -w ${ELGG_DATA_BACKUP_PATH} || mkdir -p ${ELGG_DATA_BACKUP_PATH}

logger "rdiff_backup_elgg_data: Suppression des anciens backups (> 30 jours)"
rdiff-backup --remove-older-than 30D --force ${ELGG_DATA_BACKUP_PATH}
logger "rdiff_backup_elgg_data: Backup du répertoire ${ELGG_DATA_PATH}."
rdiff-backup ${ELGG_DATA_PATH} ${ELGG_DATA_BACKUP_PATH}
logger "rdiff_backup_elgg_data: Fin du backup."
