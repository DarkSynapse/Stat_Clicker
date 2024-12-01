library(shiny)

# install.packages("rhandsontable") # install the package
library(rhandsontable) # load the package
library(shinydashboard) 



shinyUI(dashboardPage(
  dashboardHeader(title = "Stat Clicker"),
  dashboardSidebar(sidebarMenu("", sidebarMenuOutput("menu"))),
  dashboardBody(tabItems(
    tabItem(tabName = "dashboard",
            fluidRow(
              box(plotOutput("plot2")),
              box(
                br(),
                sliderInput(
                  "height",
                  "Высота",
                  min = 100,
                  max = 1000,
                  value = 350
                ),
                sliderInput(
                  "width",
                  "Ширина",
                  min = 100,
                  max = 1000,
                  value = 350
                ),
                textInput("text1", "Ось Х:", "Пациенты"),
                textInput("text2", "Ось Y:", "Время"),
                textInput("text3", "Легенда:", "Группы"),
                column(
                  9,
                  helpText("Внесите данные:"),
                  rHandsontableOutput("table"),
                  br()
                ),
                h6("Main_time - синяя полоса (например: время общей выживамости)"),
                h6(
                  "Add_time - красная полоса(например: время БПВ, или время до рецидива)"
                ),
                h6(
                  "Fact_time - координаты точек (например время от дз до ответа на терапию)"
                ),
                h6("Fact_stat - цвет точек (например тип ответа) "),
                h6(
                  "Death_1_0 - жив или мертв (ставит крестики и стрелочки в конце графика)"
                )
              )
            )),
    tabItem(tabName = "wf_tab",
            fluidRow(
              box(width = 12,
                plotOutput("wf_plot",
                  height = "100%", 
                  width = "100%")),
              box(
                br(),
                sliderInput(
                  "wf_height",
                  "Высота",
                  min = 100,
                  max = 1000,
                  value = 350
                ),
                sliderInput(
                  "wf_width",
                  "Ширина",
                  min = 100,
                  max = 1000,
                  value = 350
                ),
                textInput("wf_text1", "Ось Х:", "Пациенты"),
                textInput("wf_text2", "Ось Y:", "Изменение от исходного значения (%)"),
                textInput("wf_text3", "Легенда:", "Группы")),
               box(
                column(
                  9,
                  helpText("Внесите данные:"),
                  rHandsontableOutput("table2"),
                  br()
                ),
                h6("Before - объем опухоли до терапии"),
                h6("After - объем опухоли после терапии"),
                h6("Strata - факторная переменная для цвета (например терапия)"
                )
              )
            )),
    tabItem(tabName = "widgets", 
            fluidRow(
              column(width = 12,
              box(title = "Как построить Swimmer Plot",collapsible = TRUE, 
                h4("Свиммер плот – график, который идеально подходит для визуализации небольшого количества данных. Линии визуализируют конкретного пациента от исходной точки (например, начало терапии), до конца наблюдения."),
                h4("Чтобы построить график вам необходимо:"),
                h6("Main_time - синяя полоса (например: время общей выживаемости) в цифрах"),
                h6("Add_time - красная полоса (например: время БПВ, или время до рецидива), если не нужно – оставить пустым"),
                h6("Fact_time - координаты точек (например время от дз до ответа на терапию)"),
                h6("Fact_stat - цвет точек (например тип ответа), можно в виде номинативных данных"),
                h6("Death_1_0 - жив или мертв (ставит крестики и стрелочки в конце графика)"),
                h4("! Важно, если вы например хотите показать время от диагноза до ответа, то необходимо из вычесть из даты ответа, дату трансплантации, а не из даты последнего контакта")
                
              )
            ))),
    tabItem(tabName = "author", 
            fluidRow(
              column(width = 12,
                     box(title = "Авторы",collapsible = FALSE, 
                         h4("Волков Никита Павлович"),
                         h5("Врач-гематолог"),
                         h5("ПСПбГМУ им. акад. Павлова"),
                         h5("НИИ ДОГиТ им. Р.М. Горбачевой"),
                         h5("Почта: volkov.n.hem@gmail.com")
                         )
              ))
            )
    
))

))
