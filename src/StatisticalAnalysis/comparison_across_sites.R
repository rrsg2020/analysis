comparison_across_sites <- function(site){
  multComparisons <- list()
  for (j in seq(1,14)){
    flag = 1
    anovaGer <- data.frame(T1=numeric(),group=numeric())
    
    for (k in site){
      if (flag==1){
        firstIndex = 0
        lastIndex = 0
      }
      sample = as.numeric(unlist(listSpheres[[k]][j]))
      lastIndex = length(sample)
      anovaGer[(1+firstIndex):(firstIndex+lastIndex),1] = sample
      anovaGer[(1+firstIndex):(firstIndex+lastIndex),2] = rep(as.numeric(data[k,"id"]),length(sample))
      
      firstIndex = firstIndex + length(sample)
      flag = 0
    }
    anovaGer$group <- as.factor(anovaGer$group)
    res.aov <- aov(T1 ~ group, data = anovaGer)
    multComparisons[j] = TukeyHSD(res.aov)
  }
  
  return(multComparisons)
}
