FROM nvidia/cuda:12.9.1-cudnn-runtime-ubuntu22.04

# 构建时可传入代理（仅用于构建，不写入最终镜像环境）
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY

# 设置环境变量（包括代理环境变量）
ENV DEBIAN_FRONTEND=noninteractive
ENV COMFYUI_PORT=8188
ENV COMFYUI_HOME=/app/ComfyUI

# 安装系统依赖 - 使用阿里云镜像源加速
RUN export http_proxy=${HTTP_PROXY} https_proxy=${HTTPS_PROXY} no_proxy=${NO_PROXY} && \
    sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        wget \
        curl \
        libgl1 \
        libglib2.0-0 \
        python3.10 \
        python3-pip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 创建应用目录和用户
RUN mkdir -p ${COMFYUI_HOME} && \
    groupadd -r comfyui && \
    useradd -r -g comfyui -d ${COMFYUI_HOME} comfyui && \
    chown -R comfyui:comfyui ${COMFYUI_HOME}

# 切换到应用用户
USER comfyui
WORKDIR ${COMFYUI_HOME}

# 克隆仓库 + 安装依赖（临时 export 代理，执行后自动失效）
RUN export http_proxy=${HTTP_PROXY} https_proxy=${HTTPS_PROXY} no_proxy=${NO_PROXY} && \
    git clone https://github.com/comfyanonymous/ComfyUI . && \
    git checkout master

# 先安装 PyTorch，增加超时时间
RUN export http_proxy=${HTTP_PROXY} https_proxy=${HTTPS_PROXY} no_proxy=${NO_PROXY} && \
    pip install --no-cache-dir --default-timeout=1000 -i https://pypi.tuna.tsinghua.edu.cn/simple \
        torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu129

# 再安装其他依赖
RUN export http_proxy=${HTTP_PROXY} https_proxy=${HTTPS_PROXY} no_proxy=${NO_PROXY} && \
    pip install --no-cache-dir --default-timeout=1000 -i https://pypi.tuna.tsinghua.edu.cn/simple \
        -r requirements.txt

# 创建必要目录
RUN mkdir -p \
    models/checkpoints \
    models/vae \
    models/loras \
    models/controlnet \
    models/upscale_models \
    input \
    output

# 复制启动脚本
COPY --chown=comfyui:comfyui start.sh ${COMFYUI_HOME}/start.sh
RUN chmod +x ${COMFYUI_HOME}/start.sh

# 暴露端口
EXPOSE ${COMFYUI_PORT}

# 健康检查
HEALTHCHECK --interval=60s --timeout=30s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${COMFYUI_PORT} || exit 1

# 设置启动脚本为入口点
ENTRYPOINT ["/bin/bash", "/app/ComfyUI/start.sh"]