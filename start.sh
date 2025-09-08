#!/bin/bash

# 等待 GPU 设备就绪
echo "等待 GPU 设备初始化..."
sleep 5

# 启动 ComfyUI
exec python3 main.py \
    --listen 0.0.0.0 \
    --port 8188 \
    --enable-cors-header \
    --auto-launch