## merged.mutation
# chromosomes

mm.chr <- merged.mutation %>% count(Chromosome) %>% arrange(desc(n))
mm.chr$Chromosome <- factor(mm.chr$Chromosome, levels = mm.chr$Chromosome)

ggplot(mm.chr, aes(Chromosome, n)) + geom_point() + 
  geom_abline(intercept = sd(mm.chr$n), color = "orange") +
  geom_abline(intercept = mean(mm.chr$n), color = "blue")

ggplot(mm.chr, aes(n)) + geom_boxplot()l
