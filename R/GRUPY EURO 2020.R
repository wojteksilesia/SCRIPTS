
library(ggplot2)

euro_2020 <- function(){

rm(list=ls())




a1 <- "W£OCHY"

b1 <- "BELGIA"
b2 <- "ROSJA"
b3 <- "DANIA"

c1 <- "UKRAINA"
c2 <- "HOLANDIA"

d1<- "ANGLIA"

e1 <- "HISZPANIA"

f1<- "NIEMCY"


koszyk_2 <- c("FRANCJA","POLSKA","SZWAJCARIA","CHORWACJA")

koszyk_3 <- c("PORTUGALIA","TURCJA","AUSTRIA","SZWECJA","CZECHY")

walia_finlandia <- c("WALIA","FINLANDIA")

baraze_b <- c("BOŒNIA","IRLANDIA PÓ£NOCNA","S£OWACJA","IRLANDIA")

baraze_d <- c("GRUZJA","BIA£ORUŒ","MACEDONIA","KOSOWO")


## Split bara¿owy

sb <- floor(runif(1,1,5)) 

if(sb==1){
  baraze_a <- c("ISLANDIA","RUMUNIA","IZRAEL","WÊGRY")
  baraze_c <- c("SZKOCJA","BU£GARIA","NORWEGIA","SERBIA")
}else if(sb==2){
  baraze_a <- c("ISLANDIA","RUMUNIA","BU£GARIA","WÊGRY")
  baraze_c <- c("SZKOCJA","IZRAEL","NORWEGIA","SERBIA")
}else if(sb==3){
  baraze_a <- c("ISLANDIA","RUMUNIA","BU£GARIA","IZRAEL")
  baraze_c <- c("SZKOCJA","WÊGRY","NORWEGIA","SERBIA")
}else{ 
  baraze_a <- c("ISLANDIA","WÊGRY","BU£GARIA","IZRAEL")
  baraze_c <- c("SZKOCJA","RUMUNIA","NORWEGIA","SERBIA")
}


## Z których bara¿y dru¿yny trafi¹ do grup C, D i F

choose_baraze <- c("A","C","D")

## Grupa C
c4_baraz <- sample(choose_baraze,1)

choose_baraze[which(choose_baraze==c4_baraz)] <- NA

choose_baraze<- na.omit(choose_baraze)



if(c4_baraz=="D"){
  c4_vector <- baraze_d
}else if(c4_baraz=="C"){
  c4_vector<- baraze_c
}else if(c4_baraz=="A"){
  c4_vector<-baraze_a
}


### Grupa D

d4_baraz <-"A"

while(d4_baraz=="A"){
  d4_baraz<-sample(choose_baraze,1)
}


choose_baraze[which(choose_baraze==d4_baraz)] <- NA

choose_baraze<- na.omit(choose_baraze)


if(d4_baraz=="D"){
  d4_vector <- baraze_d
}else if(d4_baraz=="C"){
  d4_vector<- baraze_c
}


### Grupa F

f4_baraz <- choose_baraze

if(f4_baraz=="D"){
  f4_vector <- baraze_d
}else if(f4_baraz=="C"){
  f4_vector<- baraze_c
}else if(f4_baraz=="A"){
  f4_vector<-baraze_a
}




############

a2 <- sample(koszyk_2,1)

koszyk_2[which(koszyk_2==a2)] <- NA

koszyk_2 <- na.omit(koszyk_2)


####

a3 <- sample(koszyk_3,1)

koszyk_3[which(koszyk_3==a3)] <- NA

koszyk_3 <- na.omit(koszyk_3)


####

a4 <- sample(walia_finlandia,1)

##

b4 <- walia_finlandia[which(walia_finlandia!=a4)]


####

c3 <- sample(koszyk_3,1)

koszyk_3[which(koszyk_3==c3)] <-NA

koszyk_3 <- na.omit(koszyk_3)


### 

c4 <- sample(c4_vector,1)

##

d2 <- sample(koszyk_2,1)

koszyk_2[which(koszyk_2==d2)] <- NA
koszyk_2 <- na.omit(koszyk_2)


## d3

d3 <- sample(koszyk_3,1)

koszyk_3[which(koszyk_3==d3)] <-NA

koszyk_3 <- na.omit(koszyk_3)


## d4

d4 <- sample(d4_vector,1)

## e2

e2 <- sample(koszyk_2,1)

f2 <- koszyk_2[which(koszyk_2!=e2)] 

## 

e3 <- sample(koszyk_3,1)

f3 <- koszyk_3[which(koszyk_3!=e3)] 

###

e4 <- sample(baraze_b,1)

##

f4 <- sample(f4_vector,1)




######################


grupa_a <- data.frame(KOSZYK=1:4,KRAJ=c(a1,a2,a3,a4))
grupa_b<- data.frame(KOSZYK=1:4,KRAJ=c(b1,b2,b3,b4))
grupa_c<- data.frame(KOSZYK=1:4,KRAJ=c(c1,c2,c3,c4))
grupa_d<- data.frame(KOSZYK=1:4,KRAJ=c(d1,d2,d3,d4))
grupa_e<- data.frame(KOSZYK=1:4,KRAJ=c(e1,e2,e3,e4))
grupa_f<- data.frame(KOSZYK=1:4,KRAJ=c(f1,f2,f3,f4))




#View(grupa_b)
#View(grupa_c)
#View(grupa_d)
#View(grupa_e)
#View(grupa_f)


grupy <- list(grupa_a,grupa_b,grupa_c,grupa_d,grupa_e,grupa_f)



kraje <- c(as.character(grupa_a$KRAJ),as.character(grupa_b$KRAJ),
           as.character(grupa_c$KRAJ),as.character(grupa_d$KRAJ),
           as.character(grupa_e$KRAJ),as.character(grupa_f$KRAJ))

ix <- c(rep(5,8),rep(45,8),rep(85,8))
igrek <- c(rep(c(90,83,76,69,40,33,26,19),2))

df <- data.frame(ix=1:100,igrek=1:100)


ty <- c(rep(100,3),rep(50,3))
tx <- rep(c(5,45,85),2)

tg <- c("GRUPA A","GRUPA C","GRUPA E","GRUPA B","GRUPA D","GRUPA F")

#xaxt="n",yaxt="n"

plot(df,col="white",xlab=NA,ylab=NA,ylim=c(15,100),xaxt="n",yaxt="n",main="SYMULACJA GRUP EURO 2020")
text(ix,igrek,kraje,cex=ifelse(kraje=="POLSKA",1,0.7),col=ifelse(kraje=="POLSKA","red","black"))
text(tx,ty,tg,cex=1.2,col="blue")

}