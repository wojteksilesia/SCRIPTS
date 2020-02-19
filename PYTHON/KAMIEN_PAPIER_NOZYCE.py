import numpy as np 

def kamien_papier():
    
    user_choice=""
    player_score = []
    computer_score=[]
    
    boarder_points = int(input("Do ilu chcesz graæ:"))
    
    while ((sum(player_score) < boarder_points) and (sum(computer_score)<boarder_points)) and user_choice!="EXIT":
    
        
        
        user_choice = input("Kamieñ [K], papier [P] lub no¿yczki [N]:")
        
        while user_choice!="K" and user_choice!="P" and user_choice!="N" and user_choice!="EXIT":
        
            if user_choice!="K" and user_choice!="P" and user_choice!="N" and user_choice!="EXIT":
                print("\n","Co ty nie umiesz w knefel trafiæ? Zrób ruch jeszcze raz")
                user_choice=input("Kamieñ [K], papier [P] lub no¿yczki [N]:")
    
        computer_choice = abs(np.round(np.random.uniform(-0.5,2.5,1),0))
    
        if computer_choice==0:
            comp_move = "K"
        elif computer_choice==1:
            comp_move="P"
        else:
            comp_move="N"
        
        if user_choice=="K" and comp_move=="K":
            player_score.append(0)
            computer_score.append(0)
            print("Komputer wybra³ KAMIEÑ, ta runda na remis. WYNIK: ",
              sum(player_score),":",sum(computer_score))
    
        elif user_choice=="K" and comp_move=="P":
            player_score.append(0)
            computer_score.append(1)
            print("Komputer wybra³ PAPIER, przegrywasz rundê. WYNIK: ",
              sum(player_score),":",sum(computer_score))
    
        elif user_choice=="K" and comp_move=="N":
            player_score.append(1)
            computer_score.append(0)
            print("Komputer wybra³ NO¯YCZKI, wygrywasz rundê. WYNIK: ",
              sum(player_score),":",sum(computer_score))
            
        elif user_choice=="P" and comp_move=="K":
            player_score.append(1)
            computer_score.append(0)
            print("Komputer wybra³ KAMIEÑ, wygrywasz rundê. WYNIK: ",
              sum(player_score),":",sum(computer_score))
            
        elif user_choice=="P" and comp_move=="P":
            player_score.append(0)
            computer_score.append(0)
            print("Komputer wybra³ PAPIER, ta runda na remis. WYNIK: ",
              sum(player_score),":",sum(computer_score))
        
        elif user_choice=="P" and comp_move=="N":
            player_score.append(0)
            computer_score.append(1)
            print("Komputer wybra³ NO¯YCZKI, przegrywasz rundê. WYNIK: ",
              sum(player_score),":",sum(computer_score))
            
        
        elif user_choice=="N" and comp_move=="K":
            player_score.append(0)
            computer_score.append(1)
            print("Komputer wybra³ KAMIEÑ, przegrywasz rundê. WYNIK: ",
              sum(player_score),":",sum(computer_score))
        
        elif user_choice=="N" and comp_move=="P":
            player_score.append(1)
            computer_score.append(0)
            print("Komputer wybra³ PAPIER, wygrywasz rundê. WYNIK: ",
              sum(player_score),":",sum(computer_score))
            
        elif user_choice=="N" and comp_move=="N":
            player_score.append(0)
            computer_score.append(0)
            print("Komputer wybra³ NO¯YCZKI, ta runda na remis. WYNIK: ",
              sum(player_score),":",sum(computer_score))
            
            
    if user_choice=="EXIT":
        print("\n","PRZERWA£EŒ GRÊ")
    elif sum(player_score) < sum(computer_score):
        print("\n","PRZEGRA£EŒ SZPIL rezultatem ",sum(player_score),":",sum(computer_score))
    else:
        print("\n","WYGRA£EŒ SZPIL ",sum(player_score),":",sum(computer_score)," BRAWO!!!!!")