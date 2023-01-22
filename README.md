# honk

Take control of your honks and join the federation.
An ActivityPub server with minimal setup and support costs.
Spend more time using the software and less time operating it.

This repository packages the docker version of honk.

Read more about [honk](https://humungus.tedunangst.com/r/honk) here.

## setup

honk expects to be fronted by a TLS terminating reverse proxy.

You'll start it like this:
```
docker run \
	--rm \
	--detach \
	-e HONK_USERNAME=user \
	-e HONK_PASSWORD=password \
	-e HONK_LISTEN_ADDRESS=0.0.0.0:31337 \
	-e HONK_SERVER_NAME=honk.example.com \
	--user 1000:1000 \
	--publish=31337:31337 \
	--volume=${DATA_DIR}:/config \
	--hostname=honk \
	--name=honk \
	jolt/honk
```
The sqlite db will be stored in /config, which I suggest you map to a persistent folder. USER/PW/ADDR/NAME also needs to be set for it to start.

## upgrade

I did it like this, enter the container like so `docker exec -it honk ash`
```
./honk-entrypoint.sh backup
./honk-entrypoint.sh upgrade
```
Now exit the container (exit) and restart it with `docker restart honk`.

## Ansible

I have included a [provision-honk](provision-honk.yml) file you can use. Just change the "hosts" parameter and set some defaults in host/group_vars and you should be good to go:

host_vars/docker_host.yml:

```yml
honk_config_path: /docker/honk
honk_username: honk
honk_password: "super secret pw with spaces"
honk_server_name: honk.example.com
honk_listen_address: 0.0.0.0:31337
```

`ansible-provision provision-honk.yml`

## Nginx

Here is a config to send the honk traffic to your honk docker container:

```bash
server {
    listen 80;
    server_name honk.example.com;
    return 301 https://$host$request_uri;
}

server {
    # SSL configuration
    listen 443 ssl http2;
    server_name honk.example.com;

    ssl_certificate /etc/nginx/certs/example.com.crt;
    ssl_certificate_key /etc/nginx/certs/example.com.key;
    # modern configuration, https://ssl-config.mozilla.org/#server=nginx&config=modern
    ssl_protocols TLSv1.3;
    ssl_prefer_server_ciphers off;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_pass http://<inside host>:31337;
    }
}
```

## Build own docker containers

`export VERSION=(develop|vX.X.X)`

`make`

Will download golang docker container, build the binary, package and build the honk binary and add to a alpine container.

To run your own build: `make run`.

Modify the files as you see fit. You can upload new builds to your own repository with `make push`.