1 \
Dockerfile
```yaml
FROM elasticsearch:7.17.7
COPY --chown=elasticsearch:elasticsearch elasticsearch.yml /usr/share/elasticsearch/config/
RUN mkdir /var/lib/logs \
    && chown elasticsearch:elasticsearch /var/lib/logs \
    && mkdir /var/lib/data \
    && chown elasticsearch:elasticsearch /var/lib/data
```
elasticsearch.yml
```yaml
cluster.name: netology_test
discovery.type: single-node

path.data: /var/lib/data
path.logs: /var/lib/logs

network.host: 0.0.0.0
discovery.seed_hosts: ["127.0.0.1", "[::1]"]

ingest.geoip.downloader.enabled: false
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
```bash
curl -X PUT http://localhost:9200/ind-1 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 1,  "number_of_replicas": 0 }}'
curl -X PUT http://localhost:9200/ind-2 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 2,  "number_of_replicas": 1 }}'
curl -X PUT http://localhost:9200/ind-3 -H 'Content-Type: application/json' -d'{ "settings": { "number_of_shards": 4,  "number_of_replicas": 2 }}'
```
```bash
vagrant@server1:~$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 VUKzZaNsQFOj9JxtPsq61w   1   0          0            0       226b           226b
yellow open   ind-3 mYE3WQxQRRq3GGwKLJtREg   4   2          0            0       904b           904b
yellow open   ind-2 rjKtsBvIR6uQQ2Nf5oGqLg   2   1          0            0       452b           452b
```
```bash
vagrant@server1:~$ curl -X GET 'http://localhost:9200/_cluster/health?pretty'
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 9,
  "active_shards" : 9,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 47.368421052631575
}
```
кол-во реплик для 2,3 превышает кол-вол доступных серверов data node (single node)
```bash
vagrant@server1:~$ curl -X DELETE 'http://localhost:9200/ind-1?pretty'
{
  "acknowledged" : true
}
vagrant@server1:~$ curl -X DELETE 'http://localhost:9200/ind-2?pretty'
{
  "acknowledged" : true
}
vagrant@server1:~$ curl -X DELETE 'http://localhost:9200/ind-3?pretty'
{
  "acknowledged" : true
}
vagrant@server1:~$
```
3
переделываем образ, пересобираем контейнер
```yaml
FROM elasticsearch:7.17.7
COPY --chown=elasticsearch:elasticsearch elasticsearch.yml /usr/share/elasticsearch/config/
RUN mkdir /var/lib/logs \
    && chown elasticsearch:elasticsearch /var/lib/logs \
    && mkdir /var/lib/data \
    && chown elasticsearch:elasticsearch /var/lib/data \
    && mkdir /usr/share/elasticsearch/snapshots \
    && chown elasticsearch:elasticsearch /usr/share/elasticsearch/snapshots
```
```yaml
cluster.name: netology_test
discovery.type: single-node

path.data: /var/lib/data
path.logs: /var/lib/logs
path.repo: /usr/share/elasticsearch/snapshots

network.host: 0.0.0.0
discovery.seed_hosts: ["127.0.0.1", "[::1]"]
```
регистрация
```bash
vagrant@server1:/opt/stack/elastic$ curl -X POST http://localhost:9200/_snapshot/netology_backup?pretty -H 'Content-Type: application/json' -d'{"type": "fs", "settings": { "location":"/usr/share/elasticsearch/snapshots" }}'
{
  "acknowledged" : true
}
```
проверка
```bash
vagrant@server1:/opt/stack/elastic$ curl -X GET 'http://localhost:9200/_snapshot/netology_backup?pretty'
{
  "netology_backup" : {
    "type" : "fs",
    "settings" : {
      "location" : "/usr/share/elasticsearch/snapshots"
    }
  }
}
```
snapshots:
```bash
vagrant@server1:/opt/stack/elastic$ docker exec -it 42ad65d6225c bash
root@42ad65d6225c:/usr/share/elasticsearch# cd snapshots/
root@42ad65d6225c:/usr/share/elasticsearch/snapshots# ls -lah
total 60K
drwxr-xr-x 1 elasticsearch elasticsearch 4.0K Nov  9 11:19 .
drwxrwxr-x 1 root          root          4.0K Nov  9 11:03 ..
-rw-rw-r-- 1 elasticsearch root          1.4K Nov  9 11:19 index-0
-rw-rw-r-- 1 elasticsearch root             8 Nov  9 11:19 index.latest
drwxrwxr-x 6 elasticsearch root          4.0K Nov  9 11:19 indices
-rw-rw-r-- 1 elasticsearch root           29K Nov  9 11:19 meta-DAM_A8BOQsiHAwolc4Is9A.dat
-rw-rw-r-- 1 elasticsearch root           712 Nov  9 11:19 snap-DAM_A8BOQsiHAwolc4Is9A.dat
```
список после удаления, создания
```bash
vagrant@server1:/opt/stack/elastic$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases Db1rOf9_R3e4FektRBcXCQ   1   0         41            0     39.3mb         39.3mb
green  open   test-2           wbQWJhiRR_2Jps0NbWuJ2A   1   0          0            0       226b           226b
```
восстанавливаем
```bash
vagrant@server1:/opt/stack/elastic$ curl -X POST http://localhost:9200/_snapshot/netology_backup/elasticsearch/_restore?pretty -H 'Content-Type: application/json' -d'{"indices": "test"}'
{
  "accepted" : true
}
vagrant@server1:/opt/stack/elastic$ curl -X GET 'http://localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases Db1rOf9_R3e4FektRBcXCQ   1   0         41            0     39.3mb         39.3mb
green  open   test-2           wbQWJhiRR_2Jps0NbWuJ2A   1   0          0            0       226b           226b
green  open   test             G0nWHwzeSM2zLWvD4WaUMg   1   0          0            0       226b           226b
vagrant@server1:/opt/stack/elastic$
```