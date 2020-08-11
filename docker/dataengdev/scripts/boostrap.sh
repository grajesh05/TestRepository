#!/bin/sh

#### Source command not effective - so copying all exports here again :(
export SHARED_DIR=/home/hadoopuser/.shared_data
export NAMENODE_DIR=${SHARED_DIR}/hadoop/namenode
export HADOOP_HOME=/home/hadoopuser/opt/hadoop
export HIVE_HOME=/home/hadoopuser/opt/hive
export SPARK_HOME=/home/hadoopuser/opt/spark
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$SPARK_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"

sudo /etc/init.d/ssh start

# Actions for first time
# -----------------------

# Namenode initialize

if [ ! -e ${NAMENODE_DIR}/format.done ];then
    ${HADOOP_HOME}/bin/hdfs namenode -format
    touch ${NAMENODE_DIR}/format.done
fi

export MYSQL_PWD=root
attempt=1
while true;do
    hive_user_exist=$(mysql --host=hive-meta --port=3306 --user=root -sN -e "select 1 from mysql.user where user = 'hive';")
    if [ $? -ne 0 ];then
        echo "MySql connection failed. Waiting.."
        sleep 10
        echo "Retrying..."        
        if [ $attempt -eq 5 ];then
        	echo "Unable to connect to MySQL after $attempt attempts. Exiting..."
        	exit 1
        fi
        attempt=$((attempt+1))
        continue
    fi
    echo "MySQL Connection successful"
    break
done    



if [ "${hive_user_exist}" != "1" ];then
    cd /home/hadoopuser/opt/hive/scripts/metastore/upgrade/mysql
    mysql --host=hive-meta --port=3306 --user=root -sN -e "\
    CREATE USER 'hive'@'%' IDENTIFIED BY 'hive';\
    CREATE DATABASE metastore;\
    USE metastore;\
    SOURCE hive-schema-2.3.0.mysql.sql;\
    REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'hive'@'%';\
    GRANT ALL PRIVILEGES ON metastore.* TO 'hive'@'%';\
    FLUSH PRIVILEGES;"
    cd -

fi

# Starting services    
# ------------------

${HADOOP_HOME}/sbin/start-dfs.sh

${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/hadoopuser
${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /tmp
${HADOOP_HOME}/bin/hdfs dfs -chmod g+w /tmp
${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/hive/warehouse
${HADOOP_HOME}/bin/hdfs dfs -chmod g+w /user/hive/warehouse
    

${HADOOP_HOME}/sbin/start-yarn.sh

${HIVE_HOME}/bin/hive --service metastore > /dev/null 2>&1 &
${HIVE_HOME}/bin/hiveserver2 start > /dev/null 2>&1 &
    
# Keep system alive
# -----------------

sleep infinity


