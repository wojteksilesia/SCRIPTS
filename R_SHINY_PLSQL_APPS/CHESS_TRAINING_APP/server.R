library(shiny)
library(RJDBC)
library(shinyalert)
library(DT)
library(shinyjs)

shinyServer(
  function(input,output){
    
    jdbcDriver <- JDBC("oracle.jdbc.OracleDriver",classPath="C:/Users/Wojtek/Desktop/ojdbc6.jar")
    gv_con <- dbConnect(jdbcDriver, "jdbc:oracle:thin:@//localhost:1521/xe", "CHESS", "chess")    
    
    ### ADD NEW OPENING
    
    add_new_opening_exe<-function(iopening,icolor){
      q<-paste0("BEGIN PCG_OPENING_TRAINING.ADD_OPENING(","'",iopening,"',","'",icolor,"'","); END;")
      err<-try(dbSendUpdate(gv_con,q),silent=TRUE)
      if(length(err)==0){
        return("NEW OPENING SUCCESSFULLY ADDED")
      }else{
        return('ERROR - OPENING NOT ADDED')
      }
    }
    
    o_new_opening <- reactive({input$in_new_opening})
    o_new_color <- reactive(input$in_new_color)
    
    observeEvent(input$in_add_opening_button,{
      o_add_opening_error<-add_new_opening_exe(o_new_opening(),o_new_color())
      if(substr(o_add_opening_error,1,1)=="N"){
        shinyalert(o_add_opening_error,type="success")
      }else if(substr(o_add_opening_error,1,1)=="E"){
        shinyalert(o_add_opening_error,type="error")
      }
      
    })
    
    #################################################
    
    ### REPEAT TODAY
    
    observeEvent(input$in_repeat_today,{
      output$out_repeat_today <- renderTable(dbGetQuery(gv_con,"select * from v_repeat_today"))
    })    
    
  
    ### DONE TODAY
    
    observeEvent(input$in_done_today,{
      output$out_done_today <- renderTable(dbGetQuery(gv_con,"select * from v_done_today"))
    }) 
    
    ################################################
    
    ### MARK AS DONE
    
    ## View
    
    output$out_view_openings <- renderUI({
      selectInput(inputId="in_done_opening",label="OPENING",
                  choices=unique(dbGetQuery(gv_con,"select * from opening_training")$OPENING))
    })
    
    ## Functions
    set_is_done_exe<-function(iopening,idate){
      q<-paste0("BEGIN PCG_OPENING_TRAINING.SET_IS_DONE(","'",iopening,"',","'",idate,"'","); END;")
      err<-try(dbSendUpdate(gv_con,q),silent=TRUE)
      if(length(err)==0){
        return("UPDATED")
      }else{
        return("ERROR - SCHEDULE NOT UPDATED")
      }
    }
    
    o_update_opening <- reactive({input$in_done_opening})
    o_update_date <- reactive({input$in_done_day})
    
    observeEvent(input$in_set_done_button,{
      o_mark_done_error<-set_is_done_exe(o_update_opening(),as.character(format(o_update_date(),"%Y%m%d")))
      if(substr(o_mark_done_error,1,1)=="U"){
        shinyalert(o_mark_done_error,type="success")
      }else if(substr(o_mark_done_error,1,1)=="E"){
        shinyalert(o_mark_done_error,type="error")
      }
      
    })
    
    #################################################
    
    ### REPEAT TOMORROW
    
    observeEvent(input$in_repeat_tomorrow,{
      output$out_repeat_tomorrow <- renderTable(dbGetQuery(gv_con,"select * from v_repeat_tomorrow"))
    })   
    
    ### DONE YESTERDAY
    
    observeEvent(input$in_done_yesterday,{
      output$out_done_yesterday <- renderTable(dbGetQuery(gv_con,"select * from v_done_yesterday"))
    }) 
    
    
    ##############################################
    
    ### MISSED
    observeEvent(input$in_show_missed,{
      output$out_total_lag_days<-renderText(paste0("TOTAL DELAY (IN DAYS): ",
                                                    ifelse(max(dbGetQuery(gv_con,"select * from V_SHOW_MISSED")$DELAY)=="-Inf",0,max(dbGetQuery(gv_con,"select * from V_SHOW_MISSED")$DELAY))
                                                  )
                                            )
      
      output$out_delay_df <-renderTable(ifelse(nrow(dbGetQuery(gv_con,"select * from V_SHOW_MISSED"))==0,data.frame(),dbGetQuery(gv_con,"select * from V_SHOW_MISSED")))
    })
    
    ###########################################
    
    ### RAWDATA
    observeEvent(input$in_show_rawdata,{
      output$out_rawdata<-renderDataTable({dbGetQuery(gv_con,"select * from OPENING_TRAINING order by id")},
                                          filter="top",
                                          rownames=FALSE,
                                          options=list(pageLength=400,info=TRUE,
                                                       lengthMenu=list(c(10,20,40,-1),c("10","20","40","All"))
                                          )
      )
      
    })
    
    
    #####################################
    
    ### RANDOM POSITION
    
    ### Get sample position from the database
    get_random_position<-function(){
      d<-dbGetQuery(gv_con,"SELECT PICTURE_NAME,SOLUTION,PLAYERS,MOVE FROM (SELECT * FROM POSITIONAL_PICTURES ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM=1")
      return(d)
    }
    
    ## Handling scope
    g_solution<-reactiveValues(solution="")
    #g_players<-reactiveValues(players="")
    
    ## Event show diagram
    observeEvent(input$in_random_position_button,{
      random_position_df<-get_random_position()
      
      ## Update global solution variable
      g_solution$solution<-random_position_df$SOLUTION
      #g_players$players<-random_position$PLAYERS
      
      output$out_diagram_players<-renderText(random_position_df$PLAYERS)
      output$out_diagram_interface<-renderUI(tags$img(src=random_position_df$PICTURE_NAME,width=400,height=400))
      output$out_on_move<-renderText(paste0(random_position_df$MOVE," TO MOVE"))
      
      output$out_show_solution_button<-renderUI(actionButton(inputId="in_show_solution_button",label="SHOW SOLUTION"))
      output$out_solution_text<-renderText(NULL)  
    })
    
    ## Event show solution
    observeEvent(input$in_show_solution_button,{
      output$out_solution_text<-renderText(g_solution$solution)
    })
    
    ####################
    
    ### ADD NEW POSITION
    
    add_picture_exe<-function(ifile_name,ion_move,iplayers,isolution){
      q<-paste0("BEGIN PCG_OPENING_TRAINING.ADD_PICTURE('",ifile_name,"','",isolution,"','",ion_move,"','",iplayers,"'); END;")
      err<-try(dbSendUpdate(gv_con,q),silent=TRUE)
      if(length(err)==0){
        return(TRUE)
      }else{
        return(FALSE)
      }
    }
    
    o_on_move<-reactive({input$in_on_move})
    o_players<-reactive({input$in_players})
    o_solution<-reactive({input$in_solution})
    
    observeEvent(input$in_add_picture_button,{
      inFile <- input$in_input_file
      ### Check if file name is not already taken
      q<-paste0("SELECT COUNT(1) COUNTER FROM POSITIONAL_PICTURES WHERE UPPER(PICTURE_NAME)='",toupper(inFile$name),"'")
      counter<-dbGetQuery(gv_con,q)
      if(counter$COUNTER>0){
        shinyalert("FILE NAME ALREADY EXISTS IN THE DATABASE",type="error")
      }else{
        file.copy(inFile$datapath, file.path("C:/Users/Wojtek/Desktop/SZACHY_APP/www",inFile$name))
        err<-add_picture_exe(inFile$name,o_on_move(),o_players(),o_solution())
        if(err==TRUE){
          shinyalert("FILE SUCCESSFULLY ADDED",type="success")
        }else{
          shinyalert("ERROR - FILE NOT LOADED",type="error")
      }
      
      }
    })
    
    ### Random repertiore Let's play today
    observeEvent(input$id_roll_the_dice,{
      source("C:/Users/Wojtek/Desktop/SZACHY_APP/RANDOM_OPENING.R")
      output$out_repertoire<-renderText(random_repertoire())
    })
    
    #######################################
    ### WAITING LIST ####################
    
    ### EXE FUNCTION
    
    add_remove_waiting_exe<-function(istatus,inewopening,ioldopening,icolor,ilink){
      if(istatus==1){
        q<-paste0("BEGIN PCG_OPENING_TRAINING.ADD_REMOVE_WAITING_LIST(1,","'",inewopening,"',","'",icolor,"'",",'",ilink,"'); END;")
      }else if(istatus==-1){
        q<-paste0("BEGIN PCG_OPENING_TRAINING.ADD_REMOVE_WAITING_LIST(-1,","'",ioldopening,"',NULL,NULL); END;")
      }
      err<-try(dbSendUpdate(gv_con,q),silent=TRUE)
      if(length(err)==0){
        return("VARIATION SUCCESSFULLY ADDED TO WAITING LIST")
      }else{
        return('ERROR - VARIATION NOT ADDED')
      }
    }
    
    
    ## LIST OF VARIATIONS
    output$out_view_waiting_list <- renderUI({
      disabled(selectInput(inputId="in_waiting_list_view",label="VARIATION TO REMOVE",
                  choices=unique(dbGetQuery(gv_con,"select opening from waiting_list")$OPENING)))
    })
    
    
    observeEvent(input$in_action,{
      if(input$in_action==1){
        disable("in_waiting_list_view")
        enable("in_new_var_waiting_list")
        enable("in_color_waiting_list")
        enable("in_waiting_link")
      }else if(input$in_action==-1){
        enable("in_waiting_list_view")
        disable("in_new_var_waiting_list")
        disable("in_color_waiting_list")
        disable("in_waiting_link")        
      }
    })
    
    o_status_wl<-reactive({input$in_action})
    o_new_opening_wl<-reactive({input$in_new_var_waiting_list})
    o_old_opening_wl<-reactive({input$in_waiting_list_view})
    o_color_wl<-reactive({input$in_color_waiting_list})
    o_link_wl<-reactive({input$in_waiting_link})
    
    observeEvent(input$in_waiting_button_submit,{
      wl_err<-add_remove_waiting_exe(o_status_wl(),o_new_opening_wl(),o_old_opening_wl(),o_color_wl(),o_link_wl())
      if(substr(wl_err,1,1)=="V"){
        shinyalert("WAITING LIST SUCCESSFULLY UPDATED",type="success")
        ## Update view 
        output$out_view_waiting_list <- renderUI({
          selectInput(inputId="in_waiting_list_view",label="VARIATION TO REMOVE",
                               choices=unique(dbGetQuery(gv_con,"select opening from waiting_list")$OPENING))})
      }else if(substr(wl_err,1,1)=="E"){
        shinyalert("ERROR - WAITING LIST NOT UPDATED",type="error")
      }
    })
    
    
    ### Display
    observeEvent(input$in_show_waiting_button,{
      df_w<-dbGetQuery(gv_con,"select * from waiting_list order by id")
      df_w$ID<-as.integer(df_w$ID)
      output$out_waiting_df<-renderTable(df_w)
    })
    
    
  }
)



