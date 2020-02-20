library(shiny)
library(shinyjs)
library(shinyalert)
library(shinythemes)
library(DT)

shinyUI(
  fluidPage(useShinyjs(), useShinyalert(),theme=shinytheme("spacelab"),
            titlePanel(h2("SYMULATOR 2019/2020")),
            sidebarLayout(
              sidebarPanel(h4("PARAMETRY",align="center"),
                           br(),
                           sliderInput(inputId="in_scenarios",label="Liczba scenariuszy",min=0,max=50000,step=100,value=100,ticks=FALSE,sep=" "),
                           textInput(inputId="in_text_scenarios",label=NULL,value=100),
                           selectInput(inputId="in_league",label="Poziom",choices=c("Ekstraklasa"=0,"Fortuna I liga"=1,"II liga"=2,"III liga gr. 3"=3),selectize=TRUE),
                           radioButtons(inputId="in_stage",label="Faza sezonu",choices=c("Po podziale"=FALSE,"Zasadnicza"=TRUE)),
                           textInput(inputId="in_fall_down",label="Spadek",value="3"),
                           textInput(inputId="in_promoted",label="Mistrzostwo/awans",value="1"),
                           textInput(inputId="in_chmp_group",label="Grupa mistrzowska",value=8),
                           textInput(inputId="in_cups",label="Europejskie puchary",value=3),
                           textInput(inputId="in_playoff",label="Faza playoff",value="6"),
                           selectInput(inputId="in_method",label="Metoda symulacji",choices=c("Rozkład jednostajny"=FALSE,"Model bayesowski"=TRUE),selectize=TRUE),
                           actionButton(inputId="in_button",label="URUCHOM SYMULACJĘ"),
                           actionButton(inputId="in_button_2",label="WYCZYŚĆ WYNIKI")
              ),
              mainPanel(
                tabsetPanel(type="tab",
                            tabPanel("SYMULACJA",tableOutput("out_df")),
                            tabPanel("WYNIKI MECZÓW (BAYES)",dataTableOutput("out_probs"))
                            )
                
                        )
                       )
  )
)
