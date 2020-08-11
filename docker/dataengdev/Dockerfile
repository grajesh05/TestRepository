FROM ubuntu:18.04
LABEL Rajesh Gomathinayagam

# -----------------
# Tool installation
# -----------------

RUN apt update
RUN apt install openjdk-8-jdk -y
RUN apt install openssh-server openssh-client -y
RUN apt install mysql-client -y
RUN apt install vim -y
RUN apt install sudo -y
RUN apt install sysvinit-utils -y
RUN apt install figlet -y


# -------------
# User Addition
# -------------

RUN useradd -m -p MzDPWUmdqZqV2 -s /bin/bash -U hadoopuser
RUN usermod -aG sudo hadoopuser
RUN echo "hadoopuser  ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/hadoopuser
USER hadoopuser
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys
RUN mkdir -p /home/hadoopuser/.shared_data
RUN mkdir -p /home/hadoopuser/.shared_data/hadoop/namenode
RUN mkdir -p /home/hadoopuser/.shared_data/hadoop/datanode

# ----------------------
# Environment Variables
# ----------------------

ENV USER_HOME /home/hadoopuser
ENV HADOOP_VERSION 2.7.7
ENV HADOOP_HOME ${USER_HOME}/opt/hadoop
ENV HIVE_HOME ${USER_HOME}/opt/hive
ENV SPARK_HOME ${USER_HOME}/opt/spark
ENV BASHRC_FILE ${USER_HOME}/.bashrc

# -------------
# COPY/INSTALL
# ------------

# Copy Artificats

RUN mkdir -p ${USER_HOME}/downloads
RUN mkdir -p ${USER_HOME}/opt

COPY ./artifacts/hadoop-2.7.7.tar.gz ${USER_HOME}/downloads/
COPY ./artifacts/apache-hive-2.3.7-bin.tar.gz ${USER_HOME}/downloads/
COPY ./artifacts/spark-2.4.6-bin-hadoop2.7.tgz ${USER_HOME}/downloads/
COPY ./artifacts/mysql-connector-java_8.0.21-1ubuntu18.04_all.deb ${USER_HOME}/downloads/

RUN sudo chown -R hadoopuser:hadoopuser ${USER_HOME}/downloads

# ------------ 
# INSTALLATION
# ------------ 

# Hadoop Installation

RUN tar -C ${USER_HOME}/opt -xf ${USER_HOME}/downloads/hadoop-2.7.7.tar.gz
RUN ln -s ${USER_HOME}/opt/hadoop-2.7.7 ${HADOOP_HOME}

# Hive Installation
RUN tar -C ${USER_HOME}/opt -xf ${USER_HOME}/downloads/apache-hive-2.3.7-bin.tar.gz
RUN ln -s ${USER_HOME}/opt/apache-hive-2.3.7-bin ${HIVE_HOME}

# Spark Installation
RUN tar -C ${USER_HOME}/opt -xf ${USER_HOME}/downloads/spark-2.4.6-bin-hadoop2.7.tgz
RUN ln -s ${USER_HOME}/opt/spark-2.4.6-bin-hadoop2.7 ${SPARK_HOME}

# Configs
COPY ./config/ssh_config ${USER_HOME}/.ssh/config
COPY ./config/hadoop-env.sh ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh
COPY ./config/core-site.xml ${HADOOP_HOME}/etc/hadoop/core-site.xml
COPY ./config/hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml
COPY ./config/yarn-site.xml ${HADOOP_HOME}/etc/hadoop/yarn-site.xml
COPY ./config/mapred-site.xml ${HADOOP_HOME}/etc/hadoop/mapred-site.xml
COPY ./config/hive-site.xml ${HIVE_HOME}/conf/hive-site.xml
RUN ln -s ${HIVE_HOME}/conf/hive-site.xml ${SPARK_HOME}/conf/hive-site.xml

RUN sudo chown -R hadoopuser:hadoopuser ${USER_HOME}/.ssh/config
RUN sudo chown -R hadoopuser:hadoopuser ${USER_HOME}/opt/

# MySql Connector
RUN sudo apt install ${USER_HOME}/downloads/mysql-connector-java_8.0.21-1ubuntu18.04_all.deb -y
RUN cp /usr/share/java/mysql-connector-java-8.0.21.jar ${USER_HOME}/opt/hive/lib/

# Boostrap/bashrc
COPY ./scripts/boostrap.sh ${USER_HOME}/boostrap.sh
COPY ./config/bashrc.config ${USER_HOME}/bashrc.config
RUN sudo chown hadoopuser:hadoopuser ${USER_HOME}/boostrap.sh
RUN sudo chown hadoopuser:hadoopuser ${USER_HOME}/bashrc.config

RUN chmod 755 ${USER_HOME}/boostrap.sh
RUN chmod 755 ${USER_HOME}/bashrc.config

RUN echo "#CUSTOM CONFIGS" >> ${USER_HOME}/.bashrc
RUN echo "#--------------" >> ${USER_HOME}/.bashrc
RUN cat ${USER_HOME}/bashrc.config >> ${USER_HOME}/.bashrc


# --------------------------------
# Exposing all the necessary ports 
# --------------------------------

				# SSH
EXPOSE 22
				# Namenode
EXPOSE 50070
    			# Datanode
EXPOSE 50075    			
		        # Resource Manager
EXPOSE 8088
                # History Server
EXPOSE 19888
                # Spark UI
EXPOSE 4040
                # Spark Master
EXPOSE 7077
EXPOSE 8080
EXPOSE 8081

# -----------------
# Cleanup Artifacts --- we don't need source files post installation
# -----------------

RUN rm -f ${USER_HOME}/downloads/*

# -----------
# Entry point
# -----------

ENTRYPOINT ${HOME}/boostrap.sh



