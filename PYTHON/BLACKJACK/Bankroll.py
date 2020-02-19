class Bankroll():
    def __init__(self,amount):
        self.amount=amount
    
    def increase(self,level):
        self.amount=self.amount+level
    
    def decrease(self,level):
        if level>self.amount:
            return "Nie masz aż tylu żetonów"
        self.amount=self.amount-level




