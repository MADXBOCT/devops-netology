1

```yaml
FROM elasticsearch:7.17.7
COPY --chown=elasticsearch:elasticsearch elasticsearch.yml /usr/share/elasticsearch/config/
RUN mkdir /var/lib/logs \
    && chown elasticsearch:elasticsearch /var/lib/logs \
    && mkdir /var/lib/data \
    && chown elasticsearch:elasticsearch /var/lib/data
```
```bash
docker build --tag=madxboct/elasticsearch-custom:7.17.7 .
docker login -u madxboct
docker push madxboct/elasticsearch-custom:7.17.7
docker run -it -p 9200:9200 -p 9300:9300 -v /opt/elastic/data:/var/lib/data -v /opt/elastic/logs:/var/lib/logs madxboct/elasticsearch-custom:7.17.7
```

https://hub.docker.com/repository/docker/madxboct/elasticsearch-custom

```bash
vagrant@server1:~$ curl -X GET 'http://localhost:9200/'
{
  "name" : "c286d2a049c5",
  "cluster_name" : "netology_test",
  "cluster_uuid" : "gFagM31lR7291ED9aPrsfQ",
  "version" : {
    "number" : "7.17.7",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "78dcaaa8cee33438b91eca7f5c7f56a70fec9e80",
    "build_date" : "2022-10-17T15:29:54.167373105Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

2

