FROM jupyter/base-notebook:ubuntu-20.04

# --- Set arguments for building image ---
ARG IAI_WS=/home/${NB_USER}/workspace/ros
ARG ROS_PKG=ros-base
ARG ROSINSTALL_PREFIX=https://raw.githubusercontent.com/cram2/cram/devel
ARG CRAM_ROSINSTALL_FILE="${ROSINSTALL_PREFIX}/cram-20.04-http.rosinstall"
ARG JUPYTER_ROSINSTALL_FILE="${ROSINSTALL_PREFIX}/jupyter/common-lisp-jupyter.rosinstall"

# --- Set system environment variables ---
ENV ROS_DISTRO=noetic
ENV ROS_PATH=/opt/ros/${ROS_DISTRO}
ENV ROS_ROOT=/opt/ros/noetic/share/ros
ENV ROS_PYTHON_VERSION=3
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /home/${NB_USER}
ENV ROS_PACKAGE_PATH=${IAI_WS}/src:${ROS_PATH}/share:${ROS_PATH}/stacks
ENV CMAKE_PREFIX_PATH=/home/${NB_USER}/workspace/ros/devel:${ROS_PATH}
ENV PATH=${ROS_PATH}/bin:$PATH
ENV PATH=/root/.local/bin:$PATH
ENV PYTHONPATH=${IAI_WS}/devel/lib/python3/dist-packages:${ROS_PATH}/lib/python3/dist-packages
ENV LD_LIBRARY_PATH=${IAI_WS}/devel/lib:${ROS_PATH}/lib:${ROS_PATH}/lib/x86_64-linux-gnu
ENV ROS_MASTER_URI=http://localhost:11311

# --- Install ros noetic and compiler packages ---
USER root
RUN apt-get update && apt-get install -y curl gnupg2 build-essential lsb-release net-tools xvfb
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
RUN apt-get update
RUN apt-get install -y ros-${ROS_DISTRO}-${ROS_PKG}
RUN pip install rospkg
RUN apt-get install -y net-tools xdot xvfb htop byobu nano vim python-is-python3 
RUN echo "source ${ROS_PATH}/setup.bash" >> /root/.bashrc
RUN echo "source ${ROS_PATH}/setup.bash" >> /home/${NB_USER}/.bashrc

USER ${NB_USER}
# Use the conda environment to install python packages whenever possible
SHELL ["conda", "run", "-n", "base", "/bin/bash", "-c"]
RUN mamba install -y git vim 
USER root
RUN pip install rosdep rosinstall rosinstall-generator wstool rosdistro \ 
        catkin-tools pyyaml==5.4.1 empy
# "rosdep init" need root permission
RUN rosdep init
USER ${NB_USER}
RUN rosdep update

# ---  Create CRAM Catkin Workspace ---
RUN mkdir -p /home/${NB_USER}/workspace/ros/src 
WORKDIR /home/${NB_USER}/workspace/ros
RUN catkin init
WORKDIR /home/${NB_USER}/workspace/ros/src
RUN wstool init
RUN wstool merge $CRAM_ROSINSTALL_FILE
RUN wstool update
# "rosdep install" need root permission
USER root
RUN rosdep install -y --ignore-src --from-paths ./ -r
USER ${NB_USER}
WORKDIR /home/${NB_USER}/workspace/ros/
RUN catkin config --extend ${ROS_PATH}
RUN catkin build
RUN echo "source /home/${NB_USER}/workspace/ros/devel/setup.bash" >> /home/${NB_USER}/.bashrc

# --- Install Commonlisp Jupyterlab kernel ---
WORKDIR /home/${NB_USER}/workspace/ros/src
RUN catkin_create_pkg jupyter
WORKDIR /home/${NB_USER}/workspace/ros/src/jupyter
RUN wstool init 
RUN wstool merge $JUPYTER_ROSINSTALL_FILE
RUN wstool update
USER root
RUN rosdep install -y --ignore-src --from-paths ./ -r
USER ${NB_USER}
WORKDIR /home/${NB_USER}/workspace/ros/
RUN catkin build
ENV ROSLISP_PACKAGE_DIRECTORIES=/home/${NB_USER}/workspace/ros/devel/share/common-lisp
RUN /usr/bin/sbcl --load /home/${NB_USER}/workspace/ros/src/cram/jupyter/sbcl-jupyter-kernel-installer.lisp

# ------
USER root
RUN fix-permissions "/home/${NB_USER}"
RUN source /home/${NB_USER}/workspace/ros/devel/setup.bash
RUN echo "source /home/${NB_USER}/workspace/ros/devel/setup.bash" >> ~/.bashrc
RUN source ~/.bashrc


WORKDIR ${HOME}

COPY task_tree_export-1661872120.dot ${HOME}/lectures/demos/task_tree_export-1661872120.dot

# #if running the file locally
# CMD ["jupyter", "lab", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]