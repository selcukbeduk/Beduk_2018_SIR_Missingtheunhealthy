/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Beduk, S. (2018). Missing the unhealthy? Examining empirical validity of material deprivation indices (MDIs) using a partial criterion variable. Social indicators research, 135(1), 91-115.

Author: Selçuk Bedük 

Date of code: 03 February 2018

Purpose: Comparing deprivation measures

Inputs: EUSILC2009_Paper4_RPH.dta (from D2_Constructing_indices, using EU SILC 2009; household, register and individual core modules including deprivation module)

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.
See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview
See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896
See for data availability table: https://ec.europa.eu/eurostat/documents/203647/771732/Datasets-availability-table.pdf 

Outputs: determinantsofdimensionsmlogit.csv
		comparingmeasures.csv
*/


clear all
set more off
capture log close
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"

use EUSILC2009_Paper4_RPH.dta

gen finst1=(finstrain>0) if finstrain!=.
global vars MDfood MDhoc MDfuel MDclothing MDrsf MDhealthc MDenv MDeducation MDlearning MDinformation MDleisureact MDsocialact
foreach i in $vars {
	tabstat meet2 poor120 finst1 if `i'==1
	}

foreach i in $vars {
	gen `i'a=`i'
	replace `i'a=0 if poor60==0 & finstrain<3 & miss!=1
	}
	
tabstat MDfood MDhoc MDfuel MDclothing MDrsf MDhealthc MDenv MDeducation MDlearning MDinformation MDleisureact MDsocialact [aw=RB050] if miss!=1, by(country) format(%9.2f)  
tabstat MDfooda MDhoca MDfuela MDclothinga MDrsfa MDhealthca MDenva MDeducationa MDlearninga MDinformationa MDleisureacta MDsocialacta [aw=RB050] if miss!=1, by(country) format(%9.2f)  

global dims basic health education social 

foreach i in $dims {
	gen `i'a=`i'
	replace `i'a=0 if poor60==0 & finstrain<3 & miss!=1
	}	

gen onlybasic=(basic==1 & education==0 & social==0 & health==0) 
gen onlysocial=(basic==0 & education==0 & social==1 & health==0) 
gen onlyeducation=(basic==0 & education==1 & social==0 & health==0) 
gen onlyhealth=(basic==0 & education==0 & social==0 & health==1) 
	
gen onlybasica=(basica==1 & educationa==0 & sociala==0 & healtha==0) 
gen onlysociala=(basica==0 & educationa==0 & sociala==1 & healtha==0) 
gen onlyeducationa=(basica==0 & educationa==1 & sociala==0 & healtha==0) 
gen onlyhealtha=(basica==0 & educationa==0 & sociala==0 & healtha==1) 

global only onlybasic onlyhealth onlyeducation onlysocial 
global onlya onlybasica onlyhealtha onlyeducationa onlysociala 
global dimsa basica healtha educationa sociala
	
tabstat $dims $only [aw=RB050] if miss!=1, by(country) format(%9.2f) 
tabstat $dimsa $onlya [aw=RB050] if miss!=1, by(country) format(%9.2f) 	
	

/*
ciplot meet2, by(tbasic) recast(connected) ylabel(0(0.1)1) scheme(s1mono) yline(0.8) name(meetba)

ciplot meet2, by(tsocial) recast(connected) ylabel(0(0.1)1) scheme(s1mono) yline(0.8) name(meetsoc)

ciplot meet2, by(thealth) recast(connected) ylabel(0(0.1)1) scheme(s1mono) yline(0.8) name(meethe)

ciplot meet2, by(teducation) recast(connected) ylabel(0(0.1)1) scheme(s1mono) yline(0.8) name(meetedu)

graph combine meetba meethe meetedu meetsoc

gen finst=(finstrain>0) if finstrain!=.

ciplot finst, by(tbasic) recast(connected) ylabel(0(0.1)1) scheme(s1mono) yline(0.8) name(finba)

ciplot finst, by(tsocial) recast(connected) ylabel(0(0.1)1) scheme(s1mono) yline(0.8) name(finsoc, replace)

ciplot finst, by(thealth) recast(connected) ylabel(0(0.1)1) scheme(s1mono) yline(0.8) name(finhe)

ciplot finst, by(teducation) recast(connected) ylabel(0(0.1)1) scheme(s1mono) yline(0.8) name(finedu)

graph combine finba finsoc finhe finedu

ciplot poor120, by(tbasic) recast(connected) ylabel(0(0.1)1) scheme(s1mono) yline(0.8) name(po12bas)

ciplot poor120, by(tsocial) recast(connected) ylabel(0(0.1)1) scheme(s1mono) yline(0.8) name(po12soc)

ciplot poor120, by(thealth) recast(connected) ylabel(0(0.1)1) scheme(s1mono) yline(0.8) name(po12he)

ciplot poor120, by(teducation) recast(connected) ylabel(0(0.1)1) scheme(s1mono) yline(0.8) name(po12edu)

graph combine po12bas po12he po12edu po12soc
*/


global model4 esec isced hhunemployed tenant hhdisabled hhchronic hhhealth ch02 ch34 ch511 ch1215 singlepar extendedfam divsep female   

misstable summarize neu2020 guio16SMD poor60 jobless endsmeet poor120 finstrain meet MDun_exp MDarrears burhc burdebt
misstable summarize $model4 if HRP==1cop

tabstat neu2020 guio16SMD poor60 jobless endsmeet poor120 finstrain meet MDun_exp MDarrears burhc burdebt if depmiss!=1 & valmiss!=1,  columns(stat) stat(mean sd min max n)
tabstat $model4 if HRP==1 & miss!=1, columns(stat) stat(mean sd min max n)

tabstat deprived guio16MD wm12MD [aw=RB050], format(%9.3f) stat(mean var)

tabstat deprived guio16MD wm12MD [aw=RB050], by(country) format(%9.2f)
tabstat deprived guio16MD wm12MD [aw=RB050], by(country) format(%9.2f) stat(mean var)
tabstat deprivedx neu2020 cwm12MD [aw=RB050], by(country) format(%9.2f)

tetrachoric deprived guio16MD wm12MD

ciplot deprived wm12MD guio16MD deprivedx neu2020 [aw=RB050], by(deptot) recast(connect) scheme(s1mono) 
ciplot codeprived cwm12MD [aw=RB050], by(deptot) recast(connect) scheme(s1mono) 

tabstat basic health education social [aw=RB050], columns(stat) format(%9.3f)
tabstat basic health education social [aw=RB050], by(country) format(%9.2f)

//////////////////////
// //////////////////
/////////////////////
tetrachoric basic health education social poor60 guio16SMD wm12MD


gen bassoc=(basic==1 & education==0 & social==1 & health==0)
gen basedu=(basic==1 & education==1 & social==0 & health==0)
gen bashea=(basic==1 & education==0 & social==0 & health==1)
gen socedu=(basic==0 & education==1 & social==1 & health==0)
gen sochea=(basic==0 & education==0 & social==1 & health==1)
gen eduhea=(basic==0 & education==1 & social==0 & health==1)

gen common=(basic==1 & education==1 & social==1 & health==1)

gen com=(deprived==1 & onlybasic==0 & onlyhealth==0 & onlyeducation==0 & onlysocial==0)

tabstat basic health education social onlybasic onlyhealth onlyedu onlysoc deprived common [aw=RB050], by(country) format(%9.2f)
tabstat basic social education health only* bass base bash socedu sochea eduhea common [aw=RB050], columns(stat) format(%9.3f)
tabstat basic social education health only* bass base bash socedu sochea eduhea common [aw=RB050], columns(stat) format(%9.3f) by(country1)
tabstat basic social education health only* bass base bash socedu sochea eduhea common [aw=RB050] if deprived==1, columns(stat) format(%9.3f)
tabstat basic social education health only* bass base bash socedu sochea eduhea common [aw=RB050] if deprived==1 & depmiss!=1, columns(stat) format(%9.3f)
tabstat basic social education health only* bass base bash socedu sochea eduhea common [aw=RB050] if deprived==1, columns(stat) format(%9.3f) by(country1)

global coun 1 2 3 4 5 6 7 8 9 10 11 12 13 14 16 17 18 19 20 21 23 24 25 26 27 28 29 
global lowcoun 3 5 8 13 17 19 23 25 28
global highcoun 1 2 4 6 7 9 10 11 12 14 16 18 20 21 24 26 27 29 	

foreach ab in $highcoun {
	ciplot equinc if country1==`ab', recast(connect) by(totdep) ylabel(5000(5000)30000) title(`ab') ytitle("") xtitle(, size(small)) note("") legend(rows(1)) scheme(s1mono) name(ix_`ab', replace)
	}
foreach ab in $lowcoun {
	ciplot equinc if country1==`ab', recast(connect) by(totdep) ylabel(0(2000)10000) title(`ab') ytitle("") xtitle(, size(small)) note("") legend(rows(1)) scheme(s1mono) name(ix_`ab', replace)
	}
	
foreach ab in $highcoun {
	ciplot equinc if country1==`ab', recast(connect) by(deptot) ylabel(5000(5000)30000) title(`ab') ytitle("") xtitle(, size(small)) note("") legend(rows(1)) scheme(s1mono) name(ix_`ab', replace)
	}
foreach ab in $lowcoun {
	ciplot equinc if country1==`ab', recast(connect) by(deptot) ylabel(0(2000)10000) title(`ab') ytitle("") xtitle(, size(small)) note("") legend(rows(1)) scheme(s1mono) name(ix_`ab', replace)
	}
	
graph combine ix_3 ix_5 ix_8 ix_13 ix_17 ix_19 ix_23 ix_25 ix_28
graph combine ix_1 ix_2 ix_4 ix_6 ix_7  ix_9 ix_10 ix_11 ix_12  ix_14 ix_16  ix_18  ix_20 ix_21 ix_24 ix_26 ix_27 ix_29

// 
ciplot equinc, by(tbasic) recast(connect) scheme(s1mono) ylabel(0(5000)25000) name(bas, replace)
ciplot equinc, by(tsocial) recast(connect) scheme(s1mono) ylabel(0(5000)25000)  name(soc, replace)
ciplot equinc, by(thealth) recast(connect) scheme(s1mono) ylabel(0(5000)25000) name(hea, replace)
ciplot equinc, by(teducation) recast(connect) scheme(s1mono) ylabel(0(5000)25000)  name(edu, replace)
graph combine bas soc hea edu

// Determinants of dimensions 

global model1 i.esec i.isced i.female i.unemployed i.disability i.chronic i.srhealth i.tenant ib2.marstat i.singlepar i.extendedfam i.ageg 
global model2 i.esec i.isced i.female i.unemployed i.hhdisabled i.hhchronic i.ch34 i.ch511 i.ch1215 i.tenant ib2.marstat i.singlepar i.extendedfam ib3.ageg 
  
// Multinomial - only one deprivation 

global model3 i.esec i.isced log_equinc jobless tenant hhdisabled hhchronic hhhealth ch34 ch511 ch1215 singlepar ib2.marstat ib3.ageg female
global model4 i.esec i.isced hhunemployed tenant hhdisabled hhchronic hhhealth ch02 ch34 ch511 ch1215 singlepar extendedfam divsep female ib3.ageg  

global model5 i.esec i.isced hhunemployed tenant log_equinc hhdisabled hhchronic hhhealth ch02 ch34 ch511 ch1215 singlepar extendedfam divsep female 
//
 gen basdep=0
 replace basdep=1 if basic==1
 replace basdep=2 if basic==0 & deprived==1
 replace basdep=. if depmiss==1
  gen socdep=0
 replace socdep=1 if social==1
 replace socdep=2 if social==0 & deprived==1
 replace socdep=. if depmiss==1
 gen edudep=0
 replace edudep=1 if education==1
 replace edudep=2 if education==0 & deprived==1
 replace edudep=. if depmiss==1
 gen headep=0
 replace headep=1 if health==1
 replace headep=2 if health==0 & deprived==1
 replace headep=. if depmiss==1 
 
 eststo clear 
 eststo: mlogit basdep $model5 i.country1 [pw=RB050] if HRP==1, rrr baseoutcome(2)
 eststo: mlogit socdep $model5 i.country1 [pw=RB050] if HRP==1, rrr baseoutcome(2)
 eststo: mlogit edudep $model5 i.country1 [pw=RB050] if HRP==1, rrr baseoutcome(2)
 eststo: mlogit headep $model5 i.country1 [pw=RB050] if HRP==1, rrr baseoutcome(2)

 esttab using determinantsofdimensionsmlogit.csv, replace eform   ///
	nonumbers mtitle wide compress b(3) se(2) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	
	
 
/////////////	
// Comparing deprivation measures 
//////////////

tab deprived guio16MD if depmiss==0 [aw=RB050], cell nofreq 
tab deprived wm12MD if depmiss==0 [aw=RB050], cell nofreq 

gen depguioag=(deprivedx==1 & guio16MD==1) | (deprivedx==0 & guio16MD==0) if depmiss==0
gen ondep=(deprivedx==1 & guio16MD==0) if depmiss==0
gen onguio=(deprivedx==0 & guio16MD==1) if depmiss==0

gen depwm12MDag=(deprived==1 & wm12MD==1) | (deprived==0 & wm12MD==0) if depmiss==0
gen ondepwm=(deprived==1 & wm12MD==0) if depmiss==0
gen onwmdep=(deprived==0 & wm12MD==1) if depmiss==0

tabstat depguioag ondep onguio [aw=RB050], by(country) format(%9.2f)


// Missed group and the dimensional distribution of their deprivations 

tabstat onlybasic onlyhealth onlyeducation onlysocial [aw=RB050] if deprived==1 & guio16MD==0, column(stat) format(%9.3f)
tabstat onlybasic onlyhealth onlyeducation onlysocial [aw=RB050] if deprived==1 & guio16MD==0, by(country) format(%9.2f)
tabstat onlybasic onlyhealth onlyeducation onlysocial [aw=RB050] if deprived==1 & wm12MD==0, column(stat) format(%9.3f)
tabstat onlybasic onlyhealth onlyeducation onlysocial [aw=RB050] if deprived==1 & wm12MD==0, by(country) format(%9.2f)

// Who are the missed group? 
gen finst=(finstrain>1) if finstrain!=. 
tabstat meet2 finst poor60 jobless poor120  [aw=RB050], columns(stat) format(%9.3f)
tabstat meet2 finst poor60 jobless poor120 if deprived==1 & guio16MD==0 [aw=RB050], columns(stat) format(%9.3f)
tabstat meet2 finst poor60 jobless poor120 if deprived==1 & wm12MD==0 [aw=RB050], columns(stat) format(%9.3f)

tab esec if deprived==1 & guio16MD==0 & HRP==1 [aw=RB050]
tab esec if deprived==1 & wm12MD==0 & HRP==1 [aw=RB050]
tab esec if HRP==1 [aw=RB050]



///////////
// A poverty measure? 
//////////
tabstat deprivedx neu2020 codeprived cwm12MD [aw=RB050], format(%9.3f) by(country1)

gen degu=(deprivedx==1 & neu2020==1) | (deprivedx==0 & neu2020==0) if miss!=1
gen onde=(deprivedx==1 & neu2020==0) if miss!=1
gen ongu=(deprivedx==0 & neu2020==1) if miss!=1

gen depcwm=(codeprived==1 & cwm12MD==1) | (codeprived==0 & cwm12MD==0) if depmiss==0
gen ondew=(codeprived==1 & cwm12MD==0) if depmiss==0
gen onwm=(codeprived==0 & cwm12MD==1) if depmiss==0

tabstat deprivedx neu2020 degu onde ongu codeprived cwm12MD depcwm ondew onwm[aw=RB050], by(country) format(%9.3f) stats(mean var)

tabstat deprivedx neu2020 degu onde ongu [aw=RB050], by(country) format(%9.3f) stat(mean var)

  
// Comparing measures based on social class variation 


eststo clear 
logistic deprivedx i.esec i.country1 [pw=PB040] if HRP==1 & depmiss!=1
eststo depxame: margins, at(esec=(1(1)6))  post
logistic neu2020 i.esec i.country1 [pw=PB040] if HRP==1 & depmiss!=1
eststo neu2020: margins, at(esec=(1(1)6)) post

esttab, cells(b(star fmt(3)) se(par fmt(2))) ///
legend label varlabels(_cons constant)               ///
stats(r2 N, fmt(3 0 1) label(R-sqr N))

	coefplot depxame neu2020 , vertical recast(connected) ciopts(recast(rcap)) title(Comparing measures) ///
		xlabel(`=1' "Salariat" `=2' "Mixed" `=3' "Self" `=4' "LaborI" `=5' "LaborII" `=6' "Excluded") ///
		ylabel(0(0.2)0.6) scheme(s1mono) nooffsets name(mdsc, replace)
	
/*
eststo clear 
logistic deprivedx $model2 i.country1  [pw=RB050] if HRP==1
eststo deprivedx: margins, dydx(*) post 
logistic neu2020 $model2 i.country1 [pw=RB050] if HRP==1
eststo neu2020: margins, dydx(*) post 
logistic cwm12MD $model2 i.country1 [pw=RB050] if HRP==1
eststo cwm12MD: margins, dydx(*) post 

 esttab using comparingmeasures.csv, replace   ///
	nonumbers mtitle wide compress b(3) se(2) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	
*/

eststo clear 
eststo depxodd: logistic deprivedx i.esec i.country1 [pw=PB040] if HRP==1 & depmiss!=1
eststo neuodd: logistic neu2020 i.esec i.country1 [pw=PB040] if HRP==1 & depmiss!=1
eststo wmodd: logistic cwm12MD i.esec i.country1 [pw=PB040] if HRP==1 & depmiss!=1
	
gen incg=0
replace incg=1 if medinc==2 & medinc!=.
replace incg=2 if medinc==1	& medinc!=.
replace incg=. if medinc==.

gen depguio=.
replace depguio=0 if deprivedx==0 & neu2020==0 & miss!=1
replace depguio=1 if deprivedx==1 & neu2020==1 & miss!=1
replace depguio=2 if deprivedx==1 & neu2020==0 & miss!=1
replace depguio=3 if deprivedx==0 & neu2020==1 & miss!=1

gen wdepguio=.
replace wdepguio=0 if deprivedx==0 & wneu2020==0 & miss!=1
replace wdepguio=1 if deprivedx==1 & wneu2020==1 & miss!=1
replace wdepguio=2 if deprivedx==1 & wneu2020==0 & miss!=1
replace wdepguio=3 if deprivedx==0 & wneu2020==1 & miss!=1

gen depwm=.
replace depwm=0 if codeprived==0 & cwm12MD==0 & miss!=1
replace depwm=1 if codeprived==1 & cwm12MD==1 & miss!=1
replace depwm=2 if codeprived==1 & cwm12MD==0 & miss!=1


global model4 i.esec i.isced hhunemployed tenant hhdisabled hhchronic hhhealth ch02 ch34 ch511 ch1215 singlepar extendedfam divsep female ib3.ageg  

eststo clear 	
eststo: mlogit depguio $model4 i.country1 [pw=RB050] if  HRP==1 & miss!=1, rrr baseoutcome(3)
eststo: mlogit wdepguio $model4 i.country1 [pw=RB050] if  HRP==1 & miss!=1, rrr baseoutcome(3)
eststo: mlogit depwm $model4 i.country1 [pw=RB050] if  HRP==1 & miss!=1, rrr baseoutcome(0)


 esttab using comparingmeasures.csv, eform replace   ///
	nonumbers mtitle wide compress b(3) se(2) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	

ciplot deprivedx eu2020 cwm12MD, by(medinc) recast(connect) scheme(s1mono)
ciplot deprivedx eu2020 cwm12MD, by(guiotot) recast(connect) scheme(s1mono)
	
eststo clear 
eststo: logistic deprived $model2 i.country1 [pw=RB050] if HRP==1
eststo: logistic deprivedx $model2 i.country1  [pw=RB050] if HRP==1
eststo: logistic neu2020 $model2 i.country1 [pw=RB050] if HRP==1
eststo: logistic cwm12MD $model2 i.country1 [pw=RB050] if HRP==1

esttab using comparingmeasures.csv, replace eform  ///
	nonumbers mtitle wide compress b(3) se(2) star ///
   legend label varlabels(_cons constant)               ///
    stats(r2 N, fmt(3 0 1) label(R-sqr N))	
	
