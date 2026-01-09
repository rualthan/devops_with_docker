FROM ubuntu:latest
RUN apt update && apt install ruby-full build-essential zlib1g-dev -y
COPY setup.sh .
RUN ./setup.sh
RUN gem install jekyll bundler 
RUN jekyll new myblog
EXPOSE 4000
WORKDIR /myblog
CMD [ "bundle","exec","jekyll", "serve", "--host", "0.0.0.0"]