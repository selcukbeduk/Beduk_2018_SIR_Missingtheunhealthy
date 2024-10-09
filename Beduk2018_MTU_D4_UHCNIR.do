/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2018). Missing the unhealthy? Examining empirical validity of material deprivation indices (MDIs) using a partial criterion variable. Social indicators research, 135(1), 91-115.

Author: Selçuk Bedük 

Date of code: 30 August 2017

Purpose: Analysing Unmet Health Care Need due to Inadequate resources indicator for individuals

Inputs: SILC09_G09 (from MD_D3_MDindices, using EU SILC 2009; core household, register and personal files and the deprivation module)
Note: For Register countries, there is information only from Household Reference Person (HRP)

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.
See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview
See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896
See for data availability table: https://ec.europa.eu/eurostat/documents/203647/771732/Datasets-availability-table.pdf 

Outputs: eu2020Iunmet.rtf 
		logitmodels1.text 
		logitmodels2.text 	
*/

version 12
clear all
set memory 500m
set more off
capture log close
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"

// INDIVIDUAL LEVEL ANALYSIS // 

use SILC09_G09.dta

svyset psu1 [pw=DB090], strata(strata1) 

gen r_country=0
replace r_country=1 if country1==7 | country1==11 | country1==15 | country1==21 | country1==22 | country1==27 | country1==26

keep if age>15 & r_country==0 & mis_cases==0 & I_unmet!=.

inspect urban hhtype marstat health i_disability i_chronic ecost log_equinc
keep if urban!=. & hhtype!=. & marstat!=. & health!=. & i_disability!=. & i_chronic!=. & ecost!=. & log_equinc!=.  // count=349,438

gen health_st=.
replace health_st=0 if health==1 | health==2 | health==3
replace health_st=1 if health==4 | health==5
label define hea 0 "Good" 1 "Bad", replace 
label values health_st hea 
label variable health_st "Subjective health"

// Extent of UHCNIR and its relation with poverty indicators across countries 

tab country I_unmet [aw=RB050], row nofreq 
tab country eu2020 [aw=RB050], row nofreq 
tab country SMDstat [aw=RB050], row nofreq 
tab country poor60 [aw=RB050], row nofreq 


tab agegr I_unmet [aw=RB050], col nofreq 		// age group
tab agegr eu2020 [aw=RB050], col nofreq  

tab female I_unmet [aw=RB050], col nofreq 		// gender 
tab female eu2020 [aw=RB50], col nofreq 
bysort agegr: tab female I_unmet [aw=RB050], col nofreq 

tab hhtype I_unmet [aw=RB050], col nofreq 		// household type
tab hhtype eu2020 [aw=RB050], col nofreq 
bysort agegr: tab hhtype I_unmet [aw=RB050], col nofreq 

tab marstat I_unmet [aw=RB050], col nofreq		// marital status 
tab marstat eu2020 [aw=RB050], col nofreq 
bysort agegr: tab marstat I_unmet [aw=RB050], col nofreq		// marital status 


tab t_UNmed I_unmet [aw=RB050], col nofreq 		// the density of UHNCIR problem within the household 
/* 58% of the people having UHCNIR are the only ones having this problem in the household 
	in 31.15% of the cases, there are two people in the same household having the UHNCIR problem 
	in 7% of the cases, there are three; and in 3% of the cases there are more than three people in the household having the UHNCIR problem */

tab urban I_unmet [aw=RB050], col nofreq 		// degree of urbanisation 
tab urban eu2020 [aw=RB050], col nofreq 
bysort agegr: tab urban I_unmet [aw=RB050], col nofreq 		// degree of urbanisation 

tab ecost I_unmet [aw=RB050], col nofreq 		// economic status
tab ecost eu2020 [aw=RB050], col nofreq 
bysort agegr: tab ecost I_unmet [aw=RB050], col nofreq 		// economic status

tab occupation I_unmet [aw=RB050], col nofreq	// occupation
tab occupation eu2020 [aw=RB050], col nofreq 
bysort agegr: tab occupation I_unmet [aw=RB050], col nofreq	// occupation

tab inctile I_unmet [aw=RB050], col nofreq		// income deciles

tab health I_unmet [aw=RB050], col nofreq 		// subjective health 
tab health_st I_unmet [aw=RB050], col nofreq 		// subjective health
tab health_st eu2020 [aw=RB050], col nofreq  
bysort agegr: tab health I_unmet [aw=RB050], col nofreq 		// subjective health 

tab i_chronic I_unmet [aw=RB050], col nofreq	// chronic health conditions
tab i_chronic eu2020 [aw=RB050], col nofreq  
bysort agegr: tab i_chronic I_unmet [aw=RB050], col nofreq	// chronic health conditions 

tab i_disability I_unmet [aw=RB050], col nofreq // disability 
tab i_disability eu2020 [aw=RB050], col nofreq 
bysort agegr: tab i_disability I_unmet [aw=RB050], col nofreq // disability 




 
// I_unmet or unmet_med
tab unmet_med if mis_cases!=1 [aw=RB050]
tab unmet_med if mis_cases!=1 [aw=RB050], m
tab I_unmet if mis_cases!=1 [aw=RB050], m

// Country differences 
tab country I_unmet if mis_cases!=1 [aw=RB050], m row nofreq


/// 
bysort bad_health: tab SMDstat I_unmet, cell freq 
bysort bad_health: tab poor60 I_unmet, cell freq 
bysort bad_health: tab meetend I_unmet, cell freq 

// Regression analysis - determinants of UHNCIR 

logit I_unmet log_equinc SMDstat poor60 poor120 endsmeet i.eco_st bad_health ib3.ageg

collin log_equinc SMDstat poor60 endsmeet eco_st health i_disability i_chronic 

gen bad_health=.
replace bad_health=0 if health==1 | health==2 | health==3 | i_disability==0 | i_chronic==0
replace bad_health=1 if health==4 | health==5 | i_disability==1 | i_chronic==1

coldiag2 log_equinc SMDstat poor60 endsmeet eco_st bad_health 

eststo clear
eststo: logistic eu2020 I_unmet log_equinc female ib3.ageg i.marstat health_st i_disability i_chronic 

esttab using eu2020Iunmet.rtf, replace onecell eform ///
	cells(b(star fmt(3)) se(par fmt(2)))   ///
   legend label varlabels(_cons constant)               ///
   refcat(1.ageg "Age group", nolabel) ///
   stats(r2 N, fmt(3 0 1) label(R-sqr N))
   
   



logistic I_unmet SMDstat poor60 log_equinc
estimates store m1, title(Model 1)
  
logistic I_unmet SMDstat poor60 log_equinc female ib3.ageg ib2.marstat
estimates store m2, title(Model 2)

logistic I_unmet SMDstat poor60 log_equinc female ib3.ageg ib2.marstat health i_disability i_chronic
estimates store m3, title(Model 3)

coldiag2 SMDstat poor60 log_equinc ecost endsmeet  // an alternative is "perturb"
collin SMDstat poor60 log_equinc ecost endsmeet, corr

log using logitmodels1, text replace 
estout m1 m2 m3, eform cells(b(star fmt(3)) se(par fmt(2)))   ///
   legend label varlabels(_cons constant)               ///
   stats(r2_p df_m bic N, fmt(3 0 1) label(R-sqr dfm BIC N)) 
log close 

tetrachoric I_unmet eu2020 SMDstat poor60  
polychoric SMDstat I_unmet poor60 log_equinc endsmeet bad_health  


/* Important points

1. Income, income poverty status, material deprivation status explains having unmet health care needs due to inadequate resources.

2. Income poverty status (60% median) becomes non-significant when economic status variable is included into the model - the aim for adding economic status 
in addition to income and material deprivation was to capture the access to health care through insurance 

3. 120% of median status becomes insignifcant when endsmeet included into the model - probably endsmeet capture those people under 120% median line. 
	There are people above the 60% median threshold who is having UHCNIR problem. 

3. Having difficulties making ends meet is the most closely related indicator to UHCNIR. 
People having difficulties on making ends meet are not only those identified as in poverty (by 60% median) or severely materially deprived - 
some has more income than threshold  mostly between 60% and 120% of median (given that poor120 becomes non-significant after adding endsmeet)

3. Compared to full-time workers (except being in military service and other inactive person), unemployed, part-time workers, 
people doing domestic or unpaid work, students, disabled and retirees have higher risks in having UHCNIR problem. People doing domestic
and unpaid work is the highest risk group. 

4. People reporting worse health conditions, with disabilities or chronic health conditions are more likely to have UHCNIR 
after controlling for all other factors (income, poverty statuses, economic status, health) 

6. Younger (15-24) and elderly people (65+) tend to have less UHCNIR problem than others after controlling for all other factors 
(income, poverty statuses, economic status, health, disability, chronic health conditions)

*/



logistic eu2020 I_unmet
estimates store m1, title(Model 1)
  
logistic eu2020 I_unmet female ib3.ageg ib2.marstat
estimates store m2, title(Model 2)

logistic eu2020 I_unmet female ib3.ageg ib2.marstat health i_disability i_chronic
estimates store m3, title(Model 3)

coldiag2 SMDstat poor60 log_equinc ecost endsmeet  // an alternative is "perturb"
collin SMDstat poor60 log_equinc ecost endsmeet, corr

log using logitmodels2, text replace 
estout m1 m2 m3, eform cells(b(star fmt(3)) se(par fmt(2)))   ///
   legend label varlabels(_cons constant)               ///
   stats(r2_p df_m bic N, fmt(3 0 1) label(R-sqr dfm BIC N)) 
log close 




// NEW

bysort bad_health: tab I_unmet SMDstat [aw=RB050], cell nofreq 

logistic I_unmet i.SMDstat i.bad_health i.ageg
margins, at(ageg=(2(1)6)) over(SMDstat bad_health)
marginsplot, name(SMD)


logistic I_unmet i.poor60 i.bad_health i.ageg
margins, at(ageg=(2(1)6)) over(poor60 bad_health)
marginsplot, name(po)


logistic I_unmet i.meetend i.bad_health i.ageg
margins, at(ageg=(2(1)6)) over(meetend bad_health)
marginsplot, name(me)

graph combine SMD po me




