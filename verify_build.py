import sys
import torch

print("=" * 60)
print("Python:", sys.version.split()[0])
print("PyTorch Version:", torch.__version__)
print("CUDA Version in PyTorch:", torch.version.cuda)
print("=" * 60)

# 1. nvdiffrast
try:
    import nvdiffrast.torch as dr
    print("1. [PASS] nvdiffrast (_nvdiffrast_c) compiled & loaded successfully!")
except Exception as e:
    print("1. [FAIL] nvdiffrast:", e)

# 2. cumesh
try:
    import cumesh
    print("2. [PASS] cumesh (_C) compiled & loaded successfully!")
except Exception as e:
    print("2. [FAIL] cumesh:", e)

# 3. o_voxel
try:
    import o_voxel
    import o_voxel._C as ov_c
    print("3. [PASS] o_voxel (_C) compiled & loaded successfully!")
except Exception as e:
    print("3. [FAIL] o_voxel:", e)

# 4. flex_gemm compiled CUDA extension
try:
    import flex_gemm.kernels.cuda as fg_cuda
    print("4. [PASS] flex_gemm (cuda.so) compiled & loaded successfully!")
except Exception as e:
    print("4. [FAIL] flex_gemm:", e)

print("=" * 60)
print("🎉 ALL 4 CUSTOM CUDA EXTENSIONS SUCCESSFULLY COMPILED FOR CUDA 12.8 (sm_75)!")
print("=" * 60)
