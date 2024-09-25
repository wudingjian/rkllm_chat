Rk3588平台用 NPU跑大模型，rknn-llm 服务端
https://github.com/airockchip/rknn-llm


# 一、RKLLM 简介
RKLLM 可以帮助用户快速将 LLM 模型部署到 Rockchip 芯片中，本仓库所述目前支持芯片：rk3588，整体框架如下：

![Framework](https://github.com/airockchip/rknn-llm/raw/main/res/framework.jpg)

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

# 二、模型转换（RKLLM-Toolkit容器转换工具）
要使用 RKNPU，用户需要先在 x86 工作站上运行 RKLLM-Toolkit 容器转换工具，将训练好的模型转换为 RKLLM 格式的模型，然后在开发板上使用 RKLLM C API 进行推理

`★内存要大于32G 否则会失败，转换前一定要关闭其他应用，以免资源不足，转换失败`

`★本文有第三章节有转换好的模型供下载`

## 1. docker-compose.yml 
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
## 2. 启用
~~~ liunx
docker-compose up -d
~~~
## 3. [魔塔](https://www.modelscope.cn/) 或[Hugging Face](https://huggingface.co)下载模型
模型放在下载在 ./model 目录

## 4. 下载转换python程序到./model
~~~ liunx
wget https://raw.githubusercontent.com/airockchip/rknn-llm/main/rkllm-toolkit/examples/huggingface/test.py
~~~

## 5. 修改test.py中的模型路径

`modelpath = '/root/ws/Qwen2.5-3B-Instruct'`

其中“/root/ws/”为容器内的路径，“Qwen2.5-3B-Instruct” 为下载的模型文件夹

## 6. 修改test.py中的生成转换模型的名称和路径

`ret = llm.export_rkllm("./Qwen2.5-3B.rkllm") `

当前目录（./model）中生成Qwen2.5-3B.rkllm

## 7. 转换模型
### 进入容器内部：
~~~ liunx
 docker exec -it rk3588_llm /bin/bash
~~~
### 进入模型文件夹
~~~ liunx
cd /root/ws
~~~
### 运行转换
~~~ liunx
python3 test.py
~~~


# 三、RK3588 的 RKNPU driver 驱动

由于所提供的 RKLLM 所需要的 NPU 内核版本较高，用户在板端使用 RKLLM Runtime 进行模型
推理前，首先需要确认板端的 NPU 内核是否为 v0.9.6 版本（https://github.com/airockchip/rknn-llm/tree/main/rknpu-driver）
具体的查询命令如下：
~~~ liunx
# 板端执行以下命令，查询 NPU 内核版本
cat /sys/kernel/debug/rknpu/version
# 确认命令输出是否为：
# RKNPU driver: v0.9.6
~~~
若所查询的 NPU 内核版本低于 v0.9.6，请前往官方固件地址下载最新固件进行更新，详见技术手册：https://github.com/airockchip/rknn-llm/blob/main/doc/Rockchip_RKLLM_SDK_CN.pdf

若是H88K_V1，直接更新固件（内含RKNPU driver: v0.9.7）：https://github.com/wudingjian/armbian-h88k-images/releases/tag/20240917-2001


# 四、下载 转化后的.rkllm模型文件 

如果不转换模型（跳过“二、模型转换”），可以直接下载转好后的rkllm模型

例如：`Qwen2.5-3B.rkllm `

`rkllm模型下载链接：https://pan.baidu.com/s/1kIxv488-0IiQdZgDpKO-cw?pwd=up1b 
提取码：up1b`

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

## (一)浏览器访问 http://ip:8080

## (二)可选其他聊天方式（ssh中演示的demo）
### 1. rkllm_api_demo 编译(在x86 pc上编译)
#### 下载rkllm_api_demo
~~~ liunx
git clone --no-checkout https://github.com/airockchip/rknn-llm.git
cd /rknn-llm/tree/main/rkllm-runtime/examples/rkllm_api_demo
~~~

#### 下载 gcc 编译工具
使用 RKLLM Runtime 的过程中，需要注意 gcc 编译工具的版本。推荐使用交叉编译工具
gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu；下载路径为：GCC_10.2 交叉编译工具下载
地址：https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-a/10.2-2020.11/binrel/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu.tar.xz

放在 root 目录

#### 修改配置文件
修改./rkllm_api_demo/src/main.cpp中的两个参数

`param.num_npu_core = 3; # rk3588 3个核心 由1或2 改成3`
    
`param.use_gpu = false;  # 禁止gpu加速`

#### 构建
确保 `build-linux.sh` 脚本中的 `GCC_COMPILER_PATH` 选项配置正确：
```sh
GCC_COMPILER_PATH=~/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu
```
要执行，请运行：
```bash
bash build-linux.sh
```
编译生成的rk3588 上的可执行程序llm_demo目录在./rkllm_api_demo/build/build_linux_aarch64_Release/


### 3. RK3588设备安装rkllm_api_demo
将编译好的 `llm_demo` 文件和 `librkllmrt.so` 文件推送到RK3588设备：
```bash
编译好的 ./rkllm_api_demo/build/build_linux_aarch64_Release/llm_demo

★仓库中已有编译好的 /rkllm_api_demo/llm_demo

文件复制到 ~/llm  #目录自行确定


使用 wget 下载文件
~~~ liunx
# 使用 wget 下载librkllmrt.so文件
wget https://raw.githubusercontent.com/airockchip/rknn-llm/main/rkllm-runtime/runtime/Linux/librkllm_api/aarch64/librkllmrt.so
# 使用 cp 命令将文件复制到 /usr/lib/ 目录
cp librkllmrt.so /usr/lib/librkllmrt.so
~~~

```
### 运行
~~~ ssh
# 程序目录
cd ~/llm
# 将当前 shell 进程及其子进程的文件描述符限制设置为 102400
ulimit -n 102400
# "./model/Qwen2.5-3B.rkllm " 为转换好的模型路径
taskset f0 ./llm_demo ./model/Qwen2.5-3B.rkllm  
~~~
输出聊天对话界面

# 八、FAQ

FAQ：https://github.com/wudingjian/rkllm_chat/issues
