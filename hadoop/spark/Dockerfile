FROM hadoop-hive

# install sqoop
ADD sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz /tmp
RUN mv /tmp/sqoop-1.4.7.bin__hadoop-2.6.0 /usr/local/sqoop
ENV SQOOP_HOME=/usr/local/sqoop
ENV PATH=$PATH:$SQOOP_HOME/bin

# install spark
ADD spark-2.4.4-bin-hadoop2.7.tgz /tmp
RUN mv /tmp/spark-2.4.4-bin-hadoop2.7 /usr/local/spark
ENV SPARK_HOME=/usr/local/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

#Spark ports
EXPOSE 7077 8080

WORKDIR /