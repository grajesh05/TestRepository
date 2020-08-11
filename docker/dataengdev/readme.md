# How to build image and run?

## Clone

Clone this repository into local directory

## Artifact Download

Download below artifacts and place it in artifacts folder before building docker image

+ [Hadoop 2.7.7](https://archive.apache.org/dist/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz)
+ [Apache Hive 2.3.7](https://downloads.apache.org/hive/hive-2.3.7/apache-hive-2.3.7-bin.tar.gz)
+ [Apache Spark 2.4.6 for Hadoop 2.7](https://www.apache.org/dyn/closer.lua/spark/spark-2.4.6/spark-2.4.6-bin-hadoop2.7.tgz)
+ [MySQL Connector JDBC](https://dev.mysql.com/downloads/connector/j/). Select operating system as Ubuntu and version 18.04. `Note: You should be downloading file named (mysql-connector-java_8.0.21-1ubuntu18.04_all.deb)`

## Build Image

From the local directory of this repo (`i.e. where Dockerfile is present`) run the below command.

> docker build -t dedev:latest .

```
When doing for first time, base image ubuntu:18.04 will be pulled from DockerHub
```

## Verify Image

If the above build is successful. Running the `docker images` command should be showing new image named `dedev`

## Running the container

```
All these commands to be run from the location where Dockerfile/docker-compose.yml is present
```
This repo includes `docker-compose.yml` and hence docker-compose will be easier option to run both `dedev` and dependent `mysql` container.

> docker-compose up - d

The above command will kick off 2 containers (`mysql` and `dedev`). 
```
Though the container will be started in few seconds. Please wait for a minute to allow all the services like namenode, datanode, hiveserver2 to kick in
```

once the container is up and running for a minute, below command will enable to start a session

> docker exec -it dedev bash

```
This starts an interative bash shell
```

Finally to shut down the container properly, use below command

> docker-compose down




