# 使用 Ubuntu 20.04 作为基础镜像
FROM ubuntu:20.04

# 设置环境变量以避免交互式安装过程中提示输入
ENV DEBIAN_FRONTEND=noninteractive

# 更新包列表并安装必要的工具和依赖
RUN apt-get update && apt-get install -y \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*


# 安装 Flask 和 Werkzeug
RUN pip3 install flask==2.2.2 Werkzeug==2.2.2 -i https://pypi.tuna.tsinghua.edu.cn/simple

# 安装 Gradio
RUN pip3 install gradio>=4.24.0 -i https://pypi.tuna.tsinghua.edu.cn/simple/

# 复制本地的 rkllm_server 目录到容器的根目录 /
COPY ./rkllm_server /rkllm_server

# 设置 OpenCL 库路径
ENV LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu/:/usr/local/lib

# 设置卷和工作目录
VOLUME /rkllm_server/model

# 设置工作目录
WORKDIR /rkllm_server

# 暴露端口
EXPOSE 8080

# 清理安装过程中产生的缓存和临时文件
RUN rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
