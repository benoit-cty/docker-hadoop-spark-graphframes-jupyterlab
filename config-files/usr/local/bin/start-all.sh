#!/bin/bash

echo "Java home JAVA_HOME=$JAVA_HOME"

service ssh start
echo "started ssh"

echo "Starting hadoop"
echo "export JAVA_HOME=$JAVA_HOME" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
$HADOOP_HOME/sbin/start-all.sh
echo "Started hadoop !"

echo "Startinf Spark"
$SPARK_HOME/sbin/start-all.sh
echo "started spark !"

echo "starting spark history"
$SPARK_HOME/sbin/start-history-server.sh
echo "started spark history"

# pyspark --master spark://localhost:7077 > /tmp/jupyter.log 2>&1 &
# options: https://gerardnico.com/db/spark/pyspark/pyspark
$SPARK_HOME/bin/pyspark \
    --packages $PYSPARK_PACKAGES \
    --master $PYSPARK_MASTER &

#    --master $PYSPARK_MASTER > /tmp/jupyter.log 2>&1 &
echo "started pyspark"

hdfs dfs -mkdir /demo
hdfs dfs -copyFromLocal -f /usr/local/spark/data /demo/spark

if [ -d "/root/ipynb/data" ]; then
        hdfs dfs -copyFromLocal -f /root/ipynb/data /demo/
else
    echo "/root/ipynb/data does not exists"
fi

echo "Starting Jupyter"
cd /root/ipynb && jupyter lab --ip='*' --port=7988 --no-browser --allow-root  --NotebookApp.password=$NOTEBOOK_PASSWORD &

echo "done!"

while sleep 600; do
  ps aux |grep jupyter |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep spark |grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  else
    echo "Still running..."
  fi
done