/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Beduk, S. (2018). Missing the unhealthy? Examining empirical validity of material deprivation indices (MDIs) using a partial criterion variable. Social indicators research, 135(1), 91-115.

Author: Selçuk Bedük 

Date of code: 03 February 2018

Purpose: Confirmatory factor analysis 

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

rename ch* cMD* MD*, lower

gsem (BASIC-> mdfood mdclothing mdhoc mdfuel mdrsf, latent(BASIC) probit) ///
	(HEALTH-> cmdunmet cmddentist, latent(HEALTH) probit) ///
	(EDUCATION-> chbook chgamesio chtrips chworkspace mdpc mdnet, latent(EDUCATION) probit) ///
	(SOCIAL-> cmdg_out mdsmoney cmdleisure chceleb mdholiday, latent(SOCIAL) probit) ///
	(POVERTY-> BASIC HEALTH EDUCATION SOCIAL, latent(POVERTY))

	
	gsem (BASIC-> mdfood mdclothing mdhoc mdfuel mdrsf, family(bernoulli) link(logit))  ///
	(HEALTH-> cmdunmet cmddentist, family(bernoulli) link(logit)) ///
	(EDUCATION-> chbook chgamesio chtrips chworkspace mdpc mdnet, family(bernoulli) link(logit)) ///
	(SOCIAL-> cmdg_out mdsmoney cmdleisure chceleb mdholiday, family(bernoulli) link(logit)) ///
	(POVERTY-> BASIC HEALTH EDUCATION SOCIAL) if HRP==1 & country1==4, latent(BASIC HEALTH EDUCATION SOCIAL POVERTY) nocapslatent difficult 
	
		gsem (BASIC-> mdfood mdclothing mdhoc mdfuel mdrsf, family(bernoulli) link(logit)) , latent(BASIC) nocapslatent 
