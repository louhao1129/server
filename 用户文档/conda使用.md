# conda

-   普通用户（如 test）在使用时会有以下特点

-   无法直接在 base 环境安装包： 如果 test 用户直接输入 conda install numpy，会报错 "Permission denied"。

-   原因： base 环境在 /opt 目录下，属于 root，普通用户无权写入。这是为了安全，防止一个人把环境搞挂了影响所有人。

-   正确的使用姿势：建立自己的虚拟环境 用户应该创建属于自己的环境，这样 Conda 会自动把环境存在用户的家目录（\~/.conda/envs/）下，就没有权限问题了。

应该这样用：

```{bash}
1. 创建一个新环境（比如叫 myenv）

conda create -n myenv python=3.9

2. 激活环境

conda activate myenv

3. 安装包（这时候随便装，完全自由）

pip install torch 总结：Conda 的可执行文件是共享的，但环境（Environments）应该是私有的。
```

如果出现conda: command not found，先运行下面的代码尝试解决，并且联系管理员

```{bash}
source /etc/profile.d/conda.sh
```

# 镜像（conda、cran、bioconductor、GitHub）

<http://sxygptcloud.com:7000/C3/C3.1.html>

![](images/paste-1.png)