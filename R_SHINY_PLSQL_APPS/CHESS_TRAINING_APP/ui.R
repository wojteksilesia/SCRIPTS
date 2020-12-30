library(shiny)
library(RJDBC)
library(shinyalert)
library(DT)


shinyUI
(
  fluidPage(useShinyalert(),
            #tags$style("#out_solution_text {margin-left:90px;}"),
            tags$style("#in_random_position_button {margin-left:65px;}"),
            tags$style("#in_solution {width:250px; height:300px;resize:None;}"),
            tags$style("#out_diagram_players {margin-left:90px;font-weight: bold;}"),
            tags$style("#out_on_move {margin-left:120px;font-style: italic;}"),
            #tags$style("#out_solution_text {text-align:justify;float:left;display:inline,width:49%}"),
            #tags$style("#out_diagram_interface {float:left;display:inline,width:49%}"),
            tags$style("#out_solution_text {text-align:justify;height:400px;}"),
            tags$style("#out_show_solution_button {margin-left:105px;}"),
    titlePanel("DAILY CHESS TRAINING"),
    sidebarLayout(
      sidebarPanel(width=2,
                   tags$img(src="logo.png",width=50,height=50)),
      mainPanel(
        tabsetPanel(type="tab",
                    tabPanel("OPENINGS PRACTICE",
                             br(),
                             br(),
                             tabsetPanel(type="tab",
                                         tabPanel("ADD NEW OPENING",
                                                  br(),
                                                  br(),
                                                  textInput(inputId="in_new_opening",label="NEW OPENING",value=""),
                                                  selectInput(inputId="in_new_color",label="COLOR",choices=c("WHITE","BLACK")),
                                                  br(),
                                                  actionButton(inputId="in_add_opening_button",label="SUMBIT"),
                                                  textOutput("out_msg")
                                                  ),
                                         tabPanel("REPEAT TODAY",
                                                  br(),
                                                  br(),
                                                  actionButton(inputId="in_repeat_today",label="SHOW"),
                                                  br(),
                                                  br(),
                                                  tableOutput("out_repeat_today")
                                                  ),
                                         tabPanel("DONE TODAY",
                                                  br(),
                                                  br(),
                                                  actionButton(inputId="in_done_today",label="SHOW"),
                                                  br(),
                                                  br(),
                                                  tableOutput("out_done_today")
                                                  ),
                                         tabPanel("MARK AS DONE",
                                                  br(),
                                                  br(),
                                                  uiOutput("out_view_openings"),
                                                  dateInput(inputId="in_done_day",label="DATE",value=Sys.Date(),format="dd-mm-yyyy"),
                                                  br(),
                                                  actionButton(inputId="in_set_done_button",label="MARK AS DONE")
                                                  ),
                                         tabPanel("REPEAT TOMORROW",
                                                  br(),
                                                  br(),
                                                  actionButton(inputId="in_repeat_tomorrow",label="SHOW"),
                                                  br(),
                                                  br(),
                                                  tableOutput("out_repeat_tomorrow")
                                                  ),
                                         tabPanel("DONE YESTERDAY",
                                                  br(),
                                                  br(),
                                                  actionButton(inputId="in_done_yesterday",label="SHOW"),
                                                  br(),
                                                  br(),
                                                  tableOutput("out_done_yesterday")
                                                  ),
                                         tabPanel("MISSING",
                                                  br(),
                                                  br(),
                                                  actionButton(inputId="in_show_missed",label="SHOW"),
                                                  br(),
                                                  br(),
                                                  textOutput("out_total_lag_days"),
                                                  br(),
                                                  tableOutput("out_delay_df")
                                                  ),
                                         tabPanel("RAWDATA",
                                                  br(),
                                                  br(),
                                                  actionButton(inputId="in_show_rawdata",label="SHOW RAWDATA"),
                                                  br(),
                                                  br(),
                                                  dataTableOutput("out_rawdata")
                                                  )
                                         )
                             ),
                    tabPanel("MIDDLEGAME EXERCISES",
                             br(),
                             br(),
                             tabsetPanel(type="tab",
                                         tabPanel("RANDOM TRAINING",
                                                  br(),
                                                  br(),
                                                  actionButton(inputId="in_random_position_button",label="GET RANDOM TRAINING POSITION"),
                                                  br(),
                                                  br(),
                                                  textOutput("out_diagram_players"),
                                                  #htmlOutput("out_diagram_players"),
                                                  #br(),
                                                  splitLayout(cellWidths = c("40%", "60%"),
                                                    uiOutput("out_diagram_interface"),
                                                    htmlOutput("out_solution_text"),
                                                    cellArgs = list(style='white-space: normal;')
                                                  ),
                                                  #br(),
                                                  textOutput("out_on_move"),
                                                  br(),
                                                  br(),
                                                  uiOutput("out_show_solution_button"),
                                                  br()
                                                  #textOutput("out_solution_text")
                                                  #htmlOutput("out_solution_text")
                                                  ),
                                         tabPanel("ADD NEW POSITION",
                                                  br(),
                                                  br(),
                                                  fileInput(inputId="in_input_file", label="UPLOAD DIAGRAM", accept = c('image/png', 'image/jpeg')),
                                                  br(),
                                                  selectInput(inputId="in_on_move",label="ON MOVE",choices=c("WHITE","BLACK")),
                                                  br(),
                                                  textInput(inputId="in_players",label="PLAYERS",value=""),
                                                  br(),
                                                  textAreaInput(inputId="in_solution",label="SOLUTION",value=""),
                                                  br(),
                                                  actionButton(inputId="in_add_picture_button",label="ADD POSITION")
                                                  )
                                         
                                         )
                             
                             ),
                    tabPanel("LET'S PLAY TODAY",
                             br(),
                             br(),
                             actionButton(inputId="id_roll_the_dice",label="CHOOSE TODAY'S REPERTOIRE"),
                             br(),
                             br(),
                             htmlOutput("out_repertoire")
                             )
                    )

      )
    )
  )
)
