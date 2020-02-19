## Paradoks Hall'a

import random as rd

### Ile chcesz uruchomień
n = int(input("Podaj liczbę iteracji: "))
print("\n")


## Globalne zmienne
wygrana_zmiana=0
wygrana_brak_zmiany=0

zmiana_decyzji_licznik=0
brak_zmiany_decyzji_licznik=0


for i in range(1,n+1):

    ## Bramka gracza
    bramka_gracza = rd.randint(1,3)


    ## Bramka wygrywająca 
    bramka_wygrywajaca = rd.randint(1,3)


    ## Bramka do odsłonięcia
    bramka_odslonieta = rd.randint(1,3)

    ## Losuj tak długo, aż będzie różna od bramki gracza/wygrywającej 
    while bramka_odslonieta in [bramka_gracza,bramka_wygrywajaca]:
        bramka_odslonieta = rd.randint(1,3)
    

    ### Czy gracz zmienia decyzję 0-nie; 1-tak
    zmiana_decyzji = rd.randint(0,1)

    ## Przypisanie bramki graczowi w drugiej turze

    if zmiana_decyzji==0:
        bramka_2_tura=bramka_gracza
    elif zmiana_decyzji==1:
            bramka_2_tura=rd.randint(1,3)
            while bramka_2_tura in [bramka_gracza,bramka_odslonieta]:
                bramka_2_tura=rd.randint(1,3)

    ## Sprawdzenie czy wygrana
    if bramka_2_tura==bramka_wygrywajaca:
        if zmiana_decyzji==1:
            wygrana_zmiana=wygrana_zmiana+1
            zmiana_decyzji_licznik=zmiana_decyzji_licznik+1
        elif zmiana_decyzji==0:
                wygrana_brak_zmiany=wygrana_brak_zmiany+1
                brak_zmiany_decyzji_licznik=brak_zmiany_decyzji_licznik+1
    elif bramka_2_tura != bramka_wygrywajaca:
        if zmiana_decyzji==1:
                        zmiana_decyzji_licznik=zmiana_decyzji_licznik+1
        elif zmiana_decyzji==0:
                            brak_zmiany_decyzji_licznik=brak_zmiany_decyzji_licznik+1


winrate_zmiana_decyzji =  round(100*wygrana_zmiana/zmiana_decyzji_licznik,2)
winrate_brak_zmiany_decyzji = round(100*wygrana_brak_zmiany/brak_zmiany_decyzji_licznik,2)
        
print("Winrate przy zmianie decyzji: " + str(winrate_zmiana_decyzji))  
print("Winrate przy niezmienionej decyzji: " + str(winrate_brak_zmiany_decyzji))  