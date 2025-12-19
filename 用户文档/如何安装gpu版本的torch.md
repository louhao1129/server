首先查看服务器cuda版本，为12.4

```{bash}
nvidia-smi
```

然后进入[pytorch官网](https://pytorch.org/)，找到对应版本的安装命令

![](images/paste-25.png)

![](images/paste-28.png)

```{bash}
pip install torch==2.6.0 torchvision==0.21.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cu124
```

检查pytorch是否可用gpu

```{python}
import torch
torch.cuda.is_available()

# 输出true说明安装成功
```

**最后，使用GPU跑代码，必须要在表格中进行登记**

另外：

如果使用uv配置pytorch，需要手动编辑pyproject.toml文件如下，然后执行 `uv sync` ，同样方法检查pytorch是否可用GPU

```{python}
[project]
name = "dl"
version = "0.1.0"
description = "Deep Learning Project with CUDA 12.4"
readme = "README.md"
requires-python = ">=3.10"

dependencies = [
    "torch==2.6.0",
    "torchvision==0.21.0",
    "torchaudio==2.6.0",
]

# 1. 配置清华源为“默认”源 (default = true)
#    uv 会优先在这里查找普通包 (如 numpy, requests 等)
[[tool.uv.index]]
name = "tsinghua"
url = "https://pypi.tuna.tsinghua.edu.cn/simple"
default = true

# 2. 显式把官方 PyPI 加回来 (可选)
#    如果在清华源找不到包，uv 会尝试在这里查找
[[tool.uv.index]]
name = "pypi"
url = "https://pypi.org/simple"

# 3. 配置 PyTorch CUDA 12.4 专用源
#    explicit = true 表示只有在 [tool.uv.sources] 指定了的包才用这个源，
#    避免 uv 去这个源里找无关的包从而拖慢速度。
[[tool.uv.index]]
name = "pytorch-cu124"
url = "https://download.pytorch.org/whl/cu124"
explicit = true

# 4. 绑定具体的包到具体的源
[tool.uv.sources]
torch = { index = "pytorch-cu124" }
torchvision = { index = "pytorch-cu124" }
torchaudio = { index = "pytorch-cu124" }


```