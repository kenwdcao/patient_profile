
%include '_setup.sas';


* ---> Appendix 3: Reference Range of Chemistry and Hematology of Lab Results;
data pdata.lbrange(label='Appendix 3: Reference Range of Chemistry and Hematology of Lab Results');
	retain SUBJECTNUMBERSTR LBCAT A_VISITMNEMONIC TEST1 unit LAB LOW HIGH; 
	keep  SUBJECTNUMBERSTR LBCAT A_VISITMNEMONIC TEST1 unit LAB LOW HIGH;  
	set pdata.hemidx pdata.chemidx pdata.chemothidx;
run;
