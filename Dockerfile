FROM continuumio/anaconda3

RUN cd $HOME;\
    git clone https://github.com/rrsg2020/analysis ; \
    cd analysis;\
    pip install -r requirements.txt

WORKDIR $HOME

USER $NB_UID
