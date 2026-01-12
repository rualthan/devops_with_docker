## Inspecting official images

Checking the history of image:
```
docker image history --no-trunc ubuntu:24.04
```

## Avoid root user

 - Use a non root user
 - If you must use root user, map it to a high, non-existing user id on the host with https://docs.docker.com/engine/security/userns-remap/.

To retrofit yt-dlp ./exercise/yt-dlp/Dockerfile to run as non root:

- Add `RUN useradd -m appuser`
- Use USER directive to run all commands as appuser:
    ```
    USER appuser
    ``` 
- Give permission to this user to the working directory:
    ```
     RUN chown appuser .
    ```

```
FROM ubuntu:24.04
WORKDIR /mydir
RUN apt-get update && apt-get install -y curl python3 ffmpeg
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
RUN chmod a+x /usr/local/bin/yt-dlp
RUN useradd -m appuser
USER appuser
ENTRYPOINT ["/usr/local/bin/yt-dlp"]
```
The non-root version of your yt-dlp: [yt-dlp-non-root](./exercise/yt-dlp-non-root/)


## Optimizing Image

- Use a small base image such as alpine
- The language you use may provide a base image
- Otherwise, alpine is a good base image
- If the language is a compiled one, there are tools required to compile and build it but these tools are not required to run it. Hence the compiling/building can be done in one container and code package into another container. This is called multi-stage build

Techniques to optimize image:
* Use lean base image
* Combine RUNs
* Remove tools installed such as curl
* Remove cache, sources, repository sources etc
* Multi stage build


## Benefit of small image
- Performance: Less time to build, pull and start
- Security: Less attack service 

## Layer
- Each instruction in a Dockerfile creates a layer in the image. 
- When you change the Dockerfile and rebuild the image, only those layers which have changed are rebuilt. 

We can publish whatever variants we want without overriding the others by publishing them with a describing tag:

```
$ docker image tag yt-dlp:alpine-3.21 <username>/yt-dlp:alpine-3.21
$ docker image push <username>/yt-dlp:alpine-3.21
```

Or if we don't want to keep the Ubuntu version anymore, we can replace that pushing an Alpine-based image as the latest.

```
$ docker image tag yt-dlp:python-alpine <username>/yt-dlp
$ docker image push <username>/yt-dlp
```

It's important to keep in mind that if not specified, the tag :latest simply refers to the most recent image that has been built and pushed, which can potentially contain any updates or changes.


### Example of optimization

From:
```
FROM ubuntu:24.04

WORKDIR /mydir

RUN apt-get update && apt-get install -y curl python3 ffmpeg
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
RUN chmod a+x /usr/local/bin/yt-dlp

RUN useradd -m appuser
RUN chown appuser .

USER appuser

ENTRYPOINT ["/usr/local/bin/yt-dlp"]
```

To:
```
FROM ubuntu:24.04

WORKDIR /mydir

RUN apt-get update && apt-get install -y curl python3 ffmpeg && \
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp && \
    chmod a+x /usr/local/bin/yt-dlp && \
    useradd -m appuser && \
    chown appuser .

USER appuser

ENTRYPOINT ["/usr/local/bin/yt-dlp"]
```

## Multi stage build, Jekyll, Nginx
[jekyll-nginx](./exercise/jekyll-nginx/)