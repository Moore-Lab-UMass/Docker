# Packages
list <- c("devtools", "config", "log4r",
            "plot3D", "ggplot2", "tsne", "Rtsne",
            "UMap", "tidyverse", "MASS", "paletteer",
            "reshape2", "patchwork", "GGally", "rlang",
            "PRROC", "ROCR", "BiocManager",
            "ape", "phylotools", "ggsci", "ggstatsplot",
            "gganimate", "ggthemes", "ggrepel", "ggforce",
            "cowplot", "shiny", "tidytree", "data.table",
            "scales", "DT", "ggseqlogo", "pheatmap", "wordcloud",
            "wordcloud2", "microplot", "rmeta", "plotly")

install.packages(list, dependencies = TRUE)

BiocManager::install(c("BiocGenerics", "DelayedArray", "DelayedMatrixStats",
                       "limma", "lme4", "S4Vectors", "SingleCellExperiment",
                       "SummarizedExperiment", "batchelor", "Matrix.utils",
                       "HDF5Array", "terra", "ggrastr", "Gviz",
                       "GenomicRanges", "rtracklayer", "DESeq2", "edgeR",
                       "ggtree", "treeio", "org.Mm.eg.db", "org.Hs.eg.db",
                       "org.Dm.eg.db", "org.Ce.eg.db",
                       "BSgenome.Hsapiens.UCSC,hg38",
                       "BSgenome.Mmusculus.UCSC.mm10", "DEXSeq"))

# Monocle3
devtools::install_github("cole-trapnell-lab/monocle3", ref = "develop")

# Cicero
devtools::install_github("cole-trapnell-lab/cicero-release", ref = "monocle3")