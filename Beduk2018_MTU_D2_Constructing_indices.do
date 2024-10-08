/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Beduk, S. (2018). Missing the unhealthy? Examining empirical validity of material deprivation indices (MDIs) using a partial criterion variable. Social indicators research, 135(1), 91-115.

Author: Selçuk Bedük 

Date of code: 03 February 2018

Purpose: Constructing deprivation measures 

Inputs: SILC09_R_P_H.dta (from D1_Data_management, using EU SILC 2009; household, register and individual core modules including deprivation module)

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.
See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview
See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896
See for data availability table: https://ec.europa.eu/eurostat/documents/203647/771732/Datasets-availability-table.pdf 

Outputs: EUSILC2009_Paper4_RPH.dta 
*/


clear all
set more off
capture log close
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"

use SILC09_R_P_H.dta

// Constructing the new multidimensional measure of poverty 

global foodpov cMDmeat chfruit chthmeals 
global shelter MDwarm MDbtw MDevict
global clothing cMDcloth cMDshoes 
global basic $foodpov $shelter $clothing 
global social cMDg_out MDsmoney cMDleisure chceleb
global education chbook chgamesio chtrips chworkspace MDpc_net
global health cMDunmet cMDdentist


// Missing data 

misstable summarize ch* MD* burhc
tabstat ch* MD* burhc, stats(mean sd min max) columns(stat)
gen depmiss=( MDmeat==. | chfruit==. | chthmeals==. | MDwarm==. | MDbtw==. |  MDcloth==. | chceleb==. ///
	| MDshoes==. | chbook==. | chgamesio==. | chtrips==. | chworkspace==. | MDPC==. | MDnet==.  | MDg_out==. ///
	| MDsmoney==. | MDleisure==. | MDunmet==. | MDdentist==. | MDarrears==. | MDroof==. | MDspace==. ///
	| MDholiday==. | MDun_exp==. | MDcar==. | MDrefurnish==. | MDevict==. | burhc==. )
tab depmiss
tab country depmiss

gen valmiss=(poor60==. | jobless==. | finstrain==.) 

misstable summarize esec isced hhunemployed tenant hhdisabled hhchronic hhhealth ch02 ch34 ch511 ch1215 singlepar extendedfam divsep female if HRP==1
egen modmiss=rowmiss(esec isced hhunemployed tenant hhdisabled hhchronic hhhealth ch02 ch34 ch511 ch1215 singlepar extendedfam divsep female) if HRP==1
replace modmiss=1 if modmiss>0 & modmiss!=. 

gen miss=(depmiss==1 | valmiss==1 | modmiss==1)

// Constructing measures 
				
// Basic 

egen tfood=rsum(cMDmeat chfruit chthmeals), m
gen MDfood=(tfood>0) if miss!=1
gen MDhoc=(MDevict==1 | MDmortgage==1)  & (burhc==1) if miss!=1
gen MDfuel=(MDwarm==1 | MDutility==1) if miss!=1
gen MDclothing=(cMDcloth==1 | cMDshoes==1) if miss!=1
egen trsf=rsum(MDroof MDspace MDrefurnish) if miss!=1
gen MDrsf=(trsf>1) if miss!=1 

egen tbasic=rsum(MDfood MDclothing MDhoc MDfuel MDrsf) if miss!=1
gen basic=(tbasic>0) if tbasic!=. 
alpha MDfood MDclothing MDhoc MDfuel MDrsf if miss!=1

// Health

egen thealthc=rsum(cMDunmet cMDdentist) if miss!=1
gen MDhealthc=(thealth>0) & thealth!=. 
alpha cMDunmet cMDdentist if miss!=1

gen MDnoise=(HS170==1) if HS170!=.
gen MDpollution=(HS180==1) if HS180!=. 
gen MDcrime=(HS190==1) if HS190!=. 
gen MDlitter=(HD040==1 | HD040==2) if HD040!=. 
gen MDdamaged=(HD050==1 | HD050==2) if HD050!=. 
gen choutplay=(HD230==2) if HD230_F!=-1
egen tenv=rsum(MDnoise MDpollution MDcrime MDlitter MDdamaged choutplay), m
tab endsmeet tenv [aw=RB050], col nofreq
gen MDenv=(tenv>3) if tenv!=. 

gen health=(MDhealthc==1 | MDenv==1) if MDhealthc!=. & MDenv!=. 

// Education 
gen MDeducation=(chtrips==1 | chworkspace==1) if miss!=1
gen MDlearning=(chbook==1 | chgamesio==1) if miss!=1
gen MDinformation=(MDpc==1 | MDnet==1) if miss!=1

egen teducation=rsum(MDeducation MDlearning MDinformation) if miss!=1
gen education=(teducation>0) if teducation!=. 
alpha chbook chgamesio chtrips chworkspace MDPC MDnet if miss!=1
alpha MDeducation MDlearning MDinformation if miss!=1

// Leisure and social activities
egen tleisure=rsum(cMDleisure MDsmoney cMDholiday) if miss!=1
gen MDleisureact=(tleisure>0) if miss!=1
gen MDsocialact=(cMDg_out==1 | chceleb==1) if miss!=1

egen tsocial=rsum(MDleisureact MDsocialact) if miss!=1
gen social=(tsocial>0) if tsocial!=. 
alpha cMDg_out MDsmoney cMDleisure chceleb MDholiday if miss!=1
alpha MDleisureact MDsocialact

egen deptot= rsum (MDfood MDhoc MDfuel MDclothing MDrsf cMDunmet cMDdentist MDenv MDeducation MDlearning MDinformation MDleisureact MDsocialact) if miss!=1, m

tabstat MDfood MDhoc MDfuel MDclothing MDrsf cMDunmet cMDdentist MDenv MDeducation MDlearning MDinformation MDleisureact MDsocialact [aw=RB050], by(country) format(%9.2f)  

// Multidimensional deprivation measure of poverty 
					
gen deprived=(basic==1 | social==1 | education==1 | health==1 ) if miss!=1

tab country deprived [aw=RB050] if miss!=1, row nofreq 

// Adjustment using income poverty and financial strain 
// Exclusion
gen deprivedx=(basic==1 | social==1 | education==1 | health==1 ) if miss!=1

replace deprivedx=0 if poor60==0 & finstrain<3 & miss!=1

tab country deprivedx [aw=RB050] if miss!=1, row nofreq 

// Inclusion 
replace deprivedx=1 if poor60==1 & finstrain>2 & miss!=1

tab country deprivedx [aw=RB050], row nofreq 

// Consistent poverty

gen cdeprivedx=(deprivedx==1 | poor60==1) if miss!=1 & poor60!=.

gen codeprived=(deprived==1 & poor60==1) if miss!=1 & poor60!=.

egen totdep=rsum(basic social education health) if miss!=1

gen sevdeprived=(totdep>1) if totdep!=. 

gen sevdeprivedx=(totdep>1) if totdep!=. 
replace sevdeprivedx=0 if equinc>thresh60 & finstrain<3 & miss!=1

gen absdeprived=(basic==1 | education==1 | health==1) if miss!=1

tab country deprived, row nofreq m 
tab endsmeet deprived, col nofreq m

tab country totdep, row nofreq m 
tab endsmeet totdep, col nofreq m

tab country absdeprived, row nofreq m 
tab endsmeet absdeprived, col nofreq m 

tab country sevdeprived, row nofreq m 
tab endsmeet sevdeprived, col nofreq m 

tetrachoric deprived sevdeprived absdeprived meet RX060 HX080


//////////////////////////////
/* GUIO GORDON MARLIER 2016 */
//////////////////////////////

egen guiotot= rsum(MDarrears MDholiday MDmeat MDun_exp MDcar MDwarm MDrefurnish MDpc_net MDcloth MDshoes MDg_out MDleisure MDsmoney) if miss!=1, m
gen guio16MD= (guiotot>4) if depmiss!=1
gen guio16SMD= (guiotot>6) if depmiss!=1
gen guio16MDx= (guiotot>4) if depmiss!=1
replace guio16MDx=0 if equinc>thresh60 & finstrain<3 & depmiss!=1
gen guio16SMDx= (guiotot>6) if depmiss!=1
replace guio16SMDx=0 if equinc>thresh60 & finstrain<3 & depmiss!=1
gen neu2020=(guio16SMD==1 | poor60==1 | jobless==1) if depmiss!=1 & poor60!=. & jobless!=. 
gen wneu2020=(guio16SMD==1 | poor60==1) if depmiss!=1 & poor60!=.
gen cguio16MD=(guio16MD==1 & poor60==1) if depmiss!=1 & poor60!=.

//////////////////////////////
/* WHELAN MAITRE 2012 */
//////////////////////////////
						
egen wmtot= rsum(MDholiday MDmeat MDwarm MDrefurnish MDcloth MDshoes MDg_out MDleisure MDsmoney) if depmiss!=1
gen wm12MD= (wmtot>2) if wmtot!=. 
gen wm12MDx= (wmtot>2) if wmtot!=. 
replace wm12MDx=0 if equinc>thresh60 & finstrain<3 & depmiss!=1
gen cwm12MD=(wm12MD==1 & poor60==1) if depmiss!=1 & poor60!=.

save EUSILC2009_Paper4_RPH.dta, replace 
