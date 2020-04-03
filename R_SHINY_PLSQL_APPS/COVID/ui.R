library(shiny)
library(shinyjs)
library(shinythemes)
library(httr)
library(ggplot2)
library(dplyr)
library(utils)

shinyUI
(
  fluidPage(useShinyjs(),theme=shinytheme("flatly"),
            titlePanel("COVID-19"),
            sidebarLayout(
              sidebarPanel(
                #br(),
                numericInput(inputId="id_number",label="Ile krajów pokazać",
                             value=3,min=1,max=3,step=1),
                uiOutput("out_country_1"),
                uiOutput("out_country_2"),
                uiOutput("out_country_3"),
                textInput(inputId="in_day_0",label="DZIEŃ 0 (LICZBA ZAKAŻONYCH)"),
                radioButtons(inputId="id_x_axis",label="OŚ X",choices=c("DATA","DZIEŃ 0")),
                radioButtons(inputId="id_y_axis",
                             label="OŚ Y",
                             choices=c("ZACHOROWANIA","SUMA ZACHOROWAŃ",
                                       "DYNAMIKA ZACHOROWAŃ","ZGONY","SUMA ZGONÓW")),
                actionButton(inputId="in_button",label="POKAŻ")),
              mainPanel(plotOutput("out_plot"))
            )
  )
)
