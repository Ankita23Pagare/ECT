rm(list=ls(all=T))

setwd("C:/Users/ankita/NASSCOM/DATA ANALYTICS")

#Load Libraries
x = c("ggplot2", "corrgram", "DMwR", "caret", "randomForest", "unbalanced", "e1071", "Information", "rpart", "gbm", "ROSE", 'sampling', 'DataCombine', 'inTrees')

#install.packages(x)
lapply(x, require, character.only = TRUE)
rm(x)

## Read the data
Ect1= read.csv(file = 'Ect1.csv')
head(Ect1)

###########################################Explore the data##########################################
str(Ect1)

## Univariate Analysis and Variable Consolidation

Ect1$Subject[Ect1$Subject %in% "illiterate"] = "unknown"
Ect1$Series_title_2[Ect1$Series_title_2 %in% c("RTS core industries")] = "Total"
Ect1$marital[Ect1$marital %in% "unknown"] = "married"
Ect1$marital = as.factor(as.character(Ect1$marital))
Ect1$month[Ect1$month %in% c("sep","oct","mar","dec")] = "dec"
Ect1$month[Ect1$month %in% c("aug","jul","jun","may","nov")] = "jun"
Ect1$month = as.factor(as.character(Ect1$month))
Ect1$loan[Ect1$loan %in% "unknown"] = "no"
Ect1$loan = as.factor(as.character(Ect1$loan))
Ect1$schooling = as.factor(as.character(Ect1$schooling))
Ect1$profession[Ect1$profession %in% c("management","unknown","unemployed","admin.")] = "admin."
Ect1$profession[Ect1$profession %in% c("blue-collar","housemaid","services","self-employed","entrepreneur","technician")] = "blue-collar"
Ect1$profession = as.factor(as.character(Ect1$profession))
View(Ect1)

##################################Missing Values Analysis###############################################

missing_val = data.frame(apply(Ect1,2,function(x){sum(is.na(x))}))
missing_val

missing_val$Columns = row.names(missing_val)
missing_val
names(missing_val)[1] =  "Missing_percentage"
missing_val$Missing_percentage = (missing_val$Missing_percentage/nrow(Ect1)) * 100
missing_val = missing_val[order(missing_val$Missing_percentage),]
row.names(missing_val) = NULL
missing_val = missing_val[,c(2,1)]
write.csv(missing_val, "Ect1_prec.csv", row.names = F)
read.csv("Ect1_prec.csv")
Ect1$Series_reference[8] 
Ect1$Series_reference[8]=NaN

ggplot(data = missing_val[1:3,], aes(x=reorder(Columns,-Missing_percentage),y = Missing_percentage))+
  geom_bar(stat = "identity",fill = "grey")+xlab("Parameter")+
  ggtitle("Missing data percentage (Train)") + theme_bw()

#Mean Method

Ect1$Series_reference[is.na(Ect1$Series_reference)] = mean(Ect1$Series_reference, na.rm = T)
Ect1$Series_reference[70] 


numeric_index = sapply(Ect1,is.numeric)      #selecting only numeric

numeric_data = Ect1[,numeric_index]

cnames = colnames(numeric_data)
cnames



##Data Manupulation; convert string categories into factor numeric

for(i in 1:ncol(Ect1)){
  
  if(class(Ect1[,i]) == 'factor'){
    
    Ect1[,i] = factor(Ect1[,i], labels=(1:length(levels(factor(Ect1[,i])))))
    
  }
}
str(Ect1)

############################################Outlier Analysis#############################################
# ## BoxPlots - Distribution and Outlier Check

library(ggplot2)
numeric_index = sapply(Ect1,is.numeric) #selecting only numeric

numeric_data = Ect1[,numeric_index]

cnames = colnames(numeric_data)
cnames
 
for (i in 1:length(cnames))
{
  assign(paste0("gn",i), ggplot(aes_string(y = (cnames[i]), x = "responded"), data = subset(Ect1))+ 
           stat_boxplot(geom = "errorbar", width = 0.5) +
           geom_boxplot(outlier.colour="red", fill = "grey" ,outlier.shape=18,
                        outlier.size=1, notch=FALSE) +
           theme(legend.position="bottom")+
           labs(y=cnames[i],x="responded")+
           ggtitle(paste("Box plot of responded for",cnames[i])))
}

# ## Plotting plots together

gridExtra::grid.arrange(gn1,gn2,ncol=3)

# # #Remove outliers using boxplot method

df = Ect1
Ect1 = df


for(i in cnames){
  val = Ect1[,i][Ect1[,i] %in% boxplot.stats(Ect1[,i])$out]
  print(length(val))
  Ect1[,i][Ect1[,i] %in% val] = NA
}
for (i in cnames){
  Ect1[,i][is.na(Ect1[,i])] = median(Ect1[,i], na.rm = T)
}


sum(is.na(Ect1))

##################################Feature Selection################################################
## Correlation Plot 

library(corrgram)
corrgram(Ect1[,numeric_index], order = F,
         upper.panel=panel.pie, text.panel=panel.txt, main = "Correlation Plot")

## Chi-squared Test of Independence

factor_index = sapply(Ect1,is.factor)
factor_data = Ect1[,factor_index]

for (i in 1:10)
{
  print(names(factor_data)[i])
  print(chisq.test(table(factor_data$responded,factor_data[,i])))
}


View(Ect1)

##################################Feature Scaling################################################
#Normality check

qqnorm(Ect1$Series_reference)



#Normalisation
cnames = c("Series_reference","profession","schooling","housing","loan","contact","month",
           "Data_value","Magnitude")

for(i in cnames){
 print(i)

}




###################################Model Development#######################################
#Clean the environment

rmExcept("Ect1")

#Divide data into train and test using stratified sampling method

set.seed(1234)
train.index = createDataPartition(Ect1$responded, p = .80, list = FALSE) #80% training data
train = Ect1[ train.index,]
train                         #80% data for traing
test  = Ect1[-train.index,]
test                          #20% data for testing data
View(Ect1)
names(Ect1)
dim(Ect1)                     #diamention of data




