FROM solarcentos7jdk7:v1
MAINTAINER wwd <2512885541@qq.com>
RUN  yum install -y npm unzip
RUN  cd /opt && \
    wget http://192.168.2.173:8081/node-v4.8.3-linux-x64.tar.gz\
     && tar -xvf ./node-v4.8.3-linux-x64.tar.gz && rm -f /opt/node-v4.8.3-linux-x64.tar.gz
ENV JAVA_HOME=/opt/jdk1.8.0_144
ENV JRE_HOME=/opt/jdk1.8.0_144/jre
ENV NODE_HOME=/opt/node-v4.8.3-linux-x64
ENV PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin:$NODE_HOME/bin
ENV CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
RUN export JAVA_HOME JRE_HOME PATH NODE_HOME CLASSPATH

RUN  cd /opt && wget http://192.168.2.173:8081/drd-modeler.zip\
     && unzip  ./drd-modeler.zip && rm -f /opt/drd-modeler.zip

RUN npm install -g grunt-cli

#RUN  cd  /opt/drd-modeler/node_modules/grunt && nohup grunt auto-build &
RUN chmod -R 777 /opt/drd-modeler	 
EXPOSE 9013
EXPOSE 9014
ENV HOME=/root
#WORKDIR /opt/drd-modeler/node_modules/grunt
#RUN chmod -R 777 /opt/drd-modeler/node_modules/grunt/nohup.out
#CMD nohup grunt auto-build &

#RUN  cd  /opt/drd-modeler/node_modules/grunt && nohup grunt auto-build &
WORKDIR /root
CMD ["/bin/bash"]
