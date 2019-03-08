
------------------------------------------------------------------------BRINGING IN  SALES FROM AVUS INSERTION TABLE 201747 and plus
select b.avus_account_number, a.fiscalyear, a.fiscalweek, a.fiscalyear*100+a.fiscalweek as year_wk, FISCALYEAR*100+FISCALMONTH as year_mth, a.WEEKID ,b.Name, b.[OEM], b.DG_NonDG, b.Type2, b.BillingPostalCode as postalcode, d.Territory, 
	b.Package_Level, b.Primary_URL_Provider, b.Franchise_Type, b.Product_Type, c.Family, c.Summary_Product_Group , CONCAT(family,'_',summary_product_group) as family_group, CASE WHEN (family='New Car' OR Summary_Product_Group like '%(NC)%') THEN 1 ELSE 0 END as new_prd_flag,
 sum(netamount) as tot_sales, sum(quantity) * sum(listprice) as listprice
  

into #sales -- drop table #sales -- select * from #sales

from Dash.DPL.AVUS_INSERTION_DETAIL a left join [RAL_MI].[DTL].[CURR_SF_ACCOUNTS] b on a.CUSTOMERNUMBER = b.Avus_Account_Number
left join Dash.DTL.CURR_SF_PRODUCT c on a.RATECARDPRICEUNITID=c.avus_rate_card_ID
left join Marketing_Sandbox.dbo.ref_FSA_HeatMapTerritories d on SUBSTRING(b.BillingPostalCode,1,3) = d.[Forward Sortation Area]


where a.CUSTOMERNUMBER is not NULL and fiscalyear*100+FISCALWEEK between 201901 and 201905
	and (CONCAT(c.Family,'-',c.Product_Type) not in ('A la Carte-Total Control Dominator','A la Carte-SetUp Fee','Add-on-Listing Upgrades','Setup Fee-SetUp Fee' )) 
	and CHARINDEX('fee', b.Name) = 0
	and netamount >=0 
	--and b.avus_account_number = '01003318'

group by b.avus_account_number, b.Name, b.[OEM], b.DG_NonDG, b.Type2, b.BillingPostalCode , b.Package_Level ,fiscalyear, fiscalweek, fiscalyear*100+fiscalweek
	,d.Territory, b.Primary_URL_Provider, b.Product_Type, b.Franchise_Type, a.WEEKID,c.Family, c.Summary_Product_Group,FISCALYEAR*100+FISCALMONTH

order by Avus_Account_Number, year_wk

-----------------------BRINGING IN SALES FROM SALES HISTORY TABLE 201746 and under

/*insert into #sales
select b.avus_account_number, a.fiscalyear, a.fiscalweek, a.fiscalyear*100+a.fiscalweek as year_wk, fiscalyear*100+fiscalmonth as year_mth, a.FiscalWeekID ,b.Name, b.[OEM], b.DG_NonDG, b.Type2, b.BillingPostalCode as postalcode, d.Territory, 
	b.Package_Level, b.Primary_URL_Provider, b.Franchise_Type, b.Product_Type, c.Family, c.Summary_Product_Group, CONCAT(family,'_',summary_product_group) as family_group ,CASE WHEN (family='New Car' OR Summary_Product_Group like '%(NC)%') THEN 1 ELSE 0 END as new_prd_flag, 
	sum(InvoiceRowNetAmount) as tot_sales, sum(quantity) * sum(RatecardPrice) as listprice 



from Marketing_Sandbox.dbo.SalesHistory a left join [RAL_MI].[DTL].[CURR_SF_ACCOUNTS] b on a.CUSTOMERNUMBER = b.Avus_Account_Number
left join Dash.DTL.CURR_SF_PRODUCT c on a.RATECARDPRICEUNITID=c.avus_rate_card_ID
left join Marketing_Sandbox.dbo.ref_FSA_HeatMapTerritories d on SUBSTRING(b.BillingPostalCode,1,3) = d.[Forward Sortation Area]


where a.ManualInv = 0 and a.CUSTOMERNUMBER is not NULL and fiscalyear*100+FISCALWEEK between 201848 and 201852
	and (CONCAT(c.Family,'-',c.Product_Type) not in ('A la Carte-Total Control Dominator','A la Carte-SetUp Fee','Add-on-Listing Upgrades','Setup Fee-SetUp Fee' )) 
	and CHARINDEX('fee', b.Name) = 0
	and InvoiceRowNetAmount >=0 

group by b.avus_account_number, b.Name, b.[OEM], b.DG_NonDG, b.Type2, b.BillingPostalCode , b.Package_Level ,fiscalyear, fiscalweek, fiscalyear*100+fiscalweek
	,d.Territory, b.Primary_URL_Provider, b.Product_Type, b.Franchise_Type, a.FiscalWeekID, c.Family, c.Summary_Product_Group,fiscalyear*100+fiscalmonth

order by Avus_Account_Number, year_wk*/

-----------------------BRINGING IN MANUAL SALES from 201701 and plus

insert into #sales
select b.avus_account_number, a.fiscalyear, a.fiscalweek, a.fiscalyear*100+a.fiscalweek as year_wk, fiscalyear*100+fiscalmonth as year_mth, a.FiscalWeekID ,b.Name, b.[OEM], b.DG_NonDG, b.Type2, b.BillingPostalCode as postalcode, d.Territory, 
	b.Package_Level, b.Primary_URL_Provider, b.Franchise_Type, b.Product_Type, c.Family, c.Summary_Product_Group, CONCAT(family,'_',summary_product_group) as family_group ,CASE WHEN (family='New Car' OR Summary_Product_Group like '%(NC)%') THEN 1 ELSE 0 END as new_prd_flag, 
	sum(InvoiceRowNetAmount) as tot_sales, sum(quantity) * sum(RatecardPrice) as listprice 



from Marketing_Sandbox.dbo.SalesHistory a left join [RAL_MI].[DTL].[CURR_SF_ACCOUNTS] b on a.CUSTOMERNUMBER = b.Avus_Account_Number
left join Dash.DTL.CURR_SF_PRODUCT c on a.RATECARDPRICEUNITID=c.avus_rate_card_ID
left join Marketing_Sandbox.dbo.ref_FSA_HeatMapTerritories d on SUBSTRING(b.BillingPostalCode,1,3) = d.[Forward Sortation Area]


where a.ManualInv = 1 and a.CUSTOMERNUMBER is not NULL and fiscalyear*100+FISCALWEEK between 201901 and 201905
	and (CONCAT(c.Family,'-',c.Product_Type) not in ('A la Carte-Total Control Dominator','A la Carte-SetUp Fee','Add-on-Listing Upgrades','Setup Fee-SetUp Fee' )) 
	and CHARINDEX('fee', b.Name) = 0
	and InvoiceRowNetAmount >=0 

group by b.avus_account_number, b.Name, b.[OEM], b.DG_NonDG, b.Type2, b.BillingPostalCode , b.Package_Level ,fiscalyear, fiscalweek, fiscalyear*100+fiscalweek
	,d.Territory, b.Primary_URL_Provider, b.Product_Type, b.Franchise_Type, a.FiscalWeekID, c.Family, c.Summary_Product_Group,fiscalyear*100+fiscalmonth

order by Avus_Account_Number, year_wk

-- select top 100 * from #sales where year_wk = 201845and new_prd_flag = 1
-- select distinct family, summary_product_group, family_group, new_prd_flag from #sales 

---------------GROUPING AND PIVOTING SALES DATA TO CALCULATE DISCOUNTS

select Avus_Account_Number, Product_Type, year_mth, First_week_invoiced, Last_Week_invoiced, Number_Weeks_Active, Number_Weeks_Inactive, Name, [OEM], DG_NonDG, Type2, postalcode, Territory,
	Franchise_Type,Primary_URL_Provider, case when Primary_URL_Provider = 'Trader' then 1 else 0 end as binary_URL_provider, 
	sum(case when family in ('DSS Solution','Marketplace Only Solution','EasyLead')  then tot_sales else 0 end) as Used_Solution_sales,
	sum(case when family in ('DSS Solution','Marketplace Only Solution','EasyLead')  then listprice else 0 end) - sum(case when family in ('DSS Solution','Marketplace Only Solution','EasyLead')  then tot_sales else 0 end) as used_solution_discount,
	sum(case when family in ('NULL','Listing Upgrade','Mobile Boost') then tot_sales else 0 end) as used_upsell_sales,
	sum(case when family in ('NULL','Listing Upgrade','Mobile Boost') then listprice else 0 end) - sum(case when family in ('NULL','Listing Upgrade','Mobile Boost') then tot_sales else 0 end) as used_upsell_discount,
	sum(case when family in ('VelocIT','VT') then tot_sales else 0 end) as Velocit_sales,
	sum(case when family in ('TRFFK','UAX') then tot_sales else 0 end) as TRFFK_sales,
	sum(case when family_group in ( 'New Car_Listing (NC)','New Car_Subscriptions (NC)','New Car_Ad Impressions (NC)') then tot_sales else 0 end) as new_solution_sales,
	sum(case when family_group in ( 'New Car_Listing (NC)','New Car_Subscriptions (NC)','New Car_Ad Impressions (NC)') then listprice else 0 end) - sum(case when family_group in ( 'New Car_Listing (NC)','New Car_Subscriptions (NC)','New Car_Ad Impressions (NC)') then tot_sales else 0 end) as new_solution_discount,
	sum(case when family_group in ('Listing Upgrade_Priority Listing (NC)','Listing Upgrade_Accelerator (NC)','Listing Upgrade_PL+MB (NC)','Listing Upgrade_Swipe Pro (NC)','Capture Services_Listing (NC)') then tot_sales else 0 end) as new_upsell_sales,
	sum(case when family_group in ('Listing Upgrade_Priority Listing (NC)','Listing Upgrade_Accelerator (NC)','Listing Upgrade_PL+MB (NC)','Listing Upgrade_Swipe Pro (NC)','Capture Services_Listing (NC)') then listprice else 0 end) -
	sum(case when family_group in ('Listing Upgrade_Priority Listing (NC)','Listing Upgrade_Accelerator (NC)','Listing Upgrade_PL+MB (NC)','Listing Upgrade_Swipe Pro (NC)','Capture Services_Listing (NC)') then tot_sales else 0 end) as new_upsell_discount,
	sum(case when family not in ('DSS Solution','Marketplace Only Solution','EasyLead','NULL','Listing Upgrade','Mobile Boost','VelocIT','VT','TRFFK','UAX') AND 
					family_group not in ('New Car_Ad Impressions (NC)','New Car_Listing (NC)','New Car_Subscriptions (NC)','Listing Upgrade_Priority Listing (NC)','Listing Upgrade_Accelerator (NC)','Listing Upgrade_PL+MB (NC)','Listing Upgrade_Swipe Pro (NC)','Capture Services_Listing (NC)') then tot_sales else 0 end) as other_sales,
		sum(case when family not in ('DSS Solution','Marketplace Only Solution','EasyLead','NULL','Listing Upgrade','Mobile Boost','VelocIT','VT','TRFFK','UAX') AND 
					family_group not in ('New Car_Ad Impressions (NC)','New Car_Listing (NC)','New Car_Subscriptions (NC)','Listing Upgrade_Priority Listing (NC)','Listing Upgrade_Accelerator (NC)','Listing Upgrade_PL+MB (NC)','Listing Upgrade_Swipe Pro (NC)','Capture Services_Listing (NC)') then listprice else 0 end) - 
			sum(case when family not in ('DSS Solution','Marketplace Only Solution','EasyLead','NULL','Listing Upgrade','Mobile Boost','VelocIT','VT','TRFFK','UAX') AND 
					family_group not in ('New Car_Ad Impressions (NC)','New Car_Listing (NC)','New Car_Subscriptions (NC)','Listing Upgrade_Priority Listing (NC)','Listing Upgrade_Accelerator (NC)','Listing Upgrade_PL+MB (NC)','Listing Upgrade_Swipe Pro (NC)','Capture Services_Listing (NC)') then tot_sales else 0 end) as other_sales_discount
into #sales_grouped -- drop table #sales_grouped select * from #sales_grouped
from #sales s left join (select customernumber, min(S.WeekID) AS First_week_invoiced, max(S.WeekID) AS Last_Week_invoiced,
				count(distinct S.WeekID) -1 AS Number_Weeks_Active,  max(S.WeekID) - min(S.WeekID) - (count(distinct S.WeekID)-1) AS Number_Weeks_Inactive
				 from Dash.DPL.AVUS_INSERTION_DETAIL S 
				 group by customernumber) t on s.Avus_Account_Number = t.CustomerNumber

group by Avus_Account_Number, Product_Type, FISCALYEAR, First_week_invoiced, Last_Week_invoiced, Number_Weeks_Active, Number_Weeks_Inactive, Name, [OEM], DG_NonDG, Type2, postalcode, Territory,
	Franchise_Type,Primary_URL_Provider, year_mth

/*select year_mth, sum(Used_Solution_sales) as used_sales, sum(new_solution_sales) as new_sales
from #sales_grouped
group by year_mth8*/


-------------------------------BRINGING IN DEALER UPSELL PENETRATION LEVELS INFO
declare @startdate as date;
declare @enddate as date;
set @startdate = (select min(calendardate) from Marketing_Sandbox.dbo.FiscalCalendar where FiscalYear*100+FiscalWeek = 201901) 
set @enddate = (select max(calendardate) from Marketing_Sandbox.dbo.FiscalCalendar where FiscalYear*100+FiscalWeek = 201905)
--select @startdate
--select @enddate

------------------------------------------------------CREATING NEW DEALER LIST
 
select distinct CalendarDate, FiscalYear*100+FiscalWeek as year_wk, companyID, PPG_ID, CustomerNumber, avg(EnableNewCarListing*1.0) as enablenewcarlisting
 --drop table #enablenewcar -- select * from #enablenewcar
into #enablenewcar
from [RAL_MI].dbo.[DIM_COMPANY_ADDITIONAL] a join [marketing_sandbox].[dbo].[FISCALCALENDAR]  b 
on 	(calendarDate between @startdate and  @enddate)	   and  
 calendarDate >= cast(a.RecordLifeStart as date) and calendarDate <= isnull(cast(a.RecordLifeEnd as date),'September 1,2099')  
 where isnull(CustomerNumber,' ')  != ' ' --and CustomerNumber = '09783417'
 group by CalendarDate, FiscalYear*100+FiscalWeek , companyID, PPG_ID, CustomerNumber
--create clustered index ind_nc on 	#enablenewcar(CalendarDate, companyID)  
--select year_wk, count(*) as rowss from #enablenewcar group by year_wk order by year_wk = 201845

-----------------------------------BRINING ADS
 --select max(year_wk) as year_wk from Marketing_Sandbox.dbo.ads_mp_upsells

select  a.COMPANY_ID, a.ad_id,cast(a.ONLINE_DATE as date) as online_date, c.vehicle_cond, convert(bigint,VEHICLE_ODOMETER) as vehicle_odomoter, b.fiscalyear, b.fiscalweek, b.FiscalYear*100+b.FiscalWeek as year_wk, avg(e.EnableNewCarListing*1.0) as EnableNewCarListing,
		avg(a.UPSELL_COUNT) as upsell_count, 
		avg(a.UPSELL_FL*1.0) as upsell_fl,
		avg(a.upsell_pl*1.0) as avg_pl,
		avg(upsell_ppl*1.0) as avg_ppl,
		avg(UPSELL_LESPAC_PL*1.0) as avg_lespac_pl,
		avg(UPSELL_MB*1.0) as avg_mb,
		avg(UPSELL_SWIPEPRO*1.0) as avg_swppro,
		avg(UPSELL_TOPAD*1.0) as avg_topad,
		avg(UPSELL_MHL*1.0) as avg_mhl,
		avg(a.price) as avg_price,
		--count(a.ONLINE_DATE) as days_online, 
		avg(a.PHOTO_COUNT) as avg_photos 
 --drop table #fact_ad -- select * from #fact_ad where company_id = '22815' order by ad_id, online_date , year_wk
into #fact_ad

 from RAL_MI.dbo.FACT_AD_BY_DAY a join Marketing_Sandbox.dbo.FiscalCalendar b on cast(a.ONLINE_DATE as date)  = cast(b.CalendarDate as date) 
 join (select * from ral_mi.dbo.dim_ads where [START_DATE] >= 2017-01-01) c on a.AD_ID=c.AD_ID and a.COMPANY_ID=c.COMPANY_ID
 left join #enablenewcar e on a.COMPANY_ID=e.CompanyID and a.ONLINE_DATE=e.CalendarDate
 
 where (a.auto_trader = 1 or a.AUTO_HEBDO = 1) and a.is_online = 1 and is_private =0 and a.company_id is not null and a.company_id >0 and a.ONLINE_DATE between @startdate and @enddate
 group by a.COMPANY_ID, a.ad_id, b.fiscalyear, b.fiscalweek, b.FiscalYear*100+b.FiscalWeek, a.COMPANY_ID, a.ONLINE_DATE,c.vehicle_cond, VEHICLE_ODOMETER

 
-----------------------------------Aggregate daily ad data to Weekly
select  d.AdTackingID,  a.online_date, a.fiscalweek,  a.fiscalyear, a.year_wk, a.FiscalYear*100+month(a.online_date) as year_mth, a.vehicle_cond, a.EnableNewCarListing, count(distinct a.ad_id) as total_ads   
		,avg(a.avg_price) as avg_price
		,avg(case when a.VEHICLE_COND = 'Used' then avg_price else NULL end) used_avg_price
		,avg(case when a.VEHICLE_COND = 'New' then avg_price else NULL end) new_avg_price
		--,COUNT(distinct a.ONLINE_DATE) as days_online
		,avg(a.avg_photos) as avg_photos
		,avg(case when a.VEHICLE_COND = 'Used' then avg_photos else NULL end) used_avg_photos
		,avg(case when a.VEHICLE_COND = 'New' then avg_photos else NULL end) new_avg_photos
		--,avg(a.custom_photo_count) as avg_cust_photos
		,avg(convert(bigint,a.vehicle_odomoter)) as avg_odometer
		,avg(case when a.VEHICLE_COND = 'Used' then convert(bigint,a.vehicle_odomoter) else NUll end) as used_avg_odometer
		,avg(case when a.VEHICLE_COND = 'New' then convert(bigint,a.vehicle_odomoter) else NUll end) as new_avg_odometer
		,avg(a.UPSELL_COUNT) as avg_upsells
		,avg(case when a.VEHICLE_COND = 'Used' then a.UPSELL_COUNT else NUll end) as used_avg_upsells
		,avg(case when a.VEHICLE_COND = 'New' then a.UPSELL_COUNT else NUll end) as new_avg_upsells
		,count(distinct (case when a.avg_ppl*1.0 > 0 and a.vehicle_cond = 'Used' then AD_ID else NULL end)) as used_avg_ppls
		,count(distinct (case when a.avg_ppl*1.0 > 0 and (a.vehicle_cond = 'New' and a.enablenewcarlisting = 1) then a.AD_ID else NULL end)) as new_avg_ppls
		,count( distinct (case when a.avg_pl*1.0 > 0 and a.VEHICLE_COND = 'Used' then a.AD_ID else NULL end))  as used_avg_pls
		,count( distinct (case when a.avg_pl*1.0 > 0 and (a.VEHICLE_COND = 'New' and a.enablenewcarlisting = 1) then a.AD_ID else NULL end))  as new_avg_pls
		,count( distinct (case when a.upsell_fl*1.0 > 0 and a.VEHICLE_COND = 'Used' then a.AD_ID else NULL end))  as used_avg_fls
		,count( distinct (case when a.upsell_fl*1.0 > 0 and (a.VEHICLE_COND = 'New' and a.enablenewcarlisting = 1)then a.AD_ID else NULL end) ) as new_avg_fls
		,count( distinct (case when a.avg_mb*1.0 > 0 and a.vehicle_cond = 'Used' then a.AD_ID else NULL end))  as used_avg_mb
		,count( distinct (case when a.avg_mb*1.0 > 0 and (a.vehicle_cond = 'New' and a.enablenewcarlisting = 1) then a.AD_ID else NULL end))  as new_avg_mb
		,count( distinct (case when a.avg_topad*1.0 > 0 and a.VEHICLE_COND = 'Used' then a.AD_ID else NULL end))  as used_avg_topads
		,count( distinct (case when a.avg_topad*1.0 > 0 and (a.VEHICLE_COND = 'New' and a.enablenewcarlisting = 1) then a.AD_ID else NULL end))  as new_avg_topads
		,count( distinct (case when a.avg_mhl*1.0 > 0 and a.VEHICLE_COND = 'Used' then a.AD_ID else NULL end))  as used_avg_mhl
		,count( distinct (case when a.avg_mhl*1.0 > 0 and (a.VEHICLE_COND = 'New' and a.enablenewcarlisting = 1) then a.AD_ID else NULL end))  as new_avg_mhl
		,count( distinct (case when a.avg_swppro * 1.0 > 0 and a.VEHICLE_COND = 'Used' then a.AD_ID else NULL end)) as used_avg_swppro
		,count( distinct (case when a.avg_swppro * 1.0 > 0 and (a.VEHICLE_COND = 'New' and a.enablenewcarlisting = 1) then a.AD_ID else NULL end)) as new_avg_swppro
		--,count( distinct case when a.UPSELL_SA*1.0 > 0 then 1 else 0 end)  as avg_sa
		--,count( distinct case when a.UPSELL_PHL*1.0 > 0 then 1 else 0 end)  as avg_phl		
		--,count( distinct case when a.avg_HL*1.0 > 0 then 1 else 0 end)  as avg_hls
		--,count( distinct case when a.UPSELL_GL*1.0 > 0 then 1 else 0 end)  as avg_gls
		--,count( distinct case when a.UPSELL_VU*1.0 > 0 then 1 else 0 end)  as avg_vu		
		--,count( distinct case when a.UPSELL_MPV*1.0 > 0 then 1 else 0 end)  as avg_mpvs
		--,count( distinct case when a.UPSELL_VS*1.0 > 0 then 1 else 0 end)  as avg_vs
		--,count( distinct case when a.UPSELL_ST*1.0 > 0 then 1 else 0 end)  as avg_st
		--,count(distinct case when ((a.UPSELL_PPL*1.0)*(a.UPSELL_TOPAD*1.0) > 0) then 1 else 0 end) as avg_eus
		--,max(a.online_date) as week_end_date
	
	into  #fact_by_week -- drop table #fact_by_week
	from #fact_ad as a
	--left join RAL_MI.dbo.dim_ads c on a.AD_ID=c.AD_ID and a.COMPANY_ID = c.COMPANY_ID
	left join RAL_MI.dbo.CURRENT_ONL_COMPANY d on a.COMPANY_ID=d.CompanyID
	 
	where AdTackingID is not null 
	group by   a.online_date ,fiscalyear,  fiscalweek, a.year_wk, AdTackingID,  a.vehicle_cond, a.EnableNewCarListing,a.FiscalYear*100+month(a.online_date)

	--select * from #fact_by_week where year_wk = 201844 and AdTackingID = '04072568'
	--select * from Marketing_Sandbox.dbo.ads_mp_upsells where adtacking = '04072568' and year_wk = 201844
	--, a.is_online, a.auto_trader, c.SEARCHYEAR, c.MAKE, c.MODEL, c.PV_NPV, c.VEHICLE_COND, c.VEHICLE_ODOMETER, a.ad_id,

	-- select   * from #fact_by_week where company_id  = '22815'


/*create table marketing_sandbox.dbo.ads_mp_upsells (
adtacking varchar(30),
fiscalweek int,
fiscalyear int,
year_wk int,
used_ads int,
new_ads int,
avg_price  decimal(10,0)
,used_avg_price decimal(10,0)
,new_avg_price decimal(10,0)
,avg_photos int
,used_avg_photos int
,new_avg_photos int
,avg_odometer int
,used_avg_odometer int
,new_avg_odometer int
,avg_upsells int
,used_avg_upsells int
,new_avg_upsells int
,used_avg_ppls  int
,new_avg_ppls int
,used_avg_pls int
,new_avg_pls int
,used_avg_fls int
,new_avg_fls int
,used_avg_mb int
,new_avg_mb int
,used_avg_topads int
,new_avg_topads int
,used_avg_mhl int
,new_avg_mhl int
,used_avg_swppro int
,new_avg_swppro int
);
 insert into Marketing_Sandbox.dbo.ads_mp_upsells*/
 --select max(year_wk) from Marketing_Sandbox.dbo.ads_mp_upsells
--delete from Marketing_Sandbox.dbo.ads_mp_upsells where year_wk = 201901
insert into  Marketing_Sandbox.dbo.ads_mp_upsells
select  AdTackingID,  a.fiscalweek,  a.fiscalyear, a.year_wk--, c.FiscalYear*100+c.FiscalMonth as year_mth
		,avg( case when vehicle_cond = 'Used' then total_ads else NULL end) as used_ads   
		,avg( case when vehicle_cond = 'New' then total_ads else NULL end) as new_ads   
		,avg(a.avg_price) as avg_price
		,avg(used_avg_price) as used_avg_price
		,avg(new_avg_price) as new_avg_price
		--,COUNT(distinct a.ONLINE_DATE) as days_online
		,avg(a.avg_photos) as avg_photos
		,avg(used_avg_photos) as used_avg_photos
		,avg(new_avg_photos) as new_avg_photos
		--,avg(a.custom_photo_count) as avg_cust_photos
		,avg(a.avg_odometer) as avg_odometer
		,avg(a.used_avg_odometer) as used_avg_odometer
		,avg(a.new_avg_odometer) as new_avg_odometer
		,avg(a.avg_upsells) as avg_upsells
		,avg(used_avg_upsells) as used_avg_upsells
		,avg(new_avg_upsells) as new_avg_upsells
		,avg(case when used_avg_ppls > 0 then used_avg_ppls else NULL end) as used_avg_ppls 
		,avg(case when new_avg_ppls > 0 then new_avg_ppls else NULL end) as new_avg_ppls
		,avg(case when used_avg_pls > 0 then used_avg_pls else NULL end)   as used_avg_pls
		,avg( case when new_avg_pls > 0 then new_avg_pls else NULL end)  as new_avg_pls
		,avg(case when used_avg_fls > 0 then used_avg_fls else NULL end)  as used_avg_fls
		,avg(case when new_avg_fls > 0 then new_avg_fls else NULL end)  as new_avg_fls
		,avg( case when used_avg_mb > 0 then used_avg_mb else NULL end) as used_avg_mb
		,avg(case when new_avg_mb > 0 then new_avg_mb else NULL end)  as new_avg_mb
		,avg(case when used_avg_topads > 0 then used_avg_topads else NULL end) as used_avg_topads
		,avg(case when new_avg_topads > 0 then new_avg_topads else NULL end) as new_avg_topads
		,avg(case when used_avg_mhl > 0 then used_avg_mhl else NULL end)  as used_avg_mhl
		,avg(case when new_avg_mhl > 0 then new_avg_mhl else NULL end) as new_avg_mhl
		,avg(case when used_avg_swppro > 0  then used_avg_swppro else NULL end) as used_avg_swppro
		,avg(case when  new_avg_swppro > 0 then new_avg_swppro else NULL end) as new_avg_swppro
		--,count( distinct case when a.UPSELL_SA*1.0 > 0 then 1 else 0 end)  as avg_sa
		--,count( distinct case when a.UPSELL_PHL*1.0 > 0 then 1 else 0 end)  as avg_phl		
		--,count( distinct case when a.avg_HL*1.0 > 0 then 1 else 0 end)  as avg_hls
		--,count( distinct case when a.UPSELL_GL*1.0 > 0 then 1 else 0 end)  as avg_gls
		--,count( distinct case when a.UPSELL_VU*1.0 > 0 then 1 else 0 end)  as avg_vu		
		--,count( distinct case when a.UPSELL_MPV*1.0 > 0 then 1 else 0 end)  as avg_mpvs
		--,count( distinct case when a.UPSELL_VS*1.0 > 0 then 1 else 0 end)  as avg_vs
		--,count( distinct case when a.UPSELL_ST*1.0 > 0 then 1 else 0 end)  as avg_st
		--,count(distinct case when ((a.UPSELL_PPL*1.0)*(a.UPSELL_TOPAD*1.0) > 0) then 1 else 0 end) as avg_eus
		--,max(a.online_date) as week_end_date
	
	 -- drop table #fact_by_week_check
	from #fact_by_week as a left join Marketing_Sandbox.dbo.FiscalCalendar c on a.year_wk=c.FiscalYear*100+c.FiscalWeek
		 
	where isnull(AdTackingID,' ')  != ' ' 
	group by  AdTackingID, a.fiscalyear,  a.fiscalweek, a.year_wk--, c.FiscalYear*100+c.FiscalMonth
-- delete * from 
---------ADDING THE MONTH
select  a.adtacking, a.fiscalyear, c.FiscalYear*100+c.FiscalMonth as year_mth
		,avg( used_ads) as used_ads   
		,avg( new_ads) as new_ads   
		,avg(a.avg_price) as avg_price
		,avg(used_avg_price) as used_avg_price
		,avg(new_avg_price) as new_avg_price
		--,COUNT(distinct a.ONLINE_DATE) as days_online
		,avg(a.avg_photos) as avg_photos
		,avg(used_avg_photos) as used_avg_photos
		,avg(new_avg_photos) as new_avg_photos
		--,avg(a.custom_photo_count) as avg_cust_photos
		,avg(a.avg_odometer) as avg_odometer
		,avg(a.used_avg_odometer) as used_avg_odometer
		,avg(a.new_avg_odometer) as new_avg_odometer
		,avg(a.avg_upsells) as avg_upsells
		,avg(used_avg_upsells) as used_avg_upsells
		,avg(new_avg_upsells) as new_avg_upsells
		,avg(used_avg_ppls) as used_avg_ppls 
		,avg(new_avg_ppls) as new_avg_ppls
		,avg(used_avg_pls)   as used_avg_pls
		,avg(new_avg_pls)  as new_avg_pls
		,avg(used_avg_fls)  as used_avg_fls
		,avg(new_avg_fls)  as new_avg_fls
		,avg(used_avg_mb) as used_avg_mb
		,avg(new_avg_mb)  as new_avg_mb
		,avg(used_avg_topads) as used_avg_topads
		,avg(  new_avg_topads) as new_avg_topads
		,avg(used_avg_mhl)  as used_avg_mhl
		,avg(  new_avg_mhl) as new_avg_mhl
		,avg(used_avg_swppro) as used_avg_swppro
		,avg( new_avg_swppro) as new_avg_swppro
		--,count( distinct case when a.UPSELL_SA*1.0 > 0 then 1 else 0 end)  as avg_sa
		--,count( distinct case when a.UPSELL_PHL*1.0 > 0 then 1 else 0 end)  as avg_phl		
		--,count( distinct case when a.avg_HL*1.0 > 0 then 1 else 0 end)  as avg_hls
		--,count( distinct case when a.UPSELL_GL*1.0 > 0 then 1 else 0 end)  as avg_gls
		--,count( distinct case when a.UPSELL_VU*1.0 > 0 then 1 else 0 end)  as avg_vu		
		--,count( distinct case when a.UPSELL_MPV*1.0 > 0 then 1 else 0 end)  as avg_mpvs
		--,count( distinct case when a.UPSELL_VS*1.0 > 0 then 1 else 0 end)  as avg_vs
		--,count( distinct case when a.UPSELL_ST*1.0 > 0 then 1 else 0 end)  as avg_st
		--,count(distinct case when ((a.UPSELL_PPL*1.0)*(a.UPSELL_TOPAD*1.0) > 0) then 1 else 0 end) as avg_eus
		--,max(a.online_date) as week_end_date
	into #ad_grouped
	 -- drop table #ad_grouped select * from #ad_grouped
	from Marketing_Sandbox.dbo.ads_mp_upsells as a left join Marketing_Sandbox.dbo.FiscalCalendar c on a.year_wk=c.FiscalYear*100+c.FiscalWeek
		 
	where isnull(a.adtacking,' ')  != ' ' 
	group by  a.adtacking,a.fiscalyear,  c.FiscalYear*100+c.FiscalMonth

	
---------------CALCULATE THE PENETRATION LEVELS FROM THE 2 TABLES ABOVE

select *, cast(used_avg_ppls as float)/nullif(cast(used_ads as float),0)  as used_ppl_pen
		,cast(new_avg_ppls as float)/nullif(cast(new_ads as float) ,0) as new_ppl_pen
		, cast(used_avg_pls as float)/nullif( cast(used_ads as float),0) as used_pl_pen
		, cast(new_avg_pls as float)/nullif(cast(new_ads as float),0)  as new_pl_pen
		,cast(used_avg_fls as float)/nullif(cast(used_ads as float),0)  as used_fl_pen
		,cast(new_avg_fls as float)/nullif(cast(new_ads as float),0)  as new_fl_pen
		,cast(used_avg_mb as float)/nullif(cast(used_ads as float) ,0)  as used_mb_pen
		,cast(new_avg_mb as float)/nullif(cast(new_ads as float),0)as new_mb_pen
		,cast (used_avg_topads as float)/nullif(cast(used_ads as float),0) as used_topad_pen
		,cast(new_avg_topads as float)/nullif(cast(new_ads as float),0) as new_topad_pen
		, cast(used_avg_mhl as float)/nullif(cast(used_ads as float),0) as used_mhl_pen
		, cast(new_avg_mhl as float)/nullif(cast(new_ads as float),0) as new_mhl_pen
		,cast (used_avg_swppro as float)/nullif(cast(used_ads as float) ,0)as used_swppro_pen
		,cast (new_avg_swppro as float)/nullif(cast(new_ads as float),0) as new_swppro_pen

into #upsell_pen -- drop table #upsell_pen select top 100 * from #upsell_pen where adtacking = '09897352' order by year_mth
from #ad_grouped


--------------------------------------BRING IN DEALER INVENTORY AND PERFORMANCE METRICS

select AVUS_CUSTOMER_NUMBER, FISCAL_YEAR, FISCAL_MONTH_NUM, FISCAL_YEAR*100+FISCAL_MONTH_NUM as year_mth, 

--inventory
	avg(D_AVG_INV_PV_USED) as avg_inv_pv_used,
	avg(D_AVG_INV_PV_NEW) as avg_inv_pv_new,
	avg(D_AVG_QUA_INV_USED) as avg_inv_pv_qua_used,
	avg(D_AVG_QUA_INV_PV_NEW) as avg_inv_pv_qua_new,
	avg(D_AVG_INV_NPV_USED) as avg_inv_npv_used,
	avg(D_AVG_INV_NPV_NEW) as avg_inv_npv_new,

--total vdps
	sum(WEEKLY_DV_PV_NEW_WEB) as tot_pv_new_VDPs,
	sum(WEEKLY_DV_PV_USED_WEB) as tot_pv_used_VDPs,
	sum(WEEKLY_DV_NPV_NEW_WEB) 	as tot_npv_new_VDPs,
	sum(WEEKLY_DV_NPV_USED_WEB) as tot_npv_used_VDPs,
--mobile vps
	sum(WEEKLY_DV_PV_NEW_MOB) as mob_pv_new_VDPs,
	sum(WEEKLY_DV_PV_USED_MOB) as mob_pv_used_VDPs,
	sum(WEEKLY_DV_NPV_NEW_MOB) 	as mob_npv_new_VDPs,
	sum(WEEKLY_DV_NPV_USED_MOB) as mob_npv_used_VDPs,
--desktop vdps
	sum(WEEKLY_DV_PV_NEW_WEB) - sum(WEEKLY_DV_PV_NEW_MOB) as dt_pv_new_VDPs,
	sum(WEEKLY_DV_PV_USED_WEB) - sum(WEEKLY_DV_PV_USED_MOB) as dt_pv_used_VDPs,
	sum(WEEKLY_DV_NPV_NEW_WEB) - sum(WEEKLY_DV_NPV_NEW_MOB) as dt_npv_new_VDPs,
	sum(WEEKLY_DV_NPV_USED_WEB) - sum(WEEKLY_DV_NPV_USED_MOB) as dt_npv_used_VDPs,
--email leads
	sum(WEEKLY_EMAIL_PV_NEW_WEB) + sum(WEEKLY_EMAIL_PV_NEW_MOB) as tot_pv_new_email_leads,
	sum(WEEKLY_EMAIL_PV_USED_WEB) + sum(WEEKLY_EMAIL_PV_USED_MOB) as tot_pv_used_email_leads,
	sum(WEEKLY_EMAIL_NPV_NEW_WEB)  +sum(WEEKLY_EMAIL_NPV_NEW_MOB) as tot_npv_new_email_leads,
	sum(WEEKLY_EMAIL_NPV_USED_WEB) + sum(WEEKLY_EMAIL_NPV_USED_MOB) as tot_npv_used_email_leads,
--phone leads
	sum(WEEKLY_PHONE_NEW_WEB) + sum(WEEKLY_PHONE_NEW_MOB) as tot_new_phone_leads,
	sum(WEEKLY_PHONE_USED_WEB) + sum(WEEKLY_PHONE_USED_MOB) as tot_used_phone_leads,
----text leads
	sum(WEEKLY_TEXT_PV_NEW_MOB) as text_pv_new,
	sum(WEEKLY_TEXT_PV_USED_MOB) as text_pv_used,
	sum(WEEKLY_TEXT_NPV_NEW_MOB) as text_npv_new,
	sum(WEEKLY_TEXT_NPV_USED_MOB) as text_npv_used

into #perf_metrics -- drop table #perf_metrics select * from #perf_metrics where avus_customer_number = '07418646' and year_mth = 201812
from RAL_MI.DPL.DEMVAL_RPT_ONLINE_STAT_PPGID_WEEKLY

where FISCAL_YEAR*100+FISCAL_WEEK_NUM between 201901 and 201905 and ISNULL(AVUS_CUSTOMER_NUMBER, ' ') != ' '
group by AVUS_CUSTOMER_NUMBER, FISCAL_YEAR,  FISCAL_MONTH_NUM ,FISCAL_YEAR*100+FISCAL_MONTH_NUM

-------------------------------BRINGING IN WEEKLY REVENUE

/*select CUSTOMER_NUMBER, FISCAL_YEAR, FISCAL_WEEK_NUM, FISCAL_YEAR*100+FISCAL_MONTH_NUM as year_week, ENTRY_LEVEL_PRODUCT, 
	sum(Total_DSS_Revenue)+sum(EasyLead_Revenue) as MP_revenue, 
	sum(Upsell_revenue) as upsell_revenue,
	sum(Weekly_VelociT_Revenue) as wkly_velocit_revenue
 
 --into #wkly_revenue	
 from marketing_sandbox.dbo.RPT_CUSTOMER_DATA_WEEKLY

 where FISCAL_YEAR*100+FISCAL_MONTH_NUM = 201810 and isnull(customer_number , ' ') != ' ' and CUSTOMER_NUMBER = '00706744'

 group by CUSTOMER_NUMBER, FISCAL_YEAR, FISCAL_WEEK_NUM, FISCAL_YEAR*100+FISCAL_WEEK_NUM, ENTRY_LEVEL_PRODUCT
 */

 -------------------------SALESFORCE EVENTS

/* THIS IS THE TABLE THAT USED TO EXIST NOT IT DOES NOT
	select top 100 * from RAL_MI.DTL.DIM_SF_EVENT */

------------------COMBINING ALL TABLES TO CREATE A SINGLE VIEW OF DEALERS FOR CHURN MODEL
/*
create table marketing_sandbox.dbo.churn_model_data ( -- drop table marketing_sandbox.dbo.churn_model_data
Avus_Account_Number varchar(30),
binary_URL_provider int,
DG_NonDG varchar(20),
Franchise_Type varchar(30),
Name varchar(300),
[OEM] varchar(50),
Product_Type varchar (10),
Territory varchar(200),
Type2 varchar(20),
year_mth bigint,

--SALES INFO
new_sln_sales decimal(10,2),
new_sln_discount decimal(10,2), 
new_upsell_sales decimal(10,2), 
new_upsell_discount decimal(10,2), 
used_sln_sales decimal(10,2), 
used_sln_discount decimal(10,2),
used_upsell_sales decimal(10,2),
used_upsell_discount decimal(10,2),
velocit_sales decimal(10,2),
TRFFK_sales decimal(10,2),
other_sales decimal(10,2),
other_sales_discount decimal(10,2),
number_weeks_inactive int,
number_weeks_active int,
first_week_invoiced int,
last_week_invoiced int,
--INV & UPSELL PENETRATION INFO
used_ads int,
new_ads int,
used_avg_price decimal(10,2),
new_avg_price decimal(10,2),
used_avg_odometer int,
new_avg_odometer int,
used_avg_photos int,
new_avg_photos int,
 used_avg_upsells int,
 new_avg_upsells int,
used_ppl_pen float,
 new_ppl_pen float,
 used_pl_pen float,
 new_pl_pen float,
 used_mb_pen float,
new_mb_pen float,
used_topad_pen float,
 new_topad_pen float,
 used_fl_pen float,
new_fl_pen float,
 used_mhl_pen float,
new_mhl_pen float,
 used_swppro_pen float,
new_swppro_pen float,
---PERFORMANCE METRICS
 tot_pv_new_VDPs int,
 tot_pv_used_VDPs int,
 dt_pv_new_VDPs int,
 dt_pv_used_VDPs int,
 mob_pv_new_VDPs int,
 mob_pv_used_VDPs int, 
 tot_npv_new_VDPs int,
 tot_npv_used_VDPs int,
dt_npv_new_VDPs int,
 dt_npv_used_VDPs int,
 mob_npv_new_VDPs int,
 mob_npv_used_VDPs int,
 tot_pv_new_email_leads int, 
 tot_pv_used_email_leads int,
tot_npv_new_email_leads int,
tot_npv_used_email_leads int,
tot_new_phone_leads int, 
 tot_used_phone_leads int, 
text_pv_new int,
 text_pv_used int,
 text_npv_new int,
 text_npv_used  int
);
*/
--delete  from marketing_sandbox.dbo.churn_model_data where year_mth in (201901,201902)
SET ansi_warnings OFF --select top 10 * from marketing_sandbox.dbo.churn_model_data
insert into marketing_sandbox.dbo.churn_model_data --select year_mth, count(avus_account_number), sum(new_sln_sales) as new_sales, sum(used_sln_sales) as used_sales from  marketing_sandbox.dbo.churn_model_data  group by year_mth
select s.Avus_Account_Number, s.binary_URL_provider, s.DG_NonDG, s.Franchise_Type, s.Name, s.[OEM], s.Product_Type, s.Territory, s.Type2, s.year_mth, 
--SALES INFO
		sum(s.new_solution_sales) as new_sln_sales,
		sum(s.new_solution_discount) as new_sln_discount, 
		sum(s.new_upsell_sales) as new_upsell_sales, 
		sum(s.new_upsell_discount) as new_upsell_discount, 
		sum(s.Used_Solution_sales) as used_sln_sales, 
		sum(s.used_solution_discount) as used_sln_discount,
		sum(s.used_upsell_sales) as used_upsell_sales,
		sum(s.used_upsell_discount) as used_upsell_discount,
		sum(s.Velocit_sales) as velocit_sales,
		sum(s.TRFFK_sales) as TRFFK_sales,
		sum(s.other_sales) as other_sales,
		sum(s.other_sales_discount) as other_sales_discount,
		min(s.number_weeks_inactive) as number_weeks_inactive,
		max(s.number_weeks_active) as number_weeks_active,
		min(s.first_week_invoiced) as first_week_invoiced,
		max(s.last_Week_invoiced) as last_week_invoiced,
--INV & UPSELL PENETRATION INFO
		avg(p.avg_inv_npv_new) as new_npv_ads,
		avg(p.avg_inv_npv_used) as used_npv_ads,
		avg(p.avg_inv_pv_used) as used_pv_ads,
		avg(p.avg_inv_pv_qua_used) as used_pv_qua_ads,
		avg(p.avg_inv_pv_new) as new_pv_ads,
		avg(p.avg_inv_pv_qua_new) as new_pv_qua_ads,
		avg(used_avg_price) as used_avg_price,
		avg(new_avg_price) as new_avg_price,
		avg(used_avg_odometer) as used_avg_odometer,
		avg(new_avg_odometer) as new_avg_odometer,
		avg(used_avg_photos) as used_avg_photos,
		avg(new_avg_photos) as new_avg_photos,
		avg(used_avg_upsells) as used_avg_upsells,
		avg(new_avg_upsells) as new_avg_upsells,
		avg(used_ppl_pen) as used_ppl_pen,
		avg(new_ppl_pen) as new_ppl_pen,
		avg(used_pl_pen) as used_pl_pen,
		avg(new_pl_pen) as new_pl_pen,
		avg(used_mb_pen) as used_mb_pen,
		avg(new_mb_pen) as new_mb_pen,
		avg(used_topad_pen) as used_topad_pen,
		avg(new_topad_pen) as new_topad_pen,
		avg(used_fl_pen) as used_fl_pen,
		avg(new_fl_pen) as new_fl_pen,
		avg(used_mhl_pen) as used_mhl_pen,
		avg(new_mhl_pen) as new_mhl_pen,
		avg(used_swppro_pen) as used_swppro_pen,
		avg(new_swppro_pen) as new_swppro_pen,
---PERFORMANCE METRICS
		sum(p.tot_pv_new_VDPs) as tot_pv_new_VDPs,
		sum(p.tot_pv_used_VDPs) as tot_pv_used_VDPs,
		sum(p.dt_pv_new_VDPs) as dt_pv_new_VDPs,
		sum(p.dt_pv_used_VDPs) as dt_pv_used_VDPs,
		sum(p.mob_pv_new_VDPs) as mob_pv_new_VDPs,
		sum(p.mob_pv_used_VDPs) as mob_pv_used_VDPs, 
		sum(p.tot_npv_new_VDPs) as tot_npv_new_VDPs,
		sum(p.tot_npv_used_VDPs) as tot_npv_used_VDPs,
		sum(p.dt_npv_new_VDPs) as dt_npv_new_VDPs,
		sum(p.dt_npv_used_VDPs) as dt_npv_used_VDPs,
		sum(p.mob_npv_new_VDPs) as mob_npv_new_VDPs ,
		sum(p.mob_npv_used_VDPs) as mob_npv_used_VDPs,
		sum(p.tot_pv_new_email_leads) as tot_pv_new_email_leads, 
		sum(p.tot_pv_used_email_leads) as tot_pv_used_email_leads,
		sum(p.tot_npv_new_email_leads) as tot_npv_new_email_leads,
		sum(p.tot_npv_used_email_leads) as tot_npv_used_email_leads,
		sum(p.tot_new_phone_leads) as tot_new_phone_leads,
		sum(p.tot_used_phone_leads) as tot_used_phone_leads, 
		sum(p.text_pv_new) as text_pv_new,
		sum(p.text_pv_used) as text_pv_used ,
		sum(p.text_npv_new) as text_npv_new,
		sum(p.text_npv_used) as text_npv_used 

from #sales_grouped s 
left join #upsell_pen u on s.Avus_Account_Number=u.adtacking and s.year_mth=u.year_mth
left  join #perf_metrics p on s.Avus_Account_Number=p.AVUS_CUSTOMER_NUMBER and s.year_mth=p.year_mth

group by s.Avus_Account_Number, s.binary_URL_provider, s.DG_NonDG, s.Franchise_Type, s.Name, s.[OEM], s.Product_Type, s.Territory, s.Type2, s.year_mth

order by s.Avus_Account_Number, s.year_mth

--delete 
--select year_mth, count(avus_account_number), sum(new_sln_sales) as new_sales, sum(used_sln_sales) as used_sales from  marketing_sandbox.dbo.churn_model_data  group by year_mth
--select * from #perf_metrics where avus_customer_number = '07426363' and year_mth = 201812
--select * from marketing_sandbox.dbo.churn_model_data where Avus_Account_Number = '07426363' and year_mth = 201812
-- select * from Marketing_Sandbox.dbo.ads_mp_upsells where adtacking = '07418646' and year_wk = 201852

--select top 10 * from marketing_sandbox.dbo.churn_model_data where Avus_Account_Number= '07418646' and year_mth = 201812
-- alter table marketing_sandbox.dbo.churn_model_data drop column used_qua_ads, new_qua_ads, used_ads, new_ads


-- alter table marketing_sandbox.dbo.churn_model_data add used_pv_ads int, used_pv_qua_ads int, new_pv_ads int, new_pv_qua_ads int, new_npv_ads int, used_npv_ads int
 
-- select top 10 * from #perf_metrics
--update  a
--set a.used_pv_ads=b.avg_inv_pv_used, 
--	a.used_pv_qua_ads=b.avg_inv_pv_qua_used,
--	a.new_pv_ads=b.avg_inv_pv_new,
--	a.new_pv_qua_ads=b.avg_inv_pv_qua_new,
--	a.new_npv_ads=b.avg_inv_npv_new,
--	a.used_npv_ads=b.avg_inv_npv_used
--from marketing_sandbox.dbo.churn_model_data a

--left join #perf_metrics b on a.Avus_Account_Number=b.AVUS_CUSTOMER_NUMBER and a.year_mth=b.year_mth