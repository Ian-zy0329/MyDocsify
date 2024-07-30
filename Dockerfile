# 使用官方 Node.js 镜像作为基础镜像
FROM node:16

# 设置工作目录
WORKDIR /app

# 复制当前目录内容到容器的工作目录
COPY package*.json ./

# 安装 docsify-cli 工具
RUN npm install -g docsify-cli --registry=https://registry.npmmirror.com

# 复制 docs 目录到工作目录
COPY docs /app/docs

# 暴露端口
EXPOSE 3000

# 启动 docsify 服务
CMD ["docsify", "serve", "/app/docs"]
