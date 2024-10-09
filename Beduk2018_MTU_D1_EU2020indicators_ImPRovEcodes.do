/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2018). Missing the unhealthy? Examining empirical validity of material deprivation indices (MDIs) using a partial criterion variable. Social indicators research, 135(1), 91-115.

Author: Selçuk Bedük 

Date of code: 30 August 2017

Purpose: Computation of Europe 2020 poverty indicators

Inputs: EU SILC 2009; household, register and individual core modules a deprivation module 
		Using also the code provided by Goedeme & Montaigne (see below)

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.
See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview
See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896
See for data availability table: https://ec.europa.eu/eurostat/documents/203647/771732/Datasets-availability-table.pdf 

Outputs: EU2020_PSE_ind_ImPRovE.dta 
*/



*


*******************************************************************************************************
* This do-file contains the syntax to compute  the official Europe 2020 poverty indicators            *
* (at-risk-of-poverty, severe material deprivation, very low work intensity). 						  *
*******************************************************************************************************

* Authors: Tim Goedeme & Fabienne Montaigne, updated by Vincent Corluy and Aaron Van den Heede
* tim.goedeme@ua.ac.be (Herman Deleeck Centre for Social Policy, University of Antwerp; http://www.centreforsocialpolicy.eu)

* Many thanks for acknowledging the effort we put into writing this do-file

* Please note that (especially for the most recent waves of EU-SILC) prepared variables are automatically included in the UDB.

* May 2013


*This do-file has been checked for EU-SILC cross-sectional UDBs 2005-2010


*1. Preparations
*****************

*Load your data file. This do-file requires that all 4 files are merged (D, H, R and P-file of the EU-SILC UDB)


// Creating work intensity indicator of EU 
// Data: EU-SILC 2009 household, register and personal
// Using the codes by ImPRovE team: Tim Goedeme & Fabienne Montaigne, updated by Vincent Corluy and Aaron Van den Heede 


version 12
clear all
set memory 500m
set more off
capture log close
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"



********************
*Jobless households*
********************


use RB010 RB020 RB030 RX030 RB050 RB080 RB090 RB220_F RB230_F RB245 RB250 RX020 using "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\EUSILC09_personal_register"
rename RB010 year
rename RB020 country 
label variable RB080 "Year of birth"
rename RX020 age
replace age=year-RB080-1 if age==. 
labe variable RB090 "Gender" 
recode RB090 (2=1) (1=0), gen(female) 
rename RB090 sex 
rename RB030 pid
rename RX030 hid
label variable RB245 "Respondent status"

save WI_register.dta, replace  

clear 
use HB010 HB020 HB030 HB070 HD010 HS010-HS190 HH020 HH040 HH050 HH080 HD080 HD090 HY020 HY022 HY025 using "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\EUSILC09_household"
describe
rename HB010 year
rename HB020 country 
rename HB030 hid 
rename HB070 pid 
rename HH020 tenure
sort country hid pid
save WI_household.dta, replace 

clear
use WI_register
sort country hid
merge m:1 country hid using WI_household.dta 
tab _merge  
save WI_H_R.dta, replace  

clear 
use PB010 PB020 PB030 PL030-PL031_F PL060 PL060_F PL073-PL076_F PL080 PL080_F PL085 PL086 PL086_F PL087 PL087_F PL088 PL088_F ///
	PL089 PL089_F PL090 PL090_F PL100 PL100_F PB040 ///
	PY010G PY020G PY021G PY050G PY080G PB140 PB150 using "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\EUSILC09_personal"
rename PB010 year
rename PB020 country 
rename PB030 pid
rename PB150 sex
sort country pid sex
save WI_personal.dta, replace 

use WI_H_R.dta
drop _merge 
merge 1:1 country pid sex using WI_personal 
rename sex PB150
save WI_H_R_P.dta, replace 


*for the imputation procedure of the low work intensity variable, this syntax makes use of a temporary file.
*Please indicate here the location of the folder where this file may be stored:

global place1 "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"


*Indicate the EU-SILC survey year:

global year=2009

* all variables in lower-case

foreach var of varlist _all {
	local newname = lower("`var'")
	cap rename `var' `newname'
}

* rename some variables

cap rename db020 country
cap rename db030 hid
cap rename rb030 pid

* store all country codes in a global

local varlist country
sort `varlist'
tempvar tesje
qui: gen `tesje'=1 if `varlist'[_n]!=`varlist'[_n-1]
sort `tesje' `varlist'
qui: count if `tesje'==1
local nrvalues=r(N)
global countries
local counter=1
while `counter'<=`nrvalues' {
	local value1=`varlist'[`counter']
	local value2=`varlist'[`counter'-1]
	if "`value1'"!="`value2'" {
		global countries ${countries} `value1'
	}
	local counter=`counter'+1
}
global ncountries=wordcount("${countries}")
display "${countries}"
display "number of countries in datafile: " $ncountries


******************************
*At-risk-of-poverty indicator*
******************************

cap drop hydisp
cap drop child14
cap drop adult14
cap drop hhnbr_child14
cap drop hhnbr_adult14
cap drop hhnbr_pers
cap drop eqs
cap drop sum080
cap drop hystd
cap drop thresh60
cap drop arop60
cap drop thresh50
cap drop arop50
cap drop thresh70
cap drop arop70


/*total disposable hh income * within hh non-response inflation factor*/ 

*Since EU-SILC 2009, it is practice to include the sum of pensions received from individual private plans (other than
*those covered under ESSPROS) (PY080G) into equivalent disposable income (HX090). However, for reasons of consistency over time: choose whether to include it or not
*From EU-SILC 2011 onwards, PY080G is automatically included in the computation of HY020, so it is preferable to add it everywhere to make data comparable.


* 'old' style:
*gen hydisp=hy020*hy025 

* 'new' style:
if ${year}<2011 {
	bysort country hid: egen sum080=sum(py080g)
	gen hydisp=(hy020+sum080)*hy025
}
else gen hydisp=hy020*hy025

gen byte child14=.
replace child14=1 if age<14
replace child14=0 if age>=14

gen byte adult14=.
replace adult14=1 if age>=14
replace adult14=0 if age<14

bysort country hid: egen hhnbr_child14 = sum(child14)
bysort country hid: egen hhnbr_adult14 = sum(adult14)
gen hhnbr_pers = hhnbr_child14 + hhnbr_adult14

gen float eqs=.
replace eqs= 1+(hhnbr_adult14 -1)*0.5 + hhnbr_child14 * 0.3 if hhnbr_adult14>=1
replace eqs= 1+(hhnbr_child14 -1)* 0.3 if hhnbr_adult14<1

gen hystd=hydisp/eqs

gen thresh20=.
gen thresh40=.
gen thresh50=. 
gen thresh60=.
gen thresh70=.
gen thresh90=.
gen thresh120=.
gen c_median=.
gen med120=.
foreach ctry of global countries {
	qui: sum hystd [aw=rb050] if country=="`ctry'", de
	replace thresh20=0.2*r(p50) if country=="`ctry'"
	replace thresh40=0.4*r(p50) if country=="`ctry'" 
	replace thresh50=0.5*r(p50) if country=="`ctry'" 
	replace thresh60=0.6*r(p50) if country=="`ctry'"
	replace thresh70=0.7*r(p50) if country=="`ctry'" 
	replace thresh90=0.9*r(p50) if country=="`ctry'" 
	replace thresh120=1.2*r(p50) if country=="`ctry'"
	replace c_median=r(p50) if country=="`ctry'"
}

foreach ctry of global countries {
qui: sum hy020 [aw=rb050] if country=="`ctry'", de
	replace med120=1.2*r(p50) if country=="`ctry'"
}

gen poor50=.
replace poor50=1 if hystd<thresh50
replace poor50=0 if hystd>=thresh50

gen arop60=.
replace arop60=1 if hystd<thresh60
replace arop60=0 if hystd>=thresh60

gen poor120=.
replace poor120=1 if hystd<thresh120
replace poor120=0 if hystd>=thresh120

gen medinc=. 
replace medinc=7 if hystd<=thresh40
replace medinc=6 if hystd>thresh40 & hystd<=thresh50
replace medinc=5 if hystd>thresh50 & hystd<=thresh60
replace medinc=4 if hystd>thresh60 & hystd<=thresh70
replace medinc=3 if hystd>thresh70 & hystd<=thresh90
replace medinc=2 if hystd>thresh90 & hystd<=thresh120
replace medinc=1 if hystd>thresh120
replace medinc=. if hystd==.
label variable medinc "Income-to-median ratio" 
label define minc 7 "<40%median" 6 "40%-50%median" 5 "50%-60%median" 4 "60%-70%median" 3 "70%-90%median" 2 "90%-120%median" 1 ">120%median", replace 
label values medinc minc

gen relinc=. 
replace relinc=hystd/c_median
label variable relinc "Income-to-median"


***************************
*Material deprivation 2008*
***************************

*Recode variables in such a way that 1 is bad; 0 is good
*New calculation: missings are treated as no deprivation.

*a. arrears-> two variables. x0: 1=1 2=0 _F==-2:0; x1: 1|2=1 3=0 _F==-2:0

forvalues x=1/3 {
	cap drop hs0`x'0b
	gen hs0`x'0b=0
	replace hs0`x'0b=1 if (hs0`x'0==1 | hs0`x'1==1 | hs0`x'1==2) 
}


*b all other variables: 2=1, else 0 (no missings)

local vars 040 050 060 070 080 100 110

foreach x of local vars {
	cap drop hs`x'b
	gen hs`x'b=0
	replace hs`x'b=1 if hs`x'==2
}

cap drop hh050b
gen hh050b=0
replace hh050b=1 if hh050==2

*c. create index

cap drop arrears
gen arrears=0
replace arrears=1 if hs010b==1 | hs020b==1 | hs030b==1


cap drop econstrain
gen econstrain=0
replace econstrain=hh050b + hs040b + hs050b + hs060b + arrears


cap drop lackdurables
gen lackdurables=0
replace lackdurables=hs070b + hs080b + hs100b + hs110b


cap drop deptot
gen deptot=0
replace deptot=econstrain + lackdurables if econstrain!=. & lackdurables!=.

inspect deptot

*d. introduce thresholds

forvalues x=3/5 {
	cap drop dep`x'
	gen dep`x'=0
	replace dep`x'=1 if deptot>=`x'
}


********************
*Jobless households*
********************

*Correction of variables for eu-silc 2009 and newer

if ${year}>=2009 {
	cap drop pl030
	recode pl031 (1 3 = 1)(2 4 = 2)(5 = 3)(6 = 4)(7 = 5)(8 = 6)(9 = 7)(10 = 8)(11 = 9), gen(pl030)

	cap drop pl070
	cap drop pl072
	gen pl070 = pl073 + pl075 /*FT employee + self-employed*/
	gen pl072 = pl074 + pl076 /*PT employee + self-employed*/
}

*create variable with persons to be included in the computation

cap drop jobinclude

gen jobinclude=1
replace jobinclude=0 if age<18 							/* children */
replace jobinclude=0 if age>=18 & age<=24 & pl030==4    /* students in self-defined current economic status */
replace jobinclude=0 if age>=60							/* elderly  */


*grouping age to compute the mean to use in the imputation
cap drop agex

gen agex=.
replace agex=1 if age<25 & jobinclude==1
replace agex=2 if age>=25 & age<50
replace agex=3 if age>=50 & jobinclude==1


* hourx = total hours worked per week as recorded (for full-time workers)
sum pl060            /*nbr of hours usually worked per week in main job*/
sum pl100			 /*total nbr of hours usually worked in second, third, ... jobs*/  

cap drop hourx

gen hourx=.
replace hourx=pl060 if pl060!=. & pl100_f!=1 & jobinclude==1      /*there are no zero pl060*/
replace hourx=pl060 + pl100 if pl060!=. & pl100_f==1 & jobinclude==1


* compute the mean of working hours of those who work part-time at the time of interview and impute missing values
preserve
table agex country [aw=pb040] if (pl030==2 & hourx!=. & hourx<35 & jobinclude==1), c(mean hourx count hourx) by(pb150) replace
gen check=1
count
sort country pb150 agex
save "${place1}\jobimputation.dta", replace        // check place to store data!
restore

cap drop check
gen check=0
replace check=1 if pl030==2 & hourx==. & jobinclude==1
tab country check
replace check=1 if pl072>0 & pl072!=. & pl030!=2 & jobinclude==1
tab country check

table agex country if (check==1), c(count check) by(pb150)

cap drop _merge
cap drop table1
cap drop table2

sort country pb150 agex
merge country pb150 agex using "${place1}\jobimputation.dta", uniqusing // check place to retrieve data!

tab _merge
drop if _merge==2
tab _merge

table agex country if check==1, c(mean hourx count hourx) by(pb150)

* impute in hourx2
cap drop hourx2
gen hourx2=.
replace hourx2=hourx if pl030==2 & hourx!=. & hourx>=1 & jobinclude==1 	/* imputed value = recorded value */
replace hourx2=table1 if pl030!=2 & pl072>0 & pl072!=. & jobinclude==1 	/* imputation if months worked part-time and if not anymore working part time */
replace hourx2=table1 if pl030==2 & hourx==. & jobinclude==1			/* imputation if working part time and no hours recorded */


* houratio contains an estimation of the part-time ratio 
* if estimated working hours >= 35, then part-time estimation ratio =1 *
cap drop houratio
gen houratio=hourx2/35 if jobinclude==1

replace houratio=1 if hourx2>=35 & hourx2!=. & jobinclude==1
replace houratio=1 if hourx2==. & jobinclude==1
replace houratio=1 if houratio==. & jobinclude==1

cap drop nw

if ${year}<2009 {
	egen nw=rowtotal(pl070 pl072 pl080 pl085 pl087 pl090) if jobinclude==1
}
if ${year}>=2009 {
	egen nw=rowtotal(pl073 pl074 pl075 pl076 pl080 pl085 pl086 pl087 pl088 pl089 pl090) if jobinclude==1 /*extra categories ivm 2008*/
}

/* 1) in order to solve the problem of full P-record missing, use hy025 for inflating the number of hours worked
for the other hh members as it is done for income variables */

tabstat hy025, stats(min max mean q) by(country) // in many countries hy025 is equal to 1


cap drop ne1
cap drop ne2

gen ne1=pl070 +(houratio*pl072) if jobinclude==1

gen ne2= hy025*ne1 if hy025!=. & jobinclude==1
replace ne2=ne1 if hy025==. & jobinclude==1


/* 2) in order to solve the problem of missing values in some PL070 to PL090 variables,
use the income variables filled at individual level as auxiliary information 
if income from work > 2 * poverty threshold, then impute with 12 months worked 
else if income from work > poverty threshold, then impute with 6 months worked 
else if income from work > 1/2 poverty threshold, then impute with 3 months worked
else impute with 0 month worked */

cap drop incwork

if ${year}<2008 {
	egen incwork=rowtotal(py010g py020g py050g)
}
if ${year}>=2008 {
	egen incwork=rowtotal(py010g py020g py021g py050g)
	/*origineel is rowtotal(py010g py020g py050g) maar company car slechts vanaf 2008; non-cash income instead*/
}

replace ne2=0 if nw<12 & jobinclude==1 // shouldn't this only be done if ne2 would be completely missing?
replace ne2=12 if incwork>=thresh60*2 & nw<12 & jobinclude==1
replace ne2=6 if incwork>=thresh60 & incwork<thresh60*2 & nw<12 & jobinclude==1
replace ne2=3 if incwork>=thresh60/2 & incwork<thresh60 & nw<12 & jobinclude==1


/* 3) in order to solve the problem of full P-record missing for all working age members of the household,
use the income information at the hh level (disposable hh income without social transfers : EQ_INC22)
if EQ_INC22 > poverty threshold, then impute with 12 months worked 
else if EQ_INC22 > 1/2 poverty threshold, then impute with 6 months worked 
else if EQ_INC22 > 1/4 poverty threshold, then impute with 3 months worked
else impute with 0 month worked */

cap drop eq_inc22
cap drop temp080
cap drop sum_py080

gen temp080=py080g if jobinclude==1 // alternatively: drop condition of jobinclude

bysort country hid: egen sum_py080=sum(temp080)

gen eq_inc22=(hy022+sum_py080)*hy025 / eqs

replace ne2=12 if nw<12 & ne2==0 & jobinclude==1 & eq_inc22>=thresh60
replace ne2=6 if nw<12 & ne2==0 & jobinclude==1 & eq_inc22<thresh60 & eq_inc22>=thresh60/2
replace ne2=3 if nw<12 & ne2==0 & jobinclude==1 & eq_inc22<thresh60/2 & eq_inc22>=thresh60/4

cap drop monthratio

gen monthratio=ne2/12 if jobinclude==1


* compute the household work intensity as the sum, on the WORKING hh members, of the ratio of months worked *
* associate the household work intensity to all members of the household
cap drop hhnbr_wa
cap drop wintensity
cap drop hh_wi

bysort country hid: egen hhnbr_wa=sum(jobinclude)
bysort country hid: egen wintensity=sum(monthratio)

gen hh_wi=.
replace hh_wi=wintensity/hhnbr_wa if hhnbr_wa>=1


* Define cutoff point to sort out households with low work intensity
cap drop jobless

gen jobless=.
replace jobless=. if hhnbr_wa==0 				// exclude households where no one is at working age (jobinclude!=1
replace jobless=1 if hh_wi<=0.2 & hhnbr_wa>=1
replace jobless=0 if hh_wi>0.2 & hhnbr_wa>=1 & hh_wi!=.
replace jobless=. if age>=60 				// exclude elderly totally from calculation

inspect jobless

tab country jobless, row nofreq missing
tab country jobless [aw=rb050], row nofreq
tab country jobless [aw=rb050] if jobless!=999 & jobless!=. & age<60, row nofreq matcell(freq0)

*****************************
*Put the indicators together*
*****************************

cap drop eu2020
gen eu2020=0
replace eu2020=1 if arop60==1 | dep4==1 | jobless==1

ta country eu2020 [iw=rb050], row nofreq


gen WI=. 
replace WI=0 if hh_wi==0 & hhnbr_wa!=0 
replace WI=1 if hh_wi<=0.2 & hh_wi>0 
replace WI=2 if hh_wi<=0.5 & hh_wi>0.2 
replace WI=3 if hh_wi>=0.5 & hh_wi<1 
replace WI=4 if hh_wi==1 
replace WI=. if age>=60

label define wiv 0 "jobless household" 1 "very low work intensity" 2 "low work intensity" ///
						3 "high work intensity" 4 "full time"

label variable WI "Work intensity indicator" 
label values WI wiv 

compress
*Save the data

sort country hid pid 

rename arop60 poor60
keep country hid pid hystd medinc thresh60 thresh120 med120 poor50 poor60 poor120 jobless WI eu2020 c_median relinc 
save EU2020_PSE_ind_ImPRovE.dta, replace 
