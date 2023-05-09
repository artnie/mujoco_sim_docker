ARG ROS_DISTRO
FROM mujoco-ws:${ROS_DISTRO}

# Zero interaction while installing or upgrading the system via apt, see https://bobcares.com/blog/debian_frontendnoninteractive-docker/
ARG DEBIAN_FRONTEND=noninteractive 

# Install prerequisites
WORKDIR /home/giskard_ws
RUN apt-get update && apt-get install -y \
  ros-${ROS_DISTRO}-rviz \
  git

# Copy packages
COPY src /home/giskard_ws/src
WORKDIR /home/giskard_ws

RUN pip3 install -r src/giskard/giskardpy/requirements.txt

# Run script build_better_pybullet.sh, see https://github.com/SemRoCo/giskardpy#fast-custom-bullet-bindings
RUN cd src/giskard/giskardpy/scripts && ./build_better_pybullet.sh /home
ENV PYTHONPATH=${PYTHONPATH}:/home/bullet3/build_cmake/better_python:/home/bullet3/examples/pybullet

# Build catkin workspace
RUN rosdep install --from-paths src --ignore-src -r -y \
  && rm -rf /var/lib/apt/lists/*
RUN . /opt/ros/${ROS_DISTRO}/setup.sh && source /home/mujoco_ws/devel/setup.bash && catkin build

# Create entrypoint
SHELL ["/bin/bash", "-c"]
COPY ./entrypoint.bash /entrypoint.bash
RUN chmod +x /entrypoint.bash