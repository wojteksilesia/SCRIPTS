library(shiny)
library(RJDBC)
library(shinyjs)
library(XML)
library(DT)


shinyServer(
  function(input,output){
    
    ## Setting up connection
    jdbcDriver <- JDBC("oracle.jdbc.OracleDriver",classPath="C:/Users/Wojtek/Desktop/ojdbc6.jar")
    
    ## Global connection variable
    gv_con <- dbConnect(jdbcDriver, "jdbc:oracle:thin:@//localhost:1521/xe", "WATA", "wata")
    
    
    ##################  ADD_CITY #############################
    
    add_city_exec <- function(city){
      
      q<- paste0("DECLARE
                 BEGIN
                 PCG_WATA_PARAMS.ADD_CITY('",city,"');
                 END;")
      
      result <- try(dbSendUpdate(gv_con,q),silent=TRUE)
      
      if(length(result)==0){
        return("DODANO REKORD DO TABELI")
      }else{
        return('WYSTĄPIŁ BŁĄD W FUNKCJI')
      }
    }
    
    ###############################################################
    
    ########### ADD_RETAILER ######################################
    
    
    add_retailer_exec <- function(retailer){
      
      q<- paste0("DECLARE
                 BEGIN
                 PCG_WATA_PARAMS.ADD_RETAILER('",retailer,"');
                 END;")
      
      result <- try(dbSendUpdate(gv_con,q),silent=TRUE)
      
      if(length(result)==0){
        return("DODANO REKORD DO TABELI")
      }else{
        return('WYSTĄPIŁ BŁĄD W FUNKCJI')
      }
    }
    
    ###########################################################
    ############### ADD_SHOP ##################################
    
    add_shop_exec <- function(id_retailer,address,id_city){
      
      q<- paste0("DECLARE
                 BEGIN
                 PCG_WATA_PARAMS.ADD_SHOP(",id_retailer,",'",address,"',",id_city,");
                 END;")
      
      
      result <- try(dbSendUpdate(gv_con,q),silent=TRUE)
      
      if(length(result)==0){
        return("DODANO REKORD DO TABELI")
      }else{
        return('WYSTĄPIŁ BŁĄD W FUNKCJI')
      }
    }
    
    ###########################################################
    ############### ADD_PRODUCT_TYPE ##################################
    
    add_product_type_exec <- function(product_type){
      
      q<- paste0("DECLARE
                 BEGIN
                 PCG_WATA_PARAMS.ADD_PRODUCT_TYPE('",product_type,"');
                 END;")
      
      
      result <- try(dbSendUpdate(gv_con,q),silent=TRUE)
      
      if(length(result)==0){
        return("DODANO REKORD DO TABELI")
      }else{
        return('WYSTĄPIŁ BŁĄD W FUNKCJI')
      }
    }
    
    ###########################################################
    ############### ADD_PRODUCT ##################################
    
    add_product_exec <- function(prod_desc,id_product_type){
      
      q<- paste0("DECLARE
                 BEGIN
                 PCG_WATA_PARAMS.ADD_PRODUCT('",prod_desc,"',",id_product_type,");
                 END;")
      
      
      result <- try(dbSendUpdate(gv_con,q),silent=TRUE)
      
      if(length(result)==0){
        return("DODANO REKORD DO TABELI")
      }else{
        return('WYSTĄPIŁ BŁĄD W FUNKCJI')
      }
    }
    
    ###########################################################
    ################  PROCESS SHOPLIST DF #####################
    
    df_construct <- function(df,sklep,data,produkt,cena,waga=""){
      
      df<-apply(df,2,as.character)
      df<-rbind(df,c(sklep,data,produkt,cena,waga))
      colnames(df)<-c("ID_SHOP","DATE","ID_PRODUCT","PRICE","WEIGHT")
      rownames(df)<-NULL
      return(as.data.frame(df))
    }
    
    ##########################################################
    ############# ADD_SHOPPING_LIST ##########################
    
    add_shopping_list_exec<- function(x){
      
      x<-gsub("\n","",x)
      
      q<- paste0("DECLARE
                 lxXML XMLTYPE;
                 BEGIN
                 lxXML:=XMLTYPE.CREATEXML('",x,"');
                 PCG_WATA_PARAMS.ADD_SHOPPING_LIST(lxXML);
                 END;
                 ")
      
      result <- try(dbSendUpdate(gv_con,q),silent=TRUE)
      
      if(length(result)==0){
        return("DODANO REKORD DO TABELI")
      }else{
        return('WYSTĄPIŁ BŁĄD W FUNKCJI')
      }
      
    }
    
    ########################################################
    ###############  CONVERT TO VIEW ######################
    
    convert_to_view <- function(in_df,shop_vector,product_vector){
      
      sklep <- names(shop_vector)[which(shop_vector==in_df$"ID_SHOP"[1])]
      
      produkt<-c()
      for(i in 1:nrow(in_df)){
        produkt[i]<-names(product_vector)[which(product_vector==in_df$ID_PRODUCT[i])]
      }
      
      result_df <- data.frame(SKLEP=rep(sklep,nrow(in_df)),
                              DATA=in_df$DATE,
                              PRODUKT=produkt,
                              CENA=in_df$PRICE,
                              WAGA=in_df$WEIGHT
      )
      
      return(result_df)                      
      
    }
    
    
    #########################################################
    
    ###########################################################
    ######################   REAL SERVER CODE #################
    
    ###  PROCESS VIEWS 
    
    ## Cities
    view_cities <- dbGetQuery(gv_con,"SELECT * FROM V_WATA_CITIES ORDER BY MIASTO")
    v_cities <- view_cities$ID
    names(v_cities) <- view_cities$MIASTO
    
    ## Retailers
    view_retailers <- dbGetQuery(gv_con,"SELECT * FROM V_WATA_RETAILERS ORDER BY SKLEP")
    v_retailers <- view_retailers$ID
    names(v_retailers) <- view_retailers$SKLEP
    
    ## Product types
    view_product_types<-dbGetQuery(gv_con,"SELECT * FROM V_WATA_PRODUCT_TYPES ORDER BY KATEGORIA")
    v_product_types<-view_product_types$ID
    names(v_product_types)<-view_product_types$KATEGORIA
    
    ## Shops
    view_process_shops<-dbGetQuery(gv_con,"SELECT * FROM V_WATA_PROCESS_SHOPS ORDER BY SKLEP")
    v_process_shops<-view_process_shops$ID
    names(v_process_shops)<-view_process_shops$SKLEP
    
    ## Products
    view_process_products<-dbGetQuery(gv_con,"SELECT * FROM V_WATA_PROCESS_PRODUCTS ORDER BY PRODUKT")
    v_process_products<-view_process_products$ID
    names(v_process_products)<-view_process_products$PRODUKT
    
    
    
    
    ##################################################
    
    
    ###### ADD CITY ####
    
    o_new_city<-reactive({ input$in_new_city })
    
    observeEvent(input$in_commit_city,{
      o_add_city_error<-add_city_exec(o_new_city())
      output$out_add_city_error <- renderText(o_add_city_error)
      
      ## update widoku z miastami
      view_cities <- dbGetQuery(gv_con,"SELECT * FROM V_WATA_CITIES ORDER BY MIASTO")
      v_cities <- view_cities$ID
      names(v_cities) <- view_cities$MIASTO
    })
    ################################
    
    
    ###### ADD RETAILER ####
    
    o_new_retailer<-reactive({ input$in_new_retailer })
    
    observeEvent(input$in_commit_retailer,{
      o_add_retailer_error<-add_retailer_exec(o_new_retailer())
      output$out_add_retailer_error <- renderText(o_add_retailer_error)
      
      ## update widoku z retailerami 
      view_retailers <- dbGetQuery(gv_con,"SELECT * FROM V_WATA_RETAILERS ORDER BY SKLEP")
      v_retailers <- view_retailers$ID
      names(v_retailers) <- view_retailers$SKLEP   
    })
    ####################################
    
    ##### ADD SHOP ####
    
    o_new_shop_city <- reactive({ as.numeric(input$in_view_cities) })
    o_new_shop_address <- reactive({ as.character(input$in_address)})
    o_new_shop_retailer <- reactive({ as.numeric(input$in_view_retailers) })
    
    observeEvent(input$in_commit_shop,{
      o_add_shop_error <- add_shop_exec(as.numeric(o_new_shop_retailer()),o_new_shop_address(),as.numeric(o_new_shop_city()))
      output$out_add_shop_error <- renderText(o_add_shop_error)
      
      ## Update widoku ze sklepami
      view_process_shops<-dbGetQuery(gv_con,"SELECT * FROM V_WATA_PROCESS_SHOPS ORDER BY SKLEP")
      v_process_shops<-view_process_shops$ID
      names(v_process_shops)<-view_process_shops$SKLEP
      
      
    })
    
    
    
    ###### ADD PRODUCT TYPE ####
    
    o_new_product_type<-reactive({ input$in_new_product_type })
    
    observeEvent(input$in_commit_product_type,{
      o_add_product_type_error<-add_product_type_exec(o_new_product_type())
      output$out_add_product_type_error <- renderText(o_add_product_type_error)
      
      ## Update widoku z typami produktu
      view_product_types<-dbGetQuery(gv_con,"SELECT * FROM V_WATA_PRODUCT_TYPES ORDER BY KATEGORIA")
      v_product_types<-view_product_types$ID
      names(v_product_types)<-view_product_types$KATEGORIA
      
    })
    ####################################
    
    
    #### ADD PRODUCT #####
    o_new_product_desc<-reactive({ input$in_new_product})
    o_type_od_new_product<-reactive({ as.numeric(input$in_view_product_types)})
    
    observeEvent(input$in_commit_new_product,{
      o_add_new_product_error<-add_product_exec(o_new_product_desc(),o_type_od_new_product())
      output$out_add_new_product_error<-renderText(o_add_new_product_error)
      
      ## Update widoku z produktem
      view_process_products<-dbGetQuery(gv_con,"SELECT * FROM V_WATA_PROCESS_PRODUCTS ORDER BY PRODUKT")
      v_process_products<-view_process_products$ID
      names(v_process_products)<-view_process_products$PRODUKT
      
    })
    
    ##########################################################################
    
    ## LISTA ROZWIJANA RETAILERÓW NA BAZIE WIDOKU
    output$out_view_retailers <- renderUI({
      selectInput(inputId="in_view_retailers",label="MARKET",choices=v_retailers)
    })
    
    ## LISTA ROZWIJANA MIAST NA BAZIE WIDOKU
    output$out_view_cities <- renderUI({
      selectInput(inputId="in_view_cities",label="MIASTO",choices=v_cities)
    })	
    
    ## LISTA ROZWIJANA TYPÓW PRODUKTU NA BAZIE WIDOKU
    output$out_view_product_types <- renderUI({
      selectInput(inputId="in_view_product_types",label="KATEGORIA PRODUKU",choices=v_product_types)
    })
    
    ## LISTA ROZWIJANA SKLEPÓW NA BAZIE WIDOKU
    output$out_view_process_shops <- renderUI({
      selectInput(inputId="in_view_process_shops",label="SKLEP",choices=v_process_shops)
    })
    
    ## LISTA ROZWIJANA PRODUKTÓW NA BAZIE WIDOKU
    output$out_view_process_products<-renderUI({NULL})
    
    observeEvent(input$in_commit_setup,{
      
      disable("in_shopping_date")
      disable("in_view_process_shops")
      
      output$out_view_process_products<-renderUI({
        selectInput(inputId="in_view_process_products",label="PRODUKT",choices=v_process_products)
      })
      
      output$out_hidden_ui_br <- renderUI({
        br()
      })
      
      output$out_hidden_price<-renderUI({
        textInput(inputId="in_price",label="CENA (zł)")
      })
      
      output$out_hidden_weight<-renderUI({
        textInput(inputId="in_weight",label="WAGA (kg)",value="")
      })
      
      output$out_commit_single <- renderUI({
        actionButton(inputId="in_commit_single",label="DODAJ POZYCJĘ")
        
      })
      
      output$out_commit_list <- renderUI({
        actionButton(inputId="in_commit_list",label="AKCEPTUJ LISTĘ ZAKUPÓW")
        
      })     
      
      output$out_clear_interface <- renderUI({
        actionButton(inputId="in_clear_interface",label="ZERUJ LISTĘ ZAKUPÓW")
        
      })  
      
    })
    
    ##############################################################
    ################   PROCESOWANIE LISTY ZAKUPÓW ###############
    
    ## Wczytanie parametrów
    
    o_shopping_store <- reactive({ input$in_view_process_shops  })
    o_shopping_date <- reactive({ as.character(input$in_shopping_date) })
    
    o_shopping_product <- reactive({input$in_view_process_products})
    o_shopping_price<-reactive({input$in_price})
    o_shopping_weight<-reactive({input$in_weight})
    
    ### Tabela z listą zakupów
    output$out_df_shopping <- renderTable(NULL)
    
    ## Utworzenie struktury
    df_shopping<-data.frame(matrix(nrow=0,ncol=5),stringsAsFactors = FALSE)
    colnames(df_shopping)<-c("ID_SHOP","DATE","ID_PRODUCT","PRICE","WEIGHT")
    
    ## Utworzenie struktury pod widok na bazie df_shopping 
    v_df_shopping <- data.frame(matrix(nrow=0,ncol=5),stringsAsFactors = FALSE)
    colnames(v_df_shopping)<-c("SKLEP","DATA","PRODUKT","CENA","WAGA")
    
    
    v<-reactiveValues(df=df_shopping)
    
    v_v <- reactiveValues(v_df=v_df_shopping)
    
    observeEvent(input$in_commit_single,{
      # df_shopping<-df_construct(df_shopping,
      #                           o_shopping_store(),
      #                           o_shopping_date(),
      #                           o_shopping_product(),
      #                           o_shopping_price(),
      #                           o_shopping_weight())
      
      v$df<-df_construct(v$df,
                         input$in_view_process_shops,
                         as.character(input$in_shopping_date),
                         input$in_view_process_products,
                         input$in_price,
                         input$in_weight)
      
      
      v_v$v_df <-convert_to_view(v$df,v_process_shops,v_process_products)
      
      #output$out_df_shopping<-renderTable(v$df)
      
      output$out_df_shopping<-renderTable(v_v$v_df)
      
    })
    
    observeEvent(input$in_commit_list,{
      
      x <- xmlTree("SHOPPING")
      x$addTag("ID_SHOP",input$in_view_process_shops,close=T)
      x$addTag("SHOPPING_DATE",as.character(input$in_shopping_date),close=T)
      x$addTag("PRODUCTS",close=F)
      for(i in 1:nrow(v$df)){
        x$addTag("PRODUCT",close=F)
        x$addTag("ID_PRODUCT",v$df$ID_PRODUCT[i],close=T)
        x$addTag("PRICE",v$df$PRICE[i],close=T)
        x$addTag("WEIGHT",v$df$WEIGHT[i],close=T)
        x$closeTag()
      }
      x$closeTag()
      
      
      final_xml <- saveXML(x$value())
      
      o_add_shopping_list_error<-add_shopping_list_exec(final_xml)
      output$out_add_shopping_list_error<-renderText(o_add_shopping_list_error)
      
      
    }) 
    
    
    ## Wyzeruj interfejs 
    observeEvent(input$in_clear_interface,{
      
      enable("in_shopping_date")
      enable("in_view_process_shops")
      
      ## Wyzeruj tabelę z listą zakupów
      for(i in 1:nrow(v$df)){
        v$df[i,]<-NA
      }
      v$df<-v$df[complete.cases(v$df),]
      
      ## Wyzeruj widok
      for(i in 1:nrow(v_v$v_df)){
        v_v$v_df[i,]<-NA
      }
      v_v$v_df<-v_v$v_df[complete.cases(v_v$v_df),]
      
      output$out_df_shopping <- renderTable(NULL)
      
      ## Pola
      output$out_view_process_products<-renderUI({NULL})
      output$out_hidden_price<-renderUI({NULL})
      output$out_hidden_weight<-renderUI({NULL })
      output$out_commit_single <- renderUI({NULL})
      output$out_commit_list <- renderUI({NULL})
      output$out_add_shopping_list_error<-renderText({NULL})
      output$out_clear_interface<-renderUI({NULL})
      
      
    })
    
    
    ############################################################
    ############################################################
    
    
    ################### WIDOKI USERA ##########################
    
    #### SHOW RETAILERS ####
    
    observeEvent(input$in_show_retailers,{
      output$out_retailers_df<-renderTable(dbGetQuery(gv_con,"SELECT SKLEP FROM V_WATA_RETAILERS ORDER BY SKLEP"),rownames = T)
    })
    
    #### SHOW PRODUCT TYPES ####
    
    observeEvent(input$in_show_product_types,{
      output$out_product_types_df<-renderTable(dbGetQuery(gv_con,"SELECT KATEGORIA FROM V_WATA_PRODUCT_TYPES ORDER BY KATEGORIA"),rownames=T)
    })
    
    ### SHOW CITIES #####
    
    observeEvent(input$in_show_cities,{
      output$out_cities_df<-renderTable(dbGetQuery(gv_con,"SELECT MIASTO FROM V_WATA_CITIES ORDER BY MIASTO"),rownames = T)
    })
    
    #### SHOW SHOPS (USER VIEW) ####
    
    observeEvent(input$in_show_shops,{
      output$out_shops_df<-renderTable(dbGetQuery(gv_con,"SELECT * FROM V_WATA_USER_SHOPS ORDER BY MARKET"),rownames = T)
    })
    
    ### SHOW PRODUCTS 
    observeEvent(input$in_show_products,{
      output$out_products_df<-renderTable(dbGetQuery(gv_con,"SELECT * FROM V_WATA_USER_PRODUCTS ORDER BY PRODUKT"),rownames=T)
    })
    
    
    
    ########################  PANEL WYDATKI ############
    
    observeEvent(input$in_show_expenditures,{
      
      o_view_all_data<-dbGetQuery(gv_con,"SELECT DATA,
                                  PRODUKT,
                                  KATEGORIA,
                                  CENA|| ' zł' CENA,
                                  CASE WHEN WAGA IS NULL THEN WAGA ELSE WAGA || ' kg' END WAGA,
                                  SKLEP,
                                  ADRES,MIASTO 
                                  FROM V_WATA_ALL_DATA ORDER BY DATA DESC")
      
      o_view_all_data$DATA<-as.Date(format(as.Date(o_view_all_data$DATA),"%d-%b-%Y"),format="%d-%b-%Y")
      o_view_all_data$PRODUKT<-as.factor(o_view_all_data$PRODUKT)
      o_view_all_data$KATEGORIA<-as.factor(o_view_all_data$KATEGORIA)
      o_view_all_data$SKLEP<-as.factor(o_view_all_data$SKLEP)
      o_view_all_data$ADRES<-as.factor(o_view_all_data$ADRES)
      o_view_all_data$MIASTO<-as.factor(o_view_all_data$MIASTO)
      
      output$out_expenditures <- renderDataTable({o_view_all_data},
                                                 filter="top",rownames=F,
                                                 options=list(pageLength=10,info=F,
                                                              lengthMenu=list(c(10,50,100,-1),c("10","50","100","All")))
      )
    })
    
    
    ##################  PANEL WYDATKI - PRODUKT #############
    
    observeEvent(input$in_show_exp_view_dates,{
      
      q<- paste0("SELECT PRODUKT, SUM(CENA)|| ' zł'  WYDANO
                 FROM V_WATA_ALL_DATA
                 WHERE TRUNC(DATA) BETWEEN TRUNC(TO_DATE('",as.character(input$in_start_date),"','YYYY-MM-DD'))
                 AND TRUNC(TO_DATE('",as.character(input$in_end_date),"','YYYY-MM-DD'))
                 GROUP BY PRODUKT
                 ORDER BY SUM(CENA) DESC")
      
      output$out_exp_param<-renderTable(dbGetQuery(gv_con,q),rownames = F)
      
      
    })
    
    
    
  }
  
    )

