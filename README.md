# docker-hadoop-spark-graphframes-jupyterlab
Dockerfile for Hadoop+Spark+GraphFrames+Jupyterlab

Version used as of november 2020 :
- Python 3.8
- Java 11 OpenJDK (/usr/lib/jvm/java-1.11.0-openjdk-amd64)
- Hadoop 3.3.0
- Spark 3.0.1
- Anaconda3 5.3.1
- GraphFrames 0.8.1

```
docker build --no-cache -t spark-graphframes:local .
```

```
docker run -it \
    -p 9870:9870 \
    -p 8088:8088 \
    -p 8080:8080 \
    -p 18080:18080 \
    -p 9000:9000 \
    -p 8889:8888 \
    -p 7988:7988 \
    -p 9864:9864 \
    -v /media/data-nvme/dev/src/docker-hadoop-spark-graphframes-jupyterlab/demo:/root/ipynb \
    -e PYSPARK_MASTER=spark://localhost:7077 \
    -e JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64 \
    -e NOTEBOOK_PASSWORD='' \
    spark-graphframes:local
```

Availiable URL :
- (Hadoop Web console)[http://localhost:9870]
- (Hadoop DataNode)[http://localhost:9864]
- (Hadoop)[http://localhost:8088]
- (Spark Master Web Console)[http://localhost:8080]
- (Spark History Server)[http://localhost:18080]
- (Spark Notebooks)[http://localhost:8889]
- (Standard Notebooks)[http://localhost:7988]

