
library(dplyr)
library(tidyr)
library(ggplot2)
library(clusterProfiler)
library(DOSE)
library(ReactomePA)

pdf("plots.pdf", 16, 12)
allgenes.df = read.table("data/allgenes_df.csv", header=T)
allgenes.df.long = allgenes.df  %>% 
    mutate_each(funs(.>0), BF_hct116:BF_dld1) %>% 
    dplyr::select(gene_id, cons100way, rank, BF_hct116:BF_dld1)  %>%
    gather(line, is.fitness, -c(gene_id:rank)) %>%
    dplyr::filter(is.fitness==T)

sm.do = compareCluster(gene_id~line, data=allgenes.df.long, fun="enrichDO")
sm.kegg = compareCluster(gene_id~line, data=allgenes.df.long, fun="enrichKEGG")
sm.react = compareCluster(gene_id~line, data=allgenes.df.long, fun="enrichPathway")

sm.do %>% plot
sm.kegg %>% plot
sm.react %>% plot

dev.off()
