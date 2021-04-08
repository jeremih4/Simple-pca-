# Simple-pca
A simple implementation of principal component analysis on Australian rainfall data

## objective

Given the amount of rainfall for each day of the year of a certain location in Australia, predict whether the location is in the north or the south.

## dataset

The training set contain p = 365 explanatory variables X1, . . . , Xp and one class membership (G = 0 or 1) for ntrain = 150 individuals. The test set contains p = 365 explanatory variabless X1, . . . , Xp and one class membership (G = 0 or 1) for ntest = 41 individuals.

In these data, for each individual, X1, . . . , Xp correspond to the amount of rainfall at each of the p = 365 days in a year. Each individual in this case is a place in Australia coming either from the North (G = 0) or from the South (G = 1) of the country. Thus, the two classes (North and South) are coded by 0 and 1.

## content

#### pca

Since the number of variables is alot more than the number of observations, we perform pca as our dimensionality reduction aproach to find a unique soludion to the problem.

#### cross validation

I consult the scree plot and/or cross validation, to help determine the number of components to use.

#### error

I conclude by predicting on unseen data and showing the classification error

