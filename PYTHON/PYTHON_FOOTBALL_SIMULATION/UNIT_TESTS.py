from bs4 import BeautifulSoup
import requests
import numpy
import pandas

###################  UNIT TESTS #####################

## IMPORTANT!! First, run METHODS script


######## TAKE TABLE TEST ######################

def ut_take_table_ekstraklasa():
    ## Ekstraklasa
    try:
        result_df = take_table(league=0)
    except:
        return 'METHOD:take_table  STATUS:FAIL'
    
    if (len(result_df.index)==16) and (len(result_df.columns)==3):
        return 'METHOD:take_table  ARG:league=0  STATUS:OK'
    else:
        return 'METHOD:take_table  ARG:league=0  STATUS:FAIL'

def ut_take_table_I():
    ## I liga
    try:
        result_df = take_table(league=1)
    except:
        return 'METHOD:take_table  ARG:league=1  STATUS:FAIL'
    
    if (len(result_df.index)==18) and (len(result_df.columns)==3):
        return 'METHOD:take_table  ARG:league=1  STATUS:OK'
    else:
        return 'METHOD:take_table  ARG:league=1  STATUS:FAIL'

def ut_take_table_II():
    ## II liga
    try:
        result_df = take_table(league=2)
    except:
        return 'METHOD:take_table  ARG:league=2  STATUS:FAIL'
    
    if (len(result_df.index)==18) and (len(result_df.columns)==3):
        return 'METHOD:take_table  ARG:league=2  STATUS:OK'
    else:
        return 'METHOD:take_table  ARG:league=2  STATUS:FAIL'

def ut_take_table_III():
    ## III liga
    try:
        result_df = take_table(league=2)
    except:
        return 'METHOD:take_table  ARG:league=2  STATUS:FAIL'
    
    if (len(result_df.index)==18) and (len(result_df.columns)==3):
        return 'METHOD:take_table  ARG:league=2  STATUS:OK'
    else:
        return 'METHOD:take_table  ARG:league=2  STATUS:FAIL'
    
    ## II liga
    try:
        result_df = take_table(league=3)
    except:
        return 'METHOD:take_table  ARG:league=3  STATUS:FAIL'
    
    if (len(result_df.index)==18) and (len(result_df.columns)==3):
        return 'METHOD:take_table  ARG:league=3  STATUS:OK'
    else:
        return 'METHOD:take_table  ARG:league=3  STATUS:FAIL'

##############################################

####### TAKE PAIRINGS TEST ################

def ut_take_pairings():
    try:
        r1=take_pairings(only_future=True)
    except:
        return 'METHOD:take_pairings  ARG:only_future=True  STATUS=FAIL'
    
    if (len(r1.columns)==3) and (r1["RESULT"].unique()=="-"):
        return 'METHOD:take_pairings  ARG:only_future=True  STATUS=OK'
    else:
        return 'METHOD:take_pairings  ARG:only_future=True  STATUS=FAIL'
    
    
    try:
        r2=take_pairings(only_future=False)
    except:
        return 'METHOD:take_pairings  ARG:only_future=False  STATUS=FAIL'
    
    if (len(r2.columns)==3) and (len(r2["RESULT"].unique())>1):
        return 'METHOD:take_pairings  ARG:only_future=False  STATUS=OK'
    else:
        return 'METHOD:take_pairings  ARG:only_future=False  STATUS=FAIL'

#######################################################################

