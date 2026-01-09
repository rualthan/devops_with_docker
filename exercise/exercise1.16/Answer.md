Dockerfile:
```
FROM ubuntu:latest
RUN apt update && apt install ruby-full build-essential zlib1g-dev -y
COPY setup.sh .
RUN ./setup.sh
RUN gem install jekyll bundler 
RUN jekyll new myblog
EXPOSE 4000
WORKDIR /myblog
CMD [ "bundle","exec","jekyll", "serve", "--host", "0.0.0.0"]
```

Build ( Render rejects arm64)

    docker build . --platform linux/amd64 -t jekyll-blog

Publish

    docker tag jekyll-blog rualthan/jekyll-blog:amd64
    docker push rualthan/jekyll-blog:amd64

URL:
[https://hub.docker.com/repository/docker/rualthan/jekyll-blog](https://hub.docker.com/repository/docker/rualthan/jekyll-blog)

I took the help of LLM for the steps to deploy a web service with Render.
I had to add PORT=4000 Env in render to get it working

App is available at:
[https://br-jekyll-blog.onrender.com/](https://br-jekyll-blog.onrender.com/)