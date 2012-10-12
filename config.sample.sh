#!/bin/bash
#------------------------------------
# CONFIGURATION FOR SCRIPTS
#------------------------------------

export TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`

#------ DATABASE -------
export DB_NAME=
export DB_USER=
export DB_PASSWD=
export DB_BACKUP_PATH=

# list of administrators emails
export DB_ADMIN_MAILS=

# The database is backuped in several packets. One packet is a set of tables.
# How many tables would you like to save in one packet ?
export DB_NUMBER_OF_TABLES_BY_PACKET=9

#------ ELGG DATA -------
export ELGG_DATA_PATH=
export ELGG_DATA_BACKUP_PATH=

#------ TOOLS ----------
export MAIL_CMD=mailx

