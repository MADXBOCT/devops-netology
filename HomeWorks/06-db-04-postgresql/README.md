1 \
```yamlex
services:
  postgres:
    image: postgres:13
    environment:
      PGDATA: "/var/lib/postgresql/data/pgdata"
      POSTGRES_PASSWORD: example
    volumes:
      - /opt/pg/vol_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    restart: unless-stopped
```