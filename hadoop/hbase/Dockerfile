FROM hadoop-sqoop-spark

# install zookeeper
ADD apache-zookeeper-3.5.9-bin.tar.gz /tmp
RUN mv /tmp/apache-zookeeper-3.5.9-bin /usr/local/zookeeper
ENV ZK_HOME=/usr/local/zookeeper
ENV PATH=$PATH:$ZK_HOME/bin
EXPOSE 2181 2888 3888

# install hbase
ADD hbase-1.6.0-bin.tar.gz /tmp
RUN mv /tmp/hbase-1.6.0 /usr/local/hbase
ENV HBASE_HOME=/usr/local/hbase
ENV PATH=$PATH:$HBASE_HOME/bin
EXPOSE 16000 16010 16020 16030

# install kylin
ADD apache-kylin-3.1.1-bin-hbase1x.tar.gz /tmp
RUN mv /tmp/apache-kylin-3.1.1-bin-hbase1x /usr/local/kylin
ENV KYLIN_HOME=/usr/local/kylin
ENV PATH=$PATH:$KYLIN/bin
EXPOSE 7070

# install elasticsearch jar
ADD elasticsearch-hadoop-7.2.0.jar /usr/local/hive/lib