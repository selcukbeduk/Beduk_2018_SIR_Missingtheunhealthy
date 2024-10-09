# Beduk_2018_SIR_Missingtheunhealthy
Code repository for replicating 

Bedük, S. (2018). Missing the unhealthy? Examining empirical validity of material deprivation indices (MDIs) using a partial criterion variable. _Social Indicators Research_, 135(1), 91-115. https://doi.org/10.1007/s11205-016-1483-2

The analysis uses data from EU-SILC 2009 including register, household and individual files and deprivation module variables. 

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.

See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview

See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896

To run the code, you need to change the working directory ("cd") and the directories for data source in each do file. The outputs will then be saved to the specified working directory. 

To replicate the whole analysis, you can run the Master Do file (Beduk2018_MTU_DX_Masterfile.do) (after changing relevant directory names), which will call each do file and execute them in order. 

To run the analysis, you will need STATA 14 (or more recent versions).

If you'd have any questions, do not hesitate contact me from selcuk.beduk@spi.ox.ac.uk.
