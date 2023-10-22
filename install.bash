#!/usr/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
create_venv=true

while [ -n "$1" ]; do
    case "$1" in
        --disable-venv)
            create_venv=false
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if $create_venv; then
    echo "Creating python venv..."
    python3 -m venv venv
    source "$script_dir/venv/bin/activate"
    echo "active venv"
fi

echo "Installing torch & xformers..."

cuda_version=$(nvcc --version | grep 'release' | sed -n -e 's/^.*release \([0-9]\+\.[0-9]\+\),.*$/\1/p')
cuda_major_version=$(echo "$cuda_version" | awk -F'.' '{print $1}')
cuda_minor_version=$(echo "$cuda_version" | awk -F'.' '{print $2}')

echo "Cuda Version:$cuda_version"

echo "install torch 2.0.0+cu118"
pip install torch==2.0.1+cu118 torchvision==0.15.2+cu118 --extra-index-url https://download.pytorch.org/whl/cu118 -i https://mirror.baidu.com/pypi/simple
pip install xformers==0.0.21 -i https://mirror.baidu.com/pypi/simple

echo "Installing deps..."
cd "$script_dir/sd-scripts" || exit

pip install --upgrade -r requirements.txt -i https://mirror.baidu.com/pypi/simple
pip install protobuf==3.20.3 -i https://mirror.baidu.com/pypi/simple
pip install --upgrade lion-pytorch lycoris-lora dadaptation prodigyopt fastapi uvicorn wandb -i https://mirror.baidu.com/pypi/simple
pip install --upgrade --no-deps pytorch-optimizer -i https://mirror.baidu.com/pypi/simple

cd "$script_dir" || exit

echo "Install completed"
