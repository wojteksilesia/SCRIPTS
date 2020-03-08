from bs4 import BeautifulSoup
import requests
import numpy
import pandas

webpage=requests.get("https://wyniki.interia.pl/rozgrywki-R-polska-ekstraklasa,cid,3,sort,I?from=mobile").text

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
    punkty.append(p.text)


result_dict={"MIEJSCE":list(range(1,17)),
            "DRUŻYNA":teams,
            "PUNKTY":punkty}
			

result_df=pandas.DataFrame(result_dict)
result_df.sort_values("PUNKTY",ascending=False,inplace=True)

################################################################
################################################################
#########   TERMINARZ ############################

from bs4 import BeautifulSoup
import requests
import numpy
import pandas

webpage=requests.get("https://wyniki.interia.pl/rozgrywki-R-polska-ekstraklasa,cid,3,sort,I?from=mobile").text

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
output_df.to_csv("C:\\Users\\Wojtek\\Desktop\\kojarzenia.csv",index=False,sep=",")