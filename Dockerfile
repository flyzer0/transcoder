FROM ubuntu:16.04
MAINTAINER zhifeng.wang

#ppa方式安装jdk默认选择条款
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

#安装java
RUN apt update \
        && apt-get -y update \
        && apt install -y software-properties-common python-software-properties \
        && add-apt-repository -y ppa:webupd8team/java \
        && apt update \
        && apt install -y oracle-java8-installer

#安装工具
RUN apt update \
        && apt install -y wget \
        && apt install -y vim \
        && apt install -y net-tools \
        && apt install -y iputils-ping \
	&& apt install -y apt-transport-https

WORKDIR /root
RUN mkdir soft && cd soft/ && mkdir hadoop && mkdir lentffmpeg

#视频文件目录
WORKDIR /opt
RUN mkdir DVTS && cd DVTS/ && mkdir input && mkdir output
COPY Parameters.xml DVTS/

#安装hadoop
WORKDIR /root/soft/hadoop
RUN wget http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-2.6.5/hadoop-2.6.5.tar.gz \
        && tar xvf hadoop-2.6.5.tar.gz \
        && rm -rf hadoop-2.6.5.tar.gz \
        && sed -i 's/JAVA_HOME=${JAVA_HOME}/JAVA_HOME=\/usr\/lib\/jvm\/java-8-oracle/g' hadoop-2.6.5/etc/hadoop/hadoop-env.sh
COPY hadoop/etc/hadoop/* hadoop-2.6.5/etc/hadoop/

#安装ffmpeg
COPY lentffmpeg /root/soft/lentffmpeg/

#安装mkvtoolnix
RUN wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add - \
        && sh -c 'echo "deb https://mkvtoolnix.download/ubuntu/ xenial main" >> /etc/apt/sources.list' \
        && apt-get update \
        && apt-get install -y mkvtoolnix mkvtoolnix-gui

#安装ssh
WORKDIR /root
RUN apt install -y ssh \
        && ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
        && cd .ssh/ && cat id_rsa.pub >> authorized_keys
COPY ssh/ssh_config /etc/ssh/

#环境变量
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle
ENV HADOOP_HOME=/root/soft/hadoop/hadoop-2.6.5
ENV HADOOP_CONFIG_HOME=$HADOOP_HOME/etc/hadoop
ENV PATH=$PATH:$JAVA_HOME/bin
ENV PATH=$PATH:$HADOOP_HOME/bin
ENV PATH=$PATH:$HADOOP_HOME/sbin

RUN mkdir /var/run/sshd
#启动脚本

CMD ["/usr/sbin/sshd", "-D"]

