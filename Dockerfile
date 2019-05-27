FROM ubuntu:16.04

RUN apt-get update && apt-get upgrade -y
RUN apt-get update && apt-get install -y curl lsb-release apt-utils git sudo
RUN apt-get install gedit -y

# Following commands arer borrowed from 
# https://stackoverflow.com/questions/25845538/how-to-use-sudo-inside-a-docker-container
#RUN adduser --disabled-password --gecos '' manish
#RUN adduser manish sudo
#RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

#Add new sudo user
ENV USERNAME manish
RUN useradd -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME && \
        # Replace 1000 with your user/group id
	usermod -a -G sudo $USERNAME && \
        usermod  --uid 1000 $USERNAME && \
        groupmod --gid 1000 $USERNAME


# Following commands are borrowed from ros docker from docker hub
# install packages
RUN sudo apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
&& sudo rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    && rm -rf /var/lib/apt/lists/*z

# setup environment
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# bootstrap rosdep
RUN rosdep init

USER $USERNAME
RUN rosdep update

USER root
# install ros packages
ENV ROS_DISTRO kinetic
RUN apt-get update && apt-get install -y ros-kinetic-desktop \
	&& rm -rf /var/lib/apt/lists/*

# Setting up tmux
RUN apt-get update && apt-get install -y tmux
RUN apt-get update
RUN apt-get install -qqy x11-apps

USER $USERNAME
# setup entrypoint
#COPY ./ros_entrypoint.sh /home/manish/ros_entrypoint.sh
#RUN sudo chmod 777 /home/manish/ros_entrypoint.sh
#ENTRYPOINT ["/home/manish/ros_entrypoint.sh"]
