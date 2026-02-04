对于Rstudio、JupyterHub等启动的进程，属于系统级服务，限制用户可用的CPU核心数对其不产生影响（即limit_cpu.sh脚本无效）

统一设置，rstudio-server总使用（所有使用Rstudio的用户加起来）的CPU核心数不超过96个

```{bash}
sudo systemctl set-property rstudio-server.service CPUQuota=9600%
```

同理对jupyterHub

```{bash}
sudo systemctl set-property jupyterhub.service CPUQuota=9600%
```

以上所有的操作（包括limit_cpu.sh），系统重启之后可能会失效，需要重新运行