/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2018). Missing the unhealthy? Examining empirical validity of material deprivation indices (MDIs) using a partial criterion variable. Social indicators research, 135(1), 91-115.

Author: Selçuk Bedük 

Date of code: 30 August 2017

Purpose: Analysing mismatch of Guio 2009 with Unmet Health Care Need due to Inadequate resources indicator

Inputs: SILC09_G09 (from MD_D3_MDindices, using EU SILC 2009; core household, register and personal files and the deprivation module)

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.
See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview
See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896
See for data availability table: https://ec.europa.eu/eurostat/documents/203647/771732/Datasets-availability-table.pdf 

Outputs: ch_dis.text
		interaction.text 
		interactionCMSD.text 	
		kap.text 
*/

//Analysing Guio, 2009
//Data: EU-SILC 2009 household, register and individual module merged file - SILC09_P_PR_H_mdind 

clear all
set more off
capture log close
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"

use SILC09_G09

svyset psu1 [pw=DB090], strata(strata1) 


gen meetend=(endsmeet<4) if endsmeet!=.
gen meet=(endsmeet<3) if endsmeet!=. 
gen healthst=(health>3) if health!=. 
gen bad_health=(healthst==1 | i_disability==1 | i_chronic==1) if healthst!=. & i_disability!=. & i_chronic!=. 
gen hhbadhealth=(hhchronic==1 | hhdisability==1 | hhhealthst==1) if hhchronic!=. & hhdisability!=. & hhdisability!=.
gen hhcodis=(hhchronic==1 | hhdisability==1 ) if hhchronic!=. & hhdisability!=. 

keep if age>15

gen r_country=0
replace r_country=1 if country1==7 | country1==11 | country1==15 | country1==21 | country1==22 | country1==27 | country1==26

// Denmark (7), Finland (11), Iceland (15), the Netherlands (21), Norway(22), Slovenia (27), Sweeden (26)


// Robustness to non-response 

tab country SMDstat [aw=RB050] if (I_unmet==. | health==.) & (country1==5 | country1==8 | country1==17 | country1==23 | country1==29), row nofreq 
tab country SMDstat [aw=RB050] if (I_unmet!=. & health!=.) & (country1==5 | country1==8 | country1==17 | country1==23 | country1==29), row nofreq 

tab country poor60 [aw=RB050] if (I_unmet==. | health==.) & (country1==5 | country1==8 | country1==17 | country1==23 | country1==29), row nofreq
tab country poor60 [aw=RB050] if (I_unmet!=. & health!=.) & (country1==5 | country1==8 | country1==17 | country1==23 | country1==29), row nofreq 

tab country poor120 [aw=RB050] if (I_unmet==. | health==.) & (country1==5 | country1==8 | country1==17 | country1==23 | country1==29), row nofreq
tab country poor120 [aw=RB050] if (I_unmet!=. & health!=.) & (country1==5 | country1==8 | country1==17 | country1==23 | country1==29), row nofreq 

tab country eu2020 [aw=RB050] if (I_unmet==. | health==.) & (country1==5 | country1==8 | country1==17 | country1==23 | country1==29), row nofreq 
tab country eu2020 [aw=RB050] if (I_unmet!=. & health!=.) & (country1==5 | country1==8 | country1==17 | country1==23 | country1==29), row nofreq

misstable patterns I_unmet health_st i_chronic i_disability 


keep if r_country==0 & mis_cases==0 & I_unmet!=. 	// count=357,056

inspect urban hhtype marstat health i_disability i_chronic ecost log_equinc endsmeet
keep if urban!=. & hhtype!=. & marstat!=. & health!=. & i_disability!=. & i_chronic!=. & ecost!=. & meetend!=. // count=349,350

tab country deptot [aw=RB050], m row nofreq
tab country I_unmet, m row
tab country I_unmet [aw=RB050], m row nofreq 
tab country i_disability [aw=RB050], m row nofreq 
tab country i_chronic [aw=RB050], m row nofreq 
tab country health [aw=RB050], m row nofreq 



// Descriptive analysis of material deprivation and unmet health need due to inadequate resources (UHCNIR) 

label variable deptot "Total deprivation score" 
label variable hystd "HH equivalised disposable income" 
gen loginc=log(hystd)
histogram deptot, normal

scatter deptot hystd, xline(10000) yline(3 4)
graph twoway (lfit deptot loginc) (scatter deptot loginc)
scatter deptot hystd if hystd<100000, yline(3 4) xline(8000)


sum MDstat SMDstat CMD CSMD [aw=RB050]

graph twoway scatter deptot t_UNmed

tab deptot unmet_med if mis_cases!=1 [aw=RB050], row col nofreq  // household
tab deptot I_unmet if mis_cases!=1 [aw=RB050], row col nofreq 	// individual 
polychoric deptot unmet_med
polychoric deptot I_unmet
tetrachoric MDstat SMDstat I_unmet unmet_med

tetrachoric SMDstat I_unmet poor60 meetend bad_health

tab decile deptot if mis_cases!=1 [aw=RB050], col nofreq 



** MISMATCH
// Material deprivation

tab MDstat I_unmet 
tab MDstat I_unmet [aw=RB050], nofreq cell 
tab MDstat I_unmet [aw=RB050], nofreq col 

tab MDstat I_unmet, chi2 lrchi2
tabchi MDstat I_unmet, a


// Severe material deprivation
label variable SMDstat "SMD"
tab SMDstat I_unmet
tab SMDstat I_unmet [aw=RB050], nofreq cell
tab SMDstat I_unmet [aw=RB050], nofreq col

tab SMDstat I_unmet, chi2 gamma taub

// Consistent poverty with MD
tab CMD I_unmet 
tab CMD I_unmet [aw=RB050], nofreq cell
tab CMD I_unmet [aw=RB050], nofreq col
tab CMDstat I_unmet, chi2 lrchi2


// Consistent poverty with SMD
tab CSMD I_unmet 
tab CSMD I_unmet [aw=RB050], nofreq cell
tab CSMD I_unmet [aw=RB050], nofreq col

tab CSMDstat I_unmet, chi2 gamma taub



// Mismatch in each country  
tab country SMDstat if mis_cases!=1 [aw=RB050], row nofreq 
tab country I_unmet if mis_cases!=1 & SMD==0 [aw=RB050], m row nofreq 
bysort country: tab SMD I_unmet if mis_cases!=1 [aw=RB050], m nofreq col row 

// by country 
tabstat I_unmet if mis_cases!=1 & SMDstat==0 [aw=RB050], m by(country)


/* Among those who are identified as not-materially-deprived (85% of the whole population)
around 1% still suffer from unmet health needs due to insufficient resources 
which is 1/3 of all having unmet needs due to insufficient resources. (In other words
the 9-item index captures 65% of those who have unmet health needs
due to insufficient resources)*/

/* Although most of those who have unmet health needs because they are unable to pay 
are identified by the material deprivation index, a significant number of people is 
not captured by the index. Given the total population of EU-28 countries, 
one percent of the non-deprived population accounts to around 4 million people. But 
this number surely represent the total amount of measurement error as it would be 
hard to argue that one indicator of unmet health need alone might not be adequate to spot
the people in poverty. Yet profiling those people in terms of their income, living and health conditions,
employment status etc. might help understand whether they might be identified as experiencing poverty*/


tab deptot I_unmet if SMDstat==0 [aw=RB050], col nofreq
tab poor60 I_unmet if SMDstat==0 [aw=RB050], col nofreq
tab poor120 I_unmet if SMDstat==0 [aw=RB050], col nofreq 
tab jobless I_unmet if SMDstat==0 [aw=RB050], col nofreq
tab meetend I_unmet if SMDstat==0 [aw=RB050], col nofreq

tab health_st I_unmet if SMDstat==0 [aw=RB050], col nofreq 
tab i_chronic I_unmet if SMDstat==0 [aw=RB050], col nofreq
tab i_disability I_unmet if SMDstat==0 [aw=RB050], col nofreq
tab bad_health I_unmet if SMDstat==0 [aw=RB050], col nofreq 
tab decile I_unmet if SMDstat==0 [aw=RB050], col nofreq 

tab female I_unmet if SMDstat==0 [aw=RB050], col nofreq 
tab agegr I_unmet if SMDstat==0 [aw=RB050], col nofreq 
tab hhtype I_unmet if SMDstat==0 [aw=RB050], col nofreq
tab marstat I_unmet if SMDstat==0 [aw=RB050], col nofreq 
tab urban I_unmet if SMDstat==0 [aw=RB050], col nofreq 
tab ecost I_unmet if SMDstat==0 [aw=RB050], col nofreq 
tab occupation I_unmet if SMDstat==0 [aw=RB050], col nofreq 

// Consistent SMD 

tab deptot I_unmet if CSMD==0 [aw=RB050], col nofreq
tab poor60 I_unmet if CSMD==0 [aw=RB050], col nofreq
tab poor120 I_unmet if CSMD==0 [aw=RB050], col nofreq 
tab jobless I_unmet if CSMD==0 [aw=RB050], col nofreq
tab meetend I_unmet if CSMD==0 [aw=RB050], col nofreq

tab health_st I_unmet if CSMD==0 [aw=RB050], col nofreq 
tab i_chronic I_unmet if CSMD==0 [aw=RB050], col nofreq
tab i_disability I_unmet if CSMD==0 [aw=RB050], col nofreq
tab bad_health I_unmet if CSMD==0 [aw=RB050], col nofreq 
tab decile I_unmet if CSMD==0 [aw=RB050], col nofreq
 
tab hcobr I_unmet if CSMD==0 [aw=RB050], col nofreq 
tab debtburden I_unmet if CSMD==0 [aw=RB050], col nofreq 
tab tothoudep I_unmet if CSMD==0 [aw=RB050], col nofreq 



tabstat poor60 jobless meetend health_st i_chronic i_disability bad_health [aw=RB050]


/* Among those 1%, 1/4 have incomes under 60% of median income threshold 
1/3 have incomes under 70% of median income and around 3/4 have incomes under
120% of median household income in their country*/

/* So only a quarter of the group is located under the relative income poverty threshold, 
but the majority of the group still have moderate income levels. Even if the result might be read
as low association with income, this does not necessarily provide enough evidence to argue that
these people are not experiencing poverty. Two arguments can support this proposition. Firstly, even tough
only a quarter of people is identified under the poverty threshold, the majority of the people have moderate
and not high incomes. Secondly, the idea for using material deprivation indices is based on the fact that 
there is low association between income and deprivation - the income poverty measures and material deprivation measures 
mostly identify different gruops of deprived people (e.g. Guio, 2009). Therefore, the lowness of income might not necessarily 
provide an adequate indicator of the poverty state, also given the somewhat arbitrary nature of the threshold levels.
Indeed what is identified by the unmet health care need due to cost indicator is not the lowness of income but inadequacy 
of income, as once suggested by Sen (1992) the relevant concept of poverty in the income space. Sen (1992) argued
that inadequacy of income cannot be judged indepedently of the of the actual possibilities of converting incomes and resources 
into capability to function.  

"The person with the kidney problem needing dialysis (in the example discussed earlier in this chapter) may have more income 
than the other person, but he is still short of economic means (indeed of income), given his problem in converting income and 
resources into functionings. .. Income adequacy to escape poverty varies parametrically with personal characteristics and circumstances
(1992:111)"

Hence income adequacy or a certain poverty threshold is a function of personal characteristics and circumstances.
This argument is closely related to the recent debates in the US around the viability of existing income thresholds. 
Defining income (in)adequacy based on income-to-needs ratio, the latest discussions focus on the need to account for 
cost-of-living differences, housing, child care as well as health care costs for the households while devising 
a poverty threshold (or multiple poverty thresholds for different household types.) 

So turning back to our case, we have a group of people who are not identified as materially deprived but have unmet health 
care needs because of not being able to pay for the cost. Yet most of them ( around 3/4) still have incomes above the relative 
income threshold however still less than the median household income. Therefore their income provide them with certain living 
standards yet still stay inadequate to meet their healthcare needs. One reason might be that they have relatively higher health care needs 
compare to the average of the population. In other words most of them might not have low but inadequate income, specifically because of 
their relatively higher needs for health care.

Indeed this is reflected in the indicators of health conditions: Those of 1% who has unmet health need due to inadequate resources
and not identified by the material deprivation index, in around 64% of the househoulds there is at least one member who has chronic 
(longstanding) ilness health conditions (physical and/or mental), and in around 63% of the households there is at least one member 
who has limitations in daily activities because of health problems. */



/* What are the economic conditions and employment status of those who have UNHNIR,
chronic health conditions or disability or bad subjective health and not captured by the indices*/

log using ch_dis, text replace 
tab poor60 if mis_cases!=1 & SMDstat==0 & I_unmet==1 & i_disability==1 [aw=RB050]
tab jobless if mis_cases!=1 & SMDstat==0 & I_unmet==1 & i_disability==1 [aw=RB050] 
tab endsmeet if mis_cases!=1 & SMDstat==0 & I_unmet==1 & i_disability==1 [aw=RB050]
tab poor120 if mis_cases!=1 & SMDstat==0 & I_unmet==1 & i_disability==1 [aw=RB050]
tab decile I_unmet if mis_cases!=1 & SMDstat==0 & i_disability==1 [aw=RB050], col nofreq
tab tenure I_unmet if mis_cases!=1 & SMDstat==0 & i_disability==1 [aw=RB050], col nofreq
tab debtburden I_unmet if mis_cases!=1 & SMDstat==0 & i_disability==1 [aw=RB050], col nofreq
tab deptot if mis_cases!=1 & SMDstat==0 & I_unmet==1 & i_disability==1 [aw=RB050]

tab poor60 if mis_cases!=1 & SMDstat==0 & I_unmet==1 & i_chronic==1 [aw=RB050]
tab jobless if mis_cases!=1 & SMDstat==0 & I_unmet==1 & i_chronic==1 [aw=RB050] 
tab endsmeet if mis_cases!=1 & SMDstat==0 & I_unmet==1 & i_chronic==1 [aw=RB050]
tab poor120 if mis_cases!=1 & SMDstat==0 & I_unmet==1 & i_chronic==1 [aw=RB050]
tab decile I_unmet if mis_cases!=1 & SMDstat==0 & i_chronic==1 [aw=RB050], col nofreq
tab tenure I_unmet if mis_cases!=1 & SMDstat==0 & i_chronic==1 [aw=RB050], col nofreq
tab deptot if mis_cases!=1 & SMDstat==0 & I_unmet==1 & i_chronic==1 [aw=RB050]

tab poor60 if mis_cases!=1 & SMDstat==0 & I_unmet==1 & health_st==1 [aw=RB050]
tab jobless if mis_cases!=1 & SMDstat==0 & I_unmet==1 & health_st==1 [aw=RB050] 
tab endsmeet if mis_cases!=1 & SMDstat==0 & I_unmet==1 & health_st==1 [aw=RB050]
tab poor120 if mis_cases!=1 & SMDstat==0 & I_unmet==1 & health_st==1 [aw=RB050]
tab decile I_unmet if mis_cases!=1 & SMDstat==0 & health_st==1 [aw=RB050], col nofreq
tab debtburden I_unmet if mis_cases!=1 & SMDstat==0 & health_st==1 [aw=RB050], col nofreq
tab deptot if mis_cases!=1 & SMDstat==0 & I_unmet==1 & health_st==1 [aw=RB050]

log close
// The issue is not of a low income but inadequate income 





* Regression analysis - testing the hypotheses / interactions between SMD and Income poverty, and disability and chronic

label variable poor60 "Inc.Poverty(60%med)"
label variable endsmeet "Subj.Inc.Inadequacy"
label variable i_disability "Disability"
label variable i_chronic "Chronic Health Problem"


recode health (1 2 3 = 0) (4 5 = 1), into(health_st)

gen SMDdis=SMDstat*i_disability
gen SMDcho=SMDstat*i_chronic
gen SMDhealth=SMDstat*health
gen SMDheast=SMDstat*health_st

label variable SMDdis "SMD*disability"
label variable SMDcho "SMD*chronic" 
label variable SMDhealth "SMD*health"


log using interaction, text replace 

logit I_unmet SMDstat i_disability SMDdis, or 
estimates store m1, title(Model 1)

logit I_unmet SMDstat i_disability SMDdis poor60, or 
estimates store m2, title(Model 2)

logit I_unmet SMDstat i_disability SMDdis poor60 endsmeet, or
estimates store m3, title(Model 3)


estout m1 m2 m3, cells(b(star fmt(3)) se(par fmt(2)))   ///
   legend label varlabels(_cons constant)               ///
   stats(r2_p N, fmt(3 0 1) label(R-sqr N)) 



logistic I_unmet SMDstat i_chronic SMDcho
estimates store m1, title(Model 1)

logistic I_unmet SMDstat i_chronic SMDcho poor60 
estimates store m2, title(Model 2)

logistic I_unmet SMDstat i_chronic SMDcho poor60 endsmeet
estimates store m3, title(Model 3)

estout m1 m2 m3, cells(b(star fmt(3)) se(par fmt(2)))   ///
   legend label varlabels(_cons constant)               ///
   stats(r2_p N, fmt(3 0 1) label(R-sqr N)) 



logistic I_unmet SMDstat health SMDhealth 
estimates store m1, title(Model 1)

logistic I_unmet SMDstat health SMDhealth poor60
estimates store m2, title(Model 2)

logistic I_unmet SMDstat health SMDhealth poor60 endsmeet 
estimates store m3, title(Model 3)

estout m1 m2 m3, cells(b(star fmt(3)) se(par fmt(2)))   ///
   legend label varlabels(_cons constant)               ///
   stats(r2_p N, fmt(3 0 1) label(R-sqr N))e1
   

log close


// NEW // 

gen SMDbadhe=SMDstat*bad_health
gen poorh=poor60*bad_health
gen meeth=meetend*bad_health

gen SMDhhbad=SMDstat*hhbadhealth
gen poorhhbad=poor60*hhbadhealth
gen meethhbad=meetend*hhbadhealth


   
eststo clear 
eststo: logistic I_unmet bad_health i.ageg SMDstat 
eststo: logistic I_unmet bad_health i.ageg SMDstat SMDbadhe
eststo: logistic I_unmet bad_health i.ageg SMDstat SMDbadhe [pw=RB050]
eststo: logistic I_unmet bad_health i.ageg poor60 
eststo: logistic I_unmet bad_health i.ageg poor60 poorh 
eststo: logistic I_unmet bad_health i.ageg poor60 poorh [pw=RB050]
eststo: logistic I_unmet bad_health i.ageg meetend 
eststo: logistic I_unmet bad_health i.ageg meetend meeth 
eststo: logistic I_unmet bad_health i.ageg meetend meeth [pw=RB050]
esttab, eform cells(b(star fmt(3)) se(par fmt(2)))  ///
   legend label varlabels(_cons constant)               ///
   stats(lr N, fmt(3 0 1) label(N)) scalars(lrtest_chi2)
   
eststo clear 
eststo: logistic I_unmet i.ageg hhbadhealth SMDstat 
eststo: logistic I_unmet i.ageg hhbadhealth SMDstat SMDhhbad
eststo: logistic I_unmet i.ageg hhbadhealth SMDstat SMDhhbad [pw=RB050]
eststo: logistic I_unmet i.ageg hhbadhealth poor60 
eststo: logistic I_unmet i.ageg hhbadhealth poor60 poorhhbad 
eststo: logistic I_unmet i.ageg hhbadhealth poor60 poorhhbad [pw=RB050]
eststo: logistic I_unmet i.ageg hhbadhealth meetend 
eststo: logistic I_unmet i.ageg hhbadhealth meetend meethhbad
eststo: logistic I_unmet i.ageg hhbadhealth meetend meethhbad [pw=RB050]
esttab, eform cells(b(star fmt(3)) se(par fmt(2)))  ///
   legend label varlabels(_cons constant)               ///
   stats(lr N, fmt(3 0 1) label(N)) scalars(lrtest_chi2)
   
eststo clear 
eststo: logistic I_unmet hhcodis i.agegr SMDstat 
eststo: logistic I_unmet hhcodis i.agegr SMDstat MDdc
eststo: logistic I_unmet hhcodis i.agegr SMDstat MDdc [pw=RB050]
eststo: logistic I_unmet hhcodis i.agegr poor60 
eststo: logistic I_unmet hhcodis i.agegr poor60 poordc 
eststo: logistic I_unmet hhcodis i.agegr poor60 poordc [pw=RB050]
eststo: logistic I_unmet hhcodis i.agegr meetend 
eststo: logistic I_unmet hhcodis i.agegr meetend meetdc 
eststo: logistic I_unmet hhcodis i.agegr meetend meetdc [pw=RB050]
esttab, eform cells(b(star fmt(3)) se(par fmt(2)))  ///
   legend label varlabels(_cons constant)               ///
   stats(lr N, fmt(3 0 1) label(N)) scalars(lrtest_chi2)   
      
   
logistic I_unmet poor60  
estimates store m1, title(Model 1)

logistic I_unmet poor60 bad_health 
estimates store m2, title(Model 2)

logistic I_unmet poor60 bad_health poorbad 
estimates store m3, title(Model 3)

logistic I_unmet poor60 bad_health poorbad debtburden
estimates store m4, title(Model 4)

logistic I_unmet poor60 bad_health poorbad debtburden poordebt
estimates store m5, title(Model 5)

estout m1 m2 m3 m4 m5, eform cells(b(star fmt(3)) se(par fmt(2)))   ///
   legend label varlabels(_cons constant)               ///
   stats(r2_p N, fmt(3 0 1) label(R-sqr N)) 
   

gen endbad=meetend*bad_health
gen enddebt=meetend*debtburden
label variable meetend "Subj. income inadeq."
label variable endbad "Meetend*bad_health"
label variable enddebt "Subj.inc.inad.*debt" 

logistic I_unmet meetend  
estimates store m1, title(Model 1)

logistic I_unmet meetend bad_health 
estimates store m2, title(Model 2)

logistic I_unmet meetend bad_health endbad 
estimates store m3, title(Model 3)

logistic I_unmet meetend bad_health endbad debtburden
estimates store m4, title(Model 4)

logistic I_unmet meetend bad_health endbad debtburden enddebt
estimates store m5, title(Model 5)

estout m1 m2 m3 m4 m5, eform cells(b(star fmt(3)) se(par fmt(2)))   ///
   legend label varlabels(_cons constant)               ///
   stats(r2_p N, fmt(3 0 1) label(R-sqr N)) 
   







// CONSISTENT POVERTY - CSMD //

gen CSMDdis=CSMD*i_disability
gen CSMDcho=CSMD*i_chronic
gen CSMDhealth=CSMD*health
gen CSMDbadhe=CSMD*bad_health

label variable CSMDdis "CSMD*disability"
label variable CSMDcho "CSMD*chronic" 
label variable CSMDhealth "CSMD*health"


log using interactionCSMD, text replace 

logit I_unmet CSMD i_disability CSMDdis, or 
estimates store m1, title(Model 1)

logit I_unmet CSMD i_disability CSMDdis poor60, or 
estimates store m2, title(Model 2)

logit I_unmet CSMD i_disability CSMDdis poor60 endsmeet, or
estimates store m3, title(Model 3)


estout m1 m2 m3, cells(b(star fmt(3)) se(par fmt(2)))   ///
   legend label varlabels(_cons constant)               ///
   stats(r2_p N, fmt(3 0 1) label(R-sqr N)) 



logistic I_unmet CSMD i_chronic CSMDcho
estimates store m1, title(Model 1)

logistic I_unmet CSMD i_chronic CSMDcho poor60 
estimates store m2, title(Model 2)

logistic I_unmet CSMD i_chronic CSMDcho poor60 endsmeet
estimates store m3, title(Model 3)

estout m1 m2 m3, cells(b(star fmt(3)) se(par fmt(2)))   ///
   legend label varlabels(_cons constant)               ///
   stats(r2_p N, fmt(3 0 1) label(R-sqr N)) 



logistic I_unmet CSMD health CSMDhealth 
estimates store m1, title(Model 1)

logistic I_unmet CSMD health CSMDhealth poor60
estimates store m2, title(Model 2)

logistic I_unmet CSMD health CSMDhealth poor60 endsmeet 
estimates store m3, title(Model 3)

estout m1 m2 m3, cells(b(star fmt(3)) se(par fmt(2)))   ///
   legend label varlabels(_cons constant)               ///
   stats(r2_p N, fmt(3 0 1) label(R-sqr N)) 


log close




gen xcs=i_chronic*SMDstat


logit I_unmet SMDstat##i_dis, or
logit I_unmet SMDstat##i_chro [pw=RB050], or
logit I_unmet SMDstat##healthst, or

logit I_unmet SMDstat#female, or



* Alternative ways to control for this 
log using kap, text 
kap MDstat unmet_med if mis_cases!=1 & !missing(unmet_med), tab
kap SMDstat I_unmet if mis_cases!=1 & !missing(I_unmet), tab
kap CMD unmet_med if mis_cases!=1 & !missing(unmet_med), tab
kap CSMD unmet_med if mis_cases!=1 & !missing(unmet_med), tab
log close 




forvalues x=1/14{ 
	kap SMDstat I_unmet if mis_cases!=1 & !missing(I_unmet) & country1==`x'
}
	
forvalues x=16/21 { 
	kap SMDstat I_unmet if mis_cases!=1 & !missing(I_unmet) & country1==`x'
}	

forvalues x=23/29 { 
	kap SMDstat I_unmet if mis_cases!=1 & !missing(I_unmet) & country1==`x'
}
 



