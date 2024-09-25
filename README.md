Rk3588平台用 NPU跑大模型，rknn-llm 服务端
https://github.com/airockchip/rknn-llm


# 一、RKLLM 简介
RKLLM 可以帮助用户快速将 LLM 模型部署到 Rockchip 芯片中，目前支持芯片：rk3588/rk3576，整体框架如下：
    <center class="half">
        <div style="background-color:#ffffff;">
        <img src="res/framework.jpg" title="RKLLM"/>
    </center>

要使用RKNPU，用户需要先在电脑上运行RKLLM-Toolkit工具，将训练好的模型转换为RKLLM格式的模型，然后在开发板上使用RKLLM C API进行推理。

- RKLLM-Toolkit是一套软件开发包，供用户在PC上进行模型转换和量化。
- RKLLM Runtime为Rockchip NPU平台提供C/C++编程接口，帮助用户部署RKLLM模型，加速LLM应用的实现。
- RKNPU内核驱动负责与NPU硬件交互，已经开源，可以在Rockchip内核代码中找到。

## 支持平台
- RK3588系列

## 目前支持模型
  - [X] [TinyLLAMA 1.1B](https://huggingface.co/TinyLlama/TinyLlama-1.1B-Chat-v1.0/tree/fe8a4ea1ffedaf415f4da2f062534de366a451e6) 
  - [X] [Qwen 1.8B](https://huggingface.co/Qwen/Qwen-1_8B-Chat/tree/1d0f68de57b88cfde81f3c3e537f24464d889081)
  - [X] [Qwen2 0.5B](https://huggingface.co/Qwen/Qwen1.5-0.5B/tree/8f445e3628f3500ee69f24e1303c9f10f5342a39)
  - [X] [Phi-2 2.7B](https://hf-mirror.com/microsoft/phi-2/tree/834565c23f9b28b96ccbeabe614dd906b6db551a)
  - [X] [Phi-3 3.8B](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct/tree/291e9e30e38030c23497afa30f3af1f104837aa6)
  - [X] [ChatGLM3 6B](https://huggingface.co/THUDM/chatglm3-6b/tree/103caa40027ebfd8450289ca2f278eac4ff26405)
  - [X] [Gemma 2B](https://huggingface.co/google/gemma-2b-it/tree/de144fb2268dee1066f515465df532c05e699d48)
  - [X] [InternLM2 1.8B](https://huggingface.co/internlm/internlm2-chat-1_8b/tree/ecccbb5c87079ad84e5788baa55dd6e21a9c614d)
  - [X] [MiniCPM 2B](https://huggingface.co/openbmb/MiniCPM-2B-sft-bf16/tree/79fbb1db171e6d8bf77cdb0a94076a43003abd9e)

# 二、模型转换
## RKLLM-Toolkit容器转换工具
要使用 RKNPU，用户需要先在 x86 工作站上运行 RKLLM-Toolkit 容器转换工具，将训练好的模型转换为 RKLLM 格式的模型，然后在开发板上使用 RKLLM C API 进行推理

### 1. docker-compose.yml 
~~~ docker
version: '3.8'

services:
  rk3588_llm:
    image: kaylor/rk3588_llm
    platform: linux/amd64
    container_name: rk3588_llm
    restart: unless-stopped
    privileged: true
    volumes:
      - ./model:/root/ws
    stdin_open: true  # -i
    tty: true         # -t
    command: /bin/bash
~~~
### 2. 启用
~~~ liunx
docker-compose up -d
~~~
#### 3. 通过魔塔或huggingface下载模型
模型放在下载在 ./model 目录

#### 4. 下载转换py程序到./model
https://github.com/airockchip/rknn-llm/blob/main/rkllm-toolkit/examples/huggingface/test.py

#### 5. 修改test.py中的模型路径

modelpath = '/root/ws/Qwen2.5-3B-Instruct'
其中“/root/ws/”为容器内的路径，“Qwen2.5-3B-Instruct” 为下载的模型文件夹

#### 6. 修改test.py中的生成转换模型的名称和路径

ret = llm.export_rkllm("./Qwen2.5-3B.rkllm") # 当前目录（./model）中生成Qwen2.5-3B.rkllm

#### 7. 转换模型
##### 进入容器内部：
~~~ liunx
 docker exec -it rk3588_llm /bin/bash
~~~
##### 进入模型文件夹
~~~ liunx
cd /root/ws
~~~
##### 运行转换
~~~ liunx
python3 test.py
~~~


# 三、RK3588 的 RKNPU driver 驱动

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


# 四、下载 转化后的.rkllm模型文件 

如果不转换模型，可以直接转好后的rkllm模型

例如：Qwen2.5-3B.rkllm 

rkllm模型下载链接：https://pan.baidu.com/s/1kIxv488-0IiQdZgDpKO-cw?pwd=up1b 
提取码：up1b

下载后的模型文件放在./model目录下

# 五、docker-compose.yml 

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
# 六、聊天web界面

浏览器访问 http://容器ip:8080

# 七、FAQ

FAQ：https://github.com/wudingjian/rkllm_chat/issues
