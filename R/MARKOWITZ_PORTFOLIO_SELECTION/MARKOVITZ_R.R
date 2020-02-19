library(readxl)
library(matlib)
library(stringr)

## Importing dataset
stock_data <- read_excel("C:/Users/Wojtek/Desktop/R skrypty/MARKOWITZ/DATASET_NA.xlsx", 
                         sheet = "2008-2013")

## Setting global n variable, representing number of stocks in the portfolio
n_elements <- 3

## Setting DATES as rownames
rownames(stock_data) <- stock_data$DATA
stock_data$DATA <- NULL

## Calculating avrage return rate
average_r <- apply(stock_data,2,mean)

## Calculating return rate standard deviation
stdev_r <- apply(stock_data,2,sd)

## Correlation matrix
corr_df <- cor(stock_data)

## All n-elements stock combinations
stock_combos <- combn(colnames(stock_data),n_elements)

### Defining result df attributes
all_rows_names <- c()
all_parameters <- c()


### Iterating over each combination
for(i in 1:ncol(stock_combos)){
  
  ## Creating I-vector
  i_vector <- c(rep(0,n_elements),1)
  
  ## Creating c-matrix N+1 x N+1
  c_matrix <- matrix(rep(0,(n_elements+1)**2),ncol=n_elements+1,nrow=n_elements+1)
  
  ### Filling matrix content
  for(p in 1:n_elements){
    for(q in 1:n_elements){
      
      c_matrix[p,q] <- 2*stdev_r[stock_combos[p,i]]*stdev_r[stock_combos[q,i]]*
        corr_df[stock_combos[p,i],stock_combos[q,i]]
    }
  }
  
  c_matrix[n_elements+1,]<-1
  c_matrix[,n_elements+1]<-1
  c_matrix[n_elements+1,n_elements+1]<-0
  
  ## inverse c_matrix
  inverse_c <- inv(c_matrix)
  
  ## Multiplying inverse c matrix and  i-vector
  mvp_weights <- inverse_c %*% i_vector  
  
  ## Extracting from mvp_weights vector only real values
  weights_vector <- mvp_weights[1:n_elements,]
  names(weights_vector) <- stock_combos[,i]
  
  ## calculating portfolio return rate standard deviation
  sum_a <- 0
  sum_b <- 0
  for(a in 1:n_elements){
    sum_a<-sum_a+sum_b
    sum_b <- 0
    for(b in 1:n_elements){
      sum_b<-sum_b+(weights_vector[stock_combos[a,i]]*weights_vector[stock_combos[b,i]]*
        corr_df[stock_combos[a,i],stock_combos[b,i]]*stdev_r[stock_combos[a,i]]*stdev_r[stock_combos[b,i]])
    }
  }
  
  portfolio_stdev <- sum_a**0.5
  names(portfolio_stdev)<-NULL
  
  ## calculating portfolio expected return rate
  
  portfolio_r<-0
  for(x in 1:n_elements){
    portfolio_r<-portfolio_r+weights_vector[stock_combos[x,i]]*average_r[stock_combos[x,i]]
  }
  
  names(portfolio_r) <- NULL
  
  #### creating rowindex
  rowindex<-""
  for(r in 1:n_elements){
    rowindex<-paste(rowindex,stock_combos[r,i])
  }
  rowindex <- str_trim(rowindex)
  
  ## Filling attributes
  all_rows_names <- c(all_rows_names,rowindex)
  all_parameters <- rbind(all_parameters,c(weights_vector,portfolio_stdev,portfolio_r))
  
}

## Creating columnindex
columnindex<-c()
for(i in 1:n_elements){
  columnindex<-c(columnindex,paste0("w",i))
}
columnindex<-c(columnindex,"STANDARD_DEVIATION","E(R)")
columnindex<-c("PORTFOLIO",columnindex)


## Creating result dataframe
result_df <- data.frame(cbind(all_rows_names,all_parameters))
colnames(result_df)<- columnindex

View(result_df)

