1 \
```bash
  mysql:
    image: mysql:8
    command: --default-authentication-plugin=mysql_native_password
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: example
    volumes:
      - /opt/mysql/vol_data:/var/lib/mysql
    ports:
      - "3306:3306"
    restart: unless-stopped

vagrant@server1:~$ docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED        STATUS                    PORTS                                                  NAMES
fde0ea6c66de   mysql:8       "docker-entrypoint.s…"   24 hours ago   Up 24 hours               0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   stack-mysql-1

```
