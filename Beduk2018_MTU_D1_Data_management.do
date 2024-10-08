/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Beduk, S. (2018). Missing the unhealthy? Examining empirical validity of material deprivation indices (MDIs) using a partial criterion variable. Social indicators research, 135(1), 91-115.

Author: Selçuk Bedük 

Date of code: 03 February 2018

Purpose: Constructing data and relevant variables 

Inputs: EU SILC 2009; household, register and individual core modules including deprivation module 

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.
See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview
See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896
See for data availability table: https://ec.europa.eu/eurostat/documents/203647/771732/Datasets-availability-table.pdf 

Outputs: SILC09_R_P_H.dta 
*/


clear all
set more off
capture log close
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"


* Taking variables (e.g. hid) from Register file  

use RB010 RB020 RB030 RX030 RB050 RB080 RB090 RB220_F RB230_F RB240_F RB245 RB250 RX* using "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\EUSILC09_personal_register"
rename RB010 year
rename RB020 country 
rename RB030 pid 

encode country, gen(country1)

* Keeping only EU27 countries 

label variable RB080 "Year of birth"
rename RX020 age
replace age=year-RB080-1 if age==. 

label variable RX040 "Work intensity" 
label variable RX050 "Low work intensity" 
label variable RX060 "Severely materially deprived household" 
label variable RX070 "At risk of poverty or social exclusion" 

gen ageg=. 
replace ageg=1 if age>=0 & age<15
replace ageg=2 if age>14 & age<25
replace ageg=3 if age>24 & age<45
replace ageg=4 if age>44 & age<65
replace ageg=5 if age>64 & age<80
replace ageg=6 if age>=80

tab ageg, m

label define ag 1 "0-14" 2 "15-24" 3 "25-44" 4 "45-64" 5 "65-80" 6 "80+", replace 
label values ageg ag

gen agegr=.
replace agegr=1 if age>=0 & age<15
replace agegr=2 if age>14 & age<25
replace agegr=3 if age>24 & age<45
replace agegr=4 if age>44 & age<65
replace agegr=5 if age>64 

label define age 1 "0-14" 2 "15-24" 3 "25-44" 4 "45-64" 5 "65+", replace 
label values agegr age


labe variable RB090 "Gender" 
recode RB090 (2=1) (1=0), gen(female) 
rename RX030 hid
label variable RB245 "Respondent status" 

bysort country hid: egen hhsize=count(pid) // creating household size 
gen old=0
replace old=1 if age>64
bysort country hid: egen old_H=sum(old), m 

* OPTIONAL keep if RB245<4 	// Keeping respondents that are eligible and have contacted 
* OPTIONAL keep if RB250==11 | RB250== 12 | RB250==13 | RB250==14		// Keeping respondents that have complete information from a type of interview 

gen child= (age<16)
bysort country hid: egen nchild=sum(child), m
gen nadult=hhsize-nchild

sort year country pid
save SILC09_R.dta, replace 




clear 
use PB020 PB030 PB040 PB060 PB140 PB190 PD010-PD070_F PE040 PH010-PH070_F PL015 PL020-PL025_F PL031 PL031_F PL040 PL050 PL060 PL060_F PX* ///
	PL073-PL076_F PL080 PL080_F PL085-PL090_F PL100 PL100_F PL120 PL120_F PL130 PL140 PL150 PL190 PL200 using "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\EUSILC09_personal"
	
describe 
rename PL031 eco_status 
label define ecost 1 "ES Full-time" 2 "ES Part-time" 3 "ES Self-employed FT" 4 "ES Self-employed PT" 5 "ES Unemployed" ///
	6 "ES Student/trainee" 7 "ES Retired" 8 "ES Disabled" 9 "ES Compulsory service" 10 "ES Domestic unpaid work" 11 "ES Other inactive"
label values eco_status ecost

recode PD010 (2=1) (1 3=0), into(mobtel)
label variable mobtel "Mobile phone"


label variable PX050 "Activity status"
label define act 1 "EMP/TOT > 0.5" 2 "UNP/TOT > 0.5" 3 "RET/TOT > 0.5" 4 "OIN/TOT > 0.5"
label values PX050 act 

label variable PX040 "Respondent status"
label define resp 1 "cur HH member 16+" 2 "selected resp 16+" 3 "non-selected resp 16+"
label values PX040 resp

label variable PX030 "Household ID" 
label variable PX010 "Currency exchange rate" 

 
rename PX020 age
rename PB020 country 
rename PB030 pid
sort country pid

save SILC09_P.dta ,replace 


use SILC09_R.dta
merge 1:1 country pid using SILC09_P.dta
tab _merge
save SILC09_R_P.dta, replace




* Recoding module items

recode PD020 PD030 PD050 PD060 PD070 (1 3 = 0) (2 = 1), pre(n_) test

rename n_PD020 cloth
label variable cloth "Replace worn-out clothes by some new ones"

rename n_PD030 shoes
label variable shoes "Having two pairs of shoes"

rename n_PD050 g_out
label variable g_out "Meeting with friends/relatives at least twice a month"

rename n_PD060 leisure
label variable leisure "Participating ordinary leisure activities"

rename n_PD070 smoney
label variable smoney "Having little spare money every week"

 
bysort country hid: egen t_cloth = sum(cloth), m

list hid pid cloth t_cloth in 1/100000 if t_cloth==., display

bysort country hid: egen t_shoes = sum(shoes), m
bysort country hid: egen t_g_out = sum(g_out), m
bysort country hid: egen t_leisure = sum(leisure), m
bysort country hid: egen t_smoney = sum(smoney), m

// household is deprived if someone in the household is deprived of cloth - this choice is made for two reasons: 
// 1. In some countries (register countries), this information are only collected for the household reference person, so we do not have info for all adults and using for example
// half of the sample size as a threshold would not be feasible in this case 
// 2. Children is also included into the household size but they have separate questions ( not for smoney) 

gen MDcloth= (t_cloth>0) if t_cloth!=. 
gen MDshoes= (t_shoes>0) if t_shoes!=. 
gen MDg_out= (t_g_out>0) if t_g_out!=. 
gen MDleisure= (t_leisure>0) if t_leisure!=. 
gen MDsmoney= (t_smoney>0) if t_smoney!=. 

tab PH040_F PH050_F
tab country PH040_F, row nofreq m
tab country PH050_F, row nofreq m 

gen unmet= (PH040==1 & PH050==1)
replace unmet=. if PH040_F==-1 | PH050_F==-1
bysort country hid: egen tunmet=sum(unmet), m
tab country tunmet, row nofreq m  
gen MDunmet=(tunmet>0) if tunmet!=. // Having cost-related unmet need for healthcare - if any of the members is deprived of healthcare

gen dentist= (PH060==1 & PH070==1)
replace dentist=. if PH060_F==-1 | PH070_F==-1
bysort country hid: egen tdentist=sum(dentist), m
tab country tdentist, row nofreq m   
gen MDdentist=(tdentist>0) if tdentist!=. // Having cost-related unmet need for dental care - if any of the members is deprived of dental care 

save SILC09_R_P.dta, replace 
// Reconstruct health indicators - self-rated health, chronic health conditions and disability - to be used as validity indicators 


clear 
use HB010 HB020 HB030 HB070 HB080-HB090_F HD010 HD020 HD020_F HD025 HD025_F HS010-HS190 HH010-HH030_F HH040-HH050_F HH070-HH080_F HH081 HH081_F HH090-HH091_F ///
	HD030 HD030_F HD040-HD070_F HD080 HD090 HD100-HD265_F HY020 HY070G HY070G_F HY070G_I HY070N HY070N_F HY070N_I HX* ///
	using "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\EUSILC09_household"
describe
rename HB010 year
rename HB020 country 

encode country, gen(country1)

// Deprivation items 

renvars HB030 HB070 HH010 HH020 HH030 HH040 HH070 HY070G HH080 HH081 HH090 HH091 HS160 \ hid resp dw_type tenure nrooms lroof tothcost h_allow bathx bathy toiletx toilety dark
sort year country hid

* Binary deprivation items

recode HD010 HH050 HS040-HS060 (2 = 1) (1 = 0), pre(n_) test
recode HD080 HD090 HS070-HS110 (2 = 1) (1 3 = 0), pre(n_) test

renvars n_HS060 n_HS040 n_HS050 n_HH050 n_HS100 n_HS080  n_HS070 n_HS110 n_HS090 n_HD080 n_HD090 \ MDun_exp MDholiday MDmeat MDwarm MDwash MDTV MDtel MDcar MDPC MDrefurnish MDnet

gen MDpc_net=(MDPC==1 & MDnet==1) if MDPC!=. & MDnet!=. 

gen MDroof=(lroof==1) if lroof!=. 
recode HD010 (1=0) (2=1), into(MDwater)
gen MDbath=(bathx==2 | bathy==3) if (HH080_F!=-1 | HH081_F!=-1)
gen MDtoilet=(toiletx==2 | toilety==3) if (HH090_F!=-1 | HH091_F!=-1)
gen MDbtw=(MDwater==1 | MDbath==1 | MDtoilet==1) if (MDwater!=. & MDtoilet!=. & MDbath!=.)
gen MDbt=(MDbath==1 | MDtoilet==1) if (MDtoilet!=. & MDbath!=.)

gen MDspace=(HD030==1) if HD030_F!=-1
gen MDdark=(dark==1) if HS160_F!=-1
gen MDevict=(HD025==3 | HD025==4) if HD025_F!=-1

gen MDrsd=(MDroof==1 & MDdark==1 & MDspace==1) if MDroof!=. & MDdark!=. & MDspace!=.

// Creating arrears 

gen MDmortgage=. 
replace MDmortgage=0 if HS010==2 | HS010_F==-2 | HS011==3 | HS011_F==-2
replace MDmortgage=1 if HS010==1 | HS011==1 | HS011==2

gen MDutility=.
replace MDutility=0 if HS020==2 | HS020_F==-2 | HS021==3 | HS021_F==-2
replace MDutility=1 if HS020==1 | HS021==1 | HS021==2
replace MDutility=0 if HS020_F==-1 & country1==29

gen MDloan=. 
replace MDloan=0 if HS030==2 | HS030_F==-2 | HS031==3 | HS031_F==-2
replace MDloan=1 if HS030==1 | HS031==1 | HS031==2
replace MDloan=0 if HS030_F==-1 & country1==29

gen MDarrears=.
replace MDarrears=0 if MDmortgage==0 & MDutility==0 & MDloan==0 
replace MDarrears=1 if MDmortgage==1 | MDutility==1 | MDloan==1


// Financial strain index - Validity index proposed by Whelan and Maitre 2012

rename HS120 endsmeet 
label variable endsmeet "Subj. Income inadequacy"
gen meet=(endsmeet<3) if endsmeet!=.
gen meet2=(endsmeet<4) if endsmeet!=.

gen burhc= (HS140<2) 
replace burhc=. if HS140_F==-1
label variable burhc "Heavy burden of housing cost" 

gen burdebt= (HS150==1)
replace burdebt=. if HS150_F==-1
label variable burdebt "Heavy burden of debt" 

egen finstrain=rsum(MDarrears MDun_exp meet burhc burdebt)
replace finstrain=. if MDarrears==. | MDun_exp==. | burhc==. | burdebt==. | meet==.  

// Child deprivation indicators 

gen chcloth=(HD100==2) if HD100_F!=-1

gen chshoes=(HD110==2) if HD110_F!=-1

gen chfruit=(HD120==2) if HD120_F!=-1

gen chthmeals=(HD130==2) if HD130_F!=-1

gen chmeat=(HD140==2) if HD140_F!=-1

gen chbooks=(HD150==2) if HD150_F!=-1

gen chtoys=(HD160==2) if HD160_F!=-1

gen chgames=(HD170==2) if HD170_F!=-1

gen chleisure=(HD180==2) if HD180_F!=-1

gen chceleb=(HD190==2) if HD190_F!=-1

gen chg_out=(HD200==2) if HD200_F!=-1

gen chtrips=(HD210==2) if HD210_F!=-1

gen chworkspace=(HD220==2) if HD220_F!=-1

gen chholiday=(HD240==2) if HD240_F!=-1

gen chunmet=(HD250==1 & HD255==1) if HD250_F!=-1 | HD255_F!=-1

gen chdentist=(HD260==1 & HD265==1) if HD260_F!=-1 | HD265_F!=-1

tabstat ch* 
egen chtot=rsum(ch*), m
gen cht=(chtot>0 & chtot!=.)

sort country hid
save SILC09_H.dta, replace 

* Merging all 

use SILC09_R_P.dta 
drop _merge
merge m:1 year country hid using SILC09_H.dta
keep if _merge==3
drop _merge
sort country hid pid
save SILC09_R_P_H.dta, replace 

merge 1:1 country hid pid using EU2020_PSE_ind_ImPRovE.dta
tab _merge
drop _merge

gen log_equinc=log(hystd) if !missing(hystd)

// 

// Household responsible person from the accommodation HRP

tab HB080_F HB090_F
replace HB080=HB090 if HB080_F==-1 & HB090_F==1

gen HRP=0
replace HRP=1 if HB080==pid
replace HRP=. if HB080_F==-1 & (HB090_F==-1 | HB090_F==-2)

//

tab MDcloth chcloth, cell nofreq m 
tab MDshoes chshoes, cell nofreq m 
tab MDunmet chunmet, cell nofreq m 
tab endsmeet if MDcloth==0 & chcloth==1
tab endsmeet if MDcloth==1 & chcloth==0
tab endsmeet if MDcloth==1 & chcloth==1

** Household is deprived if a child is deprived
gen cMDcloth=(MDcloth==1 | chcloth==1) 
gen cMDshoes=(MDshoes==1 | chshoes==1) 
gen cMDmeat=(MDmeat==1 | chmeat==1) 
gen cMDleisure=(MDleisure==1 | chleisure==1) 
gen cMDg_out=(MDg_out==1 | chg_out==1)
gen cMDholiday=(MDholiday==1 | chholiday==1)
gen cMDunmet=(MDunmet==1 | chunmet==1) 
gen cMDdentist=(MDdentist==1 | chdentist==1) 

tetrachoric chfruit chthmeals chbooks chtoys chgames chceleb chtrips chworkspace
gen chgamesio=(chtoys==1 | chgames==1) & (chtoys!=. & chgames!=.)

*** INCOME 
 
rename HY020 h_income
inspect h_income
gen eq_scale=sqrt(hhsize) // OECD equivalence scale - square root 
label variable eq_scale "OECD square root equivalence scale"
gen equinc=h_income/eq_scale
label variable equinc "Equivalized income"

gen poor60120=(medinc>1 & medinc<5) if medinc!=.

* Labeling 

label variable HX090 "Equivalized Disposable HH Income"
label variable HX080 "Relative income poverty status"
label variable HX040 "Household size"
label variable HX050 "Equivalized household size" 
label variable HX070 "Tenure status"
label variable HX120 "Overcrowded household" 
label variable HX010 "Change rate" 

label variable old_H "HH # of 65+ members" 
label variable equinc "HH disposable income" 
label variable log_equinc "Log_Equiv.HHIncome" 
label variable poor120 "120% of Median HH Income"
label variable poor60 "Inc.Poverty(60%med)"

gen hhtype=HX060
label variable hhtype "Household type"
label variable HX060 "Household type"

rename PB190 marstat
label variable marstat "Marital status"

recode eco_st (3=1) (4=2) (5=3) (6=4) (7=5) (8=6) (9=1) (10=7) (11=8), into(ecost)
label variable ecost "Economic status - 8"
label define ecosta 1 "ES Full-time" 2 "ES Part-time" 3 "ES Unemployed" 4 "ES Student/trainee" 5 "ES Retired" ///
	6 "ES Disabled" 7 "ES Domestic unpaid work" 8 "ES Other inactive", replace 
label values ecost ecosta 

gen student=(ecost==4) if ecost!=. 
gen domestic=(ecost==7) if ecost!=. 

label define htyp 5 "Single person" 6 "2adults_<65 no child" 7 "2adults_65+ no child" 8 "Others no child" 9 "Single parent" ///
	10 "2 adults 1 child" 11 "2 adults 2 child" 12 "2 adults 3+ child" 13 "Extended family" 16 "Other", replace
label values hhtype htyp

recode hhtype (5=1) (6/7=2) (8=3) (9=4) (10/12=5) (13=6) (16=7), into(htype)
label variable htype "Household type"
label define htp 1 "Single person" 2 "2 adults no child" 3 "Others no child" 4 "Single parent" 5 "2 adults with children" ///
	6 "Extended family" 7 "Other"
label values htype htp 

gen singlehh=(htype==1) if htype!=. 

label define mar 1 "Never married" 2 "Married" 3 "Separated" 4 "Widowed" 5 "Divorced"
label values marstat mar 

gen divorced=(marstat==5) if marstat!=. 
gen seperated=(marstat==3) if marstat!=. 
gen divsep=(divorced==1 | seperated==1) if divorced!=. & seperated!=.
recode hhsize (5/20=5), into(h_size) 
label define hs 1 "1" 2 "2" 3 "3" 4 "4" 5 "5+"
label values h_size hs 
label variable h_size "Household size" 

gen ich02=(age<3) & age!=.
gen ich34=(age<5 & age>2) & age!=. 
gen ich511=(age>4 & age<12) & age!=.
gen ich1215=(age>11 & age<16) & age!=.
gen ich1618=(age>15 & age<19) & age!=.

gen tenant=(tenure==2 | tenure==3) if tenure!=. 

gen unemployed= (ecost==3) & ecost!=. 

recode PE040 (4 5 6 = 1) (3 = 2) (2 1 0 = 3), gen(isced)
label variable isced "Highest education level" 
label define edu 1 "Third level" 2 "Upper 2ndary" 3 "Low2nd/Primary/Pre", replace
label values isced edu

gen extendedfam=(hhtype==13) if hhtype!=.
gen singlepar=(hhtype==9) if hhtype!=. 
gen threech=(nchild>2) if nchild!=. 


// Creating ESEC from ISCO 88 
recode PL130 (15=11) (14=10), into(firmsize)

gen empst=. 
replace empst=1 if PL040==1 & firmsize>10
replace empst=2 if PL040==1 & firmsize<11
replace empst=3 if PL040==2
replace empst=4 if PL040==3 & PL150==1
replace empst=5 if PL040==3 & PL150==2 

label define em 1 "Employer-large" 2 "Employer-small" 3 "Self-employed-noemp" 4 "Supervisors" 5 "Other employees" 
label values empst em

recode PL050 (1/7 11 12 21/24 31 32 = 1) (8/10 33 34 41 = 2) (13 61 = 3) (42 51 52 = 4) (71 72 73 74 81/83 91/93 = 5), into(esec) 

replace esec=1 if empst==1

foreach x in 12 13 33 40 41 42 51 52 71 72 73 74 81 82 83 91 92 93 {
	replace esec=3 if PL050==`x' & (empst==2 | empst==3)
}

foreach y in 11 12 13 21 22 23 24 31 32 33 34 41 {
	replace esec=1 if empst==4 & PL050==`y' 
}

foreach z in 42 51 52 61 71 72 73 74 81 82 83 91 92 93 { 
	replace esec=2 if empst==4 & PL050==`z'
} 

replace esec=6 if PL015==2 & esec==.

tab esec

label variable esec "Social Class ESEC 5"
label define es 1 "Salariat" 2 "Inter. employee" 3 "Small self-emp." 4 "Lowe white collar" 5 "Manual" 6 "Never worked", replace 
label values esec es 

// Jobless
drop jobless
recode RX050 (2=0), into(jobless)
label variable jobless "Low  work intensity" 

// Health 
rename PH010 srhealth 
recode PH020 (2 8 = 0), into(chronic)
recode PH030 (2 = 1) (3 8 = 0), into(disability)
gen healthst=(srhealth>3) if srhealth!=. 

// Household variables 
egen hhdi= total(disability), by(country hid) m
gen hhdisabled=(hhdi>0) if hhdi!=.
 
egen hhch= total(chronic), by(country hid) m
gen hhchronic=(hhch>0) if hhch!=. 

egen hhhe=total(healthst), by(country hid) m
gen hhhealth=(hhhe>0) if hhhe!=. 

egen thc02=total(ich02), by(country hid) m
gen ch02=(thc02>0) if thc02!=.

egen tch34=total(ich34), by(country hid)  m
gen ch34=(tch34>0) if tch34!=.

egen tch511=total(ich511) , by(country hid) m 
gen ch511=(tch511>0) if tch511!=.

egen tch1215=total(ich1215), by(country hid) m 
gen ch1215=(tch1215>0) if tch1215!=.

egen tch1618=total(ich1618), by(country hid)  m 
gen ch1618=(tch1618>0) if tch1618!=.

egen tstudent=total(student), by(country hid)  m
gen hhstudent=(tstudent>0) if tstudent!=. 
 
egen tdomestic=total(domestic), by(country hid) m
gen hhdomestic=(tdomestic>0) if tdomestic!=. 

egen tune=total(unemployed), by(country hid) m
gen hhunemployed=(tune>0) if tune!=. 


// MISSING 
misstable summarize MD* ch*

global durables MDtel MDTV MDPC MDwas MDcar MDpc_net
global finance MDun_exp MDarrears 
global child chfruit chthmeals chbooks chtoys chgames chceleb chtrips chworkspace
global basic MDshoes MDcloth MDunmet MDdentist MDwarm
global social MDg_out MDleisure MDsmoney MDholiday MDrefurnish


gen missa=.
foreach x in $durables $finance $child $basic $social { 
	replace missa=(`x'==.)
	}
tab country missa, row nofreq m 
misstable summarize MD* ch* if country1==26
misstable summarize MD* ch* if country1==20

drop if country1==15 | country1==22  // Iceland and Norway - Non-EU
drop if country1==26 | country1==20 // Sweeden 40% missing & Malta has problems in ESEC 


save SILC09_R_P_H.dta, replace 



