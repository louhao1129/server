[Pak : A Fresh Approach to R Package Installation](https://pak.r-lib.org/reference/get-started.html)

-   pak从不同来源安装，使用相同语法

-   pak 会自动设置与当前 R 版本相对应的 CRAN 仓库和 Bioconductor 仓库

-   为什么推荐用 pak 安装本地包？ `pak::local_install()` 会扫描本地包的 `DESCRIPTION` 文件，自动从 CRAN 或 Bioconductor 下载并安装缺少的依赖。传统的 `install.packages(..., repos = NULL)` 在安装本地包时，如果缺少依赖包，它会报错并停止。

```{r}
# 下载 pak
install.packages("pak")

# 添加自定义存储库
pak::repo_add(rhub = 'https://r-hub.r-universe.dev')
pak::repo_get()

# 清理包缓存
pak::cache_clean()
```

```{r}
# 从不同来源安装，使用相同语法
pak::pkg_install("dplyr")                    # CRAN
pak::pkg_install("tidyverse/ggplot2")        # GitHub，也可以指定一个分支：user/repo@branch
pak::pkg_install("limma")                    # Bioconductor
pak::local_install("/path/to/pkg")           # 本地包
pak::pkg_install(
  "url::https://cran.r-project.org/src/contrib/Archive/tibble/tibble_3.1.7.tar.gz"
)                                            # 任意URL
```

```{r}
# 安装特定版本的包及其正确依赖
pak::pkg_install("dplyr@1.1.0")  # 自动安装兼容的依赖版本
```

```{r}
# 更新一个包
pak::pkg_install("tibble") # pak::pkg_install() 自动更新软件包
pak::pkg_install("tibble", upgrade = TRUE) # 更新一个包所有的依赖
```

```{r}
# 重新安装一个软件包，将 ?reinstall 添加到包名或包引用中
pak::pkg_install("tibble?reinstall")
```