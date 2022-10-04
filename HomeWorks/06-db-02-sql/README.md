1
```bash
version: "3.9"
services:
  postgres:
    image: postgres:12
    environment:
      PGDATA: "/var/lib/postgresql/data/pgdata"
      POSTGRES_PASSWORD: example
    volumes:
      - /opt/pg/vol_data:/var/lib/postgresql/data
      - /opt/pg/vol_bkup:/var/lib/postgresql/bkup
    ports:
      - "5432:5432"
    restart: unless-stopped
```
2
```bash
vagrant@server1:~$ docker exec -it stack-postgres-1 bash
root@e90b7ce73bee:/# psql -U postgres
psql (12.12 (Debian 12.12-1.pgdg110+1))
Type "help" for help.
postgres=# create database test_db;
CREATE DATABASE
postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)

postgres=#

```
3

