%INCLUDE "_setup.sas";

*<AE--------------------------------------------------------------------------------------------------------;
data ae0;
set source.ae(rename=(AESEQ=_AESEQ));

	attrib
 	SUBJID    label='Unique Subject Identifier' 
	AESEQ       label='Sequence#Number'
	AETOXGRC    label='Standard Toxicity Grade'    length=$100
	AESER_      label='Serious Event'            length=$10
	AEOUT       label='Outcome'
	AESTDTC     label='Start Date#(Study Day)'
	AEENDTC     label='End Date#(Study Day)'
	AEPATT      label='Pattern'
	AETOXGRC    label='Toxicity'
	AETERM      label='Reported Term'
	AEENRF      label='End Reference'
	AEACN       label='Action Taken with Study Treatment'
	AEACNOTH    label='Action Taken#for AE'
	;

	AESEQ=ifc(_AESEQ^=. ,put(_AESEQ,best.),'');
	AEENRF=propcase(strip(AEENRF));
	AEPATT=propcase(strip(AEPATT));
	AEREL=propcase(strip(AEREL));
	AEACN=propcase(strip(AEACN));
	if AEACNSP ^='' then AEACNOTH=propcase(strip(AEACNOTH))||": "||strip(AEACNSP);
		else AEACNOTH=propcase(strip(AEACNOTH));
	if strip(AESER)='Y' then AESER_='Yes';
		else if strip(AESER)='N' then AESER_='No';
	AEOUT=propcase(strip(AEOUT));
	if length(strip(AEENDTC))=10 then AEENDTC=strip(AEENDTC)||"("|| strip(ifc(AEENDY=.,'',put(AEENDY,best.)))||")";
	if length(strip(AESTDTC))=10 then AESTDTC=strip(AESTDTC)||"(" || strip(ifc(AESTDY=.,'',put(AESTDY,best.)))||")";

	AETOXGRC =put(AETOXGR,aetoxgr.);
	*Ken on 2013/05/07: ;
	AETOXGRC = scan(AETOXGRC,2,":");
	IF AETERM ^ = '';
run;

data pdata.ae(label='Adverse Event');
    retain  SUBJID AESEQ AETERM AEDECOD AEBODSYS AESTDTC AEENDTC AEENRF AEPATT AETOXGRC AEREL AEACN AEACNOTH AESER_ AEOUT;
	keep  SUBJID AESEQ AETERM AEDECOD AEBODSYS AESTDTC AEENDTC AEENRF AEPATT AETOXGRC AEREL AEACN AEACNOTH AESER_ AEOUT;
	set ae0;
run;


data ae1;
set source.ae(rename=(AESEQ=_AESEQ));
attrib
 	SUBJID       label='Unique Subject Identifier' 
	AESEQ        label='Sequence#Number'
	AESCONG_     label='Congenital Anomaly'  length=$6    
	AESDISAB_    label='Significant Disability' length=$6 
	AESDTH_      label='Results in Death'  length=$6     
	AESHOSP_     label='Hospitalization or#Prolonged Hospitalization'  length=$6 
	AESLIFE_     label='Life Threatening'  length=$6  
	AESMIE_      label='Medically Significant in the Opinion of the Investigator' length=$6 
	AETERM       label='Reported Term' 

	;
	if strip(AESCONG)='N'  then AESCONG_='';
	if strip(AESCONG)='Y'  then AESCONG_='Yes';

	if strip(AESDISAB)='N'  then AESDISAB_='';
	if strip(AESDISAB)='Y'  then AESDISAB_='Yes';

	if strip(AESDTH)='N'  then AESDTH_='';
	if strip(AESDTH)='Y'  then AESDTH_='Yes';

	if strip(AESHOSP)='N'  then AESHOSP_='';
	if strip(AESHOSP)='Y'  then AESHOSP_='Yes';

	if strip(AESLIFE)='N'  then AESLIFE_='';
	if strip(AESLIFE)='Y'  then AESLIFE_='Yes';

	if strip(AESMIE)='N'  then AESMIE_='';
	if strip(AESMIE)='Y'  then AESMIE_='Yes';

	AESEQ=ifc(_AESEQ^=. ,put(_AESEQ,best.),'');
/*	AESCONG_=put(AESCONG, $yn.);*/
/*	AESDISAB_=put(AESDISAB,$yn.);*/
/*	AESDTH_=put(AESDTH,$yn.);*/
/*	AESHOSP_=put(AESHOSP,$yn.);*/
/*	AESLIFE_=put(AESLIFE,$yn.);*/
/*	AESMIE_=put(AESMIE,$yn.);*/
	
	IF AETERM ^='' and cmiss(AESCONG_, AESDISAB_, AESDTH_, AESHOSP_, AESLIFE_, AESMIE_)<6;
run;

data pdata.sae(label='Serious Adverse Event');
    retain  SUBJID AESEQ AETERM AESCONG_ AESDISAB_ AESDTH_ AESHOSP_ AESLIFE_ AESMIE_;
	keep  SUBJID AESEQ AETERM AESCONG_ AESDISAB_ AESDTH_ AESHOSP_ AESLIFE_ AESMIE_;
	set ae1;
run;
