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
```
```bash
postgres=# create database test_db;
CREATE DATABASE
postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=#

CREATE TABLE orders (
	id integer,
	name text, 
	price integer,
	PRIMARY KEY (id)
);

CREATE TABLE clients 
(
	id integer,
	lastname text,
	country text,
	order_id integer, 
	PRIMARY KEY (id),
		FOREIGN KEY (order_id) 
			REFERENCES orders (id)
);

CREATE ROLE "test-admin-user" LOGIN;
GRANT ALL ON public.clients TO "test-admin-user";
GRANT ALL ON public.orders TO "test-admin-user";

CREATE ROLE "test-simple-user" LOGIN;
GRANT SELECT ON TABLE public.clients TO "test-simple-user";
GRANT INSERT ON TABLE public.clients TO "test-simple-user";
GRANT UPDATE ON TABLE public.clients TO "test-simple-user";
GRANT DELETE ON TABLE public.clients TO "test-simple-user";
GRANT SELECT ON TABLE public.orders TO "test-simple-user";
GRANT INSERT ON TABLE public.orders TO "test-simple-user";
GRANT UPDATE ON TABLE public.orders TO "test-simple-user";
GRANT DELETE ON TABLE public.orders TO "test-simple-user";
```

```bash
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
test_db=# 
test_db=# \du
                                       List of roles
    Role name     |                         Attributes                         | Member of 
------------------+------------------------------------------------------------+-----------
 postgres         | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
 test-admin-user  |                                                            | {}
 test-simple-user |                                                            | {}

test_db=# 
test_db=# \dt
          List of relations
 Schema |  Name   | Type  |  Owner   
--------+---------+-------+----------
 public | clients | table | postgres
 public | orders  | table | postgres
(2 rows)

test_db=#
test_db=# select * from information_schema.table_privileges where grantee like 'test-admin-user';
 grantor  |     grantee     | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy 
----------+-----------------+---------------+--------------+------------+----------------+--------------+----------------
 postgres | test-admin-user | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test-admin-user | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | DELETE         | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | TRUNCATE       | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | REFERENCES     | NO           | NO
 postgres | test-admin-user | test_db       | public       | clients    | TRIGGER        | NO           | NO
 postgres | test-admin-user | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test-admin-user | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test-admin-user | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test-admin-user | test_db       | public       | orders     | DELETE         | NO           | NO
 postgres | test-admin-user | test_db       | public       | orders     | TRUNCATE       | NO           | NO
 postgres | test-admin-user | test_db       | public       | orders     | REFERENCES     | NO           | NO
 postgres | test-admin-user | test_db       | public       | orders     | TRIGGER        | NO           | NO
(14 rows)

test_db=# 

test_db=# select * from information_schema.table_privileges where grantee like 'test-simple-user';
 grantor  |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy 
----------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 postgres | test-simple-user | test_db       | public       | clients    | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | clients    | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | clients    | DELETE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | INSERT         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | SELECT         | NO           | YES
 postgres | test-simple-user | test_db       | public       | orders     | UPDATE         | NO           | NO
 postgres | test-simple-user | test_db       | public       | orders     | DELETE         | NO           | NO
(8 rows)

test_db=# 

```
3 
```bash
insert into orders VALUES 
(1, 'Шоколад', 10), 
(2, 'Принтер', 3000), 
(3, 'Книга', 500), 
(4, 'Монитор', 7000), 
(5, 'Гитара', 4000);

insert into clients VALUES 
(1, 'Иванов Иван Иванович', 'USA'), 
(2, 'Петров Петр Петрович', 'Canada'), 
(3, 'Иоганн Себастьян Бах', 'Japan'), 
(4, 'Ронни Джеймс Дио', 'Russia'), 
(5, 'Ritchie Blackmore', 'Russia');

select count (*) from orders;
select count (*) from clients;

INSERT 0 5
INSERT 0 5
 count 
-------
     5
(1 row)

 count 
-------
     5
(1 row)

test_db=# 
```