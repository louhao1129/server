# cell2location

```         
conda create -n cell2location python=3.10.14
conda activate cell2location
pip install cell2location
pip install scvi-tools==1.2.2
pip install pooch
```

可能错误：ImportError: cannot import name 'one_hot' from 'scvi.nn'

解决方案:降低scvi-tools版本, pip install scvi-tools==1.2.2 pooch

# scVelo

```         
conda create -n scVelo python=3.10 
conda install scvelo 
pip install jinja2 
pip install python-igraph
```

如果 scv.tl.paga 报错，参考https://github.com/theislab/scvelo/issues/1241，修改源代码 这里安装的scvelo是0.3.3的版本，根据警告信息，里面有很多函数将在0.4弃用

# tangram

```         
conda create -n tangram python=3.10.18
conda activate tangram
conda install scanpy squidpy
pip install tangram-sc
```

# stLearn

```         
conda create -n stlearn python=3.10
conda activate stlearn
pip install -U stlearn
```

# deepTools

# Htseq

```         
conda create -n Htseq htseq
conda activate Htseq

htseq-count -h
```

# intervene

依赖比较复杂，注意单独创建环境

```         
conda create -n intervene intervene
conda activate intervene
intervene --help
```

可能错误：Error: A module that was compiled using NumPy 1.x cannot be run in NumPy 2.0.2 as it may crash. To support both 1.x and 2.x versions of NumPy, modules must be compiled with NumPy 2.0. Some module may need to rebuild instead e.g. with 'pybind11\>=2.12'.

解决方案: conda install numpy=2.0

# Homer

```         
conda create -n Homer 
conda install homer

conda info -e
cd /data/share/nas1/sjwlab/louhao/conda_envs/Homer
ls
cd share
cd homer
perl configureHomer.pl -list # 查看配置文件
perl configureHomer.pl -install human
perl configureHomer.pl -install hg19
```

# sra-env

```         
conda create -n sra-env -c bioconda parallel-fastq-dump 
conda activate sra-env
```

注意使用conda list sra-tools，确保'sra-tools\>=3.0.0' parallel-fastq-dump -h

# chipseq

```         
conda create -n chipseq -c bioconda trim-galore bowtie2 
conda activate chipseq

cutadapt --version
fastqc --version
bowtie2 -h
```

samtools: error while loading shared libraries: libncurses.so.5: cannot open shared object file: No such file or directory 如果有软件用不了，就给他单独新建一个，比如samtools

# sam-tools

```         
conda create -n sam-tools samtools
conda activate sam-tools
conda install macs2
```

# macs

```         
conda create -n macs 
pip install macs2
```

# bdg2bw

```         
conda create -n bdg2bw ucsc-bedgraphtobigwig ucsc-bedclip bedtools
conda activate bdg2bw
```

# pyscenic