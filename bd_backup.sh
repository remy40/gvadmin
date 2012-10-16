#!/bin/bash

TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
DB_NAME=elgg-gv
DB_USER=root
DB_PASSWD=saubion
DB_BACKUP_PATH=/var/backup/databases
DB_ADMIN_MAILS=remy.gv@gmail.com

test -w ${DB_BACKUP_PATH} || mkdir -p ${DB_BACKUP_PATH}

mysqldump -u ${DB_USER} --password=${DB_PASSWD} --hex-blob --databases ${DB_NAME} > ${DB_BACKUP_PATH}/${TIMESTAMP}_${DB_NAME}.sql

if [ $? -ne 0 ];
then
	logger "[bd_backup] error"
	SUBJECT="[DATABASE_DUMP_ERROR] : ${DB_NAME}"
	echo $SUBJECT | mailx -s ${SUBJECT} ${DB_ADMIN_MAILS}
	rm ${DB_BACKUP_PATH}/${TIMESTAMP}_${DB_NAME}.sql
	exit 1
fi

gzip -c ${DB_BACKUP_PATH}/${TIMESTAMP}_${DB_NAME}.sql > ${DB_BACKUP_PATH}/${TIMESTAMP}_${DB_NAME}.sql.gz
rm ${DB_BACKUP_PATH}/${TIMESTAMP}_${DB_NAME}.sql

echo "DB backuped !"
SUBJECT="${TIMESTAMP}:DB backuped:OK"
echo ${SUBJECT} | mailx -s ${SUBJECT} ${DB_ADMIN_MAILS}
