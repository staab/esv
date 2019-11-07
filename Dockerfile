# Copied from https://github.com/sleepyfox/janet-lang-docker/blob/master/Dockerfile

FROM ubuntu:19.10

# Install make
RUN apt -q update && apt install -yq make gcc git curl

# Install Janet
RUN cd /tmp && \
    git clone https://github.com/janet-lang/janet.git && \
    cd janet && \
    make all test install && \
    rm -rf /tmp/janet
RUN chmod 777 /usr/local/lib/janet

# Set group and user IDs for docker user
ARG GID=1000
ARG UID=1000
ARG USER=me

# Create the group and user
RUN groupadd -g $GID $USER
RUN useradd -g $GID -M -u $UID -d /var/app $USER

# Application setup
ADD * /var/app
WORKDIR /var/app
USER $USER
