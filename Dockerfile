FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential=12.1ubuntu2 \
        emacs \
        git \
        inkscape \
        jed \
        libsm6 \
        libxext-dev \
        libxrender1 \
        lmodern \
        netcat \
        unzip \
        nano \
        curl \
        wget \
        gfortran \
        cmake \
        bsdtar  \
        rsync \
        imagemagick \
        gnuplot-x11 \
        libopenblas-base \
        python3-dev \
        python3-pip \
        ttf-dejavu \
        wget \
        jq \
        vim && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install the notebook package
RUN pip3 install --no-cache --upgrade pip && \
    pip3 install --no-cache setuptools && \
    pip3 install --no-cache notebook

RUN cd ~;\
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh;\
    bash ~/miniconda.sh -b -p $HOME/miniconda;\
    echo ". ~/miniconda/etc/profile.d/conda.sh" >> ~/.bashrc;\
    /bin/bash -c ". ~/miniconda/etc/profile.d/conda.sh";\
    echo "source activate base" > ~/.bashrc;\
    git clone https://github.com/rrsg2020/analysis ; \
    cd $HOME;\
    cd analysis;\
    pip install -r requirements.txt
    #chmod +777 register_t1maps_nist.sh
