FROM java:8
ADD apache-skywalking-apm-es7-8.6.0.tar.gz /
RUN mv /apache-skywalking-apm-bin-es7 /usr/local/skywalking
ENV SW_HOME=/usr/local/skywalking
ENV PATH=$PATH:$SW_HOME/bin
ADD mysql-connector-java-8.0.19.jar /usr/local/skywalking/oap-libs
WORKDIR $SW_HOME/bin
EXPOSE 11800 12800