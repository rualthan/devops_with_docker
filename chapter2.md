## What is DevOps

DevOps as defined by [Jabbari et al](https://dl.acm.org/doi/10.1145/2962695.2962707): "DevOps is a development methodology aimed at bridging the gap between Development and Operations, emphasizing communication and collaboration, continuous integration, quality assurance and delivery with automated deployment utilizing a set of development practices".

## What is Docker?
- Docker is a set of tools to deliver software in containers. 
- Containers are packages of software.
- They are isolated, self-contained and bundled with dependencies
- Container = App + dependencies  

## What problems does it solve?

- Works on my machine 

- Apps requiring different libraries

- Instant dev environment

- You can start fast can scale with little overhead


## Container vs VM
- VMs require full OS and emulated hardware
- Containers share the host kernel, package the app and just it's dependencies
- VMs provide stronger isolation but have heavier overhead
- VMs can be used for applications requiring a complete OS

## Install Docker
- Docker can run natively on Linux
- Mac and Windows need lightweight Linux VM under the hood
- Docker desktop is a quick and easy way to get up and running with docker

## Hello World
    $ docker container run hello-world

The short form:

    $ docker run hello-world

The first run will pull the image from the registry(Docker Hub). The second time, it will use the image locally available. 


## What is an image
An image is a file that has a template or blueprint. Container are instances of an image just are how processes are instances of programs.

Image = app +  what it needs to run (dependencies)

- Immutable: You don't edit an image. You create a new one based on the existing.
- `docker image ls` to list images on your host

## Dockerfile
- Instructional file for building image
- `docker build image` parses it
- Dockerfile: Written by us
- Image: Written by the machine

## List the containers
- `docker container ls` (active ones)
- `docker container ls  -a` (active + stopped)
- Short form: `docker ps, docker ps -a`

## Docker CLI to Docker Daemon communication
cli (docker)  > Rest API > Docker Daemon

## Deleting containers and images
    docker container rm <id>
OR

    docker rm <id>

Full or unique part of the ID works.

It accepts multiple Ids

    docker rm id1 id2 id3 

Remove all stop containers

    docker container prune 

Remove dangling images ( unused or without name)

    docker image prune

Remove almost everything

    docker system prune

## Pull only without running
Just pull image without running

    docker image pull hello-world


## Two types of containers
- executes commands and exits
- continues running

For the second kind, we can run in detach mode to get back the prompt.

This will not return the prompt

    docker run nginx

Kill it with ^c.

Run again in detach mode
    
    docker run -d nginx

Inspect it from docker ps

```
$ docker container ls
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS     NAMES
f5ba4fdfbb8c   nginx     "/docker-entrypoint.…"   13 seconds ago   Up 13 seconds   80/tcp    sweet_germain
```

```
$ docker rm sweet_germain
Error response from daemon: cannot remove container "sweet_germain": container is running: stop the container before removing or force remove
```

Need to stop first

    docker stop sweet_germain

To force remove without stopping

    docker rm --force sweet_germain

We can use the name, ID or part of it.

`docker kill <ID>` can be faster than stop.

Start a stopped container

    docker start <ID> 

To remove container after stopping, start it with --rm

    $ docker run -d --rm -it --name looper-it ubuntu sh -c 'while true; do date; sleep 1; done'

## Interactive mode
Attach terminal and run container in interactive mode

    docker run -it image-name

Start a container in detached mode and pass a command to run
```
$ docker run -d -it --name looper ubuntu sh -c 'while true; do date; sleep 1; done'
```

## Container logs
Look at the logs of our container called looper

    docker logs  -f looper

## Pause
Pause and unpause from another terminal

    docker pause looper
    docker unpause looper

## Attach
Attach a running docker in detached mode

    docker attach looper

Attach with no stdin

    docker attach --no-stdin looper

Attach a bash shell in interactive mode

    docker exec -it looper bash

## Run commands inside a running container
Run commands inside a container

    docker exec looper ls -la

## Where do images come from
docker run or docker pull
- It searches docker hub https://hub.docker.com/ for the image if not found locally
- To search using docker command: `docker search hello-world`
- It searches docker hub by default
- To search other registry: `docker search quay.io/hello`
- Run or pull from different registry: `docker pull quay.io/podman/hello`

## Inspecting image
```
$ docker pull ubuntu
  Using default tag: latest
  latest: Pulling from library/ubuntu
```

This pulls the image with latest tag by default if we don't mention the tag.Usually, the latest updated version but not necessarily the case. In case of Ubuntu, it is the latest LTS per README.

It is up to the image maintainer which tag to assign to a build as we will see in the image building section. 


### Local tagging

    docker tag ubuntu:25.04 ubuntu:noble_numbat

`docker image ls` shows a new image with the new tag. This is sort of like Save As. (May be more like a soft link. The image ID remains the same. I will update it if I have find that this technically inaccurate)


An image name may consist of 3 parts plus a tag:
- Usually like the following: registry/organisation/image:tag. 
- But may be as short as ubuntu, in which case 
  - the registry will default to Docker hub
  - organisation to library and
  -  tag to latest 


## Building images
Dockerfile: Build instructions for an image

Steps
```
mkdir hello-docker
vi hello.sh
vi Dockerfile
docker build -t hello-docker
```
Check image exists

    docker image ls

To test

    docker run hello-docker

Copy file in to the container

    docker cp file_name <ID/name>:/usr/src/app

To check what has changed in a container

    docker diff <ID>

The character in front of the file name indicates the type of the change in the container's filesystem: A = added, D = deleted, C = changed. 

Save the container as new image

    docker commit <ID> new_name

All instructions in the Dockerfile except CMD are executed during the build.
CMD is executed during docker run, unless overwritten

If you have more than one Dockerfile in a directory, name it Dockerfile.something and use `docker build. -f Dockerfile.something` to build.

## Containerizing yt-dlp
Before containerizing [yt-dlp](https://github.com/yt-dlp/yt-dlp/wiki/Installation), we launched an Ubuntu container  in interactive mode (`-it`) to install the dependencies and the app like we would on  our local machine. 

Once we familiar ourself with the steps, we begin to containerize it. The Dockerfile and docker compose files are available [here](./exercise/yt-dlp/).

We create a Dockerfile with the instructions from here to install yt-dlp:
[https://github.com/yt-dlp/yt-dlp/wiki/Installation](https://github.com/yt-dlp/yt-dlp/wiki/Installation)

```
FROM ubuntu:24.04

WORKDIR /mydir

RUN apt-get update && apt-get install -y curl python3 ffmpeg
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
RUN chmod a+x /usr/local/bin/yt-dlp

CMD ["/usr/local/bin/yt-dlp"]
```

Build image

    docker build -t yt-dlp .

## CMD vs ENTRYPOINT

Run the yt-dlp image we built above.
```
$ docker run yt-dlp

  Usage: yt-dlp [OPTIONS] URL [URL...]

  yt-dlp: error: You must provide at least one URL.
  Type yt-dlp --help to see a list of all options.
```

It shows the usage, like running yt-dlp without arguments. This because the CMD in the Dockerfile has yt-dlp. CMD is the default argument to the ENTRYPOINT which is "sh -c" by default. Proving an argument to the container during run replaces the CMD in the Dockerfile.

Hence,

    docker run yt-dlp "url"

will not work because it is equivalent to running:

    sh -c "some youtube url"

When argument is provided in docker run, it replaces the CMD in the Dockerfile. So while `sh -c  /usr/local/bin/yt-dlp` would work but `sh -c "url"` would not run.

What we want is our docker run command to translate into:

    /usr/local/bin/yt-dlp "url"

To get "docker run yt-dlp url" to work, we need to overwrite the default entry point.


Updated Dockerfile:

```
FROM ubuntu:24.04
WORKDIR /mydir
RUN apt-get update && apt-get install -y curl python3 ffmpeg
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
RUN chmod a+x /usr/local/bin/yt-dlp
ENTRYPOINT ["/usr/local/bin/yt-dlp"]
```

Rebuild the image

    docker build -t yt-dlp . 


Try docker `run yt-dlp url` again. It should work.

Now this is similar to:

    /usr/local/bin/yt-dlp "url"


Summary:
- CMD is the argument list for the entrypoint.
- The default ENTRYPOINT is sh -c.
- CMD is overridden when argument is passed on the container

### exec form and shell form
CMD and ENTRYPOINT have exec form and shell form. We have been using the exec form.
IN exec form, the commands are executed directly but shell form wraps the command with `/bin/sh -c`.

This shell form:
```
ENTRYPOINT /bin/ping -c 3
CMD localhost
```
equals

    /bin/sh -c '/bin/ping -c 3' /bin/sh -c 'localhost'

This exec form:
```
ENTRYPOINT ["/bin/ping","-c","3"]
CMD ["localhost"]
````
equals

    /bin/ping -c 3 localhost

Shell form can be useful when we need to evaluate an expression like shell env.

With this new learning, we improved the script and Dockerfile for [Exercise 1.7](./exercise/exercise1.7/)

Build

    docker build -t curler-v2 -f ./Dockerfile.v2 

Run
    docker run curler-v2 "url"

## Volumes (TBR)
Docker supports bind mount and volume mount. With bind mount, we mount a directory from the host in the container. With volume mount, we create a volume managed by Docker which is made available in the container.

### Bind mount
With bind mount (opens in a new tab) (opens in a new tab) we can mount a file or directory from our own machine (the host machine) into the container.

Mount ./vol on the host as /vol in the container:
```
$ docker run -it -v ./vol/:/vol ubuntu                 
root@280c48654fa0:/# df /vol
Filesystem           1K-blocks      Used Available Use% Mounted on
/run/host_mark/Users 239362496 212777600  26584896  89% /vol
```

Mount a file on the host in the container:
```
% echo "hello" > ./vol/test.txt
% docker run -it -v ./vol/test.txt:/vol/test.txt ubuntu
root@f170f566eeb9:/# cat /vol/test.txt 
hello
```

FYI
- Before v23 of docker, absolute path was required.
- From v23, relative path is acceptable.
- The -v option creates a directory if the source directory or file does not exist.


To mount the pwd as /mydir in the yt-dlp container:
```
docker run -v "$(pwd):/mydir" yt-dlp "https://youtu.be/d6CPOpg27wg?si=SEgNGNN1OVxFJUH8"          
```

Since the workingDir is /mydir the Dockerfile, our PWD becomes the workingDir of the container. FYI default WORKINGDIR is /.

## External Communication
Applications run in a container but we have not see how will clients connect to the applications running in a container.

Ports on the host can be mapped to port on container in two steps:
- Exposing a port
- Publishing a port

To expose a port, add the line EXPOSE <port> in your Dockerfile. This is only informational though. It is up to the application to open a port for listening.It primarily serves as metadata and documentation. If you use EXPOSE in Dockerfile, `docker run -P Flag` automatically maps all EXPOSEd container ports to random, high-numbered available ports on the host machine.

To publish a port, run the container with `-p <host-port>:<container-port>`.

If you leave out the host port and only specify the container port, Docker will automatically choose a free port as the host port.

To limit to specific protocol:
```
-p <host-port>:<container-port>/udp.
```

To restrict the source
```
-p 127.0.0.1:3456:3000
```

This `-p 3456:3000` will result in the same as `-p 0.0.0.0:3456:3000`.

Example:
```
docker run -p 8080:8080 devopsdockeruh/simple-web-service server 
```
localhost:8080 will redirect to the 8080 in the container.

## Publishing to Registry
To publish an image, in this example our yt-dlp to Docker Hub under my account rualthan:
 
    docker login
    docker tag yt-dlp rualthan/yt-dlp
    docker push rualthan/yt-dlp