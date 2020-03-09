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
        print('METHOD:take_table  ARG:league=0  STATUS:FAIL')
    else:
        if (len(result_df.index)==16) and (len(result_df.columns)==3):
            print('METHOD:take_table  ARG:league=0  STATUS:OK')
        else:
            print('METHOD:take_table  ARG:league=0  STATUS:FAIL')

def ut_take_table_I():
    ## I liga
    try:
        result_df = take_table(league=1)
    except:
        print('METHOD:take_table  ARG:league=1  STATUS:FAIL')
    else:
        if (len(result_df.index)==18) and (len(result_df.columns)==3):
            print('METHOD:take_table  ARG:league=1  STATUS:OK')
        else:
            print('METHOD:take_table  ARG:league=1  STATUS:FAIL')

def ut_take_table_II():
    ## II liga
    try:
        result_df = take_table(league=2)
    except:
        print('METHOD:take_table  ARG:league=2  STATUS:FAIL')
    else:
        if (len(result_df.index)==18) and (len(result_df.columns)==3):
            print('METHOD:take_table  ARG:league=2  STATUS:OK')
        else:
            print('METHOD:take_table  ARG:league=2  STATUS:FAIL')

def ut_take_table_III():
    ## III liga
    try:
        result_df = take_table(league=3)
    except:
        print('METHOD:take_table  ARG:league=3  STATUS:FAIL')
    else:
        if (len(result_df.index)==18) and (len(result_df.columns)==3):
            print('METHOD:take_table  ARG:league=3  STATUS:OK')
        else:
            print('METHOD:take_table  ARG:league=3  STATUS:FAIL')
    

##############################################

####### TAKE PAIRINGS TEST ################

def ut_take_pairings_ekstraklasa():
    try:
        r1=take_pairings(only_future=True,league=0)
    except:
        print ('METHOD:take_pairings  ARG:only_future=True league=0  STATUS=FAIL')
    
    else:
        if (len(r1.columns)==3) and (r1["RESULT"].unique()=="-"):
            print('METHOD:take_pairings  ARG:only_future=True league=0  STATUS=OK')
        else:
            print('METHOD:take_pairings  ARG:only_future=True league=0  STATUS=FAIL')
    
    
    try:
        r2=take_pairings(only_future=False,league=0)
    except:
        print('METHOD:take_pairings  ARG:only_future=False league=0  STATUS=FAIL')
    
    else:
        if (len(r2.columns)==3) and (len(r2["RESULT"].unique())>1):
            print('METHOD:take_pairings  ARG:only_future=False league=0  STATUS=OK')
        else:
            print('METHOD:take_pairings  ARG:only_future=False league=0  STATUS=FAIL')


def ut_take_pairings_I():
    try:
        r1=take_pairings(only_future=True,league=1)
    except:
        print ('METHOD:take_pairings  ARG:only_future=True league=1  STATUS=FAIL')
    
    else:
        if (len(r1.columns)==3) and (r1["RESULT"].unique()=="-"):
            print('METHOD:take_pairings  ARG:only_future=True league=1  STATUS=OK')
        else:
            print('METHOD:take_pairings  ARG:only_future=True league=1  STATUS=FAIL')
    
    
    try:
        r2=take_pairings(only_future=False,league=1)
    except:
        print('METHOD:take_pairings  ARG:only_future=False league=1  STATUS=FAIL')
    
    else:
        if (len(r2.columns)==3) and (len(r2["RESULT"].unique())>1):
            print('METHOD:take_pairings  ARG:only_future=False league=1  STATUS=OK')
        else:
            print('METHOD:take_pairings  ARG:only_future=False league=1  STATUS=FAIL')


def ut_take_pairings_II():
    try:
        r1=take_pairings(only_future=True,league=2)
    except:
        print ('METHOD:take_pairings  ARG:only_future=True league=2  STATUS=FAIL')
    
    else:
        if (len(r1.columns)==3) and (r1["RESULT"].unique()=="-"):
            print('METHOD:take_pairings  ARG:only_future=True league=2  STATUS=OK')
        else:
            print('METHOD:take_pairings  ARG:only_future=True league=2  STATUS=FAIL')
    
    
    try:
        r2=take_pairings(only_future=False,league=2)
    except:
        print('METHOD:take_pairings  ARG:only_future=False league=2  STATUS=FAIL')
    
    else:
        if (len(r2.columns)==3) and (len(r2["RESULT"].unique())>1):
            print('METHOD:take_pairings  ARG:only_future=False league=2  STATUS=OK')
        else:
            print('METHOD:take_pairings  ARG:only_future=False league=2  STATUS=FAIL')
        

def ut_take_pairings_III():
    try:
        r1=take_pairings(only_future=True,league=3)
    except:
        print ('METHOD:take_pairings  ARG:only_future=True league=3  STATUS=FAIL')
    
    else:
        if (len(r1.columns)==3) and (r1["RESULT"].unique()=="-"):
            print('METHOD:take_pairings  ARG:only_future=True league=3  STATUS=OK')
        else:
            print('METHOD:take_pairings  ARG:only_future=True league=3  STATUS=FAIL')
    
    
    try:
        r2=take_pairings(only_future=False,league=2)
    except:
        print('METHOD:take_pairings  ARG:only_future=False league=3  STATUS=FAIL')
    
    else:
        if (len(r2.columns)==3) and (len(r2["RESULT"].unique())>1):
            print('METHOD:take_pairings  ARG:only_future=False league=3  STATUS=OK')
        else:
            print('METHOD:take_pairings  ARG:only_future=False league=3  STATUS=FAIL')

#######################################################################

def ut_run_test():
    ut_take_table_ekstraklasa()
    ut_take_table_I()
    ut_take_table_II()
    ut_take_table_III()
    ut_take_pairings_ekstraklasa()
    ut_take_pairings_I()
    ut_take_pairings_II()
    ut_take_pairings_III()
    
