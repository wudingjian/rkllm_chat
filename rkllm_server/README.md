# 一、Gradio 模式
## 服务端
### 1. 修改 gradio_server.py, 禁用 GPU 进行 prefill 加速
`rknnllm_param.use_gpu = False`

### 2.Dockerfile设置启动命令
~~~docker
CMD ["sh", "-c", "python3 gradio_server.py --target_platform rk3588 --rkllm_model_path /rkllm_server/model/Qwen2.5-3B.rkllm"]
~~~
### 3. docker-compose.yml
~~~docker
    command: >
      sh -c "python3 gradio_server.py --target_platform rk3588 --rkllm_model_path /rkllm_server/model/Qwen2.5-3B.rkllm" #  rkllm模型文件名称自行修改
~~~
## 客户端
### 下载
~~~linux
wget https://github.com/airockchip/rknn-llm/raw/main/rkllm-runtime/examples/rkllm_server_demo/chat_api_gradio.py
~~~
### 修改网址
实例化Gradio Client，用户需要根据自己部署的具体网址进行修改
    client = Client("http://172.16.10.102:8080/")
### 运行 chat_api_gradio.py
~~~linux
python3 chat_api_gradio.py
~~~

# 二 、Falsk 模式
## 服务端
### 1.修改 flask_server.py, 禁用 GPU 进行 prefill 加速
`rknnllm_param.use_gpu = False`
### 2.Dockerfile设置启动命令
~~~docker
CMD ["sh", "-c", "python3 flask_server.py --target_platform rk3588 --rkllm_model_path /rkllm_server/model/Qwen2.5-3B.rkllm"]
~~~
### 3.docker-compose.yml
~~~docker
    command: >
      sh -c "python3 flask_server.py --target_platform rk3588 --rkllm_model_path /rkllm_server/model/Qwen2.5-3B.rkllm" #  rkllm模型文件名称自行修改
~~~
## 客户端
~~~linux
wget https://github.com/airockchip/rknn-llm/raw/main/rkllm-runtime/examples/rkllm_server_demo/chat_api_flask.py
~~~
### 设置 Server 服务器的地址
修改地址
`server_url = 'http://172.16.10.102:8080/rkllm_chat'`

### 运行 chat_api_flask.py
python3 chat_api_flask.py
