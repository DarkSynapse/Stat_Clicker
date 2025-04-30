# server.R

library(shiny)
library(rhandsontable)
library(dplyr)
library(ggplot2)
library(tidyr)
library(forestplot)
library(grid)  # для gpar()

# ——— SWIMMER PLOT ————————————————————————————————————————————————
sw_plot <- function(my_dt, xax, yax, legend_names) {
  
  my_dt <- my_dt %>%
    filter(!is.na(Main_time)) %>%
    mutate(ID = factor(row_number(), levels = row_number()[order(Main_time)]))
  
  plot_data <- my_dt %>%
    pivot_longer(cols = c(Main_time, Add_time, Extra_time), names_to = "Type", values_to = "Time")
  
  plot_data$Type <- recode(plot_data$Type,
                           Main_time = legend_names[1],
                           Add_time = legend_names[2],
                           Extra_time = legend_names[3])
  
  # Цвета для полос
  custom_colors <- setNames(
    c('#0073C2FF', '#CD534CFF', '#00A087FF'),
    legend_names
  )
  
  # Автоматическая генерация цветов для всех уровней Fact_stat
  fact_levels <- unique(my_dt$Fact_stat)
  n_levels <- length(fact_levels)
  
  # Создаём красивую палитру автоматически
  fact_colors <- setNames(
    colorRampPalette(c("darkred", "black", "purple", "blue", "darkgrey"))(n_levels),
    fact_levels
  )
  
  ggplot(plot_data, aes(x = ID, y = Time, fill = Type)) +
    geom_bar(stat = "identity", width = 0.7, position = "identity") +
    
    geom_point(data = filter(my_dt, Death_1_0 == 1), aes(x = ID, y = Main_time + 0.8), shape = 4, size = 2, inherit.aes = FALSE) +
    geom_segment(data = filter(my_dt, Death_1_0 == 0),
                 aes(x = ID, xend = ID, y = Main_time + 0.7, yend = Main_time + 1.3),
                 size = 1,
                 arrow = arrow(type = "closed", length = unit(0.05, "in")),
                 inherit.aes = FALSE) +
    
    geom_point(data = my_dt, aes(x = ID, y = Fact_time, color = Fact_stat), size = 1.7, inherit.aes = FALSE) +
    
    scale_fill_manual(values = custom_colors) +
    scale_color_manual(values = fact_colors) +
    coord_flip() +
    labs(fill = "", color = "", x = xax, y = yax) +
    theme_classic() +
    theme(
      legend.title = element_text(size = 14),
      legend.text = element_text(size = 10),
      axis.ticks.y = element_blank(),
      axis.text.y = element_blank(),
      axis.title = element_text(color = "black", size = 15)
    )
}

# ——— WATERFALL PLOT ———————————————————————————————————————————————
wf_plot <- function(my_dt, xax, yax, fax) {
  my_dt <- my_dt %>%
    filter(!is.na(Before)) %>%
    mutate(
      Change = Before - After,
      ChangePercentage = -100 * Change / Before,
      id = factor(row_number(), levels = row_number()[order(ChangePercentage, decreasing = TRUE)])
    )
  
  ggplot(my_dt, aes(x = id, y = ChangePercentage, fill = Strata)) +
    geom_bar(stat = "identity") +
    labs(fill = fax, x = xax, y = yax) +
    theme_classic() +
    theme(
      legend.title = element_text(size = 14),
      legend.text = element_text(size = 10),
      axis.ticks.x = element_blank(),
      axis.text.x = element_blank()
    )
}

# ——— FOREST PLOT (с custom shapes_gp) —————————————————————————————————————————
forest_plot <- function(my_dt, xticks) {
  my_dt <- my_dt %>% filter(!is.na(Factor))
  my_dt$Highlight <- ifelse(is.na(my_dt$Highlight), "Нет", my_dt$Highlight)
  
  # table text
  hr_text <- ifelse(
    is.na(my_dt$Lower) | is.na(my_dt$Upper) | is.na(my_dt$HR),
    "Reference",
    paste0(sprintf("%.2f", my_dt$HR),
           " (", sprintf("%.2f", my_dt$Lower),
           "-", sprintf("%.2f", my_dt$Upper), ")")
  )
  pval_text <- ifelse(
    is.na(my_dt$pval), "",
    ifelse(my_dt$pval < 0.001, "< 0.001", sprintf("%.3f", my_dt$pval))
  )
  tabletext <- cbind(
    c("Фактор", my_dt$Factor),
    c("HR (95% CI)", hr_text),
    c("p-value", pval_text)
  )
  
  # numeric values
  mean_plot  <- c(NA, my_dt$HR)
  lower_plot <- c(NA, my_dt$Lower)
  upper_plot <- c(NA, my_dt$Upper)
  
  # цвета боксов/линий
  cb <- ifelse(my_dt$Highlight == "Да", "red", "black")
  lines_gp <- c(list(gpar(col="black")),
                lapply(cb, function(col) gpar(col=col)))
  box_gp   <- c(list(gpar(fill="white")),
                lapply(cb, function(col) gpar(fill=col)))
  styles   <- fpShapesGp(lines=lines_gp, box=box_gp)
  
  forestplot(
    labeltext  = tabletext,
    mean       = mean_plot,
    lower      = lower_plot,
    upper      = upper_plot,
    zero       = 1,
    xlog       = TRUE,
    shapes_gp  = styles,
    clip       = range(xticks),
    xticks     = xticks,
    boxsize    = 0.2,
    lineheight = unit(1.2, "cm"),
    graphwidth = unit(6, "cm"),
    txt_gp     = fpTxtGp(
      label = gpar(cex=0.9),
      ticks = gpar(cex=0.8),
      xlab  = gpar(cex=1),
      title = gpar(cex=1.2)
    )
  )
}

# ——— SHINY SERVER ———————————————————————————————————————————————
shinyServer(function(input, output, session) {
  
  set.seed(123)
  n <- 50
  df1 <- data.frame(
    Main_time = sample(20:60, n, replace = TRUE),
    Add_time  = sample(5:30,  n, replace = TRUE),
    Extra_time= sample(5:25,  n, replace = TRUE),
    Fact_time = sample(1:60,  n, replace = TRUE),
    Fact_stat = sample(c("CR","PR","SD","PD"), n, replace = TRUE),
    Death_1_0 = sample(c(0,1),    n, replace = TRUE)
  )
  dfwf <- data.frame(
    Before = sample(20:80, n, replace = TRUE),
    After  = sample(10:70, n, replace = TRUE),
    Strata = sample(c("Nivo","BV","Chemo"), n, replace = TRUE)
  )
  df_forest <- data.frame(
    Factor    = c("Возраст <60 (Ref)","Возраст ≥60","Пол: Мужчины (Ref)","Пол: Женщины", rep(NA,11)),
    HR        = c(1,1.75,1,0.85, rep(NA,11)),
    Lower     = c(NA,1.10,NA,0.60, rep(NA,11)),
    Upper     = c(NA,2.80,NA,1.20, rep(NA,11)),
    pval      = c(NA,0.02,NA,0.40, rep(NA,11)),
    Highlight = c(NA,"Да",NA,"Нет",   rep(NA,11)),
    stringsAsFactors = FALSE
  )
  
  rv  <- reactiveValues(data = df1)
  rv2 <- reactiveValues(data = dfwf)
  rv3 <- reactiveValues(data = df_forest)
  
  # Swimmer table
  output$table  <- renderRHandsontable({ rhandsontable(rv$data) })
  observeEvent(input$table$changes$changes, { rv$data <- hot_to_r(input$table) })
  
  # Waterfall table
  output$table2 <- renderRHandsontable({ rhandsontable(rv2$data) })
  observeEvent(input$table2$changes$changes, { rv2$data <- hot_to_r(input$table2) })
  
  # Forest table (dropdown for Highlight)
  output$table3 <- renderRHandsontable({
    rhandsontable(rv3$data) %>%
      hot_col("Highlight", type="dropdown", source=c("Да","Нет"))
  })
  observeEvent(input$table3$changes$changes, { rv3$data <- hot_to_r(input$table3) })
  
  # Plots
  output$plot2 <- renderPlot({
    req(input$text1, input$text2, input$text4, input$text5, input$text6)
    sw_plot(rv$data,
            xax = input$text1,
            yax = input$text2,
            legend_names = c(input$text4, input$text5, input$text6))
  }, width = reactive(input$width), height = reactive(input$height), res = 96)
  
  output$wf_plot <- renderPlot({
    req(input$wf_text1, input$wf_text2, input$wf_text3)
    wf_plot(rv2$data,
            xax = input$wf_text1,
            yax = input$wf_text2,
            fax = input$wf_text3)
  }, width = reactive(input$wf_width), height = reactive(input$wf_height), res = 96)
  
  output$forest_plot <- renderPlot({
    req(input$xticks_forest)
    xt <- as.numeric(strsplit(input$xticks_forest, ",")[[1]])
    forest_plot(rv3$data, xticks = xt)
  }, width = reactive(input$forest_width), height = reactive(input$forest_height), res = 96)
  
  # Sidebar menu
  output$menu <- renderMenu({
    sidebarMenu(
      menuItem("Swimmer plot",   tabName="dashboard", icon=icon("chart-bar")),
      menuItem("Waterfall plot", tabName="wf_tab",    icon=icon("chart-bar")),
      menuItem("Forest plot",    tabName="forest_tab",icon=icon("chart-bar")),
      menuItem("Помощь",         tabName="widgets",   icon=icon("info")),
      menuItem("О проекте",      tabName="author",    icon=icon("user"))
    )
  })
})
