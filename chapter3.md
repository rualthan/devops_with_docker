## Docker Compose 
The docker run command can be lengthy with port mapping, volume mount etc. We can replace those with a file and a simpler docker compose command. The docker run command can be especially complex if we want to run multiple containers.  

- It was previous a separate command.
- It is now integrated into docker.
- The goal is to simplify running multi-container applications. 

## Create a Docker compose for yt-dlp
To build and push our yt-dlp with docker compose:

- Go to the project directory
- Create docker-compose.yaml:
  ```
  services:
    yt-dlp-ubuntu:
      image: <username>/<repositoryname>
      build: .
  ```
- While still in the same directory, start the services in docker compose file.
  ```
  docker compose up
  ```
  This particular container expects an URL as an argument:
  ```
  $ docker compose run yt-dlp-ubuntu https://www.youtube.com/watch?v=saEpkcVi1d4
  ```
- Stop
  ```
  docker compose down
  ```
- Start in detach mode
  ```
  docker compose up -d
  ```
- View logs
  ```
  docker compose logs
  ```

## Running two containers with docker compose:

docker-compose.yaml:
```
services:
  nginx:
    image: nginx:1.27
  database:
    image: postgres:17 
```

List all services:
  ```
  docker compose ps
  ```

## Publishing to Docker Hub
  ```
  docker compose build
  docker compose push
  ```

## Expose ports
  ```
  services:
    whoami:
      image: jwilder/whoami
      ports:
        - 8000:8000
  ```

## Scaling up multiple instances
We can scale up the above service:
```
docker compose up --scale whoami=3
```

But it will result in a port clash as all instances will try to bind to the host port 8080.

To resolve this, we eave out host port for docker to auto assign host port.
```
ports:
        - 8000
```

To find out the host port for each service:
```
docker-compose port whoami <container_port>
docker-compose port --index 1 whoami <container_port>
```  

To test, curl those ports.
```
curl 127.0.0.1:<PORT>
```

## Volume bind mount
```
services:
  yt-dlp-ubuntu:
    image: <username>/<repositoryname>
    build: .
    volumes:
      - .:/mydir
    container_name: yt-dlp
```

Mounting volume in read only mode:
```
/host_dir:/container_dir:ro
```

## Environment variable
```
services:
  backend:
    image:
    environment:
      - VARIABLE=VALUE
      - VARIABLE2=VALUE2
```

## Networking
- Docker compose connects the containers automatically
- Services in the docker compose file can reference each other using the service name


## Manual networking description
```
services:
  db:
    image: postgres:13.2-alpine
    networks:
      - database-network 

networks:
  database-network: 
    name: database-network 
```

## Connecting to a networking defined in another docker compose
```
services:
  db:
    image: backend-image
    networks:
      - database-network

networks:
  database-network:
    external:
      name: database-network 
```
By default all services are added to a network called default.

## Configuring the default network
```
services:
  db:
    image: backend-image

networks:
  default:
    external:
      name: database-network 
```

## Load balancer
In the real world, application is placed behind a load balancer. We shall see how to place a load balancer container in front of our application containers.

- We implement a nginx as a load balancer in [whoami-nginx](./exercise/whoami-nginx/)
- jwilder/nginx-proxy is added as a service to the docker compose file
- It maps 80:80
- It mounts /var/run/docker.sock:/tmp/docker.sock, which is the communications for docker daemon
- To route the traffic to the respective application service, we use the environment variable VIRTUAL_HOST
- We use the domain colasloth.com, a service with all subdomains pointing to 127.0.0.1, that "any".colasloth.com  will resolve to 127.0.0.1 . Similar services are localtest.me, lvh.me, and vcap.me.



## Volumes in action

- Compose uses the current directory as a prefix for container and volume names so that different projects don't clash
- The prefix can be overridden with COMPOSE_PROJECT_NAME environment variable, if needed.
- Docker compose will create anonymous volumes by default if the Dockerfile has a state VOLUME statement

Example:
```
services:
  db:
    image: postgres:17
    restart: unless-stopped
    environment:
      POSTGRES_PASSWORD: example
    container_name: db_redmine
```

Run `docker compose up` and terminate it with ^C. Next, lets check for the volume.

```
docker container inspect db_redmine | grep -A 5 Mounts

 Mounts": [
            {
                "Type": "volume",
                "Name": "00b5d758f84882699ebd29ffb9528679e9ce1c9423fb7a47498ca4c6c78d6194",
                "Source": "/var/lib/docker/volumes/00b5d758f84882699ebd29ffb9528679e9ce1c9423fb7a47498ca4c6c78d6194/_data",
                "Destination": "/var/lib/postgresql/data",

```
- To inspect: `docker volume ls`
- To prune old volumes: `docker volume prune`

Adding a volume explicitly instead of randomly named ones:
```
services:
  db:
    image: postgres:17
    restart: unless-stopped
    environment:
      POSTGRES_PASSWORD: example
    container_name: db_redmine
    volumes:
      - database:/var/lib/postgresql/data

volumes:
  database:
```

Checking:

```
docker volume ls | grep database
local                redmine-admirer_database
```
The volume name redmine-admirer is picked up from the project directory.

```
 docker container inspect db_redmine | grep -A 5 Mounts
        "Mounts": [
            {
                "Type": "volume",
                "Name": "redmine-admirer_database",
                "Source": "/var/lib/docker/volumes/redmine-admirer_database/_data",
                "Destination": "/var/lib/postgresql/data",
```

Adding redmine application:
````
redmine:
  image: redmine:5.1-alpine
  environment:
    - REDMINE_DB_POSTGRES=db
    - REDMINE_DB_PASSWORD=example
  ports:
    - 9999:3000
  depends_on:
    - db
```

- depends_on ensure db is started first
- db can be used to access db as DNS internally


Querying by container name:
```
docker compose ps -q redmine
```
When docker compose includes build, to rebuild the image:
```
docker compose up --build
```