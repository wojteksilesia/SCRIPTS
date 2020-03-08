from bs4 import BeautifulSoup
import requests
import numpy
import pandas
import random 


##########################################
###########  TAKE TABLE ##################

def take_table(league):
    ## 0-Ekstraklasa; 1- I liga; 2-II liga; 3- III liga gr.III
    if league==0:
        webpage=requests.get("https://wyniki.interia.pl/rozgrywki-R-polska-ekstraklasa,cid,3,sort,I?from=mobile").text
    elif league==1:
        webpage=requests.get("https://wyniki.interia.pl/rozgrywki-L-polska-1-liga,cid,696,sort,I").text
    elif league==2:
        webpage=requests.get("https://wyniki.interia.pl/rozgrywki-L-polska-2-liga,cid,668,sort,I").text
    elif league==3:
        webpage=requests.get("https://wyniki.interia.pl/rozgrywki-R-polska-3-liga-grupa-3,cid,673,rid,4047,sort,I").text

    soup=BeautifulSoup(webpage,"lxml")

    ## Scrap HTML-a tabeli
    ekst_table=soup.find("table",class_="standings")

    ## Kluby
    teams=[]
    clubs=ekst_table.find_all("td",class_="name")
    for c in clubs:
        club=c.find("span").text.strip()
        teams.append(club)

    ## Liczba meczów
    szpile=ekst_table.find_all("td")
    mecze=[]
    for t in range(3,len(szpile)+1,13):
        mecze.append(szpile[t])


    ## Liczba punktów
    points=ekst_table.find_all("td",class_="score")
    punkty=[]
    for p in points:
        punkty.append(int(p.text))


    result_dict={"MIEJSCE":list(range(1,len(teams)+1)),
                "DRUŻYNA":teams,
                "PUNKTY":punkty}

    result_df=pandas.DataFrame(result_dict)
    result_df.sort_values(["PUNKTY","MIEJSCE"],ascending=[False,True],inplace=True)
    return result_df
    
###############################################################
###############################################################

###############################################################
#################### TAKE PAIRINGS ############################

def take_pairings(only_future,league):
    # 0-Ekstraklasa; 1-I liga; 2- II liga; 3- III liga gr.3
    
    if league==0:
        webpage=requests.get("https://wyniki.interia.pl/rozgrywki-R-polska-ekstraklasa,cid,3,sort,I?from=mobile").text
    elif league==1:
        webpage=requests.get("https://wyniki.interia.pl/rozgrywki-L-polska-1-liga,cid,696,sort,I").text
    elif league==2:
        webpage=requests.get("https://wyniki.interia.pl/rozgrywki-L-polska-2-liga,cid,668,sort,I").text
    elif league==3:
        webpage=requests.get("https://wyniki.interia.pl/rozgrywki-R-polska-3-liga-grupa-3,cid,673,rid,4047,sort,I").text       

    soup=BeautifulSoup(webpage,"lxml")

    terminarz=soup.find("div",class_="box boxSchedule")

    gospodarze_html=terminarz.find_all("span",class_="team teamA")
    gospodarze=[]
    for g in gospodarze_html:
        gospodarze.append(g.text)

    goscie_html=terminarz.find_all("span",class_="team teamB")
    goscie=[]
    for g in goscie_html:
        goscie.append(g.text)

    goals_html=terminarz.find_all("span",class_="goals")
    goals=[]
    for g in goals_html:
        goals.append(g.text)

    output_df=pandas.DataFrame({"HOME":gospodarze,"AWAY":goscie,"RESULT":goals})

    if only_future==True:
        return output_df[output_df["RESULT"]=="-"]
    else:
        return output_df

##################################################################
##################################################################

################# SIMULATION ###################################

def simulation(N,chmp,cups,degraded,first_half,final_stage,division):
    #N=100
    #chmp=1
    #cups=3
    #degraded=3
    #first_half=8
    #final_stage=True ## True-po podziale punktów
    #division 0-Ekstraklasa; 1-I liga; 2-II liga; 3-III liga gr.3

    league_table=take_table(league=division)
    upcoming_games=take_pairings(only_future=True,league=division)

    if final_stage==True:
        f_group=numpy.append(numpy.repeat(1,first_half),numpy.repeat(0,len(league_table.index)-first_half))
        league_table["GRUPA"]=f_group

    v_champ=pandas.Series(numpy.zeros(len(league_table.index)),index=league_table["DRUŻYNA"])
    v_cups=pandas.Series(numpy.zeros(len(league_table.index)),index=league_table["DRUŻYNA"])
    v_degraded=pandas.Series(numpy.zeros(len(league_table.index)),index=league_table["DRUŻYNA"])
    v_first_half=pandas.Series(numpy.zeros(len(league_table.index)),index=league_table["DRUŻYNA"])

    for scenario in range(1,N+1):
        league_table_work=league_table.copy()
        for g in range(0,len(upcoming_games)):
            result=random.randint(0,2)
            idx_home=list(numpy.where(league_table["DRUŻYNA"]==upcoming_games["HOME"].iloc[g]))[0][0]
            idx_away=list(numpy.where(league_table["DRUŻYNA"]==upcoming_games["AWAY"].iloc[g]))[0][0]

            if result==0:
                league_table_work.at[idx_home,"PUNKTY"]=league_table_work.at[idx_home,"PUNKTY"]+1
                league_table_work.at[idx_away,"PUNKTY"]=league_table_work.at[idx_away,"PUNKTY"]+1

            elif result==1:
                league_table_work.at[idx_home,"PUNKTY"]=league_table_work.at[idx_home,"PUNKTY"]+3

            elif result==2:
                league_table_work.at[idx_away,"PUNKTY"]=league_table_work.at[idx_away,"PUNKTY"]+3
        
        if final_stage==True:
            league_table_work.sort_values(["GRUPA","PUNKTY"],ascending=[False,False],inplace=True)
        else:
            league_table_work.sort_values("PUNKTY",ascending=False,inplace=True)
        
        league_table_work["MIEJSCE"]=list(range(1,len(league_table.index)+1))
        league_table_work.reset_index(inplace=True)
        league_table_work.drop("index",axis=1,inplace=True)

        
        for r in range(0,len(league_table_work.index)):
            ### Mistrzostwo/awans 
            if league_table_work["MIEJSCE"].iloc[r]<=chmp:
                v_champ[league_table_work["DRUŻYNA"].iloc[r]]=v_champ[league_table_work["DRUŻYNA"].iloc[r]]+1
            ## Puchary
            if league_table_work["MIEJSCE"].iloc[r]<=cups:
                v_cups[league_table_work["DRUŻYNA"].iloc[r]]=v_cups[league_table_work["DRUŻYNA"].iloc[r]]+1
            ## Spadek
            if league_table_work["MIEJSCE"].iloc[r]>(len(league_table_work.index)-degraded):
                v_degraded[league_table_work["DRUŻYNA"].iloc[r]]=v_degraded[league_table_work["DRUŻYNA"].iloc[r]]+1
            ## Górna ósemka
            if league_table_work["MIEJSCE"].iloc[r]<=first_half:
                v_first_half[league_table_work["DRUŻYNA"].iloc[r]]=v_first_half[league_table_work["DRUŻYNA"].iloc[r]]+1
        
    v_champ=round(v_champ/N,2)
    v_cups=round(v_cups/N,2)
    v_degraded=round(v_degraded/N,2)
    v_first_half=round(v_first_half/N,2)
    
    if final_stage==True:
        out_df=pandas.DataFrame({"MISTRZOSTWO":v_champ,"PUCHARY":v_cups,"SPADEK":v_degraded})
    else:
        out_df=pandas.DataFrame({"LIDER":v_champ,"GRUPA MISTRZOWSKA":v_first_half,"STREFA SPADKOWA":v_degraded})
    
    return out_df

##################################################################
##################################################################