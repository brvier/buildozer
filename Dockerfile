# Dockerfile for providing buildozer
#
# Build with:
# docker build --tag=kivy/buildozer .
# 
# In order to give the container access to your current working directory
# it must be mounted using the --volume option.
# Run with (e.g. `buildozer --version`):
# docker run \
#   --volume "$HOME/.buildozer":/home/user/.buildozer \
#   --volume "$PWD":/home/user/hostcwd \
#   kivy/buildozer --version
#
# Or for interactive shell:
# docker run --interactive --tty --rm \
#   --volume "$HOME/.buildozer":/home/user/.buildozer \
#   --volume "$PWD":/home/user/hostcwd \
#   --entrypoint /bin/bash \
#   kivy/buildozer
#
# If you get a `PermissionError` on `/home/user/.buildozer/cache`,
# try updating the permissions from the host with:
# sudo chown $USER -R ~/.buildozer
# Or simply recreate the directory from the host with:
# rm -rf ~/.buildozer && mkdir ~/.buildozer

FROM ubuntu:20.04

ENV USER="user"
ENV HOME_DIR="/home/${USER}"
ENV WORK_DIR="${HOME_DIR}/hostcwd" \
    SRC_DIR="${HOME_DIR}/src" \
    PATH="${HOME_DIR}/.local/bin:${PATH}"

# configures locale
RUN apt update -qq > /dev/null && \
    apt install -qq --yes --no-install-recommends \
    locales && \
    locale-gen en_US.UTF-8
ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"

RUN DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata

# system requirements to build most of the recipes
RUN apt install -qq --yes --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    ccache \
    cmake \
    gettext \
    git \
    libffi-dev \
    libltdl-dev \
    libtool \
    openjdk-8-jdk \
    patch \
    pkg-config \
    python2.7 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-dev \
    sudo \
    unzip \
    zip \
    zlib1g-dev \
    libsdl2-dev \
    libssl-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    wget \
    libbz2-dev \
    python3.8-dev

# prepares non root env
RUN useradd --create-home --shell /bin/bash ${USER}
# with sudo access and no password
RUN usermod -append --groups sudo ${USER}
RUN echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER ${USER}
WORKDIR ${WORK_DIR}
COPY --chown=user:user . ${SRC_DIR}

# installs buildozer and dependencies
RUN pip3 install --user --upgrade certifi Cython==0.29.15 wheel pip virtualenv flake8 ${SRC_DIR}

ENTRYPOINT ["buildozer"]
