对于Rstudio、JupyterHub等启动的进程，属于系统级服务，限制用户可用的CPU核心数、内存**可能对其不产生影响（即limit_user.sh脚本无效）**

因此对此二者单独设置上限

统一设置，rstudio-server总使用（所有使用Rstudio的用户加起来）的CPU核心数不超过96个，总内存占用不超过960GB（服务器总共1TB）

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