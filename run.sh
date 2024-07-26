#!/bin/bash
IMAGE_NAME="realsense-humble:latest"
CONTAINER_NAME="realsense-humble-container"

# Check for existing docker container
# Remove any exited containers.
if [ "$(docker ps -a --quiet --filter status=exited --filter name=$CONTAINER_NAME)" ]; then
    docker rm $CONTAINER_NAME > /dev/null
fi

# Re-use existing container.
if [ "$(docker ps -a --quiet --filter status=running --filter name=$CONTAINER_NAME)" ]; then
    echo "Attaching to running container: $CONTAINER_NAME"
    docker exec -i -t --workdir /root/ros2_ws $CONTAINER_NAME /sbin/ros_entrypoint.sh /bin/bash
    exit 0
fi

echo "No running container was found! Starting a new one!"

# If no container exists then run a new one!
docker run \
	--runtime nvidia \
	-it \
	--privileged \
	--net=host \
	--ipc=host \
	--pid=host \
	-e NVIDIA_DRIVER_CAPABILITIES=all \
	-e DISPLAY \
	-v /dev:/dev \
	-v /tmp/.X11-unix/:/tmp/.X11-unix \
	-v ${HOME}/workspaces/recordings:/root/ros2_ws/recordings \
	--name $CONTAINER_NAME \
	$IMAGE_NAME
