#!/bin/bash
xhost +local:docker
docker compose up cram-service

# cleanup after cram-service has been closed
xhost -local:docker