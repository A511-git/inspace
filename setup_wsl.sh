#!/usr/bin/env bash
set -e

PROJECT_DIR="/mnt/c/Users/A-511/OneDrive/Desktop/projects/inspace"
cd "$PROJECT_DIR"

echo "=========================================================="
echo " InSpace WSL 2 Environment Setup (CUDA 12.8 + sm_75)"
echo "=========================================================="

# 1. Environment Variables & Paths
export CUDA_HOME=/usr/local/cuda-12.8
export PATH=/usr/local/cuda-12.8/bin:/root/.local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH
export UV_LINK_MODE=copy
export MAX_JOBS=4
export TORCH_CUDA_ARCH_LIST="7.5"
export FORCE_CUDA=1

# Persist to ~/.bashrc if not already present
if ! grep -q "CUDA_HOME=/usr/local/cuda-12.8" ~/.bashrc; then
    cat << 'EOF' >> ~/.bashrc
export CUDA_HOME=/usr/local/cuda-12.8
export PATH=/usr/local/cuda-12.8/bin:$HOME/.local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH
EOF
fi

# 2. Virtual Environment Setup
if [ ! -d ".venv" ]; then
    echo "--> Creating Python 3.10 virtual environment..."
    uv python install 3.10
    uv venv --python 3.10 .venv
fi
source .venv/bin/activate

# 3. PyTorch Stack (CUDA 12.8)
echo "--> Installing PyTorch (CUDA 12.8)..."
uv pip install torch torchvision --index-url https://download.pytorch.org/whl/cu128

# 4. Bridge Modular CUDA 12 Headers & Libraries
echo "--> Linking CUDA SDK headers and shared libraries into /usr/local/cuda-12.8..."
find "$PROJECT_DIR"/.venv/lib/python3.10/site-packages/nvidia/*/include -type f -exec ln -sf {} /usr/local/cuda-12.8/include/ \; 2>/dev/null || true
find "$PROJECT_DIR"/.venv/lib/python3.10/site-packages/nvidia/*/lib -type f -exec ln -sf {} /usr/local/cuda-12.8/lib64/ \; 2>/dev/null || true
find "$PROJECT_DIR"/.venv/lib/python3.10/site-packages/nvidia/*/lib -type l -exec ln -sf {} /usr/local/cuda-12.8/lib64/ \; 2>/dev/null || true

export CPATH=/usr/local/cuda-12.8/include:$CPATH
export LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LIBRARY_PATH

# 5. Build Tools & Core Dependencies
echo "--> Installing build and runtime dependencies..."
uv pip install ninja wheel setuptools numpy opencv-python-headless plyfile trimesh easydict zstandard

# 6. Setup Eigen for o-voxel
mkdir -p "$PROJECT_DIR/o-voxel/third_party/eigen"
if [ -d "/usr/include/eigen3/Eigen" ]; then
    cp -r /usr/include/eigen3/Eigen "$PROJECT_DIR/o-voxel/third_party/eigen/"
fi

# 7. Compile Custom CUDA Extensions (Target sm_75 / Tesla T4)
echo "--> Compiling nvdiffrast..."
uv pip install git+https://github.com/NVlabs/nvdiffrast.git --no-build-isolation

echo "--> Compiling flex-gemm..."
uv pip install git+https://github.com/JeffreyXiang/FlexGEMM.git --no-build-isolation

echo "--> Compiling cumesh..."
uv pip install git+https://github.com/JeffreyXiang/CuMesh.git --no-build-isolation

echo "--> Compiling o-voxel..."
cd "$PROJECT_DIR/o-voxel"
rm -rf build/ dist/ *.egg-info
uv pip install . --no-build-isolation
cd "$PROJECT_DIR"

# 8. Editable InSpace Install
echo "--> Installing inspace..."
uv pip install -e . --no-deps

echo "=========================================================="
echo " Verification"
echo "=========================================================="
python check_extensions.py
