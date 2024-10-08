/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Beduk, S. (2018). Missing the unhealthy? Examining empirical validity of material deprivation indices (MDIs) using a partial criterion variable. Social indicators research, 135(1), 91-115.

Author: Selçuk Bedük 

Date of code: 03 February 2018

Purpose: Testing construct validity of items

Inputs: EUSILC2009_Paper4_RPH.dta (from D2_Constructing_indices, using EU SILC 2009; household, register and individual core modules including deprivation module)

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.
See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview
See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896
See for data availability table: https://ec.europa.eu/eurostat/documents/203647/771732/Datasets-availability-table.pdf 

Outputs: 
*/

clear all
set more off
capture log close
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"

use EUSILC2009_Paper4_RPH.dta


gen med=(equinc<c_median) 

tab endsmeet MDfood [aw=RB050], col nof
tab poor120 MDfood [aw=RB050], col nof
tab finstrain MDfood [aw=RB050], col nof

tab endsmeet MDhoc [aw=RB050], col nof
tab poor120 MDhoc [aw=RB050], col nof
tab finstrain MDhoc [aw=RB050], col nof

tab endsmeet MDfuel [aw=RB050], col nof
tab poor120 MDfuel [aw=RB050], col nof
tab finstrain MDfuel [aw=RB050], col nof

tab endsmeet MDclothing [aw=RB050], col nof
tab poor120 MDfuel [aw=RB050], col nof
tab finstrain MDfuel [aw=RB050], col nof

tab endsmeet MDrsf [aw=RB050], col nof
tab poor120 MDrsf [aw=RB050], col nof
tab finstrain MDrsf [aw=RB050], col nof

tab endsmeet MDunmet [aw=RB050], col nof
tab poor120 MDunmet [aw=RB050], col nof
tab finstrain MDunmet [aw=RB050], col nof

tab endsmeet cMDdentist [aw=RB050], col nof
tab poor120 cMDdentist [aw=RB050], col nof
tab finstrain cMDdentist [aw=RB050], col nof

tab endsmeet chbook [aw=RB050], col nof
tab poor120 chbook [aw=RB050], col nof
tab finstrain chbook [aw=RB050], col nof

tab endsmeet chgamesio [aw=RB050], col nof
tab poor120 chgamesio [aw=RB050], col nof
tab finstrain chgamesio [aw=RB050], col nof

tab endsmeet chtrips [aw=RB050], col nof
tab poor120 chtrips [aw=RB050], col nof
tab finstrain chtrips [aw=RB050], col nof

tab endsmeet chworkspace [aw=RB050], col nof
tab poor120 chworkspace [aw=RB050], col nof
tab finstrain chworkspace [aw=RB050], col nof

tab endsmeet MDPC [aw=RB050], col nof
tab poor120 MDPC [aw=RB050], col nof
tab finstrain MDPC [aw=RB050], col nof

tab endsmeet MDnet [aw=RB050], col nof
tab poor120 MDnet [aw=RB050], col nof
tab finstrain MDnet [aw=RB050], col nof

tab endsmeet cMDg_out [aw=RB050], col nof
tab poor120 cMDg_out [aw=RB050], col nof
tab finstrain cMDg_out [aw=RB050], col nof

tab endsmeet MDsmoney [aw=RB050], col nof
tab poor120 MDsmoney [aw=RB050], col nof
tab finstrain MDsmoney [aw=RB050], col nof

tab endsmeet cMDleisure [aw=RB050], col nof
tab poor120 cMDleisure [aw=RB050], col nof
tab finstrain cMDleisure [aw=RB050], col nof

tab endsmeet chceleb [aw=RB050], col nof
tab poor120 chceleb [aw=RB050], col nof
tab finstrain chceleb [aw=RB050], col nof

tab endsmeet cMDholiday [aw=RB050], col nof
tab poor120 cMDholiday [aw=RB050], col nof
tab finstrain cMDholiday [aw=RB050], col nof

tabstat MDfood MDhoc MDfuel MDclothing MDrsf cMDunmet cMDdentist chbook chgamesio chtrips chworkspace MDPC MDnet ///
					cMDg_out MDsmoney cMDleisure chceleb cMDholiday  [aw=RB050], by(country) format(%9.2f)  
