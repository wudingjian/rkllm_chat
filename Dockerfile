# 第一阶段：构建阶段
FROM python:3.8-slim as builder

# 设置环境变量以避免交互式安装过程中提示输入
ENV DEBIAN_FRONTEND=noninteractive

# 更新包列表并安装必要的工具和依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 安装 Flask 和 Werkzeug 以及 Gradio
RUN pip install --no-cache-dir --target=/install flask==2.2.2 Werkzeug==2.2.2 gradio>=4.24.0 -i https://pypi.tuna.tsinghua.edu.cn/simple

# 第二阶段：运行阶段
FROM python:3.8-slim

# 设置环境变量以避免交互式安装过程中提示输入
ENV DEBIAN_FRONTEND=noninteractive

# 复制构建阶段的安装结果到最终镜像
COPY --from=builder /install /usr/local/lib/python3.8/site-packages

# 复制本地的 rkllm_server 目录到容器的根目录 /
COPY ./rkllm_server /rkllm_server

# 设置卷和工作目录
VOLUME /rkllm_server/model

# 设置工作目录
WORKDIR /rkllm_server

# 暴露端口
EXPOSE 8080

# 清理安装过程中产生的缓存和临时文件
RUN apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*