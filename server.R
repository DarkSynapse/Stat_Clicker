library(shiny)
library(rhandsontable)
library(dplyr)
library(ggplot2)
# library(tidyverse)

# swimmer plot function
sw_plot <- function(my_dt,
                    OST ,
                    OST2,
                    OSS,
                    OSTF,
                    OSF,
                    xax,
                    yax,
                    cax) {
  my_dt$OST <- OST
  my_dt$OST2 <- OST2
  my_dt$OSS <- OSS
  
  my_dt$OSTF <- OSTF
  my_dt$OSF <- OSF
  
  my_dt$ID <- 1:nrow(my_dt)
  my_dt <- filter(my_dt, !is.na(OST))
  my_dt$ID <- factor(my_dt$ID, levels = my_dt$ID[order(my_dt$OST, decreasing = FALSE)])
  
  ggplot(my_dt, aes(x = as.factor(ID), OST)) +
    geom_bar(
      stat = "identity",
      width = 0.7,
      alpha = 1,
      colour = '#0073C2FF',
      fill = '#0073C2FF'
    ) +
    geom_bar(
      aes(y = OST2),
      alpha = 1,
      stat = "identity",
      position = "dodge",
      width = 0.7,
      colour = '#CD534CFF',
      fill = '#CD534CFF'
    ) +
    geom_point(
      data = my_dt %>% filter(OSS == 1),
      aes(x = ID, y = OST + 0.8),
      pch = 4,
      size = 2
    ) +
    geom_segment(
      data = my_dt %>% filter(OSS == 0),
      aes(
        x = ID,
        xend = ID,
        y = OST + 0.7,
        yend = OST + 1.3
      ),
      size = 1,
      arrow = arrow(type = "closed", length = unit(0.05, "in"))
    ) +
    geom_point(aes(x = ID, y = OSTF, col = as.factor(OSF)), size = 2) +
    coord_flip() +
    labs(
      fill = "PFS",
      colour = cax,
      shape = "AlloHSCT",
      x = xax,
      y = yax
    ) +
    theme(
      legend.title = element_text(size = 14),
      legend.text = element_text(size = 10),
      panel.background = element_blank(),
      axis.ticks.y = element_blank(),
      axis.text.y = element_blank(),
      axis.title.x = element_text(
        color = "black",
        size = 15,
        angle = 0,
        hjust = .5,
        vjust = .5,
        face = "plain"
      ),
      axis.title.y = element_text(
        color = "black",
        size = 15,
        angle = 90,
        hjust = .5,
        vjust = .5,
        face = "plain"
      )
    )
  
  
}






wf_plot <- function(my_dt, Before, After, Strata, yax, fax, xax) {
  my_dt$Before
  my_dt$After
  my_dt$Strata
  my_dt$id <-  1:nrow(my_dt)
  
  my_dt <- my_dt %>%
    dplyr::mutate(Change = Before - After,
                  ChangePercentage  = ((Change / Before) * 100) * -1)
  
  my_dt$id <-
    factor(my_dt$id, levels = my_dt$id[order(my_dt$ChangePercentage, decreasing = TRUE)])
  
  my_dt <- filter(my_dt, !is.na(Before))
  
  ggplot(data = my_dt, aes(x = id, y = ChangePercentage, fill = Strata)) +
    geom_bar(stat = "identity") +
    theme_classic() +
    # expand_limits(y=c(-100, 100)) +
    labs(fill = fax, x = xax, y = yax) +
    theme(
      legend.title = element_text(size = 14),
      legend.text = element_text(size = 10),
      panel.background = element_blank(),
      axis.ticks.x = element_blank(),
      axis.text.x = element_blank()
    )
  
}


# Server part
shinyServer(function(input, output, session) {
  # Creating dataset for swplot
  Main_time = rep(25:34, 3)
  Add_time = rep(10:14, 6)
  Fact_time = sample(1:30, replace = TRUE)
  Fact_stat = rep(c("CR", "PR", "SD"), 10)
  Death_1_0 = rep(rep(1:0, 15))
  
  df1 = data.frame(
    Main_time = Main_time,
    Add_time = Add_time,
    Fact_time = Fact_time,
    Fact_stat = Fact_stat,
    Death_1_0 = Death_1_0
  )
  
  
  
  datavalues <- reactiveValues(data = df1)
  
  # returns rhandsontable type object - editable excel type grid data
  output$table <- renderRHandsontable({
    rhandsontable(df1, readOnly = FALSE)
  })
  
  # on click of button the file will be saved to the working directory
  
  observeEvent(input$table$changes$changes, # observe if any changes to the cells of the rhandontable
               {
                 datavalues$data <- hot_to_r(input$table) # convert the rhandontable to R data frame object so manupilation / calculations could be done
                 
               })
  
  
  # Creating dataset for WFplot
  Before = rep(25:34, 6)
  After = rep(20:49, 2)
  Strata  = rep(c("Nivo", "BV", "Chemo"), 20)
  dfwf <- data.frame(Before, After, Strata)
  
  
  datavalues_wf <- reactiveValues(data = dfwf)
  
  
  output$table2 <- renderRHandsontable({
    rhandsontable(dfwf, readOnly = FALSE)
  })
  
  
  
  observeEvent(input$table2$changes$changes, # observe if any changes to the cells of the rhandontable
               {
                 datavalues_wf$data <- hot_to_r(input$table2) # convert the rhandontable to R data frame object so manupilation / calculations could be done
                 
               })
  
  
  output$menu <- renderMenu({
    sidebarMenu(
      menuItem(
        "Swimmer plot",
        icon = icon("line-chart"),
        tabName = "dashboard"
      ),
      menuItem(
        "Waterfall plot",
        icon = icon("line-chart"),
        tabName = "wf_tab"
      ),
      menuItem("Помощь", tabName = "widgets", icon = icon("info")),
      menuItem("О проекте", icon = icon("user"), tabName = "author")
    )
    
  })
  
  # Render swplot
  output$plot2 <- renderPlot(
    width = function()
      input$width,
    height = function()
      input$height,
    res = 96,
    
    {
      sw_plot(
        my_dt = datavalues$data,
        OST  = datavalues$data$Main_time,
        OST2 = datavalues$data$Add_time,
        OSS  = datavalues$data$Death_1_0,
        OSTF = datavalues$data$Fact_time,
        OSF  = datavalues$data$Fact_stat,
        xax = req(input$text1),
        yax = req(input$text2),
        cax = req(input$text3)
      )
      
    }
  )
  
  # Render wfplot
  output$wf_plot <- renderPlot(
    width = function()
      input$wf_width,
    height = function()
      input$wf_height,
    res = 96,
    
    {
      wf_plot(
        my_dt = datavalues_wf$data,
        Before = datavalues_wf$data$Before,
        After = datavalues_wf$data$After,
        Strata = datavalues_wf$data$Strata,
        xax = req(input$wf_text1),
        yax = req(input$wf_text2),
        fax = req(input$wf_text3)
      )
      
    }
  )
  
  
})