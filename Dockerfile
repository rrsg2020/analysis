FROM qmrlab/antsfsl

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

RUN cd $HOME;\
    git clone https://github.com/rrsg2020/analysis ; \
    cd analysis;\
    pip3 install --upgrade pip;\
    pip3 install setuptools;\
    pip3 install -r requirements.txt
   
