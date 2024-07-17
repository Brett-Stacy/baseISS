






rss2 = function(lengths_og, lengths_sim){
  # count the frequency of each observed length and assign them to a grid of length bins
  grid.temp = data.table(LENGTH = 1:141) # above there is the grid min and max = 1:141
  freqt = merge(grid.temp, lengths_og[,.(freq_og=.N),by=LENGTH], by="LENGTH", all.x = T) # table with length bins and frequency (number of fish) observed in each bin
  freqt = merge(freqt, lengths_sim[,.(freq_sim=.N),by=LENGTH], by="LENGTH", all.x = T) %>% # add resampled frequency to table %>% replace NAs with zero
    replace(is.na(.), 0)


  freqt %>% mutate(prop_og = freq_og/sum(freq_og), .keep = "unused") %>% # make a proportions at length table including og and sim data.
    mutate(prop_sim = freq_sim/sum(freq_sim), .keep = "unused") -> propt


  # RSS
  rss = sum(propt$prop_sim * (1 - propt$prop_sim)) / sum((propt$prop_sim - propt$prop_og)^2)

  return(rss)
}
