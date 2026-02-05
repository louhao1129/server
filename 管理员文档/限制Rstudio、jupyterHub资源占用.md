对于Rstudio、JupyterHub启动的进程，限制用户可用的CPU核心数、内存**对其不产生影响（即limit_user.sh脚本无效）.**原因是：它被放在了 `system.slice`，而不是 `user.slice`。

```{bash}
# 检查一个jupyterHub或者Rserver进程会发现
cat /proc/13733/cgroup 

0::/system.slice/jupyterhub.service
```

# 监护1：limit_user_system.sh

对所有system服务（包括Rserver和JupyterHub）设置总上限为960GB

对普通用户服务，32 核 + 256GB为资源上限

**注意：普通用户通过Rstudio-Server和JupyterHub启动的进程为system服务**

# 监护2：rstudio-server和JupyterHub所有用户总占用

统一设置，rstudio-server总使用（RStudio 里的所有用户 **合计** 不超过某个上限）

-   CPU核心数不超过96个

-   总内存占用不超过960GB（服务器总共1TB）

```{bash}
sudo systemctl set-property rstudio-server.service CPUQuota=9600%
sudo systemctl set-property rstudio-server.service MemoryMax=960G
# 查看配置
systemctl status rstudio-server.service
```

同理对jupyterHub

```{bash}
sudo systemctl set-property jupyterhub.service CPUQuota=9600%
sudo systemctl set-property jupyterhub.service MemoryMax=960G
# 查看配置
systemctl status jupyterhub.service
```

# 监护3：limit_session.sh

-   **单进程**限制：单个进程最多可占用256GB内存，24个CPU核心

-   基于某用户所有**目标进程（rsession、ipykernel等）的内存总和**来进行限制。如果总和超过阈值（目前设置为256GB），则杀掉该用户**最新启动**的那个进程（通常是刚刚提交导致内存溢出的那个任务）。

脚本使用nohup放在后台持续运行，输出日志，每5秒循环一次