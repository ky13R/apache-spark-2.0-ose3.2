FROM 172.30.34.177:5000/openshift/rhel7:latest

COPY epel-release-latest-7.noarch.rpm $HOME 
RUN rpm -ivh epel-release-latest-7.noarch.rpm && yum install -y tar java && \
    yum clean all

RUN cd /opt && \
    curl https://dist.apache.org/repos/dist/release/spark/spark-2.0.0/spark-2.0.0-bin-hadoop2.7.tgz | \
        tar -zx && \
    ln -s spark-2.0.0-bin-hadoop2.7 spark

# SPARK_WORKER_DIR defaults to SPARK_HOME/work and is created on
# Worker startup if it does not exist. instead of making SPARK_HOME
# world writable, create SPARK_HOME/work.
RUN mkdir /opt/spark/work && chmod a+rwx /opt/spark/work
RUN chmod -R 777 /opt/spark

# when the containers are not run w/ uid 0, the uid may not map in
# /etc/passwd and it may not be possible to modify things like
# /etc/hosts. nss_wrapper provides an LD_PRELOAD way to modify passwd
# and hosts.
RUN yum install -y nss_wrapper && yum clean all
ENV LD_PRELOAD=libnss_wrapper.so

ENV PATH $PATH:/opt/spark/bin
ENV SPARK_USER=root

ADD common.sh start-master start-worker /
RUN chmod a+rx /common.sh /start-master /start-worker
