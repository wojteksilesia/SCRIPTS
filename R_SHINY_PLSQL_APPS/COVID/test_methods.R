library(readxl)
library(httr)
library(ggplot2)
library(dplyr)
library(utils)

#create the URL where the dataset is stored with automatic updates every day
# <- paste("https://www.ecdc.europa.eu/sites/default/files/documents/COVID-19-geographic-disbtribution-worldwide-",format(Sys.time(), "%Y-%m-%d"), ".xlsx", sep = "")
#download the dataset from the website to a local temporary file
#GET(url, authenticate(":", ":", type="ntlm"), write_disk(tf <- tempfile(fileext = ".xlsx")))
#read the Dataset sheet into “R”
#data_covid <- read_excel(tf)
GET("https://opendata.ecdc.europa.eu/covid19/casedistribution/csv", authenticate(":", ":", type="ntlm"), write_disk(tf <- tempfile(fileext = ".csv")))

#read the Dataset sheet into “R”. The dataset will be called "data".
data_covid <- read.csv(tf)

df_data_sorted <- data_covid %>% arrange(dateRep)

############################################################################
###########################################################################

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
  country_df$cases_dynamic<-cases_dynamic*100
 
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

##############################################################

poland_df<-show_country_data(input_df=data_covid,input_country="Poland",input_day_0_cases=0)
usa_df<-show_country_data(input_df=data_covid,input_country="United_States_of_America",input_day_0_cases=50)

options(scipen=999)
plot(x=poland_df$day_number,y=poland_df$all_cases,type="l",ylim=c(0,100000),xlim=c(0,50),yaxt="n",lwd=2)
lines(x=usa_df$day_number,y=usa_df$all_cases,col="red",yaxt="n")
legend(x=40,y=70000,
       legend=c("Poland","USA"),
       col=c("black","red"),
       lty=c(1,1))
axis(side=2,at=seq(0,100000,by=10000),las=1,cex.axis=0.7)


plot(x=poland_df$day_number,y=poland_df$cases_dynamic,type="l")


View(cbind(poland_df$day_number,poland_df$all_cases,italy_df$day_number,italy_df$all_cases))


my_df<-show_country_data(input_df=data_covid,input_country="Poland",input_day_0_cases=0)
ggplot(data=my_df,aes(x=day_number,y=all_cases))+geom_line()


my_df$v<-my_df$day_number^2


m<-lm(data=my_df,all_cases~v)
summary(m)

ltforecast<-m$coefficients[1]+my_df$v*m$coefficients[2]
plot(x=my_df$day_number,y=my_df$all_cases,type="l")
lines(ltforecast,col="red")


df_data_sorted%>%filter(countriesAndTerritories=="Italy")
