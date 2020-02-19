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




sum([1,2,4])

