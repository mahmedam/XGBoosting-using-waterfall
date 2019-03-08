rm(list=ls())
rm(group_avg_churned_data)

##SETTING MY WORK DIRECTORY
wd <- setwd("C:\\Users\\mahmed\\OneDrive - Trader Corporation\\Retention model\\")


##BRINGING IN THE USED PV CHURNED DEALERS FROM ADARSAN
churned <- read.csv("C:/Users/mahmed/OneDrive - Trader Corporation/Retention model/Retention report by Adarsan.csv")
#install.packages('e1071', dependencies=TRUE)
#install.packages("corrplot")
library(devtools)
library(e1071)
#install_github("davidADSP/xgboostExplainer", force = T)
library(caret)
library(ggplot2)
library(xlsx)
library(tidyr)
library(dplyr)
library(openxlsx)
library(readxl)
library(skimr)
library(class)
library(magrittr)
library(ggpubr)
library(NbClust)
library(mclust)
library(RODBC)
library(GGally)
library(xtable)
library(PerformanceAnalytics)
library(Hmisc)
library(stringr)
library(broom)
library(sqldf)
#library(corrplot)
library(xgboost)
library(pROC)
library(nnet)
library(data.table)
library(rpart)
library(rpart.plot)
library(xgboostExplainer)

##SETTING UP CURRENT YEAR AND CURRENT WEEK
year_week <- 201848
cur_yearmth <- 201811

##CONNECTING TO RAL_MI 
ral <- odbcConnect('sandbox')

## BRING IN THE ALL DEALERS INFORMATION INFORMATION FROM DATA WAREHOUSE
Churn_data <- sqlQuery(ral, "SELECT  a.*, b.entry_level_product from marketing_sandbox.dbo.churn_model_data a
  left join (select CUSTOMER_NUMBER, ENTRY_LEVEL_PRODUCT 
                       FROM marketing_sandbox.dbo.RPT_CUSTOMER_DATA_WEEKLY where FISCAL_YEAR*100+FISCAL_WEEK_NUM = 201846) b on a.Avus_Account_Number = b.CUSTOMER_NUMBER")

##BRING IN DEALER MANAGER FROM DATA WAREHOUSE

dealer_manager <- sqlQuery(ral, "Avus_Account_Number as AVUSID,
                            b.Name as Dealer_Name,
                           e.LocationPostalCode as Dealer_PostalCode,
                           b.SalesOrg_PMR as Assigned_Region,
                           isnull(d.Name,'Vacant') as Assigned_Director,
                           isnull(c.Name,'Vacant') as Assigned_Manager,
                           isnull(b.Name,'Vacant') as Assigned_Salesman,
                           a.Product_Type as Segmentation,
                           a.ParentName as Dealer_Group
                           from ral_mi.dbo.CURR_SALESFORCE_ACCOUNT a
                           left join ral_mi.[dtl].[CURR_SF_USER] b on a.ownerid = b.id
                           left join ral_mi.[dtl].[CURR_SF_USER]  c on a.Sales_Regional_Account_ManagerId = c.id
                           left join ral_mi.[dtl].[CURR_SF_USER]  d on a.Sales_Account_DirectorId = d.id
                           left join ral_mi.[dbo].CURRENT_ONL_COMPANY e on isnull(a.tdsr_ppg_id, a.avus_account_number) = isnull(e.sourceforeignid, e.adtackingid)
                           where type2 = 'client - active'
                           and isnull(a.tdsr_ppg_id, a.avus_account_number) is not null
                           and a.tdsr_ppg_id is not null
                           group by
                           Avus_Account_Number,
                           b.Name,
                           e.LocationPostalCode,
                           b.SalesOrg_PMR,
                           isnull(d.Name,'Vacant'),
                           isnull(c.Name,'Vacant'),
                           isnull(b.Name,'Vacant'),
                           a.Product_Type,
                           a.ParentName")


#Churn_data$text_pv_new[is.na(Churn_data$text_pv_new)] <- 0
#summary(Churn_data[,63:72])
#leadscorrelation <- cor(Churn_data[,63:68])
#print(leadscorrelation)
##highleadscorr <- findCorrelation(leadscorrelation, cutoff = abs(0.7))
#print(highleadscorr)

churned$churned <- 1
churnedclean <- as.data.frame(churned[,c(1,57)])
churnedclean <- churnedclean[!duplicated(churnedclean),]
##churnedclean$rows <- row(churnedclean)
##churnedclean <- filter(churnedclean, rows < 1353)

##Churn_data$Avus_Account_Number <- str_pad(Churn_data$Avus_Account_Number,8,pad = "0")

Churn_data <- merge.data.frame(x = Churn_data, y = churnedclean, by.x = "Avus_Account_Number" , by.y = "AVUS.Account.Number", all.x = TRUE)
Churn_data$churned[is.na(Churn_data$churned)] <- 0
table(Churn_data$churned)
##colnames(Churn_data)

##CALCULATE THE MONTHLY AVGS
group_avg_churned_data <- Churn_data %>% filter(year_mth != 201812)  %>%  group_by(Avus_Account_Number, Product_Type, DG_NonDG, Franchise_Type, Territory, OEM, Type2, entry_level_product)  %>% 
  summarise(maxyear = max(year_mth), URL_provider = max(binary_URL_provider),
             avg_new_sln_sales = mean(new_sln_sales[new_sln_sales!=0], na.rm = TRUE),
             avg_new_sln_disc = mean(new_sln_discount[new_sln_discount != 0], na.rm=TRUE),
            avg_new_upsell_sales = mean(new_upsell_sales[new_upsell_sales != 0], na.rm = T),
            avg_new_upsell_discount = mean(new_upsell_discount[new_upsell_discount != 0], na.rm = T),
            avg_used_sln_sales = mean(used_sln_sales[used_sln_sales !=0], na.rm = T),
            avg_used_sln_discount = mean(used_sln_discount[used_sln_discount !=0], na.rm=T),
            avg_used_upsell_sales = mean(used_upsell_sales[used_upsell_sales !=0], na.rm=T),
            avg_used_upsell_disc = mean(used_upsell_discount[used_upsell_discount !=0], na.rm=T),
            avg_velocit_sales = mean(velocit_sales[velocit_sales !=0], na.rm=T),
            avg_TRFFK_sales = mean(TRFFK_sales[TRFFK_sales !=0], na.rm=T),
            avg_other_sales = mean(other_sales[other_sales !=0], na.rm=T),
            avg_other_disc = mean(other_sales_discount[other_sales_discount !=0], na.rm=T),
            number_weeks_active = max(number_weeks_active),
            number_weeks_inactive = min(number_weeks_inactive),
            avg_used_ads = mean(used_ads[used_ads !=0], na.rm=T),
            avg_new_ads = mean(new_ads[new_ads !=0], na.rm=T),
            avg_used_price = mean(used_avg_price[used_avg_price !=0], na.rm=T),
            avg_new_price = mean(new_avg_price[new_avg_price !=0], na.rm=T),
            avg_used_odometer = mean(used_avg_odometer[used_avg_odometer !=0], na.rm=T),
            avg_new_odometer = mean(new_avg_odometer[new_avg_odometer !=0], na.rm=T),
            avg_used_photos = mean(used_avg_photos, na.rm=T),
            avg_new_photos = mean(new_avg_photos, na.rm=T),
            avg_used_upsells = mean(used_avg_upsells, na.rm=T),
            avg_new_upsells = mean(new_avg_upsells, na.rm=T),
            avg_used_ppl_pen = mean(used_ppl_pen[used_ppl_pen !=0], na.rm=T),
            avg_new_ppl_pen = mean(new_ppl_pen[new_ppl_pen !=0], na.rm=T),
            avg_used_pl_pen = mean(used_pl_pen[used_pl_pen !=0], na.rm=T),
            avg_new_pl_pen = mean(new_pl_pen[new_pl_pen !=0], na.rm=T),
            avg_used_mb_pen = mean(used_mb_pen[used_mb_pen !=0], na.rm=T),
            avg_new_mb_pen = mean(new_mb_pen[new_mb_pen !=0], na.rm=T),
            avg_used_topad_pen = mean(used_topad_pen[used_topad_pen !=0], na.rm=T),
            avg_new_topad_pen = mean(new_topad_pen[new_topad_pen !=0], na.rm=T),
            avg_used_fl_pen = mean(used_fl_pen[used_fl_pen !=0], na.rm=T),
            avg_new_fl_pen = mean(new_fl_pen[new_fl_pen !=0], na.rm=T),
            avg_used_mhl_pen = mean(used_mhl_pen[used_mhl_pen !=0], na.rm=T),
            avg_new_mhl_pen = mean(new_mhl_pen[new_mhl_pen !=0], na.rm=T),
            avg_used_swppro_pen = mean(used_swppro_pen[used_swppro_pen !=0], na.rm=T),
            avg_new_swppro_pen = mean(new_swppro_pen[new_swppro_pen !=0], na.rm=T),
            avg_tot_pv_new_VDPs = mean(tot_pv_new_VDPs[tot_pv_new_VDPs !=0], na.rm=T),
            avg_tot_pv_used_VDPs = mean(tot_pv_used_VDPs[tot_pv_used_VDPs !=0], na.rm=T),
            avg_dt_pv_new_VDPs = mean(dt_pv_new_VDPs[dt_pv_new_VDPs !=0], na.rm=T),
            avg_dt_pv_used_VDPs = mean(dt_pv_used_VDPs[dt_pv_used_VDPs !=0], na.rm=T),
            avg_mob_pv_new_VDPs = mean(mob_pv_new_VDPs[mob_pv_new_VDPs !=0], na.rm=T),
            avg_mob_pv_used_VDPs = mean(mob_pv_used_VDPs[mob_pv_used_VDPs !=0], na.rm=T),
            avg_tot_npv_new_VDPs = mean(tot_npv_new_VDPs[tot_npv_new_VDPs !=0], na.rm=T),
            avg_tot_npv_used_VDPs = mean(tot_npv_used_VDPs[tot_npv_used_VDPs], na.rm=T),
            avg_dt_npv_new_VDPs = mean(dt_npv_new_VDPs[dt_npv_new_VDPs !=0], na.rm=T),
            avg_dt_npv_used_VDPs = mean(dt_npv_used_VDPs[dt_npv_used_VDPs !=0], na.rm=T),
            avg_mob_npv_new_VDPs = mean(mob_npv_new_VDPs[mob_npv_new_VDPs !=0], na.rm=T),
            avg_mob_npv_used_VDPs = mean(mob_npv_used_VDPs[mob_npv_used_VDPs !=0], na.rm=T),
            avg_tot_pv_new_email_leads = mean(tot_pv_new_email_leads[tot_pv_new_email_leads !=0], na.rm=T),
            avg_tot_pv_used_email_leads = mean(tot_pv_used_email_leads[tot_pv_used_email_leads !=0], na.rm=T),
            avg_tot_npv_new_email_leads = mean(tot_npv_new_email_leads[tot_npv_new_email_leads !=0], na.rm=T),
            avg_tot_npv_used_email_leads = mean(tot_npv_used_email_leads[tot_npv_used_email_leads !=0], na.rm=T),
            avg_tot_new_phone_leads = mean(tot_new_phone_leads[tot_new_phone_leads !=0], na.rm=T),
            avg_tot_used_phone_leads = mean(tot_used_phone_leads[tot_used_phone_leads !=0], na.rm=T),
            churned = max(churned))


##BRING IN THE CURRENT MONTH TOTALS            
group_curr_churned_data <- Churn_data %>% filter(year_mth == cur_yearmth)  %>% group_by(Avus_Account_Number, Product_Type, DG_NonDG, Franchise_Type, Territory, OEM, Type2, entry_level_product)  %>% 
  summarise(curr_new_sln_sales = sum(new_sln_sales[new_sln_sales!=0], na.rm = TRUE),
            curr_new_sln_disc = sum(new_sln_discount[new_sln_discount != 0], na.rm=TRUE),
            curr_new_upsell_sales = sum(new_upsell_sales[new_upsell_sales != 0], na.rm = T),
            curr_new_upsell_discount = sum(new_upsell_discount[new_upsell_discount != 0], na.rm = T),
            curr_used_sln_sales = sum(used_sln_sales[used_sln_sales !=0], na.rm = T),
            curr_used_sln_discount = sum(used_sln_discount[used_sln_discount !=0], na.rm=T),
            curr_used_upsell_sales = sum(used_upsell_sales[used_upsell_sales !=0], na.rm=T),
            curr_used_upsell_disc = sum(used_upsell_discount[used_upsell_discount !=0], na.rm=T),
            curr_velocit_sales = sum(velocit_sales[velocit_sales !=0], na.rm=T),
            curr_TRFFK_sales = sum(TRFFK_sales[TRFFK_sales !=0], na.rm=T),
            curr_other_sales = sum(other_sales[other_sales !=0], na.rm=T),
            curr_other_disc = sum(other_sales_discount[other_sales_discount !=0], na.rm=T),
            Curr_used_ads = mean(used_ads[used_ads !=0], na.rm=T),
            curr_new_ads = mean(new_ads[new_ads !=0], na.rm=T),
            curr_used_price = mean(used_avg_price[used_avg_price !=0], na.rm=T),
            curr_new_price = mean(new_avg_price[new_avg_price !=0], na.rm=T),
            curr_used_odometer = mean(used_avg_odometer[used_avg_odometer !=0], na.rm=T),
            curr_new_odometer = mean(new_avg_odometer[new_avg_odometer !=0], na.rm=T),
            curr_used_photos = mean(used_avg_photos, na.rm=T),
            curr_new_photos = mean(new_avg_photos, na.rm=T),
            curr_used_upsells = mean(used_avg_upsells, na.rm=T),
            curr_new_upsells = mean(new_avg_upsells, na.rm=T),
            curr_used_ppl_pen = mean(used_ppl_pen[used_ppl_pen !=0], na.rm=T),
            curr_new_ppl_pen = mean(new_ppl_pen[new_ppl_pen !=0], na.rm=T),
            curr_used_pl_pen = mean(used_pl_pen[used_pl_pen !=0], na.rm=T),
            curr_new_pl_pen = mean(new_pl_pen[new_pl_pen !=0], na.rm=T),
            curr_used_mb_pen = mean(used_mb_pen[used_mb_pen !=0], na.rm=T),
            curr_new_mb_pen = mean(new_mb_pen[new_mb_pen !=0], na.rm=T),
            Curr_used_topad_pen = mean(used_topad_pen[used_topad_pen !=0], na.rm=T),
            curr_new_topad_pen = mean(new_topad_pen[new_topad_pen !=0], na.rm=T),
            curr_used_fl_pen = mean(used_fl_pen[used_fl_pen !=0], na.rm=T),
            curr_new_fl_pen = mean(new_fl_pen[new_fl_pen !=0], na.rm=T),
            curr_used_mhl_pen = mean(used_mhl_pen[used_mhl_pen !=0], na.rm=T),
            curr_new_mhl_pen = mean(new_mhl_pen[new_mhl_pen !=0], na.rm=T),
            curr_used_swppro_pen = mean(used_swppro_pen[used_swppro_pen !=0], na.rm=T),
            curr_new_swppro_pen = mean(new_swppro_pen[new_swppro_pen !=0], na.rm=T),
            curr_tot_pv_new_VDPs = sum(tot_pv_new_VDPs[tot_pv_new_VDPs !=0], na.rm=T),
            curr_tot_pv_used_VDPs = sum(tot_pv_used_VDPs[tot_pv_used_VDPs !=0], na.rm=T),
            curr_dt_pv_new_VDPs = sum(dt_pv_new_VDPs[dt_pv_new_VDPs !=0], na.rm=T),
            curr_dt_pv_used_VDPs = sum(dt_pv_used_VDPs[dt_pv_used_VDPs !=0], na.rm=T),
            curr_mob_pv_new_VDPs = sum(mob_pv_new_VDPs[mob_pv_new_VDPs !=0], na.rm=T),
            curr_mob_pv_used_VDPs = sum(mob_pv_used_VDPs[mob_pv_used_VDPs !=0], na.rm=T),
            curr_tot_npv_new_VDPs = sum(tot_npv_new_VDPs[tot_npv_new_VDPs !=0], na.rm=T),
            curr_tot_npv_used_VDPs = sum(tot_npv_used_VDPs[tot_npv_used_VDPs], na.rm=T),
            curr_dt_npv_new_VDPs = sum(dt_npv_new_VDPs[dt_npv_new_VDPs !=0], na.rm=T),
            curr_dt_npv_used_VDPs = sum(dt_npv_used_VDPs[dt_npv_used_VDPs !=0], na.rm=T),
            curr_mob_npv_new_VDPs = sum(mob_npv_new_VDPs[mob_npv_new_VDPs !=0], na.rm=T),
            curr_mob_npv_used_VDPs = sum(mob_npv_used_VDPs[mob_npv_used_VDPs !=0], na.rm=T),
            curr_tot_pv_new_email_leads = sum(tot_pv_new_email_leads[tot_pv_new_email_leads !=0], na.rm=T),
            curr_tot_pv_used_email_leads = sum(tot_pv_used_email_leads[tot_pv_used_email_leads !=0], na.rm=T),
            curr_tot_npv_new_email_leads = sum(tot_npv_new_email_leads[tot_npv_new_email_leads !=0], na.rm=T),
            curr_tot_npv_used_email_leads = sum(tot_npv_used_email_leads[tot_npv_used_email_leads !=0], na.rm=T),
            curr_tot_new_phone_leads = sum(tot_new_phone_leads[tot_new_phone_leads !=0], na.rm=T),
            curr_tot_used_phone_leads = sum(tot_used_phone_leads[tot_used_phone_leads !=0], na.rm=T))            

##COMBING THE AVGS AND THE CURRENT MONTH STATS

group_churned_data <- left_join(group_avg_churned_data,group_curr_churned_data[,-c(2:8)], by="Avus_Account_Number")

group_churned_data$newcarflag <- ifelse(group_churned_data$avg_new_sln_sales > 0 , 1, 0)
group_churned_data$usedcarflag <- ifelse(group_churned_data$avg_used_sln_sales > 0 , 1, 0)
edit(group_churned_data)
colnames(group_churned_data)

pv_used_churn <- group_churned_data %>% filter(Product_Type == "PV" & usedcarflag == 1) %>%
  select(c(1:10,15:25,27,29,31,33,35,37,39,41,43,45,47,50,52,54,62,66,67,72:80,
           82,84,86,88,90,92,94,96,98,100,102,105,107,109,117,121))

pv_used_churn <- as.data.frame(pv_used_churn)
str(pv_used_churn)

pv_used_churn$Avus_Account_Number <- as.factor(pv_used_churn$Avus_Account_Number)
pv_used_churn$churned <- as.factor(pv_used_churn$churned)


##pv_used_churn <- select(pv_used_churn,c(1:36,41:65))
pv_used_churn[is.na(pv_used_churn)] <- 0
 
##table(pv_used_churn$churned)
##pv_used_churn$churned <- as.factor(pv_used_churn$churned)
##pv_used_churn$OEM.x <- as.factor(pv_used_churn$OEM.x)


##levels(pv_used_churn$OEM.x)


##levels(pv_used_churn$churned) <- c('N','Y')
##str(pv_used_churn$churned)
##names(pv_used_churn)

colnames(pv_used_churn)
pv_used_churn$upsell_count <- rowSums(ceiling(pv_used_churn[,52:58]), na.rm = T)

##numeric.var <- sapply(pv_used_churn, is.numeric)
##corr.matrix <- cor(pv_used_churn[,numeric.var])
##corrplot::corrplot(corr.matrix, main="\n\nCorrelation Plot for Numerical Variables", method="number")

##REPLACING NAs WITH 0 for regression
##pv_used_churn$OEM.x[is.na(pv_used_churn$OEM.x)] <- "None"
##pv_used_churn$OEM.x <- gsub(is.na(pv_used_churn$OEM.x),"None",pv_used_churn$OEM.x)

##is.nan.data.frame <- function(x) do.call(cbind, lapply(x, is.nan)) 
##pv_used_churn[is.nan(pv_used_churn)] <- 0
##pv_used_churn$upsell_count <- rowSums(ceiling(pv_used_churn[,20:26]), na.rm = T)

##sapply(pv_used_churn, function(x) sum(is.na(x)))

##pv_used_churn_full <- sqldf("select a.*, b.DG_NonDG, b.Franchise_Type, b.OEM, b.Territory 
  ##                          from pv_used_churn a left join Churn_data b on a.Avus_Account_Number=b.Avus_Account_Number 
  ##                           where b.Avus_Account_Number is not  NULL ")


##FINDING AND REMOVING CORRELATED VAIRABLES WITH A CORRELATION VALUE OF 0.7 and GREATHER
colnames(pv_used_churn)
pv_used_corr <- cor(pv_used_churn[,c(11:37,39:64)])
print(pv_used_corr)
pv_used_high_corr <- sort(findCorrelation(pv_used_corr, cutoff = 0.7))

corrplot(pv_used_corr, 
                   method = 'color', 
                   type = 'lower', 
                   is.corr = T, 
                   tl.cex = 0.5, 
                  addCoef.col = "black" ,  number.cex = 0.3,
                   tl.srt = 10,
                  diag = F)

pv_used_corr <- as.data.frame(pv_used_corr)
print(pv_used_high_corr)

corrnames <- names(pv_used_corr[c(pv_used_high_corr)])

pv_used_churn_reduced <- pv_used_churn[,!(names(pv_used_churn) %in% corrnames)]

table(pv_used_churn_reduced$churned)

##make.names(levels(pv_used_churn_reduced$churned))
##table(pv_used_churn_reduced$churned)
##levels(pv_used_churn_reduced$churned) <- c('N','Y')

str(pv_used_churn_reduced)

##VISUALZING THE CATEGORICALVARIABLES

##lapply(c("churned", "DG_NonDG.x", "Franchise_Type.x", "Territory.x","OEM.x"), 
##       function(col) { ggplot(pv_used_churn, aes_string(col)) + geom_bar() + coord_flip() })


lapply(c("DG_NonDG", "Franchise_Type", "Territory","OEM","entry_level_product","URL_provider"), 
       function(col) { ggplot(pv_used_churn_reduced, aes_string(x=col,fill=pv_used_churn_reduced$churned)) + geom_bar() + coord_flip() })

##pv_used_churn %>% gather(DG_NonDG.x, Franchise_Type.x, Territory.x,OEM.x) %>% group_by(churned) %>% summarise (n = n()) %>% mutate(freq = n / sum(n))
##SPLITTING DATA SETS

##library(forcats) 
##pv_used_churn$OEM.x <- fct_explicit_na(pv_used_churn$OEM.x, na_level = "None")
##levels(pv_used_churn$OEM)

##pv_used_churn$Territory.x <- fct_explicit_na(pv_used_churn$Territory.x, na_level = "None")
##pv_used_churn$DG_NonDG.x <- fct_explicit_na(pv_used_churn$DG_NonDG.x, na_level = "None")

set.seed(123)


levels(pv_used_churn_reduced$churned) <- c(0,1)
pv_used_churn_reduced$churned <- as.factor(pv_used_churn_reduced$churned)

train_index <- createDataPartition(pv_used_churn_reduced$churned, p = 0.8, list = FALSE)
train_set <- pv_used_churn_reduced[train_index,]
test_set <- pv_used_churn_reduced[-train_index,]
summary(pv_used_churn)

table(train_set$churned)

#######RUNNING XGBOOST MODEL
str(train_set)
contrasts(as.factor(train_set$churned)) 
levels(train_set$churned)

cv <- createFolds(train_set$churned, k = 10)
xgb.train.data <- xgb.DMatrix(data.matrix(train_set[,-c(1:2,7:9,17,29)]), label = as.numeric(as.character(train_set$churned)), missing = NA)
param <- list(objective = "binary:logistic", base_score = 0.5)
cgboost.cv = xgb.cv(param=param, data = xgb.train.data, folds = cv, nrounds = 1500, early_stopping_rounds = 100, metric='auc')
best_iteration = cgboost.cv$best_iteration

xgb.model <- xgboost(params = param,data = xgb.train.data, nrounds=best_iteration)

####RUNNING THE XGB MODEL ON THE TEST DATA
xgb.test.data = xgb.DMatrix(data.matrix(test_set[,-c(1:2,7:9,17,29)]), missing = NA)
xgb.preds = predict(xgb.model, xgb.test.data)
pred.resp <- ifelse(xgb.preds > 0.5, 1, 0)
confusionMatrix(as.factor(pred.resp), test_set$churned, positive = "1")


###XGB MODEL IMPORTANCE
col_names = attr(xgb.train.data, ".Dimnames")[[2]]
imp = xgb.importance(col_names, xgb.model)
xgb.plot.importance(imp)

###RUNNING THE EXPLAINER FOR EPLAINING THE XGBOOST VAIRBALES IN MODEL
trees = xgb.model.dt.tree(feature_names = NULL,model = xgb.model)

explainer = buildExplainer(xgb.model, xgb.test.data, type="binary", base_score = 0.5, trees_idx = NULL)
pred.breakdown = explainPredictions(xgb.model, explainer, xgb.test.data)
cat('Breakdown Complete','\n')
weights = rowSums(pred.breakdown)
pred.xgb = 1/(1+exp(-weights))
cat(max(xgb.preds-pred.xgb),'\n')

#find the max and min predicted
idx_to_get = as.integer(which.is.max(xgb.preds)-1)
test_set[idx_to_get,test_set$churned]
showWaterfall(xgb.model, explainer, xgb.test.data, data.matrix(test_set$churned) ,idx_to_get, type = "binary")

                      ##BRING IN ACTIVE DEALERS ONLY AND RUN THE MODEL

Churn_data <- sqlQuery(ral, "SELECT  a.*, b.entry_level_product from marketing_sandbox.dbo.churn_model_data a
  left join (select CUSTOMER_NUMBER, ENTRY_LEVEL_PRODUCT 
                       FROM marketing_sandbox.dbo.RPT_CUSTOMER_DATA_WEEKLY where FISCAL_YEAR*100+FISCAL_WEEK_NUM = 201848) b on a.Avus_Account_Number = b.CUSTOMER_NUMBER
                       where Type2 = 'Client - Active'")

group_avg_churned_data <- Churn_data %>% filter(year_mth != 201812)  %>%  group_by(Avus_Account_Number, Product_Type, DG_NonDG, Franchise_Type, Territory, OEM, Type2, entry_level_product)  %>% 
  summarise(maxyear = max(year_mth), URL_provider = max(binary_URL_provider),
            avg_new_sln_sales = mean(new_sln_sales[new_sln_sales!=0], na.rm = TRUE),
            avg_new_sln_disc = mean(new_sln_discount[new_sln_discount != 0], na.rm=TRUE),
            avg_new_upsell_sales = mean(new_upsell_sales[new_upsell_sales != 0], na.rm = T),
            avg_new_upsell_discount = mean(new_upsell_discount[new_upsell_discount != 0], na.rm = T),
            avg_used_sln_sales = mean(used_sln_sales[used_sln_sales !=0], na.rm = T),
            avg_used_sln_discount = mean(used_sln_discount[used_sln_discount !=0], na.rm=T),
            avg_used_upsell_sales = mean(used_upsell_sales[used_upsell_sales !=0], na.rm=T),
            avg_used_upsell_disc = mean(used_upsell_discount[used_upsell_discount !=0], na.rm=T),
            avg_velocit_sales = mean(velocit_sales[velocit_sales !=0], na.rm=T),
            avg_TRFFK_sales = mean(TRFFK_sales[TRFFK_sales !=0], na.rm=T),
            avg_other_sales = mean(other_sales[other_sales !=0], na.rm=T),
            avg_other_disc = mean(other_sales_discount[other_sales_discount !=0], na.rm=T),
            number_weeks_active = max(number_weeks_active),
            number_weeks_inactive = min(number_weeks_inactive),
            avg_used_ads = mean(used_ads[used_ads !=0], na.rm=T),
            avg_new_ads = mean(new_ads[new_ads !=0], na.rm=T),
            avg_used_price = mean(used_avg_price[used_avg_price !=0], na.rm=T),
            avg_new_price = mean(new_avg_price[new_avg_price !=0], na.rm=T),
            avg_used_odometer = mean(used_avg_odometer[used_avg_odometer !=0], na.rm=T),
            avg_new_odometer = mean(new_avg_odometer[new_avg_odometer !=0], na.rm=T),
            avg_used_photos = mean(used_avg_photos, na.rm=T),
            avg_new_photos = mean(new_avg_photos, na.rm=T),
            avg_used_upsells = mean(used_avg_upsells, na.rm=T),
            avg_new_upsells = mean(new_avg_upsells, na.rm=T),
            avg_used_ppl_pen = mean(used_ppl_pen[used_ppl_pen !=0], na.rm=T),
            avg_new_ppl_pen = mean(new_ppl_pen[new_ppl_pen !=0], na.rm=T),
            avg_used_pl_pen = mean(used_pl_pen[used_pl_pen !=0], na.rm=T),
            avg_new_pl_pen = mean(new_pl_pen[new_pl_pen !=0], na.rm=T),
            avg_used_mb_pen = mean(used_mb_pen[used_mb_pen !=0], na.rm=T),
            avg_new_mb_pen = mean(new_mb_pen[new_mb_pen !=0], na.rm=T),
            avg_used_topad_pen = mean(used_topad_pen[used_topad_pen !=0], na.rm=T),
            avg_new_topad_pen = mean(new_topad_pen[new_topad_pen !=0], na.rm=T),
            avg_used_fl_pen = mean(used_fl_pen[used_fl_pen !=0], na.rm=T),
            avg_new_fl_pen = mean(new_fl_pen[new_fl_pen !=0], na.rm=T),
            avg_used_mhl_pen = mean(used_mhl_pen[used_mhl_pen !=0], na.rm=T),
            avg_new_mhl_pen = mean(new_mhl_pen[new_mhl_pen !=0], na.rm=T),
            avg_used_swppro_pen = mean(used_swppro_pen[used_swppro_pen !=0], na.rm=T),
            avg_new_swppro_pen = mean(new_swppro_pen[new_swppro_pen !=0], na.rm=T),
            avg_tot_pv_new_VDPs = mean(tot_pv_new_VDPs[tot_pv_new_VDPs !=0], na.rm=T),
            avg_tot_pv_used_VDPs = mean(tot_pv_used_VDPs[tot_pv_used_VDPs !=0], na.rm=T),
            avg_dt_pv_new_VDPs = mean(dt_pv_new_VDPs[dt_pv_new_VDPs !=0], na.rm=T),
            avg_dt_pv_used_VDPs = mean(dt_pv_used_VDPs[dt_pv_used_VDPs !=0], na.rm=T),
            avg_mob_pv_new_VDPs = mean(mob_pv_new_VDPs[mob_pv_new_VDPs !=0], na.rm=T),
            avg_mob_pv_used_VDPs = mean(mob_pv_used_VDPs[mob_pv_used_VDPs !=0], na.rm=T),
            avg_tot_npv_new_VDPs = mean(tot_npv_new_VDPs[tot_npv_new_VDPs !=0], na.rm=T),
            avg_tot_npv_used_VDPs = mean(tot_npv_used_VDPs[tot_npv_used_VDPs], na.rm=T),
            avg_dt_npv_new_VDPs = mean(dt_npv_new_VDPs[dt_npv_new_VDPs !=0], na.rm=T),
            avg_dt_npv_used_VDPs = mean(dt_npv_used_VDPs[dt_npv_used_VDPs !=0], na.rm=T),
            avg_mob_npv_new_VDPs = mean(mob_npv_new_VDPs[mob_npv_new_VDPs !=0], na.rm=T),
            avg_mob_npv_used_VDPs = mean(mob_npv_used_VDPs[mob_npv_used_VDPs !=0], na.rm=T),
            avg_tot_pv_new_email_leads = mean(tot_pv_new_email_leads[tot_pv_new_email_leads !=0], na.rm=T),
            avg_tot_pv_used_email_leads = mean(tot_pv_used_email_leads[tot_pv_used_email_leads !=0], na.rm=T),
            avg_tot_npv_new_email_leads = mean(tot_npv_new_email_leads[tot_npv_new_email_leads !=0], na.rm=T),
            avg_tot_npv_used_email_leads = mean(tot_npv_used_email_leads[tot_npv_used_email_leads !=0], na.rm=T),
            avg_tot_new_phone_leads = mean(tot_new_phone_leads[tot_new_phone_leads !=0], na.rm=T),
            avg_tot_used_phone_leads = mean(tot_used_phone_leads[tot_used_phone_leads !=0], na.rm=T)
            )


##BRING IN THE CURRENT MONTH TOTALS            
group_curr_churned_data <- Churn_data %>% filter(year_mth == cur_yearmth)  %>% group_by(Avus_Account_Number, Product_Type, DG_NonDG, Franchise_Type, Territory, OEM, Type2, entry_level_product)  %>% 
  summarise(curr_new_sln_sales = sum(new_sln_sales[new_sln_sales!=0], na.rm = TRUE),
            curr_new_sln_disc = sum(new_sln_discount[new_sln_discount != 0], na.rm=TRUE),
            curr_new_upsell_sales = sum(new_upsell_sales[new_upsell_sales != 0], na.rm = T),
            curr_new_upsell_discount = sum(new_upsell_discount[new_upsell_discount != 0], na.rm = T),
            curr_used_sln_sales = sum(used_sln_sales[used_sln_sales !=0], na.rm = T),
            curr_used_sln_discount = sum(used_sln_discount[used_sln_discount !=0], na.rm=T),
            curr_used_upsell_sales = sum(used_upsell_sales[used_upsell_sales !=0], na.rm=T),
            curr_used_upsell_disc = sum(used_upsell_discount[used_upsell_discount !=0], na.rm=T),
            curr_velocit_sales = sum(velocit_sales[velocit_sales !=0], na.rm=T),
            curr_TRFFK_sales = sum(TRFFK_sales[TRFFK_sales !=0], na.rm=T),
            curr_other_sales = sum(other_sales[other_sales !=0], na.rm=T),
            curr_other_disc = sum(other_sales_discount[other_sales_discount !=0], na.rm=T),
            Curr_used_ads = mean(used_ads[used_ads !=0], na.rm=T),
            curr_new_ads = mean(new_ads[new_ads !=0], na.rm=T),
            curr_used_price = mean(used_avg_price[used_avg_price !=0], na.rm=T),
            curr_new_price = mean(new_avg_price[new_avg_price !=0], na.rm=T),
            curr_used_odometer = mean(used_avg_odometer[used_avg_odometer !=0], na.rm=T),
            curr_new_odometer = mean(new_avg_odometer[new_avg_odometer !=0], na.rm=T),
            curr_used_photos = mean(used_avg_photos, na.rm=T),
            curr_new_photos = mean(new_avg_photos, na.rm=T),
            curr_used_upsells = mean(used_avg_upsells, na.rm=T),
            curr_new_upsells = mean(new_avg_upsells, na.rm=T),
            curr_used_ppl_pen = mean(used_ppl_pen[used_ppl_pen !=0], na.rm=T),
            curr_new_ppl_pen = mean(new_ppl_pen[new_ppl_pen !=0], na.rm=T),
            curr_used_pl_pen = mean(used_pl_pen[used_pl_pen !=0], na.rm=T),
            curr_new_pl_pen = mean(new_pl_pen[new_pl_pen !=0], na.rm=T),
            curr_used_mb_pen = mean(used_mb_pen[used_mb_pen !=0], na.rm=T),
            curr_new_mb_pen = mean(new_mb_pen[new_mb_pen !=0], na.rm=T),
            Curr_used_topad_pen = mean(used_topad_pen[used_topad_pen !=0], na.rm=T),
            curr_new_topad_pen = mean(new_topad_pen[new_topad_pen !=0], na.rm=T),
            curr_used_fl_pen = mean(used_fl_pen[used_fl_pen !=0], na.rm=T),
            curr_new_fl_pen = mean(new_fl_pen[new_fl_pen !=0], na.rm=T),
            curr_used_mhl_pen = mean(used_mhl_pen[used_mhl_pen !=0], na.rm=T),
            curr_new_mhl_pen = mean(new_mhl_pen[new_mhl_pen !=0], na.rm=T),
            curr_used_swppro_pen = mean(used_swppro_pen[used_swppro_pen !=0], na.rm=T),
            curr_new_swppro_pen = mean(new_swppro_pen[new_swppro_pen !=0], na.rm=T),
            curr_tot_pv_new_VDPs = sum(tot_pv_new_VDPs[tot_pv_new_VDPs !=0], na.rm=T),
            curr_tot_pv_used_VDPs = sum(tot_pv_used_VDPs[tot_pv_used_VDPs !=0], na.rm=T),
            curr_dt_pv_new_VDPs = sum(dt_pv_new_VDPs[dt_pv_new_VDPs !=0], na.rm=T),
            curr_dt_pv_used_VDPs = sum(dt_pv_used_VDPs[dt_pv_used_VDPs !=0], na.rm=T),
            curr_mob_pv_new_VDPs = sum(mob_pv_new_VDPs[mob_pv_new_VDPs !=0], na.rm=T),
            curr_mob_pv_used_VDPs = sum(mob_pv_used_VDPs[mob_pv_used_VDPs !=0], na.rm=T),
            curr_tot_npv_new_VDPs = sum(tot_npv_new_VDPs[tot_npv_new_VDPs !=0], na.rm=T),
            curr_tot_npv_used_VDPs = sum(tot_npv_used_VDPs[tot_npv_used_VDPs], na.rm=T),
            curr_dt_npv_new_VDPs = sum(dt_npv_new_VDPs[dt_npv_new_VDPs !=0], na.rm=T),
            curr_dt_npv_used_VDPs = sum(dt_npv_used_VDPs[dt_npv_used_VDPs !=0], na.rm=T),
            curr_mob_npv_new_VDPs = sum(mob_npv_new_VDPs[mob_npv_new_VDPs !=0], na.rm=T),
            curr_mob_npv_used_VDPs = sum(mob_npv_used_VDPs[mob_npv_used_VDPs !=0], na.rm=T),
            curr_tot_pv_new_email_leads = sum(tot_pv_new_email_leads[tot_pv_new_email_leads !=0], na.rm=T),
            curr_tot_pv_used_email_leads = sum(tot_pv_used_email_leads[tot_pv_used_email_leads !=0], na.rm=T),
            curr_tot_npv_new_email_leads = sum(tot_npv_new_email_leads[tot_npv_new_email_leads !=0], na.rm=T),
            curr_tot_npv_used_email_leads = sum(tot_npv_used_email_leads[tot_npv_used_email_leads !=0], na.rm=T),
            curr_tot_new_phone_leads = sum(tot_new_phone_leads[tot_new_phone_leads !=0], na.rm=T),
            curr_tot_used_phone_leads = sum(tot_used_phone_leads[tot_used_phone_leads !=0], na.rm=T))            

group_churned_data <- left_join(group_avg_churned_data,group_curr_churned_data[,-c(2:8)], by="Avus_Account_Number")

group_churned_data$newcarflag <- ifelse(group_churned_data$avg_new_sln_sales > 0 , 1, 0)
group_churned_data$usedcarflag <- ifelse(group_churned_data$avg_used_sln_sales > 0 , 1, 0)

colnames(group_churned_data)

pv_used_churn <- group_churned_data %>% filter(Product_Type == "PV" & usedcarflag == 1) %>%
  select(c(1:10,15:25,27,29,31,33,35,37,39,41,43,45,47,50,52,54,62,66,71:79,
           81,83,85,87,89,91,93,95,97,99,101,104,106,108,116,120))

pv_used_churn <- as.data.frame(pv_used_churn)

colnames(pv_used_churn)
pv_used_churn$upsell_count <- rowSums(ceiling(pv_used_churn[,51:57]), na.rm = T)

## REMOVING CORRELATED VAIRABLES WITH A CORRELATION VALUE OF 0.7 and GREATHER

pv_used_corr <- as.data.frame(pv_used_corr)
print(pv_used_high_corr)

corrnames <- names(pv_used_corr[c(pv_used_high_corr)])

pv_used_churn_reduced <- as.data.frame(pv_used_churn[,!(names(pv_used_churn) %in% corrnames)])
colnames(pv_used_churn_reduced)

##RUNNING THE XGBOOST MODEL ON THE DATA
xgb.pvused.data = xgb.DMatrix(data.matrix(pv_used_churn_reduced[,-c(1:2,7:9,17)]), missing = NA)
xgb.preds = predict(xgb.model, xgb.pvused.data)

explainer = buildExplainer(xgb.model, xgb.pvused.data, type="binary", base_score = 0.5, trees_idx = NULL)
pred.breakdown = explainPredictions(xgb.model, explainer, xgb.pvused.data)
cat('Breakdown Complete','\n')
weights = rowSums(pred.breakdown)
pred.xgb = 1/(1+exp(-weights))
cat(max(xgb.preds-pred.xgb),'\n')

#find the max and min predicted
idx_to_get = as.integer(which.is.max(xgb.preds))

showWaterfall(xgb.model, explainer, xgb.pvused.data , pv_used_churn_reduced , idx_to_get, type = "binary")
str(pv_used_churn_reduced)

###BRINGING IN DEALER MANAGERS

dealer_manager <- sqlQuery(ral, "select * from marketing_sandbox.dbo.dealer_manager")
str(dealer_manager)
complete_pvused_model <- cbind(pv_used_churn_reduced[,c(1:6,8,11,10,16,36,35,34)],pred.xgb,pred.breakdown)
complete_pvused_model <- complete_pvused_model[!duplicated(complete_pvused_model$Avus_Account_Number),]

complete_pvused_model <- merge.data.frame(complete_pvused_model, dealer_manager[,c(1,6:7,9)], by.x = "Avus_Account_Number", by.y = "AVUSID", all.x = T )

complete_pvused_model <- merge.data.frame(complete_pvused_model, Churn_data[!duplicated(Churn_data$Avus_Account_Number),c(1,5)], by.x ="Avus_Account_Number", by.y = "Avus_Account_Number", all.x =T)

write.xlsx(complete_pvused_model, file ="complete_pvused_model.xlsx", colnames = T)
