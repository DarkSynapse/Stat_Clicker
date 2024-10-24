library(dplyr)
library(ggplot2)


Before = rep(25:34, 3 )
After = rep(20:49)
Strata  = rep(c("Nivo", "BV", "Chemo"), 10)
dfwf <- data.frame(After,Before, Strata)


dogit_pal <- c("#0A2C5E",
               "#4C8077" ,
               "#FD7E01",
  "#F9525C",
  "#CA4D8B",
  "#845798",
  "#455581",
  "#2F4858",
  "#C4FCF1",
  "#005247",
  "#4C8077")

wf_plot <- function(my_dt,
                    Before,
                    After,
                    Strata,
                    yax,
                    fax,
                    xax) {
  my_dt$Before
  my_dt$After
  my_dt$Strata
  my_dt$id <-  1:nrow(my_dt)

  my_dt <- my_dt %>%
    dplyr::mutate(Change = Before - After,
                  ChangePercentage  = (Change / Before) * 100)
  
  my_dt$id <-
    factor(my_dt$id, levels = my_dt$id[order(my_dt$ChangePercentage, decreasing = TRUE)])
  
  ggplot(data = my_dt,
         aes(x = id, y = ChangePercentage, fill = Strata)) +
    geom_bar(stat = "identity") +
    theme_classic() +
    scale_fill_manual(values = dogit_pal) +
    # expand_limits(y=c(-100, 100)) +
    labs(fill=fax, 
         x= xax,  y=yax) +
    theme(
      legend.title = element_text(size = 14),
      legend.text = element_text(size = 10),
      panel.background = element_blank(),
      axis.ticks.x = element_blank(),
      axis.text.x = element_blank()
    )
  
}

wf_plot(my_dt = dfwf, 
                    Before = dfwf$Before,
                    After = dfwf$After,
                    Strata = dfwf$Strata,
                    yax = "ch fr b",
                    fax = "gr",
                    xax = "pat")




  