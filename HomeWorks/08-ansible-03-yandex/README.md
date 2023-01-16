docker run -dit --name clickhouse-01 centos:7 && \
docker run -dit --name vector-01 centos:7 && \
docker run -dit -p 18123:8123 --name lighthouse-01 --cap-add=NET_ADMIN --privileged=true centos:7 /usr/sbin/init
docker run -dit -p 18123:8123 --name lighthouse-01 ubuntu:22.04
docker stop  $(docker ps -a -q) && docker rm -f $(docker ps -a -q)

mkdir htdocs && git clone https://github.com/VKCOM/lighthouse/ ./htdocs && rm -rf ./htdocs/.git/
curl -L https://github.com/do-community/html_demo_site/archive/refs/heads/main.zip -o html_demo.zip
curl -L https://github.com/VKCOM/lighthouse/archive/refs/heads/main.zip -o html_demo.zip

ansible-playbook -i inventory/test.yml site.yml