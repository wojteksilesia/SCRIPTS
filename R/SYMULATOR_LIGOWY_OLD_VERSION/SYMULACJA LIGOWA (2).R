library(readxl)
library(sqldf)
library(ggplot2)

rm(list=ls())

set.seed(1920)

### Wczytanie tabeli

tabela <- read_excel("C:/Users/Wojtek/Desktop/SYMULACJA_LIGA.xlsx")

#### Wczytanie terminarza

terminarz <- read_excel("C:/Users/Wojtek/Desktop/SYMULACJA_LIGA.xlsx", 
                             sheet = "TERMINARZ")

N<-100## liczba scenariuszy

punkty_do_utrzymania <- rep(NA,N)


### Zdefiniowanie macierzy z flagami oznczaj¹cymi spadek, awans i bara¿

spadek<-matrix(nrow=nrow(tabela),ncol=N)
rownames(spadek)<-tabela$Klub

awans<-matrix(nrow=nrow(tabela),ncol=N)
rownames(awans)<-tabela$Klub

utrzymanie<-matrix(nrow=nrow(tabela),ncol=N)
rownames(utrzymanie)<-tabela$Klub

##bara¿<-matrix(nrow=nrow(tabela),ncol=N)
##rownames(bara¿)<-tabela$Klub

for(h in 1:N){
  
  #### wczytanie ponownie tabeli, ¿eby punkty w nieskoñczonoœæ nie by³y nadpisywane
  
  tabela <- read_excel("C:/Users/Wojtek/Desktop/SYMULACJA_LIGA.xlsx") 
  

##### Symulacja wyników

wyniki<-rep(NA,nrow(terminarz))
for(i in 1:nrow(terminarz)){
  wyniki[i]<-round(runif(1,-0.5,2.5),0)
}

###  Aktualizacja liczby punktów w tabeli w zale¿noœci od wyniku

for(j in 1:length(wyniki)){
  if(wyniki[j]==0){
    tabela[tabela$Klub==as.character(terminarz[j,1]),"Punkty"]<-tabela[tabela$Klub==as.character(terminarz[j,1]),"Punkty"]+1
    tabela[tabela$Klub==as.character(terminarz[j,2]),"Punkty"]<-tabela[tabela$Klub==as.character(terminarz[j,2]),"Punkty"]+1
  }else if(wyniki[j]==1){
    tabela[tabela$Klub==as.character(terminarz[j,1]),"Punkty"]<-tabela[tabela$Klub==as.character(terminarz[j,1]),"Punkty"]+3
    tabela[tabela$Klub==as.character(terminarz[j,2]),"Punkty"]<-tabela[tabela$Klub==as.character(terminarz[j,2]),"Punkty"]+0
  }else if(wyniki[j]==2){
    tabela[tabela$Klub==as.character(terminarz[j,1]),"Punkty"]<-tabela[tabela$Klub==as.character(terminarz[j,1]),"Punkty"]+0
    tabela[tabela$Klub==as.character(terminarz[j,2]),"Punkty"]<-tabela[tabela$Klub==as.character(terminarz[j,2]),"Punkty"]+3
  }
}

#### Posortowanie tabeli

tabela_koncowa<- sqldf("select Klub, Punkty
                        from tabela
                        order by Punkty desc")

tabela_koncowa<-cbind(1:nrow(tabela),tabela_koncowa)
colnames(tabela_koncowa)<-colnames(tabela)

###### Przypisanie flagi spadku

flaga_spadek<-c()
for(s in 1:nrow(tabela)){
  if(tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[s,2]),"Miejsce"]==15 |
     tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[s,2]),"Miejsce"]==16 |
     tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[s,2]),"Miejsce"]==17 |
     tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[s,2]),"Miejsce"]==18){
            flaga_spadek[s]<-1
  }else{
    flaga_spadek[s]<-0
  }
}

#### Przypisanie flagi awansu

flaga_awans<-c()
for(a in 1:nrow(tabela)){
  if(tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[a,2]),"Miejsce"]==1 |
     tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[a,2]),"Miejsce"]==2 |
     tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[a,2]),"Miejsce"]==3){
    flaga_awans[a]<-1
  }else{
    flaga_awans[a]<-0
  }
}


#### Przypisanie flagi bara¿u 

#flaga_bara¿<-c()
#for(b in 1:nrow(tabela)){
 # if(tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[b,2]),"Miejsce"]==4){
  #  flaga_bara¿[b]<-1
  #}else{
   # flaga_bara¿[b]<-0
  #}
#}


#### Przypisanie flagi utrzymania

flaga_utrzymanie<-c()
for(u in 1:nrow(tabela)){
  if(
    #tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[u,2]),"Miejsce"]!=4 &
     tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[u,2]),"Miejsce"]!=3 &
     tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[u,2]),"Miejsce"]!=2 &
     tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[u,2]),"Miejsce"]!=1 &
     tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[u,2]),"Miejsce"]!=15 &
     tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[u,2]),"Miejsce"]!=16 &
     tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[u,2]),"Miejsce"]!=17 &
     tabela_koncowa[tabela_koncowa$Klub==as.character(tabela[u,2]),"Miejsce"]!=18){
    flaga_utrzymanie[u]<-1
  }else{
    flaga_utrzymanie[u]<-0
  }
}

##### Uzupe³nienie macierzy spadek, awans, bara¿, utrzymanie

spadek[,h]<-flaga_spadek
awans[,h]<-flaga_awans
#bara¿[,h]<-flaga_bara¿
utrzymanie[,h]<-flaga_utrzymanie


punkty_do_utrzymania[h]<-tabela_koncowa[tabela_koncowa$Miejsce==14,"Punkty"]


print(paste(N-h,"scenariuszy do koñca"))

} ### zamkniêcie pêtli for z h


### Obliczenie procentowych szans na poszczególny wynik dla ka¿dej dru¿yny

##### AWANS

szanse_awans<-c()
for(i in 1:nrow(tabela)){
  szanse_awans[i]<-(sum(awans[i,]))/N
}

names(szanse_awans)<-tabela$Klub


### SPADEK

szanse_spadek<-c()
for(i in 1:nrow(tabela)){
  szanse_spadek[i]<-(sum(spadek[i,]))/N
}

names(szanse_spadek)<-tabela$Klub

#### BARA¯

#szanse_bara¿<-c()
#for(i in 1:nrow(tabela)){
  #szanse_bara¿[i]<-(sum(bara¿[i,]))/N
#}

#names(szanse_bara¿)<-tabela$Klub


#### UTRZYMANIE (POZOSTANIE W LIDZE)

szanse_pozostanie<-c()
for(i in 1:nrow(tabela)){
  szanse_pozostanie[i]<-(sum(utrzymanie[i,]))/N
}

names(szanse_pozostanie)<-tabela$Klub


szanse_utrzymanie <- szanse_pozostanie+szanse_awans

#View(rbind(szanse_spadek,szanse_awans,szanse_bara¿,szanse_utrzymanie))

View(t(rbind(szanse_spadek,szanse_awans,szanse_pozostanie,szanse_utrzymanie)))

View(as.matrix(punkty_do_utrzymania))


ggplot(data=data.frame(punkty_do_utrzymania),aes(x=punkty_do_utrzymania))+
  geom_histogram(binwidth=1,colour="black")+
  scale_x_continuous(limits = c(30,50),breaks=30:50)+
  ggtitle("MINIMUM PUNKTÓW POTRZEBNYCH DO UTRZYMANIA")
