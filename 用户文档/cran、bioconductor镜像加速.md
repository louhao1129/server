-   R语言安装包遇到网络问题

```{r}
# 使用西湖大学镜像源

options("repos" = c(CRAN="https://mirrors.westlake.edu.cn/CRAN/"))

options(BioC_mirror="https://mirrors.westlake.edu.cn/bioconductor")

```