# FROM nvcr.io/nvidia/pytorch:24.02-py3
FROM nvcr.io/nvidia/pytorch:22.05-py3
 
 
#安装软件包
 
# RUN apt update \
#     && apt install -y vim wget htop git  language-pack-zh-hans openssh-server sudo \
#     && pip install deepspeed==0.10.0 transformers gpustat wget pytorch_lightning==2.0.7 wrapt datasets evaluate accelerate psutil gradio icetk openpyxl tensorboard cpm_kernels loguru pybind11 tiktoken wandb==0.16.4 -i https://pypi.tuna.tsinghua.edu.cn/simple \
#     && pip uninstall -y transformer-engine

RUN apt update \
    && apt install -y pip vim wget htop git openssh-server sudo \
    && pip install  gpustat -i https://pypi.tuna.tsinghua.edu.cn/simple 
#安装软件包
RUN pip install  -i https://pypi.tuna.tsinghua.edu.cn/simple timm transformers pytest av torch_dct pytest-runner tqdm scipy tensorboard tensorboardX numpy librosa Cython imageio opencv-python matplotlib h5py mir_eval mmengine mmcv-lite torch_mir_eval
# RUN pip install  -i https://pypi.tuna.tsinghua.edu.cn/simple pesq pystoi einops thop python_speech_features beartype rotary_embedding_torch
RUN mkdir /tmp/numba_cache & chmod 777 /tmp/numba_cache & NUMBA_CACHE_DIR=/tmp/numba_cache
ENV NUMBA_CACHE_DIR=/tmp/numba_cache

RUN apt-get install -y --no-install-recommends openssh-client openssh-server && \
    mkdir -p /var/run/sshd
 
COPY ./causal-conv1d /opt/app/causal-conv1d
WORKDIR /opt/app/causal-conv1d
RUN pip install  -i https://pypi.tuna.tsinghua.edu.cn/simple --editable  . --verbose

COPY ./mamba /opt/app/mamba
WORKDIR /opt/app/mamba
RUN pip install  -i https://pypi.tuna.tsinghua.edu.cn/simple --editable  . --verbose
#源码编译

# RUN ./configure --with-ssh --with-rsh --with-mrsh --with-mqshell --with-dshgroups && make && make install
# RUN pip install causal-conv1d>=1.2.0 -i https://pypi.tuna.tsinghua.edu.cn/simple --no-build-isolation --verbose

# COPY causal_conv1d-1.2.0.post2+cu122torch2.2cxx11abiTRUE-cp310-cp310-linux_x86_64.whl .
# RUN pip install causal_conv1d-1.2.0.post2+cu122torch2.2cxx11abiTRUE-cp310-cp310-linux_x86_64.whl
# COPY mamba_ssm-1.2.0.post1+cu122torch2.2cxx11abiTRUE-cp310-cp310-linux_x86_64.whl .
# RUN pip install mamba_ssm-1.2.0.post1+cu122torch2.2cxx11abiTRUE-cp310-cp310-linux_x86_64.whl



RUN sed -i 's/[ #]\(.*StrictHostKeyChecking \).*/ \1no/g' /etc/ssh/ssh_config && \
    echo "    UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config && \
    sed -i 's/#\(StrictModes \).*/\1no/g' /etc/ssh/sshd_config
 
 
# update language settings
# RUN for i in `locale | awk -F'=' '{print $1}'` ; do export  $i="zh_CN.UTF-8"; done
 
# 此处应按照具体情况进行修改：填入使用者host机器的uid、gid、组名、用户名
 
# RUN groupadd -f -g 2085 signal && groupadd -f -g 2086 liuliang \
#     && useradd -m -u 2086 -g liuliang -G signal -s /bin/bash liuliang \
#     && echo 'liuliang ALL=(ALL) NOPASSWD:  /etc/init.d/ssh ' >> /etc/sudoers && echo "liuliang:xxxx" | chpasswd
 


RUN echo 'deb http://mirrors.unisound.ai/repository/ubuntu/ focal main restricted universe multiverse' > /etc/apt/sources.list && \
echo 'deb http://mirrors.unisound.ai/repository/ubuntu/ focal-updates main restricted universe multiverse' >> /etc/apt/sources.list && \
echo 'deb http://mirrors.unisound.ai/repository/ubuntu/ focal-backports main restricted universe multiverse' >> /etc/apt/sources.list && \
echo 'deb http://mirrors.unisound.ai/repository/ubuntu/ focal-security main restricted universe multiverse' >> /etc/apt/sources.list
RUN rm -rf /etc/apt/sources.list.d

RUN echo '[global]' > /etc/pip.conf && \
echo 'index-url=http://mirrors.unisound.ai/repository/pypi/simple' >> /etc/pip.conf && \
echo '[install]' >> /etc/pip.conf && \
echo 'trusted-host=mirrors.unisound.ai' >> /etc/pip.conf

RUN groupadd -f -g 77510 liuliang && groupadd -f -g 767 signal && groupadd -f -g 1014 docker\
    && useradd -m -u 77510 -g liuliang -G signal  -g 1014 -s /bin/bash liuliang \
    && echo 'liuliang ALL=(ALL) NOPASSWD:  /etc/init.d/ssh ' >> /etc/sudoers && echo "liuliang:xxxx" | chpasswd
USER liuliang
