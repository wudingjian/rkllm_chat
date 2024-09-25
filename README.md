Rk3588平台用 NPU跑大模型，rknn-llm 服务端
https://github.com/airockchip/rknn-llm


# 一、RKNPU driver

由于所提供的 RKLLM 所需要的 NPU 内核版本较高，用户在板端使用 RKLLM Runtime 进行模型
推理前，首先需要确认板端的 NPU 内核是否为 v0.9.6 版本，具体的查询命令如下：
~~~ liunx
# 板端执行以下命令，查询 NPU 内核版本
cat /sys/kernel/debug/rknpu/version
# 确认命令输出是否为：
# RKNPU driver: v0.9.6
~~~
若所查询的 NPU 内核版本低于 v0.9.6，请前往官方固件地址下载最新固件进行更新，详见技术手册：https://github.com/airockchip/rknn-llm/blob/main/doc/Rockchip_RKLLM_SDK_CN.pdf

若是H88K_V1，直接更新固件（内含RKNPU driver: v0.9.7）：https://github.com/wudingjian/armbian-h88k-images/releases/tag/20240917-2001


# 二、下载 转化后的.rkllm模型文件 
例如：Qwen2.5-3B.rkllm 

rkllm模型下载链接：https://pan.baidu.com/s/1kIxv488-0IiQdZgDpKO-cw?pwd=up1b 
提取码：up1b

下载后的模型文件放在./model目录下

# 三、docker-compose.yml 

~~~ docker
version: '3.8'

services:
  rkllm_server:
    image: jsntwdj/rkllm_chat:1.0.1
    container_name: rkllm_chat
    restart: unless-stopped
    privileged: true
    devices:
      - /dev:/dev
    volumes:
      - ./model:/rkllm_server/model  # rkllm模型文件目录
    ports:
      - "8080:8080" # 端口自行修改
    command: >
      sh -c "python3 gradio_server.py --target_platform rk3588 --rkllm_model_path /rkllm_server/model/Qwen2.5-3B.rkllm" #  rkllm模型文件名称自行修改

~~~

启用
~~~ liunx
docker-compose up -d
~~~
# 四、聊天web界面

浏览器访问 http://容器ip:8080

# 五、FAQ

FAQ：https://github.com/wudingjian/rkllm_chat/issues
