library(shiny)
library(RJDBC)
library(shinyjs)
library(XML)
library(DT)

shinyUI
(
  fluidPage(useShinyjs(),
    titlePanel("APLIKACJA ZAKUPOWA"),
    sidebarLayout(
      sidebarPanel(
        actionButton(inputId="in_show_cities",label="POKAŻ MIASTA"),
        br(),
        br(),
        actionButton(inputId="in_show_retailers",label="POKAŻ SIECI"),
        br(),
        br(),
        actionButton(inputId="in_show_shops",label="POKAŻ SKLEPY"),
        br(),
        br(),
        actionButton(inputId="in_show_product_types",label="POKAŻ KATEGORIE PRODUKTÓW"),
        br(),
        br(),
        actionButton(inputId="in_show_products",label="POKAŻ PRODUKTY")
      ),
      mainPanel(
        tabsetPanel(type="tab",
                    tabPanel("MIASTA",
                             br(),
                             textInput(inputId="in_new_city",label=" WPROWADŹ MIASTO"),
                             br(),
                             actionButton(inputId="in_commit_city",label="ZATWIERDŹ"),
                             br(),
                             br(),
                             textOutput("out_add_city_error"),
                             br(),
                             br(),
                             tableOutput("out_cities_df")
                    ),
                    tabPanel("SIECI",
                             br(),
                             textInput(inputId="in_new_retailer",label="WPROWADŹ SIEĆ"),
                             br(),
                             actionButton(inputId="in_commit_retailer",label="ZATWIERDŹ"),
                             br(),
                             br(),
                             textOutput("out_add_retailer_error"),
                             br(),
                             br(),
                             tableOutput("out_retailers_df")
                    ),
                    tabPanel("SKLEPY",
                             br(),
                             uiOutput("out_view_retailers"),
                             textInput(inputId="in_address",label="ADRES",value="Ul."),
                             uiOutput("out_view_cities"),
                             br(),
                             actionButton(inputId="in_commit_shop",label="ZATWIERDŹ"),
                             br(),
                             br(),
                             textOutput("out_add_shop_error"),
                             br(),
                             br(),
                             tableOutput("out_shops_df")
                    ),
                    tabPanel("KATEGORIE PRODUKTÓW",
                             br(),
                             textInput(inputId="in_new_product_type",label="DODAJ KATEGORIĘ PRODUKTU"),
                             br(),
                             actionButton(inputId="in_commit_product_type",label="ZATWIERDŹ"),
                             br(),
                             br(),
                             textOutput("out_add_product_type_error"),
                             br(),
                             br(),
                             tableOutput("out_product_types_df")

                    ),
                    tabPanel("PRODUKTY",
                             br(),
                             textInput(inputId="in_new_product",label="NAZWA/OPIS PRODUKTU"),
                             uiOutput("out_view_product_types"),
                             br(),
                             actionButton(inputId="in_commit_new_product",label="DODAJ PRODUKT"),
                             br(),
                             br(),
                             textOutput("out_add_new_product_error"),
                             br(),
                             br(),
                             tableOutput("out_products_df")
                             
                             
                    ),
                    tabPanel("LISTA ZAKUPÓW",
                             br(),
                             dateInput(inputId="in_shopping_date",label="DATA ZAKUPÓW",format="yyyy-mm-dd"),
                             uiOutput("out_view_process_shops"),
                             actionButton(inputId="in_commit_setup",label="ZATWIERDŹ"),
                             br(),
                             br(),
                             uiOutput("out_view_process_products"),
                             uiOutput("out_hidden_price"),
                             uiOutput("out_hidden_weight"),
                             uiOutput("out_commit_single"),
                             br(),
                             uiOutput("out_commit_list"),
                             br(),
                             uiOutput("out_clear_interface"), ## test
                             br(),
                             tableOutput("out_df_shopping"),
                             textOutput("out_add_shopping_list_error")
                             
                    
                    ),
                    tabPanel("WYDATKI",
                             br(),
                             actionButton(inputId="in_show_expenditures",label="POKAŻ LISTĘ"),
                             br(),
                             br(),
                             dataTableOutput("out_expenditures")
                    ),
                    tabPanel("WYDATKI - PRODUKTY",
                              br(),
                             #actionButton("in_exp_last_7_days",label="OSTATNIE 7 DNI"),
                             #br(),
                             #br(),
                             #actionButton("in_exp_current_week",label="BIEŻĄCY TYDZIEŃ"),
                             #br(),
                             #br(),
                             #("WYDATKI ZA OSTATNIE ... DNI"),
                             numericInput(inputId="in_exp_days",label="WYDATKI ZA OSTATNIE ... DNI",
                                          value=7,min=0,max=50000,step=1),
                             actionButton(inputId="in_show_exp_view",label="POKAŻ LISTĘ"),
                             br(),
                             br(),
                             br(),
                             br(),
                             h4("LUB PODAJ ZAKRES DAT"),
                             br(),
                             br(),
                             dateInput(inputId="in_start_date",label="DATA POCZĄTKOWA",format="yyyy-mm-dd"),
                             dateInput(inputId="in_end_date",label="DATA KOŃCOWA",format="yyyy-mm-dd"),
                             actionButton(inputId="in_show_exp_view_dates",label="POKAŻ LISTĘ"),
                             br(),
                             br(),
                             tableOutput("out_exp_param")
                             
                    )
        )
      )
    )
  )
)
