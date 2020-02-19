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

