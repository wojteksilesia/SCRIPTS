### Definicja obiektów i funkcji
import random

board=[
    ["a8","b8","c8","d8","e8","f8","g8","h8"],
    ["a7","b7","c7","d7","e7","f7","g7","h7"],
    ["a6","b6","c6","d6","e6","f6","g6","h6"],
    ["a5","b5","c5","d5","e5","f5","g5","h5"],
    ["a4","b4","c4","d4","e4","f4","g4","h4"],
    ["a3","b3","c3","d3","e3","f3","g3","h3"],
    ["a2","b2","c2","d2","e2","f2","g2","h2"],
    ["a1","b1","c1","d1","e1","f1","g1","h1"]
]

log_moves=[]
possible_moves=[]

def find_index(square):  ### przekazujemy np. "e6", na wyjściu dostajemy [2,4]
    for row in range(0,8):
        if square in board[row]:
            i=row
            break
    j=board[i].index(square)
    return[i,j]


def available_moves(square_index):
    x=square_index[0]
    y=square_index[1]
    possible_moves=[]
    if (x+2)<=7 and (y+1)<=7:
        if board[x+2][y+1] not in log_moves:
            possible_moves.append(board[x+2][y+1])
    
    if (x+2)<=7 and (y-1)>=0:
        if board[x+2][y-1] not in log_moves: 
            possible_moves.append(board[x+2][y-1])   
    
    if (x+1)<=7 and (y+2)<=7:
        if board[x+1][y+2] not in log_moves:
            possible_moves.append(board[x+1][y+2])
    
    if (x-1)>=0 and (y+2)<=7:
        if board[x-1][y+2] not in log_moves:
            possible_moves.append(board[x-1][y+2])
    
    if (x-2)>=0 and (y+1)<=7:
        if board[x-2][y+1] not in log_moves:
            possible_moves.append(board[x-2][y+1])   
    
    if (x-2)>=0 and (y-1)>=0:
        if board[x-2][y-1] not in log_moves:
            possible_moves.append(board[x-2][y-1])     
    
    if (x-1)>=0 and (y-2)>=0:
        if board[x-1][y-2] not in log_moves:
            possible_moves.append(board[x-1][y-2]) 
    
    if (x+1)<=7 and (y-2)>=0:
        if board[x+1][y-2] not in log_moves:
            possible_moves.append(board[x+1][y-2])    
    
    return possible_moves


while True:
    #### Dostajemy na wejściu pole
    input_square="e5"
    
    ## Zerujemy listę ruchów
    log_moves=[]

    ### Wyznaczamy jego index
    square_index=find_index(input_square)

    ### Logujemy pierwsze, wejściowe pole:
    log_moves.append(input_square)

    ### Znajdujemy listę dostępnych ruchów
    possible_moves=available_moves(square_index)

    while True:
        ### Losujemy jedno z pól
        random.shuffle(possible_moves)
        random_move=possible_moves.pop()

        ## Logujemy ruch
        log_moves.append(random_move)

        ## Jeśli długość log_moves=64, kończymy zabawę
        if len(log_moves)==64:
            break

        ## Wyznaczamy index ruchu
        square_index=find_index(random_move)

        ## Znajdujemy dostępne ruchy
        possible_moves=available_moves(square_index)

        ## Jeśli lista pusta, wyjdź z pętli
        if len(possible_moves)==0:
            break
    
    ## Wyjść z pętli mogliśmy w dwóch przypadkach, sprawdzamy scenariusz wygranej
    if len(log_moves)==64:
        break



##########

SOLUTION:

['e5',
 'c4',
 'a3',
 'b1',
 'd2',
 'e4',
 'f2',
 'h1',
 'g3',
 'f5',
 'h4',
 'f3',
 'e1',
 'g2',
 'f4',
 'h5',
 'f6',
 'd5',
 'c7',
 'a8',
 'b6',
 'c8',
 'a7',
 'c6',
 'b8',
 'd7',
 'f8',
 'h7',
 'g5',
 'h3',
 'g1',
 'e2',
 'c1',
 'a2',
 'b4',
 'a6',
 'c5',
 'd3',
 'b2',
 'a4',
 'c3',
 'b5',
 'd4',
 'c2',
 'a1',
 'b3',
 'a5',
 'b7',
 'd8',
 'e6',
 'g7',
 'e8',
 'd6',
 'f7',
 'h8',
 'g6',
 'e7',
 'g8',
 'h6',
 'g4',
 'h2',
 'f1',
 'e3',
 'd1']
