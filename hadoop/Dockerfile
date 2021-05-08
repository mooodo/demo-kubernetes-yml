FROM ubuntu:14.04

# install java
ADD jdk-8u212-linux-x64.tar.gz /usr/local/java/
ENV JAVA_HOME=/usr/local/java/jdk1.8.0_212
ENV PATH=$PATH:$JAVA_HOME/bin

# install hadoop
ADD hadoop-2.7.7.tar.gz /tmp
RUN mv /tmp/hadoop-2.7.7 /usr/local/hadoop
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin 

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088

# install hive
ADD apache-hive-2.3.7-bin.tar.gz /tmp
RUN mv /tmp/apache-hive-2.3.7-bin /usr/local/hive
ENV HIVE_HOME=/usr/local/hive
ENV PATH=$PATH:$HIVE_HOME/bin:$HIVE_HOME/sbin

# install mysql-client
ADD mysql-connector-java-8.0.15.jar $HIVE_HOME/lib

# install spark
ADD spark-2.4.7-bin-hadoop2.7.tgz /tmp
RUN mv /tmp/spark-2.4.7-bin-hadoop2.7 /usr/local/spark
ENV SPARK_HOME=/usr/local/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
WORKDIR /

#Spark ports
EXPOSE 7077 8080