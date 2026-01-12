docker run -e DOCKER_USERNAME=rualthan \
-e DOCKER_PASSWORD=<Personal Access Token> \
-v /var/run/docker.sock:/var/run/docker.sock \
builder rualthan/express-app rualthan/exercise3.4