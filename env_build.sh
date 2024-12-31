#!/bin/bash

# 脚本的开始
set -e

# 定义变量
MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-py39_24.11.1-0-Linux-x86_64.sh"
MINICONDA_INSTALL_DIR="$HOME/miniconda3"
BASHRC="$HOME/.bashrc"

# 下载 Miniconda 安装脚本
echo "Downloading Miniconda..."
curl -o Miniconda3-latest-Linux-x86_64.sh $MINICONDA_URL

# 安装 Miniconda
echo "Installing Miniconda..."
bash Miniconda3-latest-Linux-x86_64.sh -b -p $MINICONDA_INSTALL_DIR

# 手动更新 PATH
echo "Updating PATH temporarily for the current session..."
export PATH="$MINICONDA_INSTALL_DIR/bin:$PATH"

# 验证 conda 是否可用
echo "Checking if conda is available..."
if ! command -v conda &>/dev/null; then
    echo "Error: conda is not available in the PATH. Exiting."
    exit 1
fi

# 配置 bashrc
echo "Configuring bashrc..."
if ! grep -q "$MINICONDA_INSTALL_DIR/bin" "$BASHRC"; then
    echo "export PATH=\"$MINICONDA_INSTALL_DIR/bin:\$PATH\"" >> "$BASHRC"
fi

# 刷新 bashrc
echo "Sourcing bashrc..."
source "$BASHRC"

# 初始化 conda
echo "Initializing conda..."
conda init bash

# 重新加载 bashrc
echo "Reloading bash configuration..."
source "$HOME/.bashrc"

# echo "Activating base environment..."
# conda activate base

# 安装 Jupyter 工具以支持 VS Code
echo "Installing Jupyter and tools for VS Code..."
conda install -y -n base ipykernel --update-deps --force-reinstall

# 安装 conda_requirements.txt 的依赖
if [ -f "conda_requirements.txt" ]; then
    echo "Installing conda dependencies from conda_requirements.txt..."
    conda install -y -c conda-forge --file conda_requirements.txt
fi

# 安装 requirements.txt 的 pip 依赖
if [ -f "requirements.txt" ]; then
    echo "Installing pip dependencies from requirements.txt..."
    pip install -r requirements.txt
fi

# 清理下载的安装文件
echo "Cleaning up..."
rm Miniconda3-latest-Linux-x86_64.sh

# 提示完成
echo "Environment setup is complete!"

# 将 `conda activate base` 添加到系统启动脚本
echo "Adding 'conda activate base' to system startup..."
if ! grep -q "conda activate base" "$BASHRC"; then
    echo "conda activate base" >> "$BASHRC"
fi
