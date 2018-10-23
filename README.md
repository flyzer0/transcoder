# transcoder
docker部署hadoop+ffmpeg分布式转码系统

该系统共有四个节点：1个主节点、3个从节点，这四个节点都在同一个宿主机上。<br/>

#版本<br/>
宿主机：ubuntu16.04<br/>
hadoop:2.6.5<br/>
ffmpeg:使用视骏的产品（lentffmpeg），该产品在高分辨率下的编码速度比H.265快很多。<br/>
mkvtoolnix:24.0.0<br/>

#系统简介<br/>
该系统实现包含两个项目：TranscoderClient和TranscoderMR，其中TranscoderClient对视频文件进行切片，并将切片文件上传至HDFS，而后在集群中调起TranscoderMR项目，对各切片进行转码，将转码成功后的切片上传至HDFS，最后用lentffmpeg对各切片进行合并。

#参数<br/>
启动TranscoderClient需要四个参数：<br/>
待转码的视频文件所在本地位置    /opt/DVTS/input/ <br/>
转码后的视频文件存放本地位置    /opt/DVTS/output/ <br/>
转码过程中读入的转码参数        /opt/DVTS/Parameters.xml <br/>
转码任务的用户名               hadoop <br/>

#注意<br/>
1.在用Dockerfile生成镜像的时候，可能会遇到mkvtoolnix安装失败的问题，请在mkvtoolnix官网上查看源是否更改。<br/>
2.本系统不会提供lentffmpeg，如果需要，请与视骏相关人员联系。<br/>

# docker启动集群
#创建网络<br/>
docker network create --driver=overlay --attachable hadoop<br/>
#启动各节点<br/>
docker run -dit -p 8042:8042 -p 8088:8088 --hostname=master -p 8054:8054 --name=master --network=hadoop transcoder:latest<br/>
docker run -dit -p 8043:8042 --hostname=slave1 --name=slave1 --network=hadoop transcoder:latest<br/>
docker run -dit -p 8044:8042 --hostname=slave2 --name=slave2 --network=hadoop transcoder:latest<br/>
docker run -dit -p 8045:8042 --hostname=slave3 --name=slave3 --network=hadoop transcoder:latest<br/>
