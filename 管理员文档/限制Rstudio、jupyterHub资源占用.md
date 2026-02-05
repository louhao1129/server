对于Rstudio、JupyterHub启动的进程，限制用户可用的CPU核心数、内存**对其不产生影响（即limit_user.sh脚本无效）.**原因是：它被放在了 `system.slice`，而不是 `user.slice`。

**推荐使用limit_user_system.sh，对所有system服务（包括Rserver和JupyterHub）设置总上限为960GB（但是仍然推荐对二者单独设置上限）**

```{bash}
# 检查一个jupyterHub或者Rserver进程会发现
cat /proc/13733/cgroup 

0::/system.slice/jupyterhub.service
```

**因此对此二者单独设置上限**

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

另外：

limit_rsession.sh 脚本用于防止**一个**rsession进程占用太多CPU和内存