#!/bin/bash

# 项目初始化脚本
# 使用: sh ~/project_init.sh /project_path remote_repository

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 模板目录
TEMPLATE_DIR="$HOME/project-init/.project_templates"

# 显示帮助
show_help() {
    echo "使用: $0 <项目路径> [远程仓库地址]"
    echo ""
    echo "参数:"
    echo "  项目路径:         要初始化的项目目录路径"
    echo "  远程仓库地址:     Git 远程仓库地址（可选）"
    echo ""
    echo "示例:"
    echo "  $0 /path/to/myproject"
    echo "  $0 /path/to/myproject git@github.com:user/repo.git"
    echo "  $0 ./myproject"
    exit 0
}

# 检查是否请求帮助
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

# 参数检查
if [ -z "$1" ]; then
    echo -e "${RED}错误: 请指定项目路径${NC}"
    echo ""
    echo "用法: $0 <项目路径> [远程仓库地址]"
    echo ""
    echo "参数说明:"
    echo "  项目路径:         要创建项目的目录路径"
    echo "  远程仓库地址:     可选的 Git 远程仓库地址"
    echo ""
    exit 1
fi

PROJECT_PATH="$1"
REMOTE_REPO="$2"

echo -e "${GREEN}开始初始化项目: $PROJECT_PATH${NC}"

# 检查模板目录是否存在
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo -e "${YELLOW}警告: 模板目录不存在，创建默认模板...${NC}"
    mkdir -p "$TEMPLATE_DIR"
    # 这里可以添加创建基础模板的代码，但根据要求不添加额外内容
    echo -e "${YELLOW}请先创建模板文件在 $TEMPLATE_DIR 目录下${NC}"
    exit 1
fi

# 创建项目目录（如果不存在）
mkdir -p "$PROJECT_PATH"/src "$PROJECT_PATH"/resources
cd "$PROJECT_PATH" || {
    echo -e "${RED}错误: 无法进入目录 $PROJECT_PATH${NC}"
    exit 1
}

# 获取项目名称（从路径的最后一部分）
PROJECT_NAME=$(basename "$PROJECT_PATH")

# 复制并处理模板文件
echo -e "${YELLOW}生成项目文件...${NC}"

# 模板文件列表
TEMPLATE_FILES=(
    ".gitignore"
    "README.md"
    "Dockerfile"
    "docker-compose.yml"
    "docker-build.sh"
)

for file in "${TEMPLATE_FILES[@]}"; do
    template_file="$TEMPLATE_DIR/$file"
    
    if [ -f "$template_file" ]; then
        # 复制并替换变量
        if [ "$file" = "docker-build.sh" ]; then
            # 对于脚本文件，需要保持可执行权限
            cp "$template_file" "./$file"
            chmod +x "./$file"
        else
            cp "$template_file" "./$file"
        fi
        
        # 替换 PROJECT_NAME 占位符
        sed -i.bak "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "./$file"
        rm -f "./$file.bak"
        
        echo -e "  ✓ $file"
    else
        echo -e "  ${YELLOW}⚠  模板文件 $file 不存在，跳过${NC}"
    fi
done

# 初始化 Git 仓库
echo -e "${YELLOW}初始化 Git...${NC}"
if [ -d ".git" ]; then
    echo -e "  ${YELLOW}⚠  Git 仓库已存在，跳过初始化${NC}"
else
    git init
    echo -e "  ✓ Git 仓库已初始化"
fi

# 配置远程仓库
if [ -n "$REMOTE_REPO" ]; then
    echo -e "${YELLOW}配置远程仓库...${NC}"
    
    # 检查是否已存在远程仓库
    if git remote | grep -q "^origin$"; then
        echo -e "  ${YELLOW}⚠  远程仓库 origin 已存在${NC}"
        echo -e "  当前远程仓库:"
        git remote -v
    else
        git remote add origin "$REMOTE_REPO"
        echo -e "  ✓ 远程仓库已添加: $REMOTE_REPO"
    fi
    
    # 创建初始提交
    echo -e "${YELLOW}创建初始提交...${NC}"
    git add .
    git commit -m "init: 项目初始化"
    echo -e "  ✓ 初始提交已创建"
    
    # 推送到远程仓库
    echo -e "${YELLOW}推送到远程仓库...${NC}"
    
    # 检查默认分支名称（可能是 main 或 master）
    if git show-ref --verify --quiet refs/heads/main; then
        DEFAULT_BRANCH="main"
    else
        DEFAULT_BRANCH="master"
        # 如果 master 不存在，创建它
        git checkout -b master 2>/dev/null
    fi
    
    # 尝试推送
    if git push -u origin "$DEFAULT_BRANCH" 2>/dev/null; then
        echo -e "  ✓ 代码已推送到远程仓库"
    else
        echo -e "  ${YELLOW}⚠  推送失败，可能需要手动推送${NC}"
        echo -e "  手动执行: git push -u origin $DEFAULT_BRANCH"
    fi
else
    echo -e "${YELLOW}未配置远程仓库${NC}"
    echo -e "  如需配置，请手动执行:"
    echo -e "  git remote add origin <远程仓库地址>"
fi

# 显示完成信息
echo -e "${GREEN}"
echo "========================================"
echo "项目初始化完成！"
echo "========================================"
echo -e "${NC}"

echo "项目信息:"
echo "  名称: $PROJECT_NAME"
echo "  路径: $(pwd)"
echo ""
echo "已创建的文件:"
ls -la
echo ""
echo "下一步:"
echo "  1. 修改配置文件中的占位符"
echo "  2. 添加项目代码到 src/ 目录"
echo "  3. 执行 sh docker-build.sh 查看 Docker-build 操作"
echo ""

if [ -n "$REMOTE_REPO" ]; then
    echo "远程仓库: $REMOTE_REPO"
else
    echo "提示: 可以使用以下命令添加远程仓库:"
    echo "  git remote add origin <仓库地址>"
fi
