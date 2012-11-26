#!/bin/bash

#set -x

TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
PARAMSFILE=$1
# PARAMSFILE MUST DEFINE THE FOLLOWING VARIABLES :
# DB_NAME=elgg-gv
# DB_USER=<dbuser>
# DB_PASSWD=<dbpasswd>
# DB_BACKUP_PATH=/var/backup/databases
# DB_ADMIN_MAILS=remy.gv@gmail.com
# NB_BACKUPS=30
. $PARAMSFILE


test -w ${DB_BACKUP_PATH} || mkdir -p ${DB_BACKUP_PATH}

nice -n 19 mysqldump -u ${DB_USER} --password=${DB_PASSWD} --hex-blob --databases ${DB_NAME} > ${DB_BACKUP_PATH}/${TIMESTAMP}_${DB_NAME}.sql

if [ $? -ne 0 ];
then
	logger "[bd_backup] error"
	SUBJECT="[DATABASE_DUMP_ERROR] : ${DB_NAME}"
	echo $SUBJECT | mailx -s ${SUBJECT} ${DB_ADMIN_MAILS}
	rm ${DB_BACKUP_PATH}/${TIMESTAMP}_${DB_NAME}.sql
	exit 1
fi

nice -n 19 gzip -9 -c ${DB_BACKUP_PATH}/${TIMESTAMP}_${DB_NAME}.sql > ${DB_BACKUP_PATH}/${TIMESTAMP}_${DB_NAME}.sql.gz
rm ${DB_BACKUP_PATH}/${TIMESTAMP}_${DB_NAME}.sql


# BEGIN : keep only ${NB_BACKUPS}
cd $DB_BACKUP_PATH

CONTINUE=1

# BEGIN : LOOP
while test $CONTINUE -eq 1
do

NBFILES=`ls $BACKUPDIR | wc -l`

echo "NBFILES="$NBFILES

if test $NBFILES -gt  ${NB_BACKUPS}
then
echo "removing & continuing"
rm  `ls -t $BACKUPDIR | tail -1`
else
CONTINUE=0
echo "exiting"
fi

done 
# END : LOOP
# END : keep only ${NB_BACKUPS}


echo "DB backuped !"
SUBJECT="${TIMESTAMP}:DB backuped:OK"
echo ${SUBJECT} | mailx -s "${SUBJECT}" ${DB_ADMIN_MAILS}
