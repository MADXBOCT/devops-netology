docker run -dit --name clickhouse-01 centos:7 && \ 
docker run -dit --name vector-01 centos:7 && \
docker run -dit --name lighthouse-01 centos:7
docker stop  $(docker ps -a -q) && docker rm -f $(docker ps -a -q)