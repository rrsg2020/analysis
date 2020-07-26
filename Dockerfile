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

#install neurodebian
RUN wget -O- http://neuro.debian.net/lists/xenial.us-tn.full | tee /etc/apt/sources.list.d/neurodebian.sources.list
RUN apt-key adv --recv-keys --keyserver hkp://pool.sks-keyservers.net:80 0xA5D32F012649A5A9

#install fsl
RUN apt-get update && apt-get install -y fsl python-numpy

ENV FSLDIR=/usr/share/fsl/5.0
ENV PATH=$PATH:$FSLDIR/bin
ENV LD_LIBRARY_PATH=/usr/lib/fsl/5.0:/usr/share/fsl/5.0/bin

#simulate . ${FSLDIR}/etc/fslconf/fsl.sh
ENV FSLBROWSER=/etc/alternatives/x-www-browser
ENV FSLCLUSTER_MAILOPTS=n
ENV FSLLOCKDIR=
ENV FSLMACHINELIST=
ENV FSLMULTIFILEQUIT=TRUE
ENV FSLOUTPUTTYPE=NIFTI_GZ
ENV FSLREMOTECALL=
ENV FSLTCLSH=/usr/bin/tclsh
ENV FSLWISH=/usr/bin/wish
ENV POSSUMDIR=/usr/share/fsl/5.0

#make it work under singularity
RUN ldconfig && mkdir -p /N/u /N/home /N/dc2 /N/soft

RUN cd $HOME;\
    echo 'export ANTSPATH=/home/jovyan/antsInstallExample/install/bin/' >> ~/.bashrc ; \
    echo 'PATH=${ANTSPATH}:$PATH' >> ~/.bashrc ;\
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh;\
    bash ~/miniconda.sh -b -p $HOME/miniconda;\
    echo ". ~/miniconda/etc/profile.d/conda.sh" >> ~/.bashrc;\
    source ~/.bashrc;\
    git clone https://github.com/rrsg2020/analysis ; \
    cd analysis;\
    pip install -r requirements.txt
    #chmod +777 register_t1maps_nist.sh
