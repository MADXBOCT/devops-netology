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
