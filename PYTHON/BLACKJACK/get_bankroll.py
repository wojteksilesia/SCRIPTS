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

