# Thanks to https://github.com/oneoffcoder/docker-containers/tree/master/spark-jupyter
# And https://github.com/dsaidgovsg/python-spark/blob/master/python3/spark2.1/Dockerfile

# Debian Buster with Python
FROM python:3.8-buster 



ENV HDFS_NAMENODE_USER=root
ENV HDFS_DATANODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root
ENV YARN_RESOURCEMANAGER_USER=root
ENV YARN_NODEMANAGER_USER=root
ENV YARN_PROXYSERVER_USER=root
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_YARN_HOME=${HADOOP_HOME}
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV HADOOP_LOG_DIR=${HADOOP_YARN_HOME}/logs
ENV HADOOP_IDENT_STRING=root
ENV HADOOP_MAPRED_IDENT_STRING=root
ENV HADOOP_MAPRED_HOME=${HADOOP_HOME}
ENV SPARK_HOME=/usr/local/spark
ENV PYSPARK_MASTER=yarn
ENV PATH=${SPARK_HOME}/bin:${HADOOP_HOME}/bin:${PATH}
ENV NOTEBOOK_PASSWORD=""
ENV SPARK_MASTER_HOST=localhost

# setup Debian
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get -y install default-jdk wget openssh-server sshpass \
    && apt-get -y install nano net-tools lynx \
    && apt-get clean

# Install Java
# TODO, use $(/usr/bin/env java -XshowSettings:properties -version 2>&1 | grep "java.home" | cut -d"=" -f2)
ENV JAVA_HOME /usr/lib/jvm/java-1.11.0-openjdk-amd64


# install hadoop

RUN wget -q http://apache.mirrors.tds.net/hadoop/common/hadoop-3.3.0/hadoop-3.3.0.tar.gz -O /tmp/hadoop.tar.gz \
    && tar -xzf /tmp/hadoop.tar.gz -C /usr/local/ && rm -fr /usr/local/hadoop-3.3.0/etc/hadoop/*
RUN ln -s /usr/local/hadoop-3.3.0 $HADOOP_HOME \
    && mkdir $HADOOP_HOME/extras \
	&& mkdir -p /var/hadoop/hadoop-datanode \
	&& mkdir /var/hadoop/hadoop-namenode \
	&& mkdir -p /var/hadoop/mr-history/done \
	&& mkdir /var/hadoop/mr-history/tmp

RUN mkdir -p /usr/local/hadoop/logs
# install spark
RUN wget -q https://miroir.univ-lorraine.fr/apache/spark/spark-3.0.1/spark-3.0.1-bin-hadoop3.2.tgz -O /tmp/spark.tgz \
    && tar -xzf /tmp/spark.tgz -C /usr/local/ \
    && ln -s /usr/local/spark-3.0.1-bin-hadoop3.2 /usr/local/spark \
    && rm /usr/local/spark/conf/*.template

# 
RUN $SPARK_HOME/bin/spark-shell --packages graphframes:graphframes:0.8.1-spark3.0-s_2.12
ENV PYSPARK_PACKAGES="graphframes:graphframes:0.8.1-spark3.0-s_2.12"

# setup volumes
RUN mkdir /root/ipynb
VOLUME [ "/root/ipynb" ]

# Setup Python env
# NodeJS for Jupyter

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs && apt-get clean
RUN python -m pip install --upgrade pip && pip install jupyterlab plotly spylon-kernel
RUN python -m spylon_kernel install
RUN jupyter labextension install jupyterlab-plotly
RUN jupyter labextension install @jupyterlab/toc
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# setup supervisor
#COPY config-files/etc/supervisor/supervisor.conf /etc/supervisor/supervisor.conf
#COPY config-files/etc/supervisor/conf.d/all.conf /etc/supervisor/conf.d/all.conf

# setup ssh : needed for Hadoop and Spark to ssh to localhost
RUN ssh-keygen -t rsa -P "" -f /root/.ssh/id_rsa \
    && cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys \
    && chmod 0600 /root/.ssh/authorized_keys
COPY config-files/root/.ssh/config /root/.ssh/config

# spark conf
COPY config-files/usr/local/spark/conf/* /usr/local/spark/conf/

# Hadoop conf
COPY config-files/usr/local/hadoop/etc/hadoop/* /usr/local/hadoop/etc/hadoop/
COPY config-files/usr/local/hadoop/extras/* /usr/local/hadoop/extras/
RUN $HADOOP_HOME/bin/hdfs namenode -format hadoopnode
# clean up : useless because already in previous layers :(
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir /tmp/spark-events

# Spark Master
EXPOSE 7077
# Hadoop WebUI for NameNode
EXPOSE 9870
# YARN Resourcemanager
EXPOSE 8088
# Spark Master Web Console
EXPOSE 8080
# Spark History Server
EXPOSE 18080
EXPOSE 9000
# Spark Jupyter Notebook
EXPOSE 8888
# Jupyter Lab Notebooks
EXPOSE 7988
# Hadoop DataNode
EXPOSE 9864
EXPOSE 4046
# Spark Job Web Console
EXPOSE 4040
# Flask
EXPOSE 5001

COPY config-files/usr/local/bin/start-all.sh /usr/local/bin/start-all.sh
RUN chmod a+x /usr/local/bin/start-all.sh
ENTRYPOINT [ "/usr/local/bin/start-all.sh" ]