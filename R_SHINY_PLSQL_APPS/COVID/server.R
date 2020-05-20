library(shiny)
library(shinyjs)
library(httr)
library(ggplot2)
library(dplyr)


shinyServer(
  function(input,output,session){
    #########################
    ##### LOAD DATA 
    #create the URL where the dataset is stored with automatic updates every day
    #url <- paste("https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide-",format(Sys.time(), "%Y-%m-%d"), ".xlsx", sep = "")
    #download the dataset from the website to a local temporary file
    #GET(url, authenticate(":", ":", type="ntlm"), write_disk(tf <- tempfile(fileext = ".xlsx")))
    #read the Dataset sheet into “R”
    #data_covid <- read_excel(tf)
    
    GET("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv", authenticate(":", ":", type="ntlm"), write_disk(tf <- tempfile(fileext = ".csv")))
    
    #read the Dataset sheet into R. The dataset will be called "data".
    data_covid <- read.csv(tf)
    
    data_covid$dateRep <- as.POSIXct(data_covid$dateRep,format="%d/%m/%Y")
    data_covid$country=factor(data_covid$countriesAndTerritories)
    
    df_data_sorted <- data_covid %>% arrange(dateRep)
    
    ##################################################################
    
    ##### COUNTRY DATASET PREPARATION ##########################
    show_country_data <- function(input_df,input_country,input_day_0_cases){
      input_df<-input_df%>%arrange(dateRep)
      country_df <- input_df %>% filter(countriesAndTerritories==input_country)
      
      ## All COVID cases
      all_cases<-c()
      all_cases[1]<-country_df$cases[1]
      for(i in 2:nrow(country_df)){
        all_cases[i]<-all_cases[i-1]+country_df$cases[i]
      }
      country_df$all_cases<-all_cases
      
      ## All deaths
      all_deaths<-c()
      all_deaths[1]<-country_df$deaths[1]
      for(i in 2:nrow(country_df)){
        all_deaths[i]<-all_deaths[i-1]+country_df$deaths[i]
      }
      country_df$all_deaths<-all_deaths
      
      ## Cases dynamics
      cases_dynamic<-c()
      cases_dynamic[1]<-0
      for(i in 2:nrow(country_df)){
        cases_dynamic[i]<-country_df$cases[i]/country_df$cases[i-1]-1
      }
      country_df$cases_dynamic<-cases_dynamic
      
      ## Day 0
      for(i in 1:nrow(country_df)){
        if(country_df$all_cases[i]<input_day_0_cases){ 
          next
        }else{
          day_0<-country_df$dateRep[i]
          break
        }
      }
      ## Subdataset based on day_0
      country_df<-country_df%>%filter(dateRep>=day_0)
      
      ## Day number 
      country_df$day_number<-1:nrow(country_df)
      
      return(country_df)
    }
    
    ######################################################################
    
    ### PLOT PREPARATION
    print_plot<-function(in_df,x_param,y_param){
      if(x_param=="DATA"){
        if(y_param=="ZACHOROWANIA"){
          p<-ggplot(data=in_df,aes(x=dateRep,y=cases,color=country))
        }else if(y_param=="SUMA ZACHOROWAŃ"){
          p<-ggplot(data=in_df,aes(x=dateRep,y=all_cases,color=country))
        }else if(y_param=="DYNAMIKA ZACHOROWAŃ"){
          p<-ggplot(data=in_df,aes(x=dateRep,y=cases_dynamic,color=country))
        }else if(y_param=="ZGONY"){
          p<-ggplot(data=in_df,aes(x=dateRep,y=deaths,color=country))
        }else if(y_param=="SUMA ZGONÓW"){
          p<-ggplot(data=in_df,aes(x=dateRep,y=all_deaths,color=country))
        }
      }else if(x_param=="DZIEŃ 0"){
        if(y_param=="ZACHOROWANIA"){
          p<-ggplot(data=in_df,aes(x=day_number,y=cases,color=country))
        }else if(y_param=="SUMA ZACHOROWAŃ"){
          p<-ggplot(data=in_df,aes(x=day_number,y=all_cases,color=country))
        }else if(y_param=="DYNAMIKA ZACHOROWAŃ"){
          p<-ggplot(data=in_df,aes(x=day_number,y=cases_dynamic,color=country))
        }else if(y_param=="ZGONY"){
          p<-ggplot(data=in_df,aes(x=day_number,y=deaths,color=country))
        }else if(y_param=="SUMA ZGONÓW"){
          p<-ggplot(data=in_df,aes(x=day_number,y=all_deaths,color=country))
        }
      }
      
      pl <- p + geom_line(size=1.2)+ggtitle(paste("COVID-19 - ",y_param))+
        theme(plot.title = element_text(hjust=0.5,size=30,colour="blue",margin=margin(b=14)),
              axis.title.y = element_text(size=16,margin = margin(r=25)),
              axis.title.x=element_text(size=16,margin=margin(t=14)),
              legend.title=element_text(size=18,,hjust=0.5),
              legend.text = element_text(size=15),
              axis.text.x = element_text(size=13),
              axis.text.y = element_text(size=13))+
        ylab(y_param) + xlab(ifelse(x_param=="DATA","DATA","DZIEŃ"))+labs(col="KRAJ")
      
      if(x_param=="DZIEŃ 0"){
        pl<-pl+scale_x_continuous(breaks=seq(0,max(in_df$day_number)+5,by=5))
      }
      
      return(pl)
    }
    
    
    #####################################################################
    
    ### Countries list
    output$out_country_1<-renderUI({
      selectInput(inputId="in_country_list_A",label="KRAJ A",
                  choices = sort(unique(df_data_sorted$countriesAndTerritories)))
    })
    
    output$out_country_2<-renderUI({
      selectInput(inputId="in_country_list_B",label="KRAJ B",
                  choices = sort(unique(df_data_sorted$countriesAndTerritories)))
    })
    
    output$out_country_3<-renderUI({
      selectInput(inputId="in_country_list_C",label="KRAJ C",
                  choices = sort(unique(df_data_sorted$countriesAndTerritories)))
    })
    
    
    ### Disable countries list 
    
    observeEvent(input$id_number,{
      if(as.numeric(input$id_number==1)){
        disable("in_country_list_B")
        disable("in_country_list_C")
      }else if(as.numeric(input$id_number==2)){
        disable("in_country_list_C")
        enable("in_country_list_B")
      }else if(as.numeric(input$id_number==3)){
        enable("in_country_list_B")
        enable("in_country_list_C")
      }
    })
    
    ### Disable DAY 0 panel if "DATE" choosen for X axis
    observeEvent(input$id_x_axis,{
      if(input$id_x_axis=="DATA"){
        updateTextInput(session=session,inputId="in_day_0",value=0)
        disable("in_day_0")
      }else{
        enable("in_day_0")
      }
    })
    
    ### Action after submitting parameters
    observeEvent(input$in_button,{
      #### Preparing dataset
      ## Empty df structure
      submited_countries_data<-df_data_sorted %>% filter(cases==-1)
      choosen_countries<-c(input$in_country_list_A,input$in_country_list_B,input$in_country_list_C)
      for(i in 1:as.numeric(input$id_number)){
        one_country_df <-show_country_data(input_df = df_data_sorted,
                                           input_country = choosen_countries[i],
                                           input_day_0_cases =as.numeric(input$in_day_0))
        
        submited_countries_data<-rbind(submited_countries_data,one_country_df)
        
        #### Preparing the plot 
        output$out_plot<-renderPlot(print_plot(in_df=submited_countries_data,
                                               x_param=input$id_x_axis,
                                               y_param=input$id_y_axis))
      }
    })
    
    
    # observeEvent(input$in_button,{
    #   if(as.numeric(input$id_number)==1){
    #     country_a_data<-show_country_data(input_df=df_data_sorted,
    #                                       input_country=input$in_country_list_A,
    #                                       input_day_0_cases=as.numeric(input$in_day_0))
    #     
    #     if(input$id_x_axis=="DATA"){
    #       if(input$id_y_axis=="ZACHOROWANIA"){
    #         output$out_plot<-renderPlot(ggplot(data=country_a_data,aes(x=dateRep,
    #                                                                    y=cases))+geom_line())
    #       }else if(input$id_y_axis=="SUMA ZACHOROWAŃ"){
    #         output$out_plot<-renderPlot(ggplot(data=country_a_data,aes(x=dateRep,
    #                                                                    y=all_cases))+geom_line())            
    #       }else if(input$id_y_axis=="DYNAMIKA ZACHOROWAŃ"){
    #         output$out_plot<-renderPlot(ggplot(data=country_a_data,aes(x=dateRep,
    #                                                                    y=cases_dynamic))+geom_line())             
    #       }else if(input$id_y_axis=="ZGONY"){
    #         output$out_plot<-renderPlot(ggplot(data=country_a_data,aes(x=dateRep,
    #                                                                    y=deaths))+geom_line())             
    #       }else if(input$id_y_axis=="SUMA ZGONÓW"){
    #         output$out_plot<-renderPlot(ggplot(data=country_a_data,aes(x=dateRep,
    #                                                                    y=all_deaths))+geom_line())             
    #       }
    #     }
    #   }
    #   
    # })
    
  }
)

#y=country_a_data[,y_parameter]))