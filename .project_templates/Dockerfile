# 使用基础镜像
FROM python:3.9-alpine

# 设置工作目录
WORKDIR /app

# 复制文件
COPY . .

# 安装 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 暴露端口
EXPOSE 5000

# 启动命令
CMD ["python3", "app.py"]