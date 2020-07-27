FROM qmrlab/antsfsl

RUN cd $HOME;\
    git clone https://github.com/rrsg2020/analysis ; \
    cd analysis;\
    pip install -r requirements.txt;\
    pip install jupyter-conda

