import torch
import importlib.machinery
import importlib.util

print("=" * 60)
print(f"PyTorch Version: {torch.__version__} | CUDA Version: {torch.version.cuda}")
print("=" * 60)

def check_so(mod_name, path):
    try:
        loader = importlib.machinery.ExtensionFileLoader(mod_name, path)
        spec = importlib.util.spec_from_loader(mod_name, loader)
        mod = importlib.util.module_from_spec(spec)
        loader.exec_module(mod)
        ops = [x for x in dir(mod) if not x.startswith("_")]
        print(f"✓ {mod_name} ({path.split('/')[-2]}): SUCCESS! Exported functions: {ops[:5]}")
    except Exception as e:
        print(f"✗ {mod_name} ({path.split('/')[-2]}): FAILED: {e}")

check_so('_nvdiffrast_c', '/mnt/c/Users/A-511/OneDrive/Desktop/projects/inspace/.venv/lib/python3.10/site-packages/_nvdiffrast_c.cpython-310-x86_64-linux-gnu.so')
check_so('_C', '/mnt/c/Users/A-511/OneDrive/Desktop/projects/inspace/.venv/lib/python3.10/site-packages/cumesh/_C.cpython-310-x86_64-linux-gnu.so')
check_so('_C', '/mnt/c/Users/A-511/OneDrive/Desktop/projects/inspace/.venv/lib/python3.10/site-packages/o_voxel/_C.cpython-310-x86_64-linux-gnu.so')
check_so('cuda', '/mnt/c/Users/A-511/OneDrive/Desktop/projects/inspace/.venv/lib/python3.10/site-packages/flex_gemm/kernels/cuda.cpython-310-x86_64-linux-gnu.so')
print("=" * 60)
