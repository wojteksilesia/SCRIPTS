import random as rd

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

