#!/bin/sh
PATH="/usr/local/mysql/bin:/usr/local/bin:/usr/bin:/bin"

MYSQL_CONTEXT="mysql -h*** -P*** -uddl_yaq_callback -pasRTF_d@q_a23er"

function exec_mysql_context()
{
	if [ $# -ne 2 ]; then
		echo "Usage: $FUNCNAME SQL SQL_CONTEXT" 1>&2
		echo "Example: $FUNCNAME \"show tables\" \"mysql -N -B -uroot -pabc xyz\"" 1>&2 
		return 1
	fi
	PARAM_SQL_STATEMENT="$1"
	MYSQL_CONTEXT="$2"
	echo "${PARAM_SQL_STATEMENT}" | ${MYSQL_CONTEXT}
	if [ $? -ne 0 ]; then
		echo "Error: exec_mysql failed ${MYSQL_CONTEXT} "
		echo "PARAM_SQL_STATEMENT:${PARAM_SQL_STATEMENT}"		
		exit 1
	fi
	return 0
}

function create_callbacknotify_db()
{
    DB_NAME_BASE="$1"
	TABLE_NAME_BASE="$2"
    MYSQL_CONTEXT=$3
    for((i=0;i<16;i++))
    {
        iIndex=$(echo "ibase=10;obase=16;$i" | bc)
        iIndex=$(echo $iIndex | tr '[:upper:]' '[:lower:]')

        strDBName="${DB_NAME_BASE}_$iIndex"
        SQL="drop database if exists ${strDBName};create database ${strDBName}"
        echo "${SQL}"
		exec_mysql_context "${SQL}" "${MYSQL_CONTEXT}"
		for((j=0;j<16;j++))
		{
			for((k=0;k<16;k++))
			{
				jIndex=$(echo "ibase=10;obase=16;$j" | bc)
				jIndex=$(echo $jIndex | tr '[:upper:]' '[:lower:]')
				kIndex=$(echo "ibase=10;obase=16;$k" | bc)
				kIndex=$(echo $jIndex | tr '[:upper:]' '[:lower:]')
				
				strTableName="${TABLE_NAME_BASE}_$jIndex$kIndex"
				SQL="use ${strDBName};drop table if exists ${strTableName};
					CREATE TABLE if not exists ${strTableName}(
					Frecord_id int(10) NOT NULL AUTO_INCREMENT COMMENT '自增ID',
					Fnotifytype TINYINT NOT NULL  DEFAULT 0 COMMENT '0-未知, 1-查缓存, 2-工接入, 3-载服务, 4-接入中心',
					Ffsha1 varchar(40) NOT NULL DEFAULT '' COMMENT '软件文件FSHA1',
					Fsource_id int NOT NULL DEFAULT 0 COMMENT '软件来源渠道id',
					Fsid  varchar(8192) NOT NULL DEFAULT '' COMMENT '软件url或者fmd5',
					Fsid_md5 varchar(32) NOT NULL DEFAULT '' COMMENT 'sid to md5',
					Finsert_time datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '插入时间',
					Fmodify_time datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '修改时间',
					PRIMARY KEY (Frecord_id),
					KEY key_fsha1 (Ffsha1),
					KEY key_fsha1_sourceid ( Ffsha1, Fsource_id ),
					KEY key_sourceid_sid ( Fsource_id, Fsid_md5)
					) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8"
				echo "${SQL}"
				exec_mysql_context "${SQL}" "${MYSQL_CONTEXT}"
			}
		}
    }
}

create_callbacknotify_db callbacknotify_db_beta callbacknotify_table "${MYSQL_CONTEXT}"
