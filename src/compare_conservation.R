#!/usr/bin/env Rscript

library(AnnotationHub)
library(dplyr)
library(tidyr)
#library(phastCons100way.UCSC.hg38)
library(phastCons100way.UCSC.hg19)
#library(TxDb.Hsapiens.UCSC.hg38.knownGene)
library(Homo.sapiens)
library(ggplot2)





print("reading S3 data")
mmc3.raw = read.csv("data/mmc3.csv")
# converting symbol to entrez - first attempt
mmc3 = mmc3.raw %>% mutate(Gene=as.character(Gene)) %>% left_join(as.data.frame(org.Hs.egSYMBOL2EG), by=c("Gene"="symbol"))
mmc3 %>% summarise(n_distinct(Gene), n_distinct(gene_id)) %>% print

print("removing duplicated genes")
# converting symbol to entrez - final attempt
mmc3 = mmc3.raw %>%  
    mutate(Gene=gsub("\\d(\\d)-Mar", "MARCH\\1", Gene)) %>% 
    mutate(Gene=gsub("(\\d\\d)-Sep", "SEP\\1", Gene)) %>% 
    mutate(Gene=gsub("(\\d\\d)-Dec", "DEC\\1", Gene)) %>%
    left_join(as.data.frame(org.Hs.egALIAS2EG), by=c("Gene"="alias_symbol")) %>% 
    filter(!duplicated(Gene)) 
mmc3 %>% summarise(n_distinct(Gene), n_distinct(gene_id)) %>% print


# getting gene coordinates
if (!exists("allgenes")) {
#        allgenes = genes(TxDb.Hsapiens.UCSC.hg38.knownGene) %>% 
        allgenes = genes(TxDb.Hsapiens.UCSC.hg19.knownGene) %>% 
        subset(gene_id %in% mmc3$gene_id) 

#    allgenes$cons100way = scores (phastCons100way.UCSC.hg38, allgenes)
    allgenes$cons100way = scores (phastCons100way.UCSC.hg19, allgenes)
}

#allgenes.df = as.data.frame(mcols(allgenes))
#head(allgenes.df)
allgenes.df = allgenes %>%
    mcols %>%
    as.data.frame %>% 
    arrange(desc(cons100way)) %>% 
    mutate(rank=min_rank(cons100way)) %>%
    left_join(mmc3, by="gene_id") %>% 
#    mutate(gene_type = ifelse(numTKOHits>2, "core", ifelse(numTKOHits>0, "fitness", "nonfitness")))
    mutate(gene_type = ifelse(numTKOHits>0, "fitness", "nonfitness"))

allgenes.df %>% write.table("data/allgenes_df.csv", row.names=F, sep="\t")
# plot
allgenes.df %>% ggplot(aes(x=gene_type, y=-log(cons100way), fill=gene_type)) + geom_violin() + theme_bw() + ggtitle("conservation scores of fitness and non-fitness genes")
ggsave("conservation_scores.png")
allgenes.df %>% group_by(gene_type) %>% summarise(perc=sum(cons100way>0.85)/n())
allgenes.df %>% mutate(fitness = numTKOHits>0) %>% glm(fitness ~ cons100way, data=., family="binomial") %>% summary 


