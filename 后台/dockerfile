#docker build -t trojan-server .
# 运行容器
# docker run -p 8888:8888 trojan-server
# 使用官方 Erlang 镜像作为基础镜像，选择精简版本～
FROM erlang:24-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV TERM=xterm-256color \
    MNESIA_DIR=/app/Mnesia

# 创建必要的目录并设置权限
RUN mkdir -p ${MNESIA_DIR} && chmod 777 ${MNESIA_DIR}

# 复制源代码到容器中
COPY trojan_socket.erl /app/

# 编译 Erlang 代码并设置权限
RUN erlc trojan_socket.erl && chmod 755 /app/trojan_socket.beam

# 暴露监听端口
EXPOSE 8888

# 创建启动脚本
RUN echo '#!/bin/sh\n\
erl -noshell \\\n\
    -mnesia dir "\"${MNESIA_DIR}\"" \\\n\
    -eval "trojan_socket:create_schema()" \\\n\
    -eval "mnesia:start()" \\\n\
    -eval "trojan_socket:create_table()" \\\n\
    -eval "trojan_socket:start()"' >/app/start.sh && chmod +x /app/start.sh

# 启动服务器
CMD ["/app/start.sh"]
