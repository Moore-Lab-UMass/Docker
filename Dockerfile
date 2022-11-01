# Ubuntu - R / Python (linux/amd64)
FROM --platform=linux/amd64 ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ='America/New_York'

RUN apt-get update && apt-get upgrade -y && \   
    apt-get install -y \
        wget curl rsync nginx \
        git tree nano nodejs \
        make cmake g++ gcc npm \
        build-essential \
        samtools bamtools bedtools \
        libcurl4-openssl-dev libcurl4 libv8-dev \
        libdeflate-dev libdeflate-tools libpq-dev \
        libcppnumericalsolvers-dev libeigen3-dev \
        libopenblas-base libopenblas-dev \        
        libxml2 libxml2-dev xml2 libgeos-dev \
        libssl-dev libudunits2-dev libtiff5-dev libcairo2-dev \
        libfontconfig1-dev libharfbuzz-dev libfribidi-dev \
        imagemagick libxml-simple-perl libxml-sax-expat-perl libxml-compile-soap-perl \
        libxml-compile-wsdl11-perl libconfig-json-perl  \
        libhtml-treebuilder-libxml-perl libhtml-template-perl \
        libhtml-parser-perl zlib1g-dev libxslt-dev libcudart11.0 \
        nvidia-cuda-dev nvidia-cuda-toolkit nvidia-cuda-gdb nvidia-cuda-toolkit-gcc \
        r-base r-base-core r-base-dev r-cran-irkernel \
        r-recommended r-cran-devtools r-cran-rjava \
        r-cran-ggplot2 r-cran-ggforce r-cran-tidyverse r-cran-markdown \
        python3-dev ipython3 python3-notebook python3-pip \
        python3-pycuda python-pycuda-doc \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install python dependencies
RUN pip3 install \
        numpy pandas torch tqdm transformers \
        scikit-learn eli5 scipy matplotlib xarray \
        tensorflow keras pyfaidx pyBigWig \
        umap-learn logomaker pysam plotnine \
        snakemake HTSeq pyGenomeTracks \
        mpl-scatter-density encode_utils

# install R packages
RUN R -e "install.packages(c( \
        'config', 'log4r', 'plot3D', 'ggplot2', \
        'tsne', 'Rtsne', 'palmerpenguins', \
        'umap', 'tidyverse', 'MASS', 'paletteer', \
        'reshape2', 'patchwork', 'GGally', 'rlang', \
        'PRROC', 'ROCR', 'BiocManager', \
        'ape', 'phylotools', 'ggsci', 'ggstatsplot', \
        'gganimate', 'ggthemes', 'ggrepel', 'ggforce', \
        'cowplot', 'shiny', 'tidytree', 'data.table', \
        'scales', 'DT', 'ggseqlogo', 'pheatmap', 'wordcloud', \
        'wordcloud2', 'microplot', 'rmeta', 'plotly'), \
        dependencies = TRUE)"

# install bioconducter dependencies
RUN R -e "BiocManager::install(c( \
            'BiocGenerics', 'DelayedArray', 'DelayedMatrixStats', \
            'limma', 'lme4', 'S4Vectors', 'SingleCellExperiment', \
            'SummarizedExperiment', 'batchelor', 'Matrix.utils', \
            'HDF5Array', 'terra', 'ggrastr', 'Gviz', 'DESeq2', \
            'GenomicRanges', 'rtracklayer', 'edgeR', \
            'ggtree', 'treeio', 'org.Mm.eg.db', 'org.Hs.eg.db', \
            'org.Dm.eg.db', 'org.Ce.eg.db', \
            'BSgenome.Hsapiens.UCSC,hg38', \
            'BSgenome.Mmusculus.UCSC.mm10', 'DEXSeq'))"

# monocle3
RUN R -e "devtools::install_github('cole-trapnell-lab/monocle3', ref = 'develop')"

# cicero
RUN R -e "devtools::install_github('cole-trapnell-lab/cicero-release', ref = 'monocle3')"

# materialUI
RUN npm install \
@mui/material @emotion/react @emotion/styled \
@mui/material @mui/styled-engine-sc styled-components \
@fontsource/roboto \
@mui/icons-material

# meme-suite
# RUN mkdir /opt/meme
# ADD http://meme-suite.org/meme-software/5.4.1/meme-5.4.1.tar.gz /opt/meme
# WORKDIR /opt/meme/
# RUN tar zxvf meme-5.4.1.tar.gz && rm -fv meme-5.4.1.tar.gz
# RUN cd /opt/meme/meme-5.4.1 && \
#     ./configure --prefix=/opt  --enable-build-libxml2 --enable-build-libxslt  && \
#     make && \
#     make install && \
#     rm -rfv /opt/meme

# ENV PATH='/opt/libexec/meme-5.4.1:/opt/bin:${PATH}'

# CMD ['python']

# WORKDIR /