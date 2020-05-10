import requests
from bs4 import BeautifulSoup
import numpy
import pandas
import random
from numpy.random import randint,rand


##################################################

def take_table(in_league):
    
    if in_league==0: ## Ekstraklasa
        url="https://wyniki.interia.pl/rozgrywki-R-polska-ekstraklasa-2019-2020,cid,3?from=mobile"
    elif in_league==1: ## I liga
        url="https://wyniki.interia.pl/rozgrywki-L-polska-1-liga,cid,696,sort,I"
    elif in_league==2: ## II liga
        url="https://wyniki.interia.pl/rozgrywki-L-polska-2-liga,cid,668,sort,I"
    elif in_league==3: ## III liga gr 3
        url="https://wyniki.interia.pl/rozgrywki-R-polska-3-liga-grupa-3,cid,673,rid,4047,sort,I"
    
    
    ht=requests.get(url).text
    source=BeautifulSoup(ht,"lxml")

    rank_code=source.find_all("span",class_="rank")
    rank=[]
    for i in rank_code:
        rank.append(int(i.text))
        
    teams_code=source.find_all("td",class_="name")
    teams=[]
    for i in teams_code:
        teams.append(i.text.strip())


    more_code=source.find_all("td")  ##3,16,29
    games=[]
    for i in range(3,13*len(teams)+1,13):
        games.append(int(more_code[i].text))


    points_code=source.find_all("td",class_="score")
    points=[]
    for i in points_code:
        points.append(int(i.text))
        
        
    wins=[]
    for i in range(6,13*len(teams)+1,13):
        wins.append(int(more_code[i].text))


    draws=[]
    for i in range(7,13*len(teams)+1,13):
        draws.append(int(more_code[i].text))


    loses=[]
    for i in range(8,13*len(teams)+1,13):
        loses.append(int(more_code[i].text))


    all_goals=[]
    for i in range(10,13*len(teams)+1,13):
        all_goals.append(more_code[i].text)

    goals_plus=[]
    goals_minus=[]
    for i in all_goals:
        goals_plus.append(int(i.split("-")[0].strip()))
        goals_minus.append(int(i.split("-")[1].strip()))

    out_table=pandas.DataFrame({"PLACE":rank,"TEAM":teams,"GAMES":games,"POINTS":points,"WINS":wins,"DRAWS":draws,"LOSES":loses,
                               "GOALS_PLUS":goals_plus,"GOALS_MINUS":goals_minus})
    return out_table
 
 ####################################################################
 
def take_pairings(in_league,in_upcoming_only):
    if in_league==0: ## Ekstraklasa
        url="https://wyniki.interia.pl/rozgrywki-R-polska-ekstraklasa-2019-2020,cid,3?from=mobile"
        start_index=16
    elif in_league==1: ## I liga
        url="https://wyniki.interia.pl/rozgrywki-L-polska-1-liga,cid,696,sort,I"
        start_index=18
    elif in_league==2: ## II liga
        url="https://wyniki.interia.pl/rozgrywki-L-polska-2-liga,cid,668,sort,I"
        start_index=18
    elif in_league==3: ## III liga gr 3
        url="https://wyniki.interia.pl/rozgrywki-R-polska-3-liga-grupa-3,cid,673,rid,4047,sort,I"
        start_index=18

    ht=requests.get(url).text
    source=BeautifulSoup(ht,"lxml")
    
    home_code=source.find_all("span",class_="team teamA")[start_index:]
    home=[]
    for i in home_code:
        home.append(i.text.strip())
        
    away_code=source.find_all("span",class_="team teamB")[start_index:]
    away=[]
    for i in away_code:
        away.append(i.text.strip())
    
    
    goals_code=source.find_all("span",class_="goals")[start_index:]
    goals=[]
    for i in goals_code:
        goals.append(i.text.strip())
    
    
    out_table=pandas.DataFrame({"HOME":home,"AWAY":away,"RESULT":goals})
    
    if in_upcoming_only==True:
        return out_table[out_table["RESULT"]=="-"]
    elif in_upcoming_only==False:
        return out_table

 ###########################################################################################
  ###########################################################################################
def run_simulation(in_scenarios,in_league,in_stage=0,in_promoted=2,in_cups=3,in_playoffs=6,in_degraded=3,in_simulation_method=1): 
    ## Download table
    league_table=take_table(in_league)

    ## Leave only POINTS and TEAM columns
    league_table_process=league_table[["TEAM","POINTS"]]

    ## Download pairings
    if in_simulation_method==0: ## Bayes
        pairings=take_pairings(in_league,in_upcoming_only=False)
    elif in_simulation_method==1: ## uniform
        pairings=take_pairings(in_league,in_upcoming_only=True)

    ## Result vectors
    v_champion=pandas.Series(numpy.zeros(len(league_table.index)),index=league_table["TEAM"])
    v_promoted=pandas.Series(numpy.zeros(len(league_table.index)),index=league_table["TEAM"])
    v_degraded=pandas.Series(numpy.zeros(len(league_table.index)),index=league_table["TEAM"])
    v_cups=pandas.Series(numpy.zeros(len(league_table.index)),index=league_table["TEAM"])
    v_playoffs=pandas.Series(numpy.zeros(len(league_table.index)),index=league_table["TEAM"])
    v_champion_division=pandas.Series(numpy.zeros(len(league_table.index)),index=league_table["TEAM"])
    v_degrade_division=pandas.Series(numpy.zeros(len(league_table.index)),index=league_table["TEAM"])


    for i in range(1,in_scenarios+1):
        
        temporary_table=pandas.DataFrame(league_table_process,copy=True)
        
        for game in range(0,len(pairings.index)):
        
        ## Random results for all games
            random_result=int(randint(0,3,1))
            if random_result==1:
                temporary_table.loc[temporary_table["TEAM"]==pairings.iloc[game]["HOME"],["POINTS"]]+=3
            elif random_result==2:
                temporary_table.loc[temporary_table["TEAM"]==pairings.iloc[game]["AWAY"],["POINTS"]]+=3
            elif random_result==0:
                temporary_table.loc[temporary_table["TEAM"]==pairings.iloc[game]["AWAY"],["POINTS"]]+=1
                temporary_table.loc[temporary_table["TEAM"]==pairings.iloc[game]["HOME"],["POINTS"]]+=1
            
        ## Random feature for sorting purposes
        random_feature=[]
        for r in range(0,len(temporary_table.index)):
            random_feature.append(float(rand()))
            
        temporary_table["RANDOM"]=random_feature
            
        ## Sort table
        temporary_table.sort_values(by=["POINTS","RANDOM"],ascending=False,inplace=True)
        temporary_table.index=list(range(0,len(temporary_table.index)))
        temporary_table["PLACE"]=list(range(1,len(temporary_table.index)+1))
            
        ## Results
        for j in range(0,len(temporary_table.index)):
                
            ## Champion
            if in_league==0 and in_stage==1:
                if temporary_table.iloc[j]["PLACE"]==1:
                    v_champion[temporary_table.iloc[j]["TEAM"]]+=1
                    
                ## Cups
                if temporary_table.iloc[j]["PLACE"]<=in_cups:
                    v_cups[temporary_table.iloc[j]["TEAM"]]+=1           
                
            ## Ekstraklasa divisions
            if in_league==0 and in_stage==0:
                if temporary_table.iloc[j]["PLACE"]<=8:
                    v_champion_division[temporary_table.iloc[j]["TEAM"]]+=1
                else:
                    v_degrade_division[temporary_table.iloc[j]["TEAM"]]+=1
                
            ## Promoted
            if in_league!=0:
                if temporary_table.iloc[j]["PLACE"]<=in_promoted:
                    v_promoted[temporary_table.iloc[j]["TEAM"]]+=1 
                
            ## Degraged
            if temporary_table.iloc[j]["PLACE"]>len(temporary_table.index)-in_degraded:
                v_degraded[temporary_table.iloc[j]["TEAM"]]+=1
                
            ## Playoffs
            if in_league==1 or in_league==2:
                if temporary_table.iloc[j]["PLACE"]<=in_playoffs:
                    v_playoffs[temporary_table.iloc[j]["TEAM"]]+=1 
            

    if in_league==0 and in_stage==0:
        return pandas.DataFrame([v_champion_division/in_scenarios,v_degrade_division/in_scenarios],index=["GRUPA_MISTRZOWSKA","GRUPA_SPADKOWA"]).transpose().reset_index()
    elif in_league==0 and in_stage==1:
        return pandas.DataFrame([v_champion/in_scenarios,v_cups/in_scenarios,v_degraded/in_scenarios],index=["MISTRZOSTWO","PUCHARY","SPADEK"]).transpose().reset_index()
    elif in_league==1 or in_league==2:
        return pandas.DataFrame([v_promoted/in_scenarios,v_playoffs/in_scenarios,v_degraded/in_scenarios],index=["AWANS","BARAŻE","SPADEK"]).transpose().reset_index()
    elif in_league==3:
        return pandas.DataFrame([v_promoted/in_scenarios,v_degraded/in_scenarios],index=["AWANS","SPADEK"]).transpose().reset_index()

###########################################################################################
###########################################################################################