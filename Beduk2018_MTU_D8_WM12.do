/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2018). Missing the unhealthy? Examining empirical validity of material deprivation indices (MDIs) using a partial criterion variable. Social indicators research, 135(1), 91-115.

Author: Selçuk Bedük 

Date of code: 30 August 2017

Purpose: Analysing mismatch of Whelan and Maitre 2012 with Unmet Health Care Need due to Inadequate resources indicator

Inputs: SILC09_NW11 (from MD_D3_MDindices, using EU SILC 2009; core household, register and personal files and the deprivation module)

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.
See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview
See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896
See for data availability table: https://ec.europa.eu/eurostat/documents/203647/771732/Datasets-availability-table.pdf 

Outputs: 
*/


clear all
set memory 500m
set more off
capture log close
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"

use SILC09_WM12 


gen meetend=.
replace meetend=1 if endsmeet==1 | endsmeet==2 | endsmeet==3
replace meetend=0 if endsmeet==4 | endsmeet==5 | endsmeet==6

gen health_st=.
replace health_st=0 if health==1 | health==2 | health==3
replace health_st=1 if health==4 | health==5

gen bad_health=.
replace bad_health=0 if health==1 | health==2 | health==3 | i_disability==0 | i_chronic==0
replace bad_health=1 if health==4 | health==5 | i_disability==1 | i_chronic==1

keep if age>15

gen r_country=0
replace r_country=1 if country1==7 | country1==11 | country1==15 | country1==21 | country1==22 | country1==27 | country1==26

// Denmark (7), Finland (11), Iceland (15), the Netherlands (21), Norway (22), Slovenia (27), Sweeden (26)

keep if r_country==0 & mis_cases==0 & I_unmet!=. 	// count=357,056

inspect urban hhtype marstat health i_disability i_chronic ecost log_equinc
keep if urban!=. & hhtype!=. & marstat!=. & health!=. & i_disability!=. & i_chronic!=. & ecost!=. & log_equinc!=.  // count=349,438


histogram deptot, normal


// MISMATCH 
tab CWM I_unmet
tab CWM I_unmet [aw=RB050], nofreq cell 
tab CWM I_unmet [aw=RB050], nofreq col

tab CWMO I_unmet
tab CWMO I_unmet [aw=RB050], nofreq cell 
tab CWMO I_unmet [aw=RB050], nofreq col
