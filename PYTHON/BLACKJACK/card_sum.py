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

