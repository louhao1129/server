-   R语言安装包遇到网络问题:

```{r}
# 使用SXY自建cran镜像源，
options(repos = c(CRAN = "http://sxygptcloud.com:6003/cran"))

# 使用SXY自建bioconductor镜像源
options(BioC_mirror="http://sxygptcloud.com:6004/bioconductor"))
```

```{r}
# 使用西湖大学镜像源

options("repos" = c(CRAN="https://mirrors.westlake.edu.cn/CRAN/"))

options(BioC_mirror="https://mirrors.westlake.edu.cn/bioconductor");

```