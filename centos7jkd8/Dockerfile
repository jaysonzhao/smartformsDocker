FROM centos:latest
MAINTAINER wwd <2512885541@qq.com>
RUN  yum update -y && \
    yum clean all && \
    yum -y install wget net-tools vim && \
    cd /opt && \
    wget http://192.168.2.173:8081/jdk-8u144-linux-x64.tar.gz\
     && tar -xvf ./jdk-8u144-linux-x64.tar.gz && rm -f /opt/jdk-8u144-linux-x64.tar.gz

ENV JAVA_HOME=/opt/jdk1.8.0_144
ENV JRE_HOME=/opt/jdk1.8.0_144/jre
ENV PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
ENV CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
run export JAVA_HOME JRE_HOME PATH CLASSPATH
ENV HOME=/root
WORKDIR /root
CMD ["/bin/bash"]
