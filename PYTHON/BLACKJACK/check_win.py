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

