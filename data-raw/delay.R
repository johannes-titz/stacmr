## code to prepare `delay` dataset goes here
library(dplyr)
download.file("https://raw.githubusercontent.com/michaelkalish/STA/refs/heads/master/STACMR-R/Data%20files/delay.dat", "data-raw/delay.tsv")

d <- readr::read_tsv("data-raw/delay.tsv", col_names = c("participant",
                     "delay", "structure", "B1", "B2", "B3", "B4"))
d$participant <- as.factor(d$participant)
d$delay <- factor(d$delay, levels = c("1", "2"), labels = c("no delay", "delay"))
d$structure <- factor(d$structure, levels = c(1, 2), labels = c("rule-based", "information-integration"))
head(d)

d2 <- tidyr::pivot_longer(d, cols = B1:B4, names_to = "block", values_to = "pc")
d3 <- d2 %>%
  arrange(block, participant) %>%
  as.data.frame()
d3$block <- as.factor(d3$block)

anti_join(d3, delay)

delay <- d3
usethis::use_data(delay, overwrite = TRUE)
