%include '_setup.sas';

proc sort data=source.ps(rename=(ID=ID_ SUBID=SUBID_)) out=s_ps(keep=subid_ id_ PSYN); by SUBID_; run;
proc sql;
	create table ps_0(drop=subid) as
	select a.*, b.*
	from s_ps as a left join source.ps1 as b
	on a.subid_=b.subid and a.ID_=b.parent
	;
quit;

proc sort data=ps_0 out=ps_1 nodupkey; by SUBID_ ID;run;

data ps;
	length VISIT PSYN  PSREG PSTYPE PSSTDTC PSENDDTC  PSDOSE PSUNIT PSROUTE PSFREQ PSBRES PSPGDTC $200;
	keep  SUBID VISIT PSYN PSREG PSNAME PSTYPE PSSTDTC PSENDDTC PSDOSE PSUNIT PSROUTE PSFREQ PSBRES PSPGDTC PSREG_;
	set ps_1(rename=(
	SUBID_=SUBID
	PSYN=PSYN_
	PSREG=PSREG_
	PSTYPE=PSTYPE_
/*	PSSTDTC=PSSTDTC_*/
/*	PSENDDTC=PSENDDTC_*/
	PSUNIT=PSUNIT_
	PSDOSE=PSDOSE_
	PSROUTE=PSROUTE_
	PSFREQ=PSFREQ_
	PSBRES=PSBRES_
/*	PSPGDTC=PSPGDTC_*/
	));
	if PSYN_^=. then PSYN=strip(put(PSYN_,NOYES.));
	VISIT='Pre-Study';
	if PSREG_^=. then PSREG=strip(put(PSREG_,best.));
	PSNAME=strip(PSNAME);
	if PSTYPE_=99 and PSTYPESP^='' then PSTYPE='Other: '||strip(PSTYPESP);
		else if PSTYPE_=99 then PSTYPE='Other';
			else if PSTYPE_^=. then PSTYPE=strip(put(PSTYPE_,PSTYPE.));	
/*	if scan(strip(PSSTDTC_),1,'-')='****' and  scan(strip(PSSTDTC_),2,'-')='**' and  scan(strip(PSSTDTC_),3,'-')='**' then PSSTDTC="";*/
/*		else if scan(strip(PSSTDTC_),2,'-')='**' and  scan(strip(PSSTDTC_),3,'-')='**' then PSSTDTC=strip(scan(strip(PSSTDTC_),1,'-'));*/
/*			else if scan(strip(PSSTDTC_),3,'-')='**' then PSSTDTC=strip(substr(strip(PSSTDTC_),1,7));*/
/*				else if index(strip(PSSTDTC_),'*')=0 and PSSTDTC_^='' then PSSTDTC=strip(PSSTDTC_);*/
/*					else PSSTDTC="";*/
/*	if scan(strip(PSENDDTC_),1,'-')='****' and  scan(strip(PSENDDTC_),2,'-')='**' and  scan(strip(PSENDDTC_),3,'-')='**' then PSENDDTC="";*/
/*		else if scan(strip(PSENDDTC_),2,'-')='**' and  scan(strip(PSENDDTC_),3,'-')='**' then PSENDDTC=strip(scan(strip(PSENDDTC_),1,'-'));*/
/*			else if scan(strip(PSENDDTC_),3,'-')='**' then PSENDDTC=strip(substr(strip(PSENDDTC_),1,7));*/
/*				else if index(strip(PSENDDTC_),'*')=0 and PSENDDTC_^='' then PSENDDTC=strip(PSENDDTC_);*/
/*					else PSENDDTC="";*/
	if PSUNIT_=99 and PSUNITSP^='' then PSUNIT='Other: '||strip(PSUNITSP);
		else if PSUNIT_=99 then PSUNIT='Other';
			else if PSUNIT_^=. then PSUNIT=strip(put(PSUNIT_,PSUNIT.));	
	if PSDOSE_^=. then PSDOSE=strip(put(PSDOSE_,best.));
	if PSROUTE_=99 and PSROUTSP^='' then PSROUTE='Other: '||strip(PSROUTSP);
		else if PSROUTE_=99 then PSROUTE='Other';
			else if PSROUTE_^=. then PSROUTE=strip(put(PSROUTE_,CMROUTE.));	
	if PSFREQ_=99 and PSFREQSP^='' then PSFREQ='Other: '||strip(PSFREQSP);
		else if PSFREQ_=99 then PSFREQ='Other';
			else if PSFREQ_^=. then PSFREQ=strip(put(PSFREQ_,PSFREQ.));	
	if PSBRES_^=. then PSBRES=strip(put(PSBRES_,PRBEST.));
/*	if scan(strip(PSPGDTC_),1,'-')='****' and  scan(strip(PSPGDTC_),2,'-')='**' and  scan(strip(PSPGDTC_),3,'-')='**' then PSPGDTC="";*/
/*		else if scan(strip(PSPGDTC_),2,'-')='**' and  scan(strip(PSPGDTC_),3,'-')='**' then PSPGDTC=strip(scan(strip(PSPGDTC_),1,'-'));*/
/*			else if scan(strip(PSPGDTC_),3,'-')='**' then PSPGDTC=strip(substr(strip(PSPGDTC_),1,7));*/
/*				else if index(strip(PSPGDTC_),'*')=0 and PSPGDTC_^='' then PSPGDTC=strip(PSPGDTC_);*/
/*					else PSPGDTC="";*/
	label VISIT='Visit'
		  PSYN='Prior Systemic Therapy for Indicated Cancer?'
		  PSREG='Regimen Number'
		  PSNAME='Drug Name'
		  PSTYPE='Type of Therapy'
		  PSSTDTC='Start Date'
		  PSENDDTC='Stop Date'
		  PSDOSE='Dose'
		  PSUNIT='Units'
		  PSROUTE='Route'
		  PSFREQ='Frequency'
		  PSBRES='Best Response'
		  PSPGDTC='Date of Progression'
		  ;
run;

proc sort data=ps; by subid PSSTDTC PSREG_ PSNAME; run;

data pdata.ps(label='Current Cancer Systemic Therapy History');
	retain SUBID /*VISIT*/ PSYN PSREG PSNAME PSTYPE PSSTDTC PSENDDTC PSDOSE PSUNIT PSROUTE PSFREQ PSBRES PSPGDTC;
	keep  SUBID /*VISIT*/ PSYN PSREG PSNAME PSTYPE PSSTDTC PSENDDTC PSDOSE PSUNIT PSROUTE PSFREQ PSBRES PSPGDTC;
	set ps;
run;

