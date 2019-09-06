# Dockerfile may have two Arguments: tag, branch
# tag - tag for the Base image, (e.g. 1.10.0-py3 for tensorflow)
# branch - user repository branch to clone (default: master, other option: test)

ARG tag=9.0-cudnn7-devel-ubuntu16.04

# Base image, e.g. tensorflow/tensorflow:1.12.0-py3
FROM nvidia/cuda:${tag}

LABEL maintainer='Carlos Garcia'
LABEL version='0.01'
# tax class

# What user branch to clone (!)
ARG branch=master

# Install ubuntu updates and python related stuff
# link python3 to python, pip3 to pip, if needed
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends \
         git \
         curl \
         wget \
         python3-setuptools \
         python3-pip \
         python3-wheel && \ 
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/* && \
    if [ "python3" = "python3" ] ; then \
       if [ ! -e /usr/bin/pip ]; then \
          ln -s /usr/bin/pip3 /usr/bin/pip; \
       fi; \
       if [ ! -e /usr/bin/python ]; then \
          ln -s /usr/bin/python3 /usr/bin/python; \
       fi; \
    fi && \
    python --version && \
    pip --version

##########################################################################################################
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
  nano \
  g++ \
  wget \
  git \
  build-essential \
  tk-dev \
  checkinstall\
  liblapack-dev \
  libopenblas-dev \
  libreadline-gplv2-dev \
  libncursesw5-dev \
  libssl-dev \
  libsqlite3-dev \
  libgdbm-dev \
  libc6-dev \
  libbz2-dev \
  libatlas-dev \
  libatlas3-base \
  python3-pip \
  python3-setuptools \
  python3-tk \
  python3-matplotlib \
  software-properties-common

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.5 1
RUN update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Set CUDA_ROOT
ENV CUDA_ROOT /usr/local/cuda/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/cuda-9.0/lib64

# Install Tensorfow
RUN pip install --upgrade six
RUN pip install --upgrade flask
RUN pip install --upgrade pandas==0.24.2
RUN pip install --upgrade wheel
RUN pip install --upgrade numpy==1.17.1
RUN pip install --upgrade sklearn
RUN pip install --upgrade tensorflow-gpu==1.12
RUN pip install --upgrade keras==2.2.4

#######################################################################

# Set LANG environment
ENV LANG C.UTF-8

# Set the working directory
WORKDIR /srv

# Install rclone
RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt install -f && \
    mkdir /srv/.rclone/ && touch /srv/.rclone/rclone.conf && \
    rm rclone-current-linux-amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Install DEEPaaS from PyPi
# Install FLAAT (FLAsk support for handling Access Tokens)
RUN pip install --no-cache-dir \
        'deepaas>=0.3.0' \
        flaat && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Disable FLAAT authentication by default
ENV DISABLE_AUTHENTICATION_AND_ASSUME_AUTHENTICATED_USER yes


# Install user app:
RUN git clone https://github.com/charlos1204/firsttest && \
    cd  firsttest && \
    pip install --no-cache-dir -e . && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/* && \
    cd ..


# Open DEEPaaS port
EXPOSE 5000

# Open Monitoring port
EXPOSE 6006

# Account for OpenWisk functionality (deepaas >=0.3.0)
CMD ["sh", "-c", "deepaas-run --openwhisk-detect --listen-ip 0.0.0.0"]
