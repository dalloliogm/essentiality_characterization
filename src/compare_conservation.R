#!/usr/bin/env Rscript

library(AnnotationHub)
library(dplyr)
library(tidyr)
library(phastCons100way.UCSC.hg19)
library(Homo.sapiens)


if (!exists("allgenes")) {
    allgenes = genes(TxDb.Hsapiens.UCSC.hg19.knownGene)
    allgenes$cons100way = scores (phastCons100way.UCSC.hg19, allgenes)
}

allgenes.df = as.data.frame(mcols(allgenes))
head(allgenes.df)
allgenes.df = allgenes.df %>%
    arrange(desc(cons100way)) %>% 
    mutate(rank=min_rank(cons100way))

print("reading S3 data")
mmc3 = read.csv("data/mmc3.csv")
mmc3 = mmc3 %>% mutate(Gene=as.character(Gene)) %>% left_join(as.data.frame(org.Hs.egSYMBOL2EG), by=c("Gene"="symbol"))
print("removing duplicated genes")

