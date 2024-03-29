# Ubuntu - R / Python (linux/amd64)
FROM --platform=linux/amd64 ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ='America/New_York'

RUN dpkg --configure -a

RUN apt-get update && apt-get upgrade -y && \   
    apt-get install -y \
        wget curl rsync nginx \
        git tree nano \
        make cmake g++ gcc \
        build-essential \
        samtools bamtools bedtools \
        libcurl4 libcurl4-gnutls-dev libnode-dev \
        libdeflate-dev libdeflate-tools libpq-dev \
        libcppnumericalsolvers-dev libeigen3-dev libeigen3-doc \
        libopenblas-base libopenblas-dev libmpfrc++-dev \        
        libxml2 libxml2-dev xml2 libgeos-dev \
        libssl-dev libudunits2-dev libtiff5-dev libcairo2-dev \
        libfontconfig1-dev libharfbuzz-dev libfribidi-dev \
        imagemagick libxml-simple-perl libxml-sax-expat-perl libxml-compile-soap-perl \
        libxml-compile-wsdl11-perl libconfig-json-perl  \
        libhtml-treebuilder-libxml-perl libhtml-template-perl \
        libhtml-parser-perl zlib1g-dev libxslt1-dev libcudart11.0 \
        nvidia-cuda-dev nvidia-cuda-toolkit nvidia-cuda-gdb \
        nvidia-cuda-toolkit-gcc nvidia-cuda-toolkit-doc \
        r-base r-base-core r-base-dev r-cran-irkernel \
        r-recommended r-cran-devtools r-cran-rjava \
        r-cran-ggplot2 r-cran-ggforce r-cran-tidyverse r-cran-markdown \
        python3-dev ipython3 python3-notebook python3-pip \
        python3-pycuda python-pycuda-doc postgresql-doc-14 \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# encode tools
RUN rsync -aP hgdownload.soe.ucsc.edu::genome/admin/exe/linux.x86_64/ ./encode
ENV PATH="$PATH:./encode >> ~/.bashrc"

# install python dependencies
RUN pip3 install \
        numpy pandas torch tqdm transformers \
        scikit-learn eli5 scipy matplotlib xarray \
        tensorflow keras pyfaidx pyBigWig \
        umap-learn logomaker pysam plotnine \
        HTSeq pyGenomeTracks mpl-scatter-density \
        encode_utils

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
        'wordcloud2', 'microplot', 'rmeta', 'plotly', 'RCurl'), \
    dependencies = TRUE)"

# install bioconducter dependencies
RUN R -e "BiocManager::install(c( \
        'BiocGenerics', 'DelayedArray', 'DelayedMatrixStats', \
        'limma', 'lme4', 'S4Vectors', 'SingleCellExperiment', \
        'SummarizedExperiment', 'batchelor', 'Matrix.utils', \
        'HDF5Array', 'terra', 'ggrastr', 'Gviz', 'DESeq2', \
        'GenomicRanges', 'rtracklayer', 'edgeR', 'DEXSeq', \
        'ggtree', 'treeio', 'org.Mm.eg.db', 'org.Hs.eg.db', \
        'org.Dm.eg.db', 'org.Ce.eg.db', \
        'BSgenome.Hsapiens.UCSC,hg38', \
        'BSgenome.Mmusculus.UCSC.mm10' \
    ))"

# monocle3
RUN R -e "devtools::install_github('cole-trapnell-lab/monocle3', ref = 'develop')"

# cicero
RUN R -e "devtools::install_github('cole-trapnell-lab/cicero-release', ref = 'monocle3')"

# meme-suite
RUN mkdir /opt/meme
ADD http://meme-suite.org/meme-software/5.4.1/meme-5.4.1.tar.gz /opt/meme
WORKDIR /opt/meme/
RUN tar zxvf meme-5.4.1.tar.gz && rm -fv meme-5.4.1.tar.gz
RUN cd /opt/meme/meme-5.4.1 && \
    ./configure --prefix=/opt  --enable-build-libxml2 --enable-build-libxslt  && \
    make && \
    make install && \
    rm -rfv /opt/meme
ENV PATH='/opt/libexec/meme-5.4.1:/opt/bin:${PATH}'
CMD ["python"]

# atacworks
RUN git clone --recursive https://github.com/clara-genomics/AtacWorks.git
RUN cd AtacWorks && pip3 install -r requirements.txt
RUN pip3 install .

# nvm & npm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
RUN nvm install node

# yarn
RUN npm install --global yarn

## MULTI-STAGE BUILD ##

# first image

FROM node:14-alpine

RUN mkdir -p /app/
COPY ui /app
COPY gcp.json /app/config.json
COPY gcp.json /app/src/config.json

WORKDIR /app/

# final image

FROM nginx:1.13-alpine

RUN mkdir -p /app/
COPY  --from=0 /app/build /usr/share/nginx/html
COPY assets /usr/share/nginx/html/assets
COPY --from=0 /app/nginx.conf /etc/nginx/nginx.conf

EXPOSE 3000
CMD [ "nginx", "-c", "/etc/nginx/nginx.conf", "-g", "daemon off;" ]

## TESTING ##

# RUN pip3 install \
#         atackworks

# RUN R -e "install.packages(c( \
#         '' \
#         dependencies = TRUE)"

# RUN R -e "BiocManager::install(c( \
#             '' \
#           ))"
