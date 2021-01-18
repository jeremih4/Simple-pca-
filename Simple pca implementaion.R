#@author: Jeremiah Munakabayo
####


library(MASS)
#train data
train_data <- read.csv("~/R/data/XGtrainRain.txt", header = TRUE,sep = ",", dec = ".") dim(train_data)

# prepare the data
Xtrain <- train_data[,1:365] # X train set
Ztrain <- train_data[,366] # response variable
XZtrain=cbind(Xtrain,Ztrain)
Xtrain_cent <- as.matrix(scale(Xtrain, center = T, scale = F)) #centered data by subtracting mean from Xtrain

dim(XZtrain) # our dataset consists of 150 rows and 365 columns/feature, and a response 
#:- more features than observations


#typically, this posses a problem for classic many machine learning algorithms because a unique solution 
#cannot be found.

# Aproaches:
# - dimensionality reduction

pca.fit <- prcomp(XZtrain[,1:365]) # fit the pca model

lambda = pca.fit$sdev^2 
gamma = pca.fit$rotation

exp_variances = (100*lambda)/sum(lambda) # variance exlplained by each component
var_df = data.frame(PC=1:length(exp_variances),exp_variances=exp_variances)
var_df$Cumulative_var <- cumsum(exp_variances) # cumulative variance explained data frame
var_df

## visualizing the scree plot
require(cowplot)
## Loading required package: cowplot
require(ggplot2)
## Loading required package:  ggplot2
Perc_var_exp <- ggplot(var_df,aes(x=PC,y=exp_variances)) + geom_point() + geom_line() + ylim(c(0,100)) + ylab("Perc variance explained")
Cum_var_exp <- ggplot(var_df,aes(x=PC,y=Cumulative_var)) + geom_point() + geom_line() + ylim(c(0,100)) + ylab("Cummulative Perc variance explained")
plot_grid(Perc_var_exp, Cum_var_exp) # not very obvious from the scree plot

##
#choose number of components using Cross Validation
##

Y = pca.fit$x 
dataCV = as.data.frame(cbind(Y, XZtrain[, 366]))
n = dim(pca.fit$x)[1]

# Choose q principal components
# I used LOOCV - leave one out cross-validation + logistic regression

CV = rep(0, 50) # we will select from the first 50 principal components
for (k in 2:50) { for (i in 1:n) {
  YDATACV = dataCV[-i, 1:k] # leave one out
  ZtrainCV = dataCV[-i, 151] # leave one out
  CVdata = cbind(YDATACV, ZtrainCV)
  logit_pca <- glm(ZtrainCV ~ ., as.data.frame(CVdata), family = binomial) # train model
  probs = predict(logit_pca, dataCV[i, 1:k], type = "response") # predict on the left out obs
  pred <- ifelse(probs > 0.5, 1, 0)
  CV[k] = CV[k] + (dataCV[i, 151] != pred) # save classification error
} }

CV[1] <- NA # do not consider first entry
plot(CV, xlab = "Num of Comp", ylab = "CV error", title = "Logistic model on PLS"
)

CV = CV[-1]
logitCV_pca = which(CV == min(CV)) + 1 # choose components No. with smallest classification error 
logitCV_pca[1] # number of components chosen

YDATACV = dataCV[, 1:logitCV_pca[1]] # selection on components
ZtrainCV = dataCV[, 151]
CVdata = cbind(YDATACV, ZtrainCV)
logit_pca <- glm(ZtrainCV ~ ., as.data.frame(CVdata), family = binomial) # final trained model on components


##############
# The model
##

# test data
test_data <- read.csv("~/R/data/XGtestRain.txt", header = TRUE, sep = ",", dec = ".")
test_data <- as.data.frame(test_data)
dim(test_data)
## [1] 41 366
Xtest <- test_data[, 0:365] # X test set
repbarX = matrix(rep(colMeans(Xtrain), dim(Xtest)[1]), dim(Xtest)[1], byrow = T) #center using train data
Xtest_cent <- (Xtest - repbarX) #center using train data
Ztest <- (test_data[, 366])

#ready test data for logistic regression with pca
Xtest_pca = as.data.frame(as.matrix(Xtest_cent) %*% pca.fit$rotation) # components


Zprobs_LogitPca = predict(logit_pca, Xtest_pca[, 1:logitCV_pca], type = "response") # prediction
Zpred_LogitPca = ifelse(Zprobs_LogitPca > 0.5, 1, 0) # cut off is o.5


# error
mean(Zpred_LogitPca != Ztest) ## classification error

