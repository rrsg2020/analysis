FROM continuumio/anaconda

RUN cd $HOME;\
    git clone https://github.com/rrsg2020/analysis ; \
    cd analysis;\
    pip3 install --upgrade pip;\
    pip3 install setuptools;\
    pip3 install -r requirements.txt

WORKDIR $HOME

USER $NB_UID
