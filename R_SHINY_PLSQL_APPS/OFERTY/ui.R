library(shiny)
library(DT)

shinyUI
(
  fluidPage(
    titlePanel("IT JOB OFFERS"),
    sidebarLayout(
      sidebarPanel( 
        br(),
        uiOutput("out_cities_list"),
        uiOutput("out_tech_list"),
        dateInput(inputId="in_date_from",label="DATA POCZĄTKOWA"),
        dateInput(inputId="in_date_to",label="DATA KOŃCOWA"),
        actionButton(inputId="in_commit_plot",label="ZATWIERDŹ")),
      mainPanel(
        tabsetPanel(type="tab",
                    tabPanel("MIASTA",
                             br(),
                             br(),
                             actionButton(inputId="in_show_cities",label="POKAŻ MIASTA"),
                             actionButton(inputId="in_hide_cities",label="UKRYJ MIASTA"),
                             br(),
                             br(),
                             tableOutput("out_v_show_cities"),
                             br(),
                             h4("WPROWADŹ MIASTO"),
                             br(),
                             textInput(inputId="in_new_city",label="MIASTO"),
                             textInput(inputId="in_city_code",label="KOD"),
                             actionButton(inputId="in_confirm_city",label="ZATWIERDŹ"),
                             br(),
                             br(),
                             textOutput("out_add_city")
                    ),
                    tabPanel("TECHNOLOGIE",
                             br(),
                             br(),
                             actionButton(inputId="in_show_tech",label="POKAŻ TECHNOLOGIE"),
                             actionButton(inputId="in_hide_tech",label="UKRYJ TECHNOLOGIE"),
                             br(),
                             br(),
                             tableOutput("out_v_show_tech"),
                             br(),
                             h4("WPROWADŹ TECHNOLOGIĘ"),
                             br(),
                             textInput(inputId="in_new_tech",label="TECHNOLOGIA"),
                             textInput(inputId="in_tech_code",label="KOD"),
                             actionButton(inputId="in_confirm_technology",label="ZATWIERDŹ"),
                             br(),
                             br(),
                             textOutput("out_add_tech")
                             
                    ),
                    tabPanel("OFERTY",
                             br(),
                             br(),
                             actionButton(inputId="in_scrap_all_data",label="POBIERZ DANE"),
                             br(),
                             br(),
                             actionButton(inputId="in_show_today_data",label="POKAŻ DZISIEJSZE DANE"),
                             actionButton(inputId="in_hide_today_data",label="UKRYJ DANE"),
                             br(),
                             br(),
                             dataTableOutput("out_v_show_today"),
                             textOutput("out_register_data")
     
                    ),
                    tabPanel("WYKRESY",
                             # br(),
                             # uiOutput("out_cities_list"),
                             # uiOutput("out_tech_list"),
                             # dateInput(inputId="in_date_from",label="DATA POCZĄTKOWA"),
                             # dateInput(inputId="in_date_to",label="DATA KOŃCOWA"),
                             # actionButton(inputId="in_commit_plot",label="ZATWIERDŹ"),
                             #tableOutput("test_tabela"),
                             #textOutput("test"),
                             plotOutput("output_plot",width = "100%", height = "600px")
                    )
                    
                    
                    
                    
                    
                    
                    
                    
        )
        
        
        
      )
    )
  )
)
