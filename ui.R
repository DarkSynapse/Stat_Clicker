library(shiny)
library(rhandsontable)
library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = "Stat Clicker"),
  
  dashboardSidebar(
    sidebarMenuOutput("menu")
  ),
  
  dashboardBody(
    tabItems(
      
      # Swimmer plot
      tabItem(tabName = "dashboard",
              fluidRow(
                box(plotOutput("plot2")),
                box(
                  br(),
                  sliderInput("height", "Высота", min = 100, max = 1000, value = 600),
                  sliderInput("width", "Ширина", min = 100, max = 1500, value = 600),
                  textInput("text1", "Ось X:", "Пациенты"),
                  textInput("text2", "Ось Y:", "Время"),
                  textInput("text4", "Название синей полосы:", "Общая выживаемость"),
                  textInput("text5", "Название красной полосы:", "БПВ"),
                  textInput("text6", "Название бирюзовой полосы:", "Событие"),
                  rHandsontableOutput("table")
                )
              )
      ),
      
      # Waterfall plot
      tabItem(tabName = "wf_tab",
              fluidRow(
                box(width = 12, plotOutput("wf_plot", height = "100%", width = "100%")),
                box(
                  br(),
                  sliderInput("wf_height", "Высота", min = 100, max = 1000, value = 500),
                  sliderInput("wf_width", "Ширина", min = 100, max = 1500, value = 1000),
                  textInput("wf_text1", "Ось X:", "Пациенты"),
                  textInput("wf_text2", "Ось Y:", "Изменение от исходного значения (%)"),
                  textInput("wf_text3", "Легенда:", "Группы"),
                  rHandsontableOutput("table2")
                )
              )
      ),
      
      # Forest plot
      tabItem(tabName = "forest_tab",
              fluidRow(
                box(width = 12, plotOutput("forest_plot", height = "100%", width = "100%")),
                box(
                  br(),
                  sliderInput("forest_height", "Высота", min = 100, max = 1000, value = 350),
                  sliderInput("forest_width", "Ширина", min = 100, max = 1500, value = 700),
                  textInput("xticks_forest", "Метки по оси X (через запятую):", "0.1, 0.5, 1, 2, 3"),
                  helpText("Внесите данные для Forest Plot:"),
                  rHandsontableOutput("table3"),
                  h6("Factor — название переменной"),
                  h6("HR — hazard ratio"),
                  h6("Lower — нижняя граница CI"),
                  h6("Upper — верхняя граница CI"),
                  h6("pval — p-value"),
                  h6("Highlight — выделение цветом (Да/Нет)")
                )
              )
      ),
      
      tabItem(tabName = "widgets",
              fluidRow(
                box(title = "Swimmer Plot", width = 12, collapsible = TRUE, collapsed = FALSE,
                    h5("Свиммер плот — график длительности событий для каждого пациента."),
                    h6("Main_time: основная длительность события (например, общая выживаемость)."),
                    h6("Add_time: дополнительная длительность (например, БПВ)."),
                    h6("Extra_time: третья длительность (например, до прогрессии)."),
                    h6("Fact_time: момент наступления события (например, ответ на терапию)."),
                    h6("Fact_stat: статус события для цветовой маркировки."),
                    h6("Death_1_0: 1 — смерть (крестик), 0 — жив (стрелка).")
                ),
                
                box(title = "Waterfall Plot", width = 12, collapsible = TRUE, collapsed = TRUE,
                    h5("Водопадный график — изменение размера опухоли по сравнению с началом терапии."),
                    h6("Before: исходный размер."),
                    h6("After: размер после лечения."),
                    h6("Strata: группа терапии (цвета столбиков).")
                ),
                
                box(title = "Forest Plot", width = 12, collapsible = TRUE, collapsed = TRUE,
                    h5("Форест плот — оценка факторов риска."),
                    h6("Factor: название фактора или группы."),
                    h6("HR: Hazard Ratio."),
                    h6("Lower: нижняя граница 95% доверительного интервала."),
                    h6("Upper: верхняя граница 95% доверительного интервала."),
                    h6("pval: p-value."),
                    h6("Highlight: выберите 'Да', чтобы подсветить важные факторы красным цветом.")
                )
              )
      ),
      
      tabItem(tabName = "author",
              fluidRow(
                column(width = 12,
                       box(title = "Авторы", collapsible = FALSE,
                           h4("Волков Никита Павлович")
                       )
                )
              )
      )
      
    )
  )
))
