import random as rd

#########################################################

class Deck():
    talia=[2,3,4,5,6,7,8,9,10,"J","Q","K","A",
           2,3,4,5,6,7,8,9,10,"J","Q","K","A",
           2,3,4,5,6,7,8,9,10,"J","Q","K","A",
           2,3,4,5,6,7,8,9,10,"J","Q","K","A"]
    
    def take_card(self):
        card_index = rd.randint(0,len(Deck.talia)-1)
        card_value = Deck.talia[card_index]
        
        del Deck.talia[card_index]
        return card_value
    
    def restart(self):
        Deck.talia=[2,3,4,5,6,7,8,9,10,"J","Q","K","A",
           2,3,4,5,6,7,8,9,10,"J","Q","K","A",
           2,3,4,5,6,7,8,9,10,"J","Q","K","A",
           2,3,4,5,6,7,8,9,10,"J","Q","K","A"]
        

#########################################################

class Bankroll():
    def __init__(self,amount):
        self.amount=amount
    
    def increase(self,level):
        self.amount=self.amount+level
    
    def decrease(self,level):
        if level>self.amount:
            return "Nie masz aż tylu żetonów"
        self.amount=self.amount-level
        

#########################################################


def get_bankroll():
    while True:
        try:
            roll=int(input("Podaj startową liczbę żetonów: "))
        except:
            print("Niepoprawna liczba!")
            continue
        else:
            pass
    
        if roll<1:
            print("Tyloma żetonami nie pograsz, weź więcej")
            continue
        
        break
        
    return roll

#########################################################

def get_bet(bankroll):
    while True:
        try:
            betsize=int(input("Podaj zakład: "))
        except:
            print("Niepoprawna wartość!")
            continue
        else:
            pass
        
        if betsize<1:
            print("Minimalna wysokość zakładu wynosi 1")
            continue
        
        if betsize>bankroll:
            print("Za mało masz żetonów na taki zakład")
            continue
        
        break
    
    return betsize

#########################################################
    

def card_sum(card_vector):
    if card_vector==['A','A']:
        return 22
    
    sum=0
    if not 'A' in card_vector:
        for i in card_vector:
            if i in ['J','Q','K']:
                i=10
            sum=sum+i
        return sum

    if 'A' in card_vector:
        for i in card_vector:
           
            if i in ['J','Q','K'] and i!='A':
                i=10
            if i=='A':
                i=0
            sum=sum+i
          
        
        if card_vector.count('A')==1 and len(card_vector)==2:
            if sum==10:
                return 21
            return (sum+1,sum+11)
            
        if card_vector.count('A')==1 and len(card_vector)>2:
            if sum>10:
                return sum+1
            return (sum+1,sum+11)
        
        if card_vector.count('A')==2 and len(card_vector)>2:
            if sum+12==21:
                return 21
        
            if sum+12<21:
                return (sum+12,sum+2)
            
            if sum+12>21:
                return sum+2
        
        if card_vector.count('A')==3 and len(card_vector)>2:
            if sum+13==21:
                return 21
            
            if sum+13<21:
                return (sum+13,sum+3)
            
            if sum+13>21:
                return sum+3

        if card_vector.count('A')==4 and len(card_vector)>2:
            if sum+14==21:
                return 21
            
            if sum+14<21:
                return (sum+14,sum+4)
            
            if sum+14>21:
                return sum+4

#########################################################

def check_boost(points):
   ''' 
   0 - nie jest boosted
   1 - boosted
   '''
   if type(points)==tuple:
       for i in points:
           if i<=21:
               return 0
               return 1
        
   if type(points)!=tuple:
       if points <=21:
           return 0
       else:
           return 1

#########################################################

def check_win(player_points,dealer_points):
    '''
    1 - wygrana dealera
    0 - dealer nie wygrał
    -1 - remis
    '''
    if type(player_points)!=tuple:
        final_pp = player_points
    elif type(player_points)==tuple:
        max_pp=0
        for i in player_points:
            if i>max_pp and i<22:
                max_pp=i
        final_pp=max_pp
    
    
    if type(dealer_points)!=tuple:
        final_dp = dealer_points
    elif type(dealer_points)==tuple:
        max_pp=0
        for i in dealer_points:
            if i>max_pp and i<22:
                max_pp=i
        final_dp=max_pp
    
    if final_pp==21 and final_dp==21:
        return -1
    elif final_pp==20 and final_dp==20:
        return -1
    elif final_pp==19 and final_dp==19:
        return -1
    elif final_dp>final_pp:
        return 1
    elif final_dp<final_pp:
        return 0

##########################################################################
##########################################################################
##########################################################################
##########################################################################



### Zapytanie gracza iloma żetonami chce grać
roll_level = get_bankroll()
    
## Ustawienie globalnej zmiennej bankroll
bankroll=Bankroll(roll_level)
    
## Nowe rozdanie
while bankroll.amount>0:
    ### Zdefiniowanie talii kart

    deck = Deck()
    deck.restart()
    
    ## Karty gracza
    player_cards = []
    
    ## Karty dealera
    dealer_cards = []
    
    ### Podaj bet
    betsize=get_bet(bankroll.amount)
    
    ### Wysokosc zakładu odejmij od rolla 
    bankroll.decrease(betsize)
    
    ## Wylosuj 2 karty dla gracza
    player_cards.append(deck.take_card())
    player_cards.append(deck.take_card())
    
    ## Wylosuj kartę dla dealera
    dealer_cards.append(deck.take_card())
    
    ## Oblicz sumę punktów dla gracza i dealera
    points_player=card_sum(player_cards)
    
    points_dealer=card_sum(dealer_cards) 
    
    ### Wyswietl wylosowane karty, sumę + wylosowane karty dealera i sumę
    
    print("Player cards: " + str(player_cards)+"\n"+
          "Player points: " + str(points_player) + "\n"+"\n"+
          "Dealer cards: " + str(dealer_cards)+ "\n"+
          "Dealer points: " + str(points_dealer))
    
    
    
    ## Pomocnicza zmienna 
    decision="H" ## H or S
    
    
    ## Czy gracz chce dobierać
    while decision=="H":
            ## Jesli gracz ma 21 lub 22, opusc pętlę
            if player_cards==['A','A'] or points_player==21:
                break
            decision=input("Co robisz? H-dobierasz, S-czekasz z tym co masz: ")
            while decision not in ['H','S']:
                decision=input("H albo S!! ")
        
            if decision=="H":
            ## Dolosuj kartę
                player_cards.append(deck.take_card())
                
                ## Oblicz punkty
                points_player=card_sum(player_cards)
            
            
            ## Sprawdź czy busted 
                if check_boost(points_player)==1:
                    print("Player cards: " + str(player_cards)+"\n"+
                          "Player points: " + str(points_player) + "\n"+"\n"+
                          "Dealer cards: " + str(dealer_cards)+ "\n"+
                          "Dealer points: " + str(points_dealer))                  
                    
                    print("Boosted!")
                    print("Bankroll: " + str(bankroll.amount))
                    
                    
                    
                    break  ### Wyjdź z pętli 'czy gracz chce dobierać'
                
                elif check_boost(points_player)==0:
                    print("Player cards: " + str(player_cards)+"\n"+
                          "Player points: " + str(points_player) + "\n"+"\n"+
                          "Dealer cards: " + str(dealer_cards)+ "\n"+
                          "Dealer points: " + str(points_dealer)) 
                    
                    input("[HIT ENTER]")
                    
                    continue ### Kontynuuj pętlę 'czy gracz chce dobierać'
    
    ### Sprawdź czy gracz jest boosted - jesli tak, wróć do nowego rozdania 
    if check_boost(points_player)==1:
        continue
    
    ### Jeli gracz nie jest boosted, losuj kolejne karty dla dealera
    while True:
       dealer_cards.append(deck.take_card())
       
       ## Oblicz punkty
       points_dealer=card_sum(dealer_cards)
       
       print("Player cards: " + str(player_cards)+"\n"+
            "Player points: " + str(points_player) + "\n"+"\n"+
            "Dealer cards: " + str(dealer_cards)+ "\n"+
            "Dealer points: " + str(points_dealer)) 
       
       round_end=0  ### pomocnicza zmienna 
       
       input()
       
       ### Sprawdź wyjątkowe przypadki z AA
       if dealer_cards == ['A','A'] and player_cards==['A','A']:
           round_end=1
           print("Runda na remis")
           bankroll.increase(betsize) ## zwrot żetonów
           print("Bankroll: " + str(bankroll.amount))
           
           break
       
       if dealer_cards== ['A','A'] and player_cards!= ['A','A']:
            round_end=1
            print("Dealer wins")
            print("Bankroll: " + str(bankroll.amount))
            
            break
        
       if dealer_cards!=['A','A'] and player_cards==['A','A']:
            round_end=1
            print("Player wins")
            bankroll.increase(betsize*2) ## Wypłata wygranej
            print("Bankroll: " + str(bankroll.amount))
            
            break
       
        ### Sprawdź czy boosted, jesli nie, sprawdź czy dealer wygrał 
       if check_boost(points_dealer)==1:
           print("Boosted, player wins")
           ## Wypłata wygranej
           bankroll.increase(betsize*2)
           print("Bankroll: " + str(bankroll.amount))
           
           round_end=1
           break
       elif check_boost(points_dealer)==0:
           ## Sprawdź wygraną 
           if check_win(points_player,points_dealer)==-1:
               round_end=1
               print("Runda na remis")
               bankroll.increase(betsize) ## zwrot żetonów
               print("Bankroll: " + str(bankroll.amount))
               
               break       
           elif check_win(points_player,points_dealer)==1:
               round_end=1
               print("Dealer wins")
               print("Bankroll: " + str(bankroll.amount))
               
               break
           elif check_win(points_player,points_dealer)==0:
               continue
               
           
    
    
           
   