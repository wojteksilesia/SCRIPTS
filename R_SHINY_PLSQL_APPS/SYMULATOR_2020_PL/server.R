library(shiny)
library(shinyjs)
library(shinyalert)
library(rvest)
library(dplyr)
library(tidyr)
library(cluster)
library(naivebayes)
library(DT)

shinyServer(
  function(input,output,session){
    
    
    
    ######################################################################################
    ######################################################################################
    #############               TAKE TABLE EKSTRAKLASA ############################
    
    
    take_table_eks <- function(){
      
      ### Page URL
      table_url <- "https://ekstraklasa.org/rozgrywki/tabela/ekstraklasa-3"
      
      ### Page source html
      html_schema <- read_html(table_url)
      
      
      ###############  TEAMS ###############
      
      ## Scraping teams
      sc_teams <- html_schema %>% html_nodes("a.clubName") %>% html_text()
      
      ## Cleaning 
      teams_vector <- gsub("\n","",sc_teams)
      teams_vector <- gsub("\t","",teams_vector)
      
      
      ############### POINTS ###############
      
      ## Scraping number of points
      sc_points <- html_schema %>% html_nodes("div.points") %>% html_text()
      
      
      ## Cleaning 
      points_vector <- gsub("\n","",sc_points)
      points_vector <- gsub("\t","",points_vector)
      
      
      ############### GOALS ###############
      
      sc_goals <- html_schema %>% html_nodes("td.txt-center.hidden-xs") %>% html_text()
      
      
      goals_vector<- sc_goals[seq(4,length(sc_goals),by=4)]
      
      
      
      ############# FINAL TABLE ##############
      
      final_table <- data.frame(TEAM=teams_vector,POINTS=as.numeric(points_vector),GOALS=goals_vector)
      
      ### Spread goals column into goals+ and goals minus
      final_table <- separate(final_table,GOALS,c("GOALS_PLUS","GOALS_MINUS"),sep=":")
      
      ### Data types cleaning
      final_table$TEAM <- as.character(final_table$TEAM)
      final_table$GOALS_PLUS <- as.numeric(final_table$GOALS_PLUS)
      final_table$GOALS_MINUS <- as.numeric(final_table$GOALS_MINUS)
      
      return(final_table)
      
    }
    
    ######################################################################################
    ######################################################################################
    
    #############################   TAKE PAIRINGS EKSTRAKLASA ############################
    
    take_pairings_eks <- function(only_future){
      
      ## Page URL
      pairings_url <- "https://wyniki.interia.pl/rozgrywki-L-polska-ekstraklasa,cid,3,sort,I"
      
      ## Page source html
      html_schema <- read_html(pairings_url)
      
      
      #### Load home teams
      home_teams <- html_schema %>% html_nodes("span.team.teamA") %>% html_text()  
      
      ### Look for the beginning pattern to avoid loading advs rounds - just start loading right from the 1st round
      for(i in 1:length(home_teams)){
        if(home_teams[i]=="Arka Gdynia" &
           home_teams[i+1]=="ŁKS" &
           home_teams[i+2]=="Raków Częstochowa" &
           home_teams[i+3]=="Wisła Kraków" &
           home_teams[i+4]=="Piast Gliwice" &
           home_teams[i+5]=="Zagłębie Lubin" &
           home_teams[i+6]=="Legia Warszawa" &
           home_teams[i+7]=="Wisła Płock"){
          start_index <- i
          break
        }
      }
      
      
      home_vector <- home_teams[start_index:length(home_teams)]
      
      
      ### Away teams
      away_teams <- html_schema %>% html_nodes("span.team.teamB") %>% html_text()  
      
      ## Applying start_index found earlier 
      away_vector <- away_teams[start_index:length(away_teams)]
      
      
      ### Score
      sc_score <- html_schema %>% html_nodes("span.goals") %>% html_text()
      
      ## Applying start_index found earlier 
      score_vector <- sc_score[start_index:length(sc_score)]
      
      ### Building results table
      all_pairings <- data.frame(HOME=home_vector,
                                 AWAY=away_vector,
                                 SCORE=score_vector)
      
      all_pairings$HOME <- as.character(all_pairings$HOME)
      all_pairings$AWAY <- as.character(all_pairings$AWAY)
      all_pairings$SCORE <- as.character(all_pairings$SCORE)
      
      
      ## standarizing team names to be consistent with scrapped table
      all_pairings[all_pairings$HOME=="ŁKS","HOME"] <- "ŁKS Łódź"
      all_pairings[all_pairings$AWAY=="ŁKS","AWAY"] <- "ŁKS Łódź"
      all_pairings[all_pairings$HOME=="Zagłębie Lubin","HOME"] <- "KGHM Zagłębie Lubin"
      all_pairings[all_pairings$AWAY=="Zagłębie Lubin","AWAY"] <- "KGHM Zagłębie Lubin"
      
      
      ### Filtering only future games
      future_games <- all_pairings %>% filter(SCORE=="-") %>% select(HOME,AWAY)
      
      if(only_future==TRUE){
        return(future_games)
      }else if(only_future==FALSE){
        return(all_pairings)
      }
      
    }
    
    
    ######################################################################################
    ######################################################################################
    
    #############################   TAKE TABLE 1st ############################
    
    
    take_table_1st <- function() {
      
      ## Page URL
      pairings_url <- "https://www.przegladsportowy.pl/pilka-nozna/fortuna-1-liga"
      
      ## Page source html
      html_schema <- read_html(pairings_url)
      
      #### Load info
      sc_info <- html_schema %>% html_nodes("span.itemName") %>% html_text()  
      
      #### TEAMS ####
      sc_teams <- sc_info[seq(2,by=10,length.out=18)]
      
      ### POINTS ###
      sc_points <- sc_info[seq(10,by=10,length.out=18)]
      
      ### GOALS PLUS ###
      sc_goals_plus <- sc_info[seq(7,by=10,length.out=18)]
      
      ### GOALS MINUS ###
      sc_goals_minus <- sc_info[seq(8,by=10,length.out=18)]
      
      
      result_df <- data.frame(TEAM=as.character(sc_teams),
                              POINTS=as.numeric(sc_points),
                              GOALS_PLUS=as.numeric(sc_goals_plus),
                              GOALS_MINUS=as.numeric(sc_goals_minus))
      
      result_df$TEAM <- as.character(result_df$TEAM)
      
      ### Standarize team names to make them the same as in pairings
      
      result_df[result_df$TEAM=="PGE FKS Stal Mielec","TEAM"] <- "Stal Mielec"
      result_df[result_df$TEAM=="Podbeskidzie Bielsko-Biała","TEAM"] <- "Podbeskidzie B.-B."
      result_df[result_df$TEAM=="Radomiak Radom","TEAM"] <- "Radomiak"
      result_df[result_df$TEAM=="GKS 1962 Jastrzębie","TEAM"] <- "GKS Jastrzębie Zdrój"
      result_df[result_df$TEAM=="Odra Opole","TEAM"] <- "OKS Odra Opole"
      result_df[result_df$TEAM=="Chojniczanka","TEAM"] <- "MKS Chojniczanka Chojnice"
      result_df[result_df$TEAM=="Bruk-Bet Nieciecza","TEAM"] <- "Bruk-Bet Termalica"
      
      return(result_df)
      
    }
    
    
    
    ######################################################################################
    ######################################################################################
    
    #############################   TAKE PAIRINGS 1st ######################################
    
    take_pairings_1st <- function(only_future){
      
      ## Page URL
      pairings_url <- "https://wyniki.interia.pl/rozgrywki-L-polska-1-liga,cid,696,sort,I?from=mobile"
      
      ## Page source html
      html_schema <- read_html(pairings_url)
      
      
      #### Load home teams
      home_teams <- html_schema %>% html_nodes("span.team.teamA") %>% html_text()  
      
      ### Look for the beginning pattern to avoid loading advs rounds - just start loading right from the 1st round
      for(i in 1:length(home_teams)){
        if(home_teams[i]=="Olimpia Grudziądz" &
           home_teams[i+1]=="Stal Mielec" &
           home_teams[i+2]=="Radomiak" &
           home_teams[i+3]=="Miedź Legnica" &
           home_teams[i+4]=="Zagłębie Sosnowiec" &
           home_teams[i+5]=="Puszcza Niepołomice" &
           home_teams[i+6]=="GKS Bełchatów" &
           home_teams[i+7]=="Wigry Suwałki" &
           home_teams[i+8]=="Bruk-Bet Termalica"){
          start_index <- i
          break
        }
      }
      
      
      home_vector <- home_teams[start_index:length(home_teams)]
      
      
      ### Away teams
      away_teams <- html_schema %>% html_nodes("span.team.teamB") %>% html_text()  
      
      ## Applying start_index found earlier 
      away_vector <- away_teams[start_index:length(away_teams)]
      
      
      ### Score
      sc_score <- html_schema %>% html_nodes("span.goals") %>% html_text()
      
      ## Applying start_index found earlier 
      score_vector <- sc_score[start_index:length(sc_score)]
      
      ### Building results table
      all_pairings <- data.frame(HOME=home_vector,
                                 AWAY=away_vector,
                                 SCORE=score_vector)
      
      all_pairings$HOME <- as.character(all_pairings$HOME)
      all_pairings$AWAY <- as.character(all_pairings$AWAY)
      all_pairings$SCORE <- as.character(all_pairings$SCORE)
      
      ### Filtering only future games
      future_games <- all_pairings %>% filter(SCORE=="-") %>% select(HOME,AWAY)
      
      if(only_future==TRUE){
        return(future_games)
      }else if(only_future==FALSE){
        return(all_pairings)
      }
      
    }
    
    ##########################################################################################
    ##########################################################################################
    
    #############################   TAKE PAIRINGS 2nd ######################################
    
    take_pairings_2nd <- function(only_future){
      
      
      
      ## Page URL
      pairings_url <- "https://wyniki.interia.pl/rozgrywki-L-polska-2-liga,cid,668,sort,I"
      
      ## Page source html
      html_schema <- read_html(pairings_url)
      
      
      #### Load home teams
      home_teams <- html_schema %>% html_nodes("span.team.teamA") %>% html_text()  
      
      ### Look for the beginning pattern to avoid loading advs rounds - just start loading right from the 1st round
      for(i in 1:length(home_teams)){
        if(home_teams[i]=="Górnik Polkowice" &
           home_teams[i+1]=="TKP Elana" &
           home_teams[i+2]=="Stal Stalowa Wola" &
           home_teams[i+3]=="Stal Rzeszów" &
           home_teams[i+4]=="RKS Garbarnia Kraków" &
           home_teams[i+5]=="WKS Gryf Wejherowo" &
           home_teams[i+6]=="KS Legionovia" &
           home_teams[i+7]=="GKS Katowice" &
           home_teams[i+8]=="Olimpia Elbląg"){
          start_index <- i
          break
        }
      }
      
      
      home_vector <- home_teams[start_index:length(home_teams)]
      
      
      ### Away teams
      away_teams <- html_schema %>% html_nodes("span.team.teamB") %>% html_text()  
      
      ## Applying start_index found earlier 
      away_vector <- away_teams[start_index:length(away_teams)]
      
      
      ### Score
      sc_score <- html_schema %>% html_nodes("span.goals") %>% html_text()
      
      ## Applying start_index found earlier 
      score_vector <- sc_score[start_index:length(sc_score)]
      
      ### Building results table
      all_pairings <- data.frame(HOME=home_vector,
                                 AWAY=away_vector,
                                 SCORE=score_vector)
      
      all_pairings$HOME <- as.character(all_pairings$HOME)
      all_pairings$AWAY <- as.character(all_pairings$AWAY)
      all_pairings$SCORE <- as.character(all_pairings$SCORE)
      
      ### Filtering only future games
      future_games <- all_pairings %>% filter(SCORE=="-") %>% select(HOME,AWAY)
      
      if(only_future==TRUE){
        return(future_games)
      }else if(only_future==FALSE){
        return(all_pairings)
      }
      
    }
    
    
    ##########################################################################################
    ##########################################################################################
    
    #############################   TAKE TABLE 2nd ######################################
    
    take_table_2nd <- function(){
      
      ## Page URL
      table_url <- "https://www.laczynaspilka.pl/rozgrywki/ii-liga,3.html"
      
      ## Page source html
      html_schema <- read_html(table_url)
      
      #### Teams
      sc_teams <- html_schema %>% html_nodes("strong") %>% html_text()  
      
      #### TEAMS ####
      teams_vector <- sc_teams[(length(sc_teams)-17):(length(sc_teams))]
      
      
      sc_info <- html_schema %>% html_nodes("td") %>% html_text() 
      
      ### POINTS ###
      sc_points <- sc_info[seq(6,by=10,length.out=18)]
      
      ### Goals
      sc_goals <- sc_info[seq(10,by=10,length.out=18)]
      
      
      
      
      result_df <- data.frame(TEAM=as.character(teams_vector),
                              POINTS=as.numeric(sc_points),
                              GOALS=sc_goals)
      
      result_df <- separate(result_df,GOALS,c("GOALS_PLUS","GOALS_MINUS"),sep=":")
      
      result_df$TEAM <- as.character(result_df$TEAM)
      result_df$GOALS_PLUS <- as.numeric(result_df$GOALS_PLUS)
      result_df$GOALS_MINUS <- as.numeric(result_df$GOALS_MINUS)
      
      ### Standarize team names to make them the same as in pairings
      
      result_df[result_df$TEAM=="Widzew Łódź SA","TEAM"] <- "Widzew Łódź"
      result_df[result_df$TEAM=="Górnik Łęczna S.A.","TEAM"] <- "Górnik Łęczna"
      result_df[result_df$TEAM=="GKS GIEKSA KATOWICE S.A.","TEAM"] <- "GKS Katowice"
      result_df[result_df$TEAM=="Resovia Rzeszów","TEAM"] <- "CWKS Resovia"
      result_df[result_df$TEAM=="ZKS Olimpia Elbląg","TEAM"] <- "Olimpia Elbląg"
      result_df[result_df$TEAM=="Stal Rzeszów S.A.","TEAM"] <- "Stal Rzeszów"
      result_df[result_df$TEAM=="Bytovia Bytów","TEAM"] <- "MKS Bytovia"
      result_df[result_df$TEAM=="Stal Rzeszów S.A.","TEAM"] <- "Stal Rzeszów"
      result_df[result_df$TEAM=="Bytovia Bytów","TEAM"] <- "MKS Bytovia"
      result_df[result_df$TEAM=="BŁĘKITNI Stargard","TEAM"] <- "Błękitni Stargard"
      result_df[result_df$TEAM=="MKS Znicz Pruszków","TEAM"] <- "Znicz Pruszków"
      result_df[result_df$TEAM=="Elana Toruń","TEAM"] <- "TKP Elana"
      result_df[result_df$TEAM=="Garbarnia Kraków","TEAM"] <- "RKS Garbarnia Kraków"
      result_df[result_df$TEAM=="GÓRNIK POLKOWICE","TEAM"] <- "Górnik Polkowice"
      result_df[result_df$TEAM=="KKS LECH II Poznań","TEAM"] <- "KKS Lech Poznań II"
      result_df[result_df$TEAM=="MKP POGOŃ Siedlce","TEAM"] <- "Pogoń Siedlce"
      result_df[result_df$TEAM=="Stal Stalowa Wola P.S.A.","TEAM"] <- "Stal Stalowa Wola"
      result_df[result_df$TEAM=="KS SKRA CZĘSTOCHOWA S.A.","TEAM"] <- "KS SKRA Częstochowa"
      result_df[result_df$TEAM=="Gryf Wejherowo WKS","TEAM"] <- "WKS Gryf Wejherowo"
      
      return(result_df)
      
    }
    
    
    #############################################################################
    #############################################################################
    #########################   TAKE TABLE III liga gr 3 ########################
    
    take_table_3rd <- function(){
      ## Page URL
      table_url <- "https://www.laczynaspilka.pl/rozgrywki/iii-liga,4.html#18"
      
      ## Page source html
      html_schema <- read_html(table_url)
      
      #### Teams
      sc_teams <- html_schema %>% html_nodes("strong") %>% html_text()  
      
      #### TEAMS ####
      teams_vector <- sc_teams[8:25]
      
      
      sc_info <- html_schema %>% html_nodes("td") %>% html_text() 
      
      ### POINTS ###
      sc_points <- sc_info[seq(6,by=10,length.out=18)]
      
      ### Goals
      sc_goals <- sc_info[seq(10,by=10,length.out=18)]
      
      
      
      
      result_df <- data.frame(TEAM=as.character(teams_vector),
                              POINTS=as.numeric(sc_points),
                              GOALS=sc_goals)
      
      result_df <- separate(result_df,GOALS,c("GOALS_PLUS","GOALS_MINUS"),sep=":")
      
      result_df$TEAM <- as.character(result_df$TEAM)
      result_df$GOALS_PLUS <- as.numeric(result_df$GOALS_PLUS)
      result_df$GOALS_MINUS <- as.numeric(result_df$GOALS_MINUS)
      
      ### Standarize team names to make them the same as in pairings
      
      result_df[result_df$TEAM=="ŚLĄSK II WROCŁAW","TEAM"] <- "WKS Śląsk Wrocław II"
      result_df[result_df$TEAM=="RUCH CHORZÓW S.A.","TEAM"] <- "Ruch Chorzów"
      result_df[result_df$TEAM=="BYTOMSKI SPORT POLONIA BYTOM SP. Z O.O.","TEAM"] <- "Polonia Bytom"
      result_df[result_df$TEAM=="MKS RUCH ZDZIESZOWICE","TEAM"] <- "HKS Ruch Zdzieszowice"
      result_df[result_df$TEAM=="MKS KLUCZBORK","TEAM"] <- "MKS Kluczbork"
      result_df[result_df$TEAM=="TS GWAREK TARNOWSKIE GÓRY","TEAM"] <- "Gwarek Tarnowskie Góry"
      result_df[result_df$TEAM=="BTS REKORD","TEAM"] <- "BTS Rekord Bielsko-Biała"
      result_df[result_df$TEAM=="KS LECHIA GRAN-BUD ZIELONA GÓRA ","TEAM"] <- "KS Falubaz Zielona Góra"
      result_df[result_df$TEAM=="GKS PNIÓWEK 74 PAWŁOWICE","TEAM"] <- "Pniówek Pawłowice Śląskie"
      result_df[result_df$TEAM=="GÓRNIK II ZABRZE S.S.A.","TEAM"] <- "KS Górnik Zabrze II"
      result_df[result_df$TEAM=="1 KS ŚLĘZA WROCŁAW","TEAM"] <- "Ślęza Wrocław"
      result_df[result_df$TEAM=="FOTO HIGIENA BŁYSKAWICA GAĆ","TEAM"] <- "LKS Foto-Higiena Gać Oława"
      result_df[result_df$TEAM=="KS ROW 1964 RYBNIK","TEAM"] <- "Energetyk ROW Rybnik"
      result_df[result_df$TEAM=="MIEDŹ II LEGNICA","TEAM"] <- "MKS Miedź Legnica II"
      result_df[result_df$TEAM=="BTP STAL BRZEG","TEAM"] <- "MZKS Stal Brzeg"
      result_df[result_df$TEAM=="PIAST ŻMIGRÓD","TEAM"] <- "MKS Piast Żmigród"
      result_df[result_df$TEAM=="ZAGŁĘBIE II LUBIN","TEAM"] <- "Zagłębie Lubin II"
      result_df[result_df$TEAM=="LZS STAROWICE DOLNE","TEAM"] <- "LZS Starowice Dolne"
      
      
      return(result_df)
    }
    
    
    #############################################################################
    #############################################################################
    
    ##################     TAKE PAIRINGS III liga gr 3 #########################
    
    take_pairings_3rd <- function(only_future){
      ## Page URL
      pairings_url <- "https://wyniki.interia.pl/rozgrywki-R-polska-3-liga-grupa-3,cid,673,rid,4047,sort,I"
      
      ## Page source html
      html_schema <- read_html(pairings_url)
      
      
      #### Load home teams
      home_teams <- html_schema %>% html_nodes("span.team.teamA") %>% html_text()  
      
      ### Look for the beginning pattern to avoid loading advs rounds - just start loading right from the 1st round
      for(i in 1:length(home_teams)){
        if(home_teams[i]=="Energetyk ROW Rybnik" &
           home_teams[i+1]=="LZS Starowice Dolne" &
           home_teams[i+2]=="MZKS Stal Brzeg" &
           home_teams[i+3]=="KS Falubaz Zielona Góra" &
           home_teams[i+4]=="Gwarek Tarnowskie Góry" &
           home_teams[i+5]=="MKS Miedź Legnica II" &
           home_teams[i+6]=="Polonia Bytom" &
           home_teams[i+7]=="HKS Ruch Zdzieszowice" &
           home_teams[i+8]=="Ruch Chorzów")    
        {
          start_index <- i
          break
        }
      }
      
      
      home_vector <- home_teams[start_index:length(home_teams)]
      
      
      ### Away teams
      away_teams <- html_schema %>% html_nodes("span.team.teamB") %>% html_text()  
      
      ## Applying start_index found earlier 
      away_vector <- away_teams[start_index:length(away_teams)]
      
      
      ### Score
      sc_score <- html_schema %>% html_nodes("span.goals") %>% html_text()
      
      ## Applying start_index found earlier 
      score_vector <- sc_score[start_index:length(sc_score)]
      
      ### Building results table
      all_pairings <- data.frame(HOME=home_vector,
                                 AWAY=away_vector,
                                 SCORE=score_vector)
      
      all_pairings$HOME <- as.character(all_pairings$HOME)
      all_pairings$AWAY <- as.character(all_pairings$AWAY)
      all_pairings$SCORE <- as.character(all_pairings$SCORE)
      
      
      
      ### Filtering only future games
      future_games <- all_pairings %>% filter(SCORE=="-") %>% select(HOME,AWAY)
      
      if(only_future==TRUE){
        return(future_games)
      }else if(only_future==FALSE){
        return(all_pairings)
      }
    }
    
    
    
    #############################################################################
    #############################################################################
    
    
    #######################################################################
    ##################        CLUSTERING    ##############################
    
    teams_clustering <- function(league_table){
      
      ### Restructure the league table: move teams to rownames, calculate goal balance
      analysis_league_table <- league_table
      
      rownames(analysis_league_table) <- analysis_league_table$TEAM
      analysis_league_table$TEAM <- NULL
      
      analysis_league_table$GOAL_BALANCE <- analysis_league_table$GOALS_PLUS - analysis_league_table$GOALS_MINUS
      analysis_league_table$GOALS_PLUS <- NULL
      analysis_league_table$GOALS_MINUS <- NULL
      
      
      ########### SILHOUETTE ANALYSIS - to find optimal number of clusters
      
      # Silhouette width vector 
      avg_si_vector <- c()
      
      # Max number of clusters to evaluate
      clusters_to_check <- nrow(league_table)-1
      
      # Estimating cluster model for each number of clusters (>=3)
      for(i in 3:clusters_to_check){
        # Model
        model_km <- pam(analysis_league_table,k=i)
        
        # Saving the result 
        avg_si_vector[i] <- model_km$silinfo$avg.width
      }
      
      ### k as maximum of vector 
      optimal_k <- which.max(avg_si_vector)
      
      ################ FINAL MODEL ESTIMATION wth optimal k
      clusters_model <- kmeans(analysis_league_table,centers = optimal_k)
      
      # Adding cluster vector to the table
      league_table$cluster <- clusters_model$cluster
      
      return(league_table)
      
    }
    
    
    #######################################################################
    ##################        BAYES MODEL    #############################
    
    bayes_estimation <- function(pairings_table,league_table){
      
      ##### TRANSFORMING GAMES INTO ONE-TEAM PER ROW DATA TABLE
      
      per_team_data <- pairings_table %>% separate(SCORE,c("HOME_SCORE","AWAY_SCORE"),sep="-")
      
      per_team_data$HOME_SCORE <- as.numeric(per_team_data$HOME_SCORE)
      per_team_data$AWAY_SCORE <- as.numeric(per_team_data$AWAY_SCORE)
      
      ### HOME TEAMS
      home_team <- c()
      home_area <- c()
      home_game_result <- c()
      home_opponent <- c()
      
      for(i in 1:nrow(per_team_data)){
        home_team[i] <- per_team_data$HOME[i]
        home_area[i] <- "HOME"
        
        if(is.na(per_team_data$HOME_SCORE[i])==TRUE){
          home_game_result[i]<-NA
        }else if(per_team_data$HOME_SCORE[i]>per_team_data$AWAY_SCORE[i]){
          home_game_result[i] <- "WIN"
        }else if(per_team_data$HOME_SCORE[i]==per_team_data$AWAY_SCORE[i]){
          home_game_result[i] <- "DRAW"
        }else if(per_team_data$HOME_SCORE[i]<per_team_data$AWAY_SCORE[i]){
          home_game_result[i] <- "LOSE"
        }
        home_opponent[i] <- league_table[league_table$TEAM==per_team_data$AWAY[i],"cluster"]
      }
      
      ## AWAY TEAMS
      away_team <- c()
      away_area <- c()
      away_game_result <- c()
      away_opponent <- c()
      
      for(i in 1:nrow(per_team_data)){
        away_team[i] <- per_team_data$AWAY[i]
        away_area[i] <- "AWAY"
        
        if(is.na(per_team_data$HOME_SCORE[i])==TRUE){
          away_game_result[i]<-NA
        }else if(per_team_data$HOME_SCORE[i]>per_team_data$AWAY_SCORE[i]){
          away_game_result[i] <- "LOSE"
        }else if(per_team_data$HOME_SCORE[i]==per_team_data$AWAY_SCORE[i]){
          away_game_result[i] <- "DRAW"
        }else if(per_team_data$HOME_SCORE[i]<per_team_data$AWAY_SCORE[i]){
          away_game_result[i] <- "WIN"
        }
        away_opponent[i] <- league_table[league_table$TEAM==per_team_data$HOME[i],"cluster"]
      }
      
      transformed_pairings <- data.frame(TEAM=c(home_team,away_team),
                                         AREA=c(home_area,away_area),
                                         RESULT=c(home_game_result,away_game_result),
                                         OPPONENT_CLUSTER=c(home_opponent,away_opponent))
      
      ### Split dataset into finished and upcoming games
      transformed_finished <- transformed_pairings[complete.cases(transformed_pairings),]
      transformed_upcoming <- transformed_pairings[!complete.cases(transformed_pairings),]
      
      ## Bayes estimator
      bayes_model <- naive_bayes(RESULT~TEAM+AREA+OPPONENT_CLUSTER, 
                                 data=transformed_finished, 
                                 laplace=1)
      
      ## Using estimated Bayes model, calculating result table
      p_home<-c()
      p_away<-c()
      p_home_win<-c() 
      p_home_draw<-c()
      p_home_lose<-c()
      p_away_win<-c()
      p_away_draw<-c()
      p_away_lose<-c()
      halftable<-nrow(transformed_upcoming)/2
      
      for(i in 1:halftable){
        p_home[i]<-as.character(transformed_upcoming$TEAM[i])
        p_away[i]<-as.character(transformed_upcoming$TEAM[i+halftable])
        
        p_home_win[i]<-predict(bayes_model,transformed_upcoming[i,],type="prob")[1,"WIN"]
        p_home_draw[i]<-predict(bayes_model,transformed_upcoming[i,],type="prob")[1,"DRAW"]
        p_home_lose[i]<-predict(bayes_model,transformed_upcoming[i,],type="prob")[1,"LOSE"]
        
        p_away_win[i]<-predict(bayes_model,transformed_upcoming[i+halftable,],type="prob")[1,"WIN"]
        p_away_draw[i]<-predict(bayes_model,transformed_upcoming[i+halftable,],type="prob")[1,"DRAW"]
        p_away_lose[i]<-predict(bayes_model,transformed_upcoming[i+halftable,],type="prob")[1,"LOSE"]
      }
      ### Average result probabilities 
      p_1 <- (p_home_win+p_away_lose)/2
      p_0 <- (p_home_draw+p_away_draw)/2
      p_2 <- (p_home_lose+p_away_win)/2
      
      result_df<-data.frame(HOME=p_home,AWAY=p_away,P_1=p_1,P_0=p_0,P_2=p_2)
      
      return(result_df)
    }
    
    ##############################################
    ##############################################
    
    ##########################  SIMULATION #################################
    
    
    season_simulation <- function(N,league,champ_promote,euro_league=3,fall_down,
                                  grupa_mistrzowska=8,before_split=TRUE,play_off=6,bayes_method=TRUE)
    {
      
      ### Global variables 
      #league <- 0             # 0-Ekstraklasa; 1-Fortuna I Liga; 2- 2 Liga
      #N <- 1000                #number of scenarios
      #champ_promote <- 1      #champion or teams promoted
      #euro_league <- 3        #last place with european cups promotion - important only for Ekstraklasa
      #fall_down <- 3          #teams falling to lower division
      #grupa_mistrzowska <- 8  #first half group, important only for Ekstraklasa
      #before_split <- TRUE    # TRUE-main part of a season; FALSE-final stage; parameter important only for Ekstraklasa
      #play_off <- 6            ## last play-off qualifier place (not important for Ekstraklasa)
      #bayes_method<-TRUE       ## TRUE-Naive Bayes Estimator; FALSE-uniform distribution
      
      ### Load table
      if(league==0){
        input_table <- take_table_eks()
      }else if(league==1){
        input_table <- take_table_1st()
      }else if(league==2){
        input_table <- take_table_2nd()
      }else if(league==3){
        input_table <- take_table_3rd()
      }
      
      ## Add column which represents the group: 1-champions battle; 0 -fall down (important only for Ekstraklasa)
      input_table$GROUP <- c(rep(1,grupa_mistrzowska),rep(0,nrow(input_table)-grupa_mistrzowska))
      
      ### For Bayes estimator, calculate clusters
      if(bayes_method==TRUE){
        input_table <- teams_clustering(input_table)
      }
      
      ## Load future pairings - non-Bayes
      if(bayes_method==FALSE){
        if(league==0){
          input_pairings <- take_pairings_eks(only_future=TRUE)
        }else if(league==1){
          input_pairings <- take_pairings_1st(only_future=TRUE)
        }else if(league==2){
          input_pairings <- take_pairings_2nd(only_future=TRUE)
        }else if(league==3){
          input_pairings <- take_pairings_3rd(only_future = TRUE)
        }
      }
      
      ## Load future pairings - Bayes
      if(bayes_method==TRUE){
        if(league==0){
          input_pairings <- take_pairings_eks(only_future=FALSE)
        }else if(league==1){
          input_pairings <- take_pairings_1st(only_future=FALSE)
        }else if(league==2){
          input_pairings <- take_pairings_2nd(only_future=FALSE)
        }else if(league==3){
          input_pairings <- take_pairings_3rd(only_future=FALSE)
        }
      }
      
      
      ### result vectors
      champions_vector <- c(rep(0,nrow(input_table))) ## champions
      names(champions_vector) <- input_table$TEAM
      
      euroleague_vector <- c(rep(0,nrow(input_table))) ## euro league
      names(euroleague_vector)<-input_table$TEAM
      
      majster_vector <- c(rep(0,nrow(input_table))) ## first half group
      names(majster_vector)<-input_table$TEAM
      
      fall_vector <- c(rep(0,nrow(input_table)))  ## fall down
      names(fall_vector) <- input_table$TEAM
      
      playoff_vector <- c(rep(0,nrow(input_table)))  ## play off qualification
      names(playoff_vector) <- input_table$TEAM
      
      ## For Bayes, apply the model
      if(bayes_method==TRUE){
        bayes_probs <- bayes_estimation(input_pairings,input_table)
        
        ### Keep only observations without the result in the input_pairings
        input_pairings <- input_pairings %>% filter(SCORE=="-")
      }
      
      
      for(n in 1:N){ ### Loop over the number of scenarios
        temporary_table <- input_table[,c("TEAM","POINTS","GROUP")]
        
        for(p in 1:nrow(input_pairings)){ ## Loop over each game in the pairings table
          ## Game result simulation: 1-host wins; 0-draw; 2-away team wins
          if(bayes_method==FALSE){
            game_result <- floor(runif(1,0,3)) ### uniform distribution
          }else if(bayes_method==TRUE)
            game_result <- sample(c(1,0,2),prob=bayes_probs[p,c("P_1","P_0","P_2")],1) # simulation according to bayesian probabilities
          
          ## Add 3 points for the home team in the temporary table
          if(game_result==1){
            temporary_table[temporary_table$TEAM==input_pairings[p,"HOME"],"POINTS"] <- 
              temporary_table[temporary_table$TEAM==input_pairings[p,"HOME"],"POINTS"]+3
            
          }else if(game_result==2){ ## 3 points to the away team
            temporary_table[temporary_table$TEAM==input_pairings[p,"AWAY"],"POINTS"] <- 
              temporary_table[temporary_table$TEAM==input_pairings[p,"AWAY"],"POINTS"]+3
            
          }else if(game_result==0){ ## 1 point for each team
            temporary_table[temporary_table$TEAM==input_pairings[p,"HOME"],"POINTS"] <- 
              temporary_table[temporary_table$TEAM==input_pairings[p,"HOME"],"POINTS"]+1
            
            temporary_table[temporary_table$TEAM==input_pairings[p,"AWAY"],"POINTS"] <- 
              temporary_table[temporary_table$TEAM==input_pairings[p,"AWAY"],"POINTS"]+1
          }
        }
        ###### Table sorting 
        ## Add random component to avoid sorting in alphabetical order for equal number of points
        temporary_table$RANDOM_COMP <- runif(nrow(input_table),0,1)
        
        if(before_split==TRUE | league!=0){ ### if final stage of Ekstraklasa, then sort by GROUP (1,0) first 
          sorted_table <- temporary_table %>% arrange(desc(POINTS),desc(RANDOM_COMP))
        }else{
          sorted_table <- temporary_table %>% arrange(desc(GROUP),desc(POINTS),desc(RANDOM_COMP))
        }
        
        sorted_table$PLACE<- 1:nrow(input_table) ## place column 
        
        ########### Fill the result 
        for(q in 1:nrow(sorted_table)){ ## champion/promoted
          if(sorted_table[q,"PLACE"]<=champ_promote){
            champions_vector[sorted_table$TEAM[q]]<-champions_vector[sorted_table$TEAM[q]]+1
          }
          
          if(league==0){
            if(sorted_table[q,"PLACE"]<=euro_league){ ## at least European League (only for Ekstraklasa)
              euroleague_vector[sorted_table$TEAM[q]]<-euroleague_vector[sorted_table$TEAM[q]]+1
            }
          }
          
          if(league==0){
            if(sorted_table[q,"PLACE"]<=grupa_mistrzowska){ ## Majster Group (only for Ekstraklasa)
              majster_vector[sorted_table$TEAM[q]] <- majster_vector[sorted_table$TEAM[q]]+1
            }
          }
          
          if(sorted_table[q,"PLACE"]>nrow(input_table)-fall_down){ ## fall down
            fall_vector[sorted_table$TEAM[q]] <- fall_vector[sorted_table$TEAM[q]]+1
          }
          
          
          if(league!=0 & league!=3){
            if(sorted_table[q,"PLACE"]<=play_off){ ## at least play offs - not for Ekstraklasa and 3rd league
              playoff_vector[sorted_table$TEAM[q]] <- playoff_vector[sorted_table$TEAM[q]] +1
            }
          }
          
        }
      }
      
      ### Results 
      
      if(league==0 & before_split==FALSE){  ### results for final stage of Ekstraklasa (after split)
        result_df <- data.frame(DRUŻYNA=input_table$TEAM,
                                MISTRZOSTWO=100*round(champions_vector/N,4),
                                PUCHARY=100*round(euroleague_vector/N,4),
                                UTRZYMANIE=100*round(1-fall_vector/N,4),
                                SPADEK=100*round(fall_vector/N,4))
        rownames(result_df) <- NULL
        
      }else if(league==0 & before_split==TRUE){ ## results for Ekstraklasa standard season stage (before split)
        result_df <- data.frame(DRUŻYNA=input_table$TEAM,
                                LIDER=100*round(champions_vector/N,4),
                                GRUPA_MISTRZOWSKA=100*round(majster_vector/N,4),
                                STREFA_SPADKOWA=100*round(fall_vector/N,4))
        rownames(result_df) <- NULL
        
      }else if(league!=0 & league!=3){
        result_df <- data.frame(DRUŻYNA=input_table$TEAM,
                                AWANS=100*round(champions_vector/N,4),
                                FAZA_PLAYOFF=100*round(playoff_vector/N,4),
                                UTRZYMANIE=100*round(1-fall_vector/N,4),
                                SPADEK=100*round(fall_vector/N,4))
        rownames(result_df) <- NULL
      }else if(league==3){
        result_df <- data.frame(DRUŻYNA=input_table$TEAM,
                                AWANS=100*round(champions_vector/N,4),
                                UTRZYMANIE=100*round(1-fall_vector/N,4),
                                SPADEK=100*round(fall_vector/N,4))
      }
      
      if(bayes_method==TRUE){
        result_list <- list(PROBS=bayes_probs,TABLE=result_df)
        return(result_list)
      }else{
        result_list <- list(TABLE=result_df)
        return(result_list)
      }
    }
    
    
    #############################################################################
    ############################################################################
    
    
    #########################    REAL SERVER CODE ############################
    
    
    o_scenarios <- reactive({as.numeric(input$in_scenarios)})
    o_league<-reactive({as.numeric(input$in_league)})
    o_stage<-reactive({as.logical(input$in_stage)})
    o_fall_down<-reactive({as.numeric(input$in_fall_down)})
    o_promoted<-reactive({as.numeric(input$in_promoted)})
    o_chmp_group<-reactive({as.numeric(input$in_chmp_group)})
    o_playoff<-reactive({as.numeric(input$in_playoff)})
    o_method<-reactive({as.logical(input$in_method)})
    o_cups<-reactive({as.numeric(input$in_cups)})
    
    observeEvent(input$in_scenarios,{
      if(as.numeric(input$in_scenarios)!=input$in_text_scenarios){
        updateTextInput(session=session,inputId="in_text_scenarios",value=input$in_scenarios)
      }
    })
    
    observeEvent(input$in_text_scenarios,{
      if(as.numeric(input$in_scenarios)!=input$in_text_scenarios){
        updateSliderInput(session=session,inputId="in_scenarios",value=input$in_text_scenarios)
      }
    })
    
    observeEvent(input$in_league,{ 
      if(input$in_league!="0"){
        disable("in_stage")
        disable("in_cups")
        disable("in_chmp_group")
        
      }else{
        enable("in_stage")
        enable("in_cups")
        enable("in_chmp_group")
      }
    })
    
    
    observeEvent(input$in_league,{
      if(input$in_league=="0" | input$in_league=="3"){
        disable("in_playoff")
      }else{
        enable("in_playoff")
      }
    })
    
    
    
    observeEvent(input$in_button,{
      shinyalert("Komunikat:", "Symulacja uruchomiona", type = "info")
    })
    
    
    observeEvent(input$in_button,{ 
      
      o_wyniki <- season_simulation(N=o_scenarios(),
                                    league=o_league(),
                                    champ_promote=o_promoted(),
                                    euro_league=ifelse(o_league()==0,o_cups(),0),
                                    fall_down=o_fall_down(),
                                    grupa_mistrzowska=ifelse(o_league()==0,o_chmp_group(),0),
                                    before_split=ifelse(o_league()==0,o_stage(),FALSE),
                                    play_off=ifelse(o_league()!=0,o_playoff(),0),
                                    bayes_method=o_method())
      
      output$out_df<-renderTable(o_wyniki$TABLE)
      
      o_rows <- nrow(o_wyniki$TABLE)/2
      
      if(input$in_method==TRUE){
          o_probs <- o_wyniki$PROBS
          o_probs$P_1<-round(o_probs$P_1,3)
          o_probs$P_0<-round(o_probs$P_0,3)
          o_probs$P_2<-round(o_probs$P_2,3)
          colnames(o_probs)<-c("HOME","AWAY","1","0","2")
          output$out_probs<-renderDataTable({o_probs},filter="top",rownames=FALSE,
                                            options=list(pageLength = o_rows, 
                                                         info = FALSE,
                                                         lengthMenu = list(c(o_rows,o_rows*2,o_rows*3,o_rows*4, -1), 
                                                                           c(as.character(o_rows),as.character(o_rows*2),
                                                                             as.character(o_rows*3),as.character(o_rows*4), "All")) 
                                                         )
                                            
                                            )
      }else{
        output$out_probs<-renderDataTable(NULL)
      }
            
    })
      
      
    
    observeEvent(input$in_button_2,{
      shinyalert("Komunikat:", "Okna wyników zostały wyczyszczone", type = "success")
    })  
    
    observeEvent(input$in_button_2,{
      output$out_df<-renderTable(NULL)
      output$out_probs<-renderDataTable(NULL)
    })
    
  }
)