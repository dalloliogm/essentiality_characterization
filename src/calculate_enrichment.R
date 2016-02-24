
library(dplyr)
library(tidyr)
library(ggplot2)


allgenes.df = read.table("data/allgenes_df.csv")
allgenes.df  %>% mutate_each(funs(.>0), BF_hct116:BF_dld1) %>% select(gene_id, cons100way, rank, BF_hct116:BF:dld1) %>% gather(line, is.fitness, -gene_id:cons100way))

