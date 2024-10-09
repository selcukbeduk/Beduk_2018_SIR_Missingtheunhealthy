/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2018). Missing the unhealthy? Examining empirical validity of material deprivation indices (MDIs) using a partial criterion variable. Social indicators research, 135(1), 91-115.

Author: Selçuk Bedük 

Date of code: 30 August 2017

Purpose: Estimating MD indices - Guio 2009, Guio Gordon Marlier 2012, Nolan Whelan 2011, Whelan and Maitre 2012 

Inputs: SILC09_H_R_P (from MD_D2_Dataprep, using EU SILC 2009; core household, register and personal files and the deprivation module)

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.
See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview
See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896
See for data availability table: https://ec.europa.eu/eurostat/documents/203647/771732/Datasets-availability-table.pdf 

Outputs: SILC09_G09.dta 
		SILC09_GGM12.dta
		SILC09_NW11.dta 
		SILC09_WM12.dta 		
*/

clear all
set more off
capture log close
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"

use SILC09_R_P_H.dta

///////////////
/* GUIO 2009 */
//////////////

* Dealing with missings

mvdecode MDwarm, mv(-1)

gen mis_cases= (MDarrears==. | MDholiday==. | MDmeat==. | MDun_exp==. | MDtel==. | MDTV==. | MDwash==. | MDcar==. | MDwarm==. )


inspect MDarrears MDholiday MDmeat MDun_exp MDtel MDTV MDwash MDcar MDwarm 
sum MDarrears MDholiday MDmeat MDun_exp MDtel MDTV MDwash MDcar MDwarm 
tetrachoric MDarrears MDholiday MDmeat MDun_exp MDtel MDTV MDwash MDcar MDwarm 
display
alpha MDarrears MDholiday MDmeat MDun_exp MDtel MDTV MDwash MDcar MDwarm

egen deptot= rowtotal(MDarrears MDholiday MDmeat MDun_exp MDtel MDTV MDwash MDcar MDwarm ) if mis_cases!=1


gen MDstat=.
replace MDstat=0 if deptot<3 & deptot>=0 & mis_cases!=1
replace MDstat=1 if deptot>2 & mis_cases!=1
label variable MDstat "Material Deprivation"

gen SMDstat=.
replace SMDstat=0 if deptot<4 & deptot>=0 & mis_cases!=1
replace SMDstat=1 if deptot>3 & mis_cases!=1
label variable SMDstat "Sev. Mat. Deprivation" 

gen CMD=.
replace CMD=0 if (MDstat==0 | poor60==0) & mis_cases!=1
replace CMD=1 if MDstat==1 & poor60==1 & mis_cases!=1
label variable CMD "Consistent Poverty with MD"

gen CSMD=.
replace CSMD=0 if (SMDstat==0 | poor60==0) & mis_cases!=1
replace CSMD=1 if SMDstat==1 & poor60==1 & mis_cases!=1
label variable CSMD "Consistent Poverty with SMD"


save SILC09_G09, replace





//////////////////////////////
/* GUIO GORDON MARLIER 2012 */
//////////////////////////////

clear
use SILC09_R_P_H.dta

* Dealing with missings


gen mis_cases=0
replace mis_cases=1 if MDarrears==. | MDholiday==. | MDmeat==. | MDun_exp==. | MDcar==. | MDwarm ==. ///
						| MDrefurnish==. | MDpc_net==. | MDcloth==. | MDshoes==. | MDg_out==. ///
						| MDleisure==. | MDsmoney==.

inspect MDarrears MDholiday MDmeat MDun_exp MDcar MDwarm MDrefurnish MDpc_net MDcloth MDshoes MDg_out MDleisure MDsmoney
sum MDarrears MDholiday MDmeat MDun_exp MDcar MDwarm MDrefurnish MDpc_net MDcloth MDshoes MDg_out MDleisure MDsmoney if mis_cases != 1
tetrachoric MDarrears MDholiday MDmeat MDun_exp MDcar MDwarm MDrefurnish MDpc_net MDcloth MDshoes MDg_out MDleisure MDsmoney if mis_cases != 1
display
alpha MDarrears MDholiday MDmeat MDun_exp MDcar MDwarm MDrefurnish MDpc_net MDcloth MDshoes MDg_out MDleisure MDsmoney if mis_cases != 1

egen deptot= rowtotal (MDarrears MDholiday MDmeat MDun_exp MDcar MDwarm MDrefurnish MDpc_net MDcloth MDshoes MDg_out MDleisure MDsmoney) if mis_cases!=1

gen MDstat= (deptot>4) if mis_cases!=1
gen SMDstat= (deptot>6) if mis_cases!=1

gen CMD=.
replace CMD=0 if (MDstat==0 | poor60==0) & mis_cases!=1
replace CMD=1 if MDstat==1 & poor60==1 & mis_cases!=1
label variable CMD "Consistent Poverty with MD"

gen CSMD=.
replace CSMD=0 if (SMDstat==0 | poor60==0) & mis_cases!=1
replace CSMD=1 if SMDstat==1 & poor60==1 & mis_cases!=1
label variable CSMD "Consistent Poverty with SMD"

save SILC09_GGM12, replace 





//////////////////////////////
/* NOLAN WHELAN 1996;2011 */
//////////////////////////////

clear 
use SILC09_R_P_H.dta

* Dealing with missings

gen mis_cases=0
replace mis_cases=1 if MDarrears==. | MDholiday==. | MDmeat==. | MDun_exp==. ///
					| MDPC==. | MDcar==. | MDwarm==.

sum MDarrears MDholiday MDmeat MDun_exp MDPC MDcar MDwarm if mis_cases != 1
tetrachoric MDarrears MDholiday MDmeat MDun_exp MDPC MDcar MDwarm  if mis_cases != 1
display
alpha MDarrears MDholiday MDmeat MDun_exp MDPC MDcar MDwarm if mis_cases != 1

egen deptot= rowtotal(MDarrears MDholiday MDmeat MDun_exp MDPC MDcar MDwarm) if mis_cases != 1

gen NW=.
replace NW=0 if deptot<1 & mis_cases!=1
replace NW=1 if deptot>0 & mis_cases!=1

gen MDNW=. 
replace MDNW=0 if deptot<2 & mis_cases!=1
replace MDNW=1 if deptot>1 & mis_cases!=1

gen SMDNW=.
replace SMDNW=0 if deptot<3 & mis_cases!=1
replace SMDNW=1 if deptot>2 & mis_cases!=1 


gen CNW=.
replace CNW=0 if (deptot<1 | poor60==0) & mis_cases != 1
replace CNW=1 if (deptot>0 & poor60==1) & mis_cases != 1

gen CMDNW=.
replace CMDNW=0 if (deptot<2 | poor60==0) & mis_cases != 1
replace CMDNW=1 if (deptot>1 & poor60==1) & mis_cases != 1

gen CSMDNW=.
replace CSMDNW=0 if (deptot<3 | poor60==0) & mis_cases != 1
replace CSMDNW=1 if (deptot>2 & poor60==1) & mis_cases != 1

save SILC09_NW11, replace 






//////////////////////////////
/* WHELAN MAITRE 2012 */
//////////////////////////////

clear
use SILC09_R_P_H.dta

* Dealing with missings

gen mis_cases=0
replace mis_cases=1 if MDholiday==-1 | MDmeat==-1 | MDwarm==-1 | MDrefurnish==-1 | MDcloth==-1 | MDshoes==-1 | MDg_out==-1 /// 
				| MDleisure==-1 | MDsmoney==-1  
						
sum MDholiday MDmeat MDwarm MDrefurnish MDcloth MDshoes MDg_out MDleisure MDsmoney if mis_cases != 1
tetrachoric MDholiday MDmeat MDwarm MDrefurnish MDcloth MDshoes MDg_out MDleisure MDsmoney if mis_cases != 1
display
alpha MDholiday MDmeat MDwarm MDrefurnish MDcloth MDshoes MDg_out MDleisure MDsmoney if mis_cases != 1

egen deptot= rowtotal(MDholiday MDmeat MDwarm MDrefurnish MDcloth MDshoes MDg_out MDleisure MDsmoney) if mis_cases != 1

gen WM=.
replace WM=0 if deptot<2 & mis_cases!=1
replace WM=1 if deptot>1 & mis_cases!=1

gen WMO=.
replace WMO=0 if deptot<3 & mis_cases!=1
replace WMO=1 if deptot>2 & mis_cases!=1

gen CWM=.
replace CWM=0 if (deptot<2 | poor60==0) & mis_cases != 1
replace CWM=1 if (deptot>1 & poor60==1) & mis_cases != 1

gen CWMO=.
replace CWMO=0 if (deptot<3 | poor60==0) & mis_cases != 1
replace CWMO=1 if (deptot>2 & poor60==1) & mis_cases != 1

save SILC09_WM12, replace 
