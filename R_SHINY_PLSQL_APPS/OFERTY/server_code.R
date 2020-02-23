library(shiny)
library(RJDBC)
library(rvest)
library(XML)
library(DT)

shinyServer(
  function(input,output){
    
    ## Setting up connection
    jdbcDriver <- JDBC("oracle.jdbc.OracleDriver",classPath="C:/Users/Wojtek/Desktop/ojdbc6.jar")
    
    ## Global connection variable
    gv_con <- dbConnect(jdbcDriver, "jdbc:oracle:thin:@//localhost:1521/xe", "PRACUJ", "pracuj")
    
    
    ####################################
    ##########   SCRAPER ##############
    
    scrap_offers_count <- function(city,technology){
      
      url0 <- "https://www.pracuj.pl/praca/"
      url1 <- paste0(url0,technology,";kw/",city,";wp")
      
      result <- 
        url1 %>% read_html() %>% html_nodes("span.results-header__offer-count-text-number") %>% html_text()
      
      if(length(result)==0){
        return(0)
      }else {
        return(as.numeric(result))
      }
      
    }
    
    ########################################
    
    ####################################
    ##########  API_ADD_CITY ##############
    
    
    api_add_city <- function(city,code){
      
      q <- paste0("DECLARE
                  BEGIN
                  PCG_PRACUJ_PARAMS.PRACUJ_ADD_CITY('",city,"','",code,"');
                  END;
                  ")
      
      r <- try(dbSendUpdate(gv_con,q),silent=TRUE)
      
      if(length(r)==0){
        return("DODANO REKORD DO TABELI")
      }else{
        return("WYSTĄPIŁ BŁĄD - NIE DODANO REKORDU DO TABELI")
      }
      
    }
    
    ######################################
    ##########  API_ADD_TECH ##############
    
    
    api_add_tech <- function(tech,code){
      
      q <- paste0("DECLARE
                  BEGIN
                  PCG_PRACUJ_PARAMS.PRACUJ_ADD_TECH('",tech,"','",code,"');
                  END;
                  ")
      
      r <- try(dbSendUpdate(gv_con,q),silent=TRUE)
      
      if(length(r)==0){
        return("DODANO REKORD DO TABELI")
      }else{
        return("WYSTĄPIŁ BŁĄD - NIE DODANO REKORDU DO TABELI")
      }
      
    }
    
    ########################################
    
    
    ##################################################
    ##########  API_REGISTER_DAILY_DATA ##############    
    
    api_register_data <- function(in_xml){
      
      in_xml<-gsub("\n","",in_xml)
      
      q<-paste0("DECLARE
                  lxXML XMLTYPE;
                BEGIN
                  lxXML:=XMLTYPE('",in_xml,"');
                  PCG_PRACUJ_PARAMS.PRACUJ_REGISTER_DAILY_DATA(lxXML);
                END;
                ")
      
      r <- try(dbSendUpdate(gv_con,q),silent=TRUE)
      
      if(length(r)==0){
        return("ZAKOŃCZONO POMYŚLNIE")
      }else{
        return("WYSTĄPIŁ BŁĄD")
      }
      
    }
    
    
    
    #####################################################
    ####################################################
    ##############   REAL SERVER CODE #################
    
    
    
    ########### ADD CITY ##########
    
    observeEvent(input$in_confirm_city,{
      
      o_add_city <- api_add_city(input$in_new_city,input$in_city_code)
      output$out_add_city <- renderText(o_add_city)
      
    })
    
    #########################################	
    #########################################
    
    ###### ADD TECH ########
    
    observeEvent(input$in_confirm_technology,{
      
      o_add_tech <- api_add_tech(input$in_new_tech,input$in_tech_code)
      output$out_add_tech <- renderText(o_add_tech)
      
    })
    
    
    ########### SHOW CITIES ################
    
    observeEvent(input$in_show_cities,{
      
      o_v_show_cities <- dbGetQuery(gv_con,"SELECT * FROM V_SHOW_CITIES")
      output$out_v_show_cities <- renderTable(o_v_show_cities,rownames=F)
      
    })
    
    
    ####### SHOW TECHNOLOGIES ####
    
    observeEvent(input$in_show_tech,{
      
      o_v_show_tech <- dbGetQuery(gv_con,"SELECT * FROM V_SHOW_TECH")
      output$out_v_show_tech <- renderTable(o_v_show_tech,rownames=F)
      
    })  
    
    
    ######## SHOW TODAY'S DATA #######
    
    observeEvent(input$in_show_today_data,{
      
      o_v_show_today <- dbGetQuery(gv_con,"SELECT MIASTO,TECHNOLOGIA,TO_CHAR(LICZBA,'FM99999990') LICZBA
                                   FROM V_SHOW_DAY_CITY_OFFER WHERE TRUNC(DATA)=TRUNC(SYSDATE)")
      
      o_v_show_today$MIASTO <- as.factor(o_v_show_today$MIASTO)
      o_v_show_today$TECHNOLOGIA <- as.factor(o_v_show_today$TECHNOLOGIA)
      
      output$out_v_show_today <- renderDataTable({o_v_show_today},filter="top",rownames=F)
      
    })
    
    
    ########## HIDE CITIES ###############
    
    observeEvent(input$in_hide_cities,{
      
      output$out_v_show_cities <- renderTable(NULL)
      
    })
    

    ########## HIDE TECHNOLOGIES ###############
    
    observeEvent(input$in_hide_tech,{
      
      output$out_v_show_tech <- renderTable(NULL)
      
    })

    ########## HIDE TODAY'S DATA ###############
    
    observeEvent(input$in_hide_today_data,{
      
      output$out_v_show_today <- renderDataTable(NULL)
      
    })  
    
    
    
    ####### SCRAP DATA ##################
    
    observeEvent(input$in_scrap_all_data,{
      
      df_city_tech <- dbGetQuery(gv_con,"SELECT * FROM V_PROCESS_CITY_TECH")
      
      offer_counter <- c()
      for(i in 1:nrow(df_city_tech)){
        offer_counter[i]<-scrap_offers_count(city=df_city_tech$CITY_CODE[i],technology=df_city_tech$TECH_CODE[i])
      }
      
      df_city_tech$count <- offer_counter
      
      x <- xmlTree("OFFERS")
      for(i in 1:nrow(df_city_tech)){
        x$addTag("OFFER",close=F)
        x$addTag("ID_CITY_TECH",df_city_tech$ID[i],close=T)
        x$addTag("COUNTER",df_city_tech$count[i],close=T)
        x$closeTag()
      }
      
      o_xml<-saveXML(x$value())
      
      o_register_data <- api_register_data(o_xml)
      
      output$out_register_data <- renderText(o_register_data)
      
    })
    
    
        
    
  }
      )
