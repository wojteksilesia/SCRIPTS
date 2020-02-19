import pandas
import numpy
import seaborn as sns
import matplotlib.pyplot as plt
import os
import itertools as it
%matplotlib inline 

## Setting up global variable representing number of elements in the portfolio
n_elements=4

## Working directory change
os.chdir('C:\\Users\\Wojtek\\Desktop\\R skrypty\\MARKOWITZ')

## Importing dataset stored in the working directory
stock_data = pandas.read_excel("DATASET_NA.xlsx",sheet_name="2008-2013")

### Setting DATE column as index
stock_data.set_index("DATA", inplace=True)

### Calculating expected return rate for each company
expected_r=pandas.DataFrame(stock_data.mean(),columns=["E(R)"])


### Calculating standard deviation for each company
standard_deviation_r=pandas.DataFrame(stock_data.std(),columns=["Std"])

## Pearson correlation
corr_df = stock_data.corr()

## Correlation plot
sns.set_context("notebook")
sns.heatmap(corr_df,cmap="coolwarm",annot=True)
plt.title("STOCK RATE OF RETURN CORRELATION HEATMAP")

## Finding all portfolio combinations for n-elements
portfolio_combinations=list(it.combinations(stock_data.columns,n_elements))

## Final portfolio dictionary (key - stock names; values - lists with MVP weights)
mvp_dict={}

## For each combination, building C matrix, I vector and final MVP weights w vector
for comb in portfolio_combinations:
    
    ## i_vector (all 0 + last element=1)
    i_vector = numpy.zeros(n_elements+1)
    i_vector[len(i_vector)-1] = 1
    
    ## c_matrix
    c_matrix=numpy.zeros((n_elements+1,n_elements+1))
    
    ### Filling matrix content
    for i in range(0,n_elements):
        for j in range(0,n_elements):
            c_matrix[i,j]=2*standard_deviation_r.loc[comb[i]]*standard_deviation_r.loc[comb[j]]*corr_df.loc[comb[i],comb[j]]
            c_matrix[n_elements,:]=1
            c_matrix[:,n_elements]=1
            c_matrix[n_elements,n_elements]=0
    
    ### inverse matrix
    c_inverse = numpy.linalg.inv(c_matrix)
    
    ### Matrix multiplying c_inverse %*% i_vector (n-rows, one column)
    mvp_weights = c_inverse @ i_vector
    
    ### Creating weights series (excluding last element) indexed by stock names
    weights_series = pandas.Series(mvp_weights[0:n_elements],index=comb)
    
    
    ### Calculating MVP standard deviation
    p_sum=0
    q_sum=0
    for p in comb:
        p_sum=p_sum+q_sum
        q_sum=0
        
        for q in comb:
            q_sum=q_sum+(weights_series[p]*weights_series[q]*
                         corr_df.loc[p,q]*standard_deviation_r.loc[p]*standard_deviation_r.loc[q])
    
    mvp_st_dev = p_sum**0.5
        
    ### Calculating MVP expected rate of return
    return_rate=0
    for z in comb:
        return_rate = return_rate + weights_series[z]*expected_r.loc[z]
    
    ### Creating row index with stock names
    row_index=""
    for name in comb:
        row_index=row_index + name + " "
    
    row_index=row_index.rstrip()
    
    
    ## Parameters list (weights+std+return rate)
    parameters_list=list(weights_series) ## append weights
    parameters_list.append(float(mvp_st_dev)) ## append st dev
    parameters_list.append(float(return_rate)) ## append return rate
    
    ## Adding result to mvp_dict
    mvp_dict[row_index]=parameters_list

### Creating column names
column_names=[]
for w in range(1,n_elements+1):
    column_names.append("w"+str(w))

column_names.append("standard_deviation")
column_names.append("E(R)")

### Result dataframe
result_df = pandas.DataFrame(mvp_dict).transpose()
result_df.columns=column_names

result_df

