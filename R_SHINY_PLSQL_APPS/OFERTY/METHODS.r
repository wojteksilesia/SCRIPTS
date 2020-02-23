### REQUIRED PACKAGES ###
library(rvest)
library(dplyr)
library(RJDBC)


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
  
  r <- try(dbSendUpdate(gv_con,q),silent=F)
  
  if(length(r)==0){
    return("DODANO REKORD DO TABELI")
  }else{
    return("WYSTĄPIŁ BŁĄD - NIE DODANO REKORDU DO TABELI")
  }
  
}


########################################

####################################
##########  API_ADD_TECH ##############


api_add_tech <- function(tech,code){
  
  q <- paste0("DECLARE
              BEGIN
                PCG_PRACUJ_PARAMS.PRACUJ_ADD_TECH('",tech,"','",code,"');
              END;
             ")
  
  r <- try(dbSendUpdate(gv_con,q),silent=F)
  
  if(length(r)==0){
    return("DODANO REKORD DO TABELI")
  }else{
    return("WYSTĄPIŁ BŁĄD - NIE DODANO REKORDU DO TABELI")
  }
  
}














