FROM python:2.7
RUN apt-get update &&\
    apt-get install -y redis-tools dnsutils
RUN pip install redis-trib
CMD ["bash"]