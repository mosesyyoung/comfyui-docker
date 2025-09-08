# ComfyUI Docker

一个开箱即用的 ComfyUI Docker 化部署方案，支持 NVIDIA GPU 加速。

![Docker](https://img.shields.io/badge/Docker-✓-blue?style=flat-square)
![NVIDIA GPU](https://img.shields.io/badge/NVIDIA%20GPU-✓-green?style=flat-square)
![Python 3.10](https://img.shields.io/badge/Python-3.10-informational?style=flat-square)

## ✨ 特性

- 🐳 **一键部署**: 支持 Docker 和 Docker Compose 两种方式
- ⚡ **GPU 加速**: 基于 CUDA 运行时环境，支持 NVIDIA GPU
- 🔒 **安全实践**: 使用非 root 用户运行，减少安全风险
- 📦 **优化构建**: 分阶段构建优化镜像大小，集成国内镜像源加速
- 🌐 **网络支持**: 支持代理配置，适应各种网络环境
- 🏗️ **生产就绪**: 包含健康检查、日志配置和资源管理

## 🚀 快速开始

### 前置要求

- **Docker** 20.10+
- **NVIDIA 环境**: NVIDIA 显卡驱动 + NVIDIA Container Toolkit
- **GPU**: NVIDIA GPU（推荐 8GB+ 显存）

### 1. 克隆项目

```bash
git clone https://github.com/mosesyyoung/comfyui-docker
cd comfyui-docker
```

### 2. 准备模型文件

```bash
# 创建模型目录结构
mkdir -p models/checkpoints models/vae models/loras models/controlnet models/faces

# 将模型文件放入对应目录
# 例如: models/checkpoints/sd_xl_base_1.0.safetensors
#       models/faces/codeformer.pth
```

### 3. 构建镜像

```bash
# 使用代理构建（如需要）
docker build \
  --build-arg HTTP_PROXY="http://your-proxy:port" \
  --build-arg HTTPS_PROXY="http://your-proxy:port" \
  -t comfyui:latest .

# 或直接构建
docker build -t comfyui:latest .

# 或直接启动
docker compose up -d
```

### 4. 启动服务

```bash
# 方式一：使用 Docker Compose（推荐）
docker compose up -d

# 方式二：使用 Docker 命令
docker run -d --name comfyui --gpus all -p 8188:8188 \
  -v $(pwd)/models/checkpoints:/app/ComfyUI/models/checkpoints \
  -v $(pwd)/models/vae:/app/ComfyUI/models/vae \
  -v $(pwd)/models/loras:/app/ComfyUI/models/loras \
  -v $(pwd)/models/controlnet:/app/ComfyUI/models/controlnet \
  -v $(pwd)/models/faces:/app/ComfyUI/models/faces \
  -v $(pwd)/output:/app/ComfyUI/output \
  -v $(pwd)/input:/app/ComfyUI/input \
  comfyui:latest
```

### 5. 访问服务

- **Web UI**: http://localhost:8188
- **API 端点**: http://localhost:8188/api

## 📁 项目结构

```
comfyui-docker/
├── Dockerfile              # Docker 构建文件
├── docker-compose.yml      # Docker Compose 配置
├── start.sh               # 自定义启动脚本
├── generate_readme.py     # README 生成脚本
├── models/                # 模型目录（外部挂载）
│   ├── checkpoints/       # 基础模型文件
│   ├── vae/              # VAE 模型
│   ├── loras/            # LoRA 模型
│   ├── controlnet/       # ControlNet 模型
│   └── faces/            # 面部修复模型
├── input/                 # 输入文件目录
└── output/                # 生成输出目录
```

## ⚙️ 配置说明

### 环境变量

| 变量名 | 默认值 | 描述 |
|--------|--------|------|
| `COMFYUI_PORT` | `8188` | 服务监听端口 |
| `COMFYUI_HOME` | `/app/ComfyUI` | ComfyUI 安装目录 |

### 构建参数

支持代理配置：

```bash
docker build \
  --build-arg HTTP_PROXY="http://your-proxy:port" \
  --build-arg HTTPS_PROXY="http://your-proxy:port" \
  --build-arg NO_PROXY="localhost,127.0.0.1" \
  -t comfyui:latest .
```

## 🛠️ 管理命令

### 常用命令

```bash
# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f

# 停止服务
docker compose down

# 进入容器
docker exec -it comfyui /bin/bash
```

### 自定义启动参数

编辑 `start.sh` 文件添加自定义启动参数：

```bash
# 在 start.sh 中添加启动参数
python main.py --listen 0.0.0.0 --port 8188 --highvram --enable-cors-header
```

支持的启动参数：
- `--highvram`: 高显存模式（推荐 12G+ 显存）
- `--enable-cors-header`: 启用 CORS 支持
- `--preview-method auto`: 自动预览方法

## 🙋 获取帮助

如果遇到问题，请：

1. 查看 [常见问题](#常见问题) 部分
2. 检查 Docker 日志：`docker compose logs comfyui`
3. 创建 [GitHub Issue](https://github.com/mosesyyoung/comfyui-docker/issues)

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**Happy Generating! 🎨**

如果这个项目对你有帮助，请给它一个 ⭐！
