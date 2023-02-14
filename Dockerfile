FROM continuumio/anaconda3

# create user with a home directory
ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN apt-get update; \
    apt-get install -y --no-install-recommends imagemagick

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
WORKDIR $HOME
USER ${USER}

RUN cd $HOME;   \
    git clone https://github.com/rrsg2020/analysis ;      \
    cd analysis;     \
    git checkout mb/plots; \
    pip install -r requirements.txt

