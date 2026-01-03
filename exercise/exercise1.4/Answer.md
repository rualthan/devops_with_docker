To start:

    docker run -d -it --rm --name task ubuntu sh -c 'while true; do echo "Input website:"; read website; echo "Searching.."; sleep 1; curl http://$website; done'

To check if it's running

    docker ps

Attach

    docker attach task

To get into the container

    docker exec -it task bash

To install curl

    apt update -y
    apt install curl -y