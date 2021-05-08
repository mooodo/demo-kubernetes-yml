FROM kibana:7.2.0
ADD logtrail-7.2.0-0.1.31.zip /tmp/
RUN ./bin/kibana-plugin install file:///tmp/logtrail-7.2.0-0.1.31.zip
COPY logtrail.json /usr/share/kibana/plugins/logtrail/

# RUN curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.2.0-darwin-x86_64.tar.gz &&\
#     tar xzvf metricbeat-7.2.0-darwin-x86_64.tar.gz 
# ADD metricbeat-7.2.1-linux-x86_64.tar.gz .
# COPY metricbeat.yml metricbeat-7.2.1-linux-x86_64/
# RUN cd metricbeat-7.2.1-linux-x86_64/ &&\
#    ./metricbeat modules enable kubernetes &&\
#    ./metricbeat setup &&\
#    ./metricbeat -e

# ADD metricbeat-7.2.1-linux-x86_64.tar.gz /tmp
# USER root
# COPY metricbeat.yml /tmp/metricbeat-7.2.1-linux-x86_64/
#RUN cd /tmp/metricbeat-7.2.1-linux-x86_64/ &&\
#    ./metricbeat modules enable kubernetes &&\
#    ./metricbeat setup &&\
#    ./metricbeat -e