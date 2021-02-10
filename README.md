# Docker version of Hadoop+Spark+GraphFrames+Jupyterlab

This repo is made for giving an easy way to learn Spark and Hadoop. In the demo folder you have many demo notebooks using pySpark.


Version used as of november 2020 :
- Python 3.8
- Java 11 OpenJDK (/usr/lib/jvm/java-1.11.0-openjdk-amd64)
- Hadoop 3.3.0
- Spark 3.0.1
- GraphFrames 0.8.1

The spark demo dataset and the local demo/data folder are copied in HDFS at startup. 



How to run :
```
docker-compose --compatibility up
```

To stop it : Ctrl+C

Availiable URL :
- [Hadoop WebUI for NameNode](http://localhost:9879)
- [Hadoop DataNode](http://localhost:9864)
- [YARN Resourcemanager](http://localhost:8988)
- [Spark Master Web Console](http://localhost:8089)
- [Spark History Server](http://localhost:1808)
- [Spark Job Web Console](http://localhost:4049)
- [Spark Notebooks](http://localhost:8892) : A notebook launched by pySpark to use GraphFrames
- [Jupyter Lab Notebooks](http://localhost:7988) : An independant Notebook to use Spark like if you were outside the container.
- [SparkStreaming + Flask + ChartJS Twitter Dashboard](http://localhost:5001) (you have to start it manualy)

## Annexes


If you want to use spark-submit with Python code you have to force the Python interpreter like this :
```
spark-submit --master spark://spark-master:7077 \
  --conf "spark.pyspark.python=$PYSPARK_PYTHON" \
  --conf "spark.pyspark.driver.python=$PYSPARK_PYTHON"\
  --name wordcount "/usr/local/spark-3.0.1-bin-hadoop3.2/examples/src/main/python/wordcount.py" \
  /demo/txt/victor_hugo-texts.txt
```

To run only one container :
```

```
docker run -it \
    -p 9879:9870 \
    -p 8988:8088 \
    -p 8089:8080 \
    -p 1808:18080 \
    -p 9009:9000 \
    -p 8892:8888 \
    -p 7988:7988 \
    -p 9864:9864 \
    -p 4946:4046 \
    -p 4049:4040 \
    -p 5001:5001 \
    -v /media/data-nvme/dev/src/docker-hadoop-spark-graphframes-jupyterlab/demo:/root/ipynb \
    -e PYSPARK_MASTER=spark://localhost:7077 \
    -e JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64 \
    -e NOTEBOOK_PASSWORD='' \
    spark-graphframes:local
```

To limit CPU and memory you could use :
```
    --memory=16G \
    --memory-swap=16G \
    --cpus=16 \
```

To only build :
```
docker build -t spark-graphframes:local .
```
(If problem, try with '--no-cache')

To go inside the container if needed :
```
docker exec -it <container id> /bin/bash
```

But you could also use the terminal of Jupyter.

A great thanks to https://github.com/oneoffcoder/docker-containers/tree/master/spark-jupyter and https://github.com/dsaidgovsg/python-spark/blob/master/python3/spark2.1/Dockerfile for the Docker part. I've updated some components to make things work.

