#!/bin/bash
# {{PROJECT_NAME}} Docker 构建脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 项目名称
PROJECT_NAME="{{PROJECT_NAME}}"

# tag参数
TAG="$1"

# 检查参数
if [ -z "$TAG" ]; then
    echo "错误：请指定 TAG "
    echo "用法: sh $0 ${PROJECT_NAME}:latest"
    exit 1
fi


# 构建镜像
echo -e "${GREEN}构建镜像...${NC}"
docker build -t ${TAG} .
echo -e "${GREEN}✓ 镜像构建完成${NC}"
