#!/bin/bash

source ./config.sh

test -w ${DB_BACKUP_PATH} || mkdir -p ${DB_BACKUP_PATH}
test -w ${DB_BACKUP_PATH}/${TIMESTAMP} || mkdir -p ${DB_BACKUP_PATH}/${TIMESTAMP}

TABLES_LIST=`mysql -u ${DB_USER} --password=${DB_PASSWD} -A --skip-column-names -e"SELECT CONCAT(table_schema,'.',table_name) FROM information_schema.tables WHERE table_schema IN ('$DB_NAME')"`

if [ $? -ne 0 ];
then
	logger "bd_backup : unable to get tables list"
	SUBJECT="[DATABASE_DUMP_ERROR] : ${DB_NAME} - UNABLE TO GET TABLE LIST"
	${MAIL_CMD} -s ${SUBJECT} ${DB_ADMIN_MAILS}
	exit 1
fi


PACKET_NUMBER=1
COMMIT_COUNT=0
COMMIT_LIMIT=${DB_NUMBER_OF_TABLES_BY_PACKET}
for DBTB in $TABLES_LIST
do
    DB=`echo ${DBTB} | sed 's/\./ /g' | awk '{print $1}'`
    TB=`echo ${DBTB} | sed 's/\./ /g' | awk '{print $2}'`
    
    COMMIT_COUNT=`expr $COMMIT_COUNT + 1`
    
    if [ ${COMMIT_COUNT} -gt ${COMMIT_LIMIT} ]
    then
		mysqldump -u ${DB_USER} --password=${DB_PASSWD} --hex-blob --databases $DB --tables $TABLES | gzip > ${DB_BACKUP_PATH}/${TIMESTAMP}/${DB_NAME}_${PACKET_NUMBER}.sql.gz &
		
		if [ $? -ne 0 ];
		then
			logger "bd_backup : error in packet n°${PACKET_NUMBER}"
			SUBJECT="[DATABASE_DUMP_ERROR] : ${DB_NAME} - PACKET N°${PACKET_NUMBER}"
			${MAIL_CMD} -s ${SUBJECT} ${DB_ADMIN_MAILS}
			exit 1
		fi

        PACKET_NUMBER=`expr $PACKET_NUMBER + 1`
        COMMIT_COUNT=0
        TABLES=""
    else
        TABLES="$TABLES $TB"
    fi
done

if [ ${COMMIT_COUNT} -gt 0 ]
then
	mysqldump -u ${DB_USER} --password=${DB_PASSWD} --hex-blob --databases $DB --tables $TABLES | gzip > ${DB_BACKUP_PATH}/${TIMESTAMP}/${DB_NAME}_${PACKET_NUMBER}.sql.gz &

	if [ $? -ne 0 ];
	then
		logger "bd_backup : error in the last packet"
		SUBJECT="[DATABASE_DUMP_ERROR] : ${DB_NAME} - LAST PACKET"
		${MAIL_CMD} -s ${SUBJECT} ${DB_ADMIN_MAILS}
		exit 1
	fi
fi

echo "$PACKET_NUMBER packet(s) saved !"
${MAIL_CMD} -s "DB_BACKUP - $PACKET_NUMBER packet(s) saved !" ${DB_ADMIN_MAILS}
