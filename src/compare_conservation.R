#!/usr/bin/env Rscript

library(phastCons100way.UCSC.hg19)
library(Homo.sapiens)


if (!exists("allgenes")) {
    allgenes = genes(TxDb.Hsapiens.UCSC.hg19.knownGene)
    allgenes$cons100way = scores (phastCons100way.UCSC.hg19, allgenes)
}


