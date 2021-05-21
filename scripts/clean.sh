source env.sh

cubrid service stop

rm -r ${DBMETHOD_DIR}
rm -r ${DBJAVASP_DIR}

rm ${DBLOG}/${DBNAME}_*.*
rm ${DBLOG_SERVER_DIR}/${DBNAME}_*.err