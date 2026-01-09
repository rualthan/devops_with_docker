## Frontend:
```
FROM ubuntu:latest
RUN apt update && apt install -y curl sudo
EXPOSE 5001
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash
RUN sudo apt install -y nodejs
WORKDIR /usr/src/app
COPY . .
ENV REACT_APP_BACKEND_URL="http://localhost:8080" 
RUN npm install 
RUN npm run build
RUN npm install -g serve
CMD ["serve", "-s", "build", "-l", "5001"]
```

Run
```
docker run -p 5001:5001 example-frontend
```

## Backend:
```
FROM golang:1.16.0
ENV PORT=8080
ENV REQUEST_ORIGIN="http://localhost:5001"
EXPOSE ${PORT}
WORKDIR /usr/src/app
COPY . .
RUN go build
CMD [ "./server" ]
```
Run
```
docker run -p 8080:8080 example-backend
```