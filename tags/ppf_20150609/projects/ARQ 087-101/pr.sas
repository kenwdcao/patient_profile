%include '_setup.sas';

proc sort data=source.pr(rename=(ID=ID_ SUBID=SUBID_)) out=s_pr(keep=subid_ id_ PRYN); by SUBID_; run;
proc sql;
	create table pr_0(drop=subid) as
	select a.*, b.*
	from s_pr as a left join source.pr1 as b
	on a.subid_=b.subid and a.ID_=b.parent
	;
quit;

proc sort data=pr_0 out=pr_1 nodupkey; by SUBID_ ID;run;

data pr;
	length VISIT PRYN  PRRNUM PRTYPE PRSTDTC PRENDDTC PRPLOC PRDOSE PRBEST DOSE $200;
/*	keep  SUBID VISIT PRYN PRRNUM PRTYPE PRSTDTC PRENDDTC PRPLOC PRDOSE PRBEST PRRNUM_;*/
	set pr_1(rename=(
	SUBID_=SUBID
	PRYN=PRYN_
	PRRNUM=PRRNUM_
	PRTYPE=PRTYPE_
/*	PRSTDTC=PRSTDTC_*/
/*	PRENDDTC=PRENDDTC_*/
	PRPLOC=PRPLOC_
	PRUNIT=PRUNIT_
	PRDOSE=PRDOSE_
	PRBEST=PRBEST_
	));
	if PRYN_^=. then PRYN=strip(put(PRYN_,NOYES.));
	VISIT='Pre-Study';
	if PRRNUM_^=. then PRRNUM=strip(put(PRRNUM_,best.));
	if PRTYPE_=99 and PRTYPESP^='' then PRTYPE='Other: '||strip(PRTYPESP);
		else if PRTYPE_=99 then PRTYPE='Other';
			else if PRTYPE_^=. then PRTYPE=strip(put(PRTYPE_,PRTYPE.));	
/*	if scan(strip(PRSTDTC_),1,'-')='****' and  scan(strip(PRSTDTC_),2,'-')='**' and  scan(strip(PRSTDTC_),3,'-')='**' then PRSTDTC="";*/
/*		else if scan(strip(PRSTDTC_),2,'-')='**' and  scan(strip(PRSTDTC_),3,'-')='**' then PRSTDTC=strip(scan(strip(PRSTDTC_),1,'-'));*/
/*			else if scan(strip(PRSTDTC_),3,'-')='**' then PRSTDTC=strip(substr(strip(PRSTDTC_),1,7));*/
/*				else if index(strip(PRSTDTC_),'*')=0 and PRSTDTC_^='' then PRSTDTC=strip(PRSTDTC_);*/
/*					else PRSTDTC="";*/
/*	if scan(strip(PRENDDTC_),1,'-')='****' and  scan(strip(PRENDDTC_),2,'-')='**' and  scan(strip(PRENDDTC_),3,'-')='**' then PRENDDTC="";*/
/*		else if scan(strip(PRENDDTC_),2,'-')='**' and  scan(strip(PRENDDTC_),3,'-')='**' then PRENDDTC=strip(scan(strip(PRENDDTC_),1,'-'));*/
/*			else if scan(strip(PRENDDTC_),3,'-')='**' then PRENDDTC=strip(substr(strip(PRENDDTC_),1,7));*/
/*				else if index(strip(PRENDDTC_),'*')=0 and PRENDDTC_^='' then PRENDDTC=strip(PRENDDTC_);*/
/*					else PRENDDTC="";*/
	if PRPLOC_=99 and PRPLOCSP^='' then PRPLOC='Other: '||strip(PRPLOCSP);
		else if PRPLOC_=99 then PRPLOC='Other';
			else if PRPLOC_=28 and PRPLOCSP^='' then PRPLOC='Lymph Node(s): '||strip(PRPLOCSP);
				else if PRPLOC_=28 then PRPLOC='Lymph Node(s)';
					else if PRPLOC_^=. then PRPLOC=strip(put(PRPLOC_,SGPLOC.));
	if PRUNIT_^=. then PRUNIT=strip(put(PRUNIT_,PRUNIT.));
/*	if PRDOSE_^=. then PRDOSE=catx(' ',strip(put(PRDOSE_,best.)),PRUNIT);*/
	if PRDOSE_^=.  then DOSE=strip(put(PRDOSE_,best.));
	PRDOSE=catx(' ',DOSE,PRUNIT);
	if PRBEST_^=. then PRBEST=strip(put(PRBEST_,PRBEST.));
	label VISIT='Visit'
		  PRYN='Any Radiotherapy for Indicated Cancer?'
		  PRRNUM='Regimen Number'
		  PRTYPE='Type of Radiotherapy'
		  PRSTDTC='Start Date'
		  PRENDDTC='Stop Date'
		  PRPLOC='Anatomical Location'
		  PRDOSE='Dose'
		  PRBEST='Best Response'
		  ;
run;

proc sort data=pr; by subid PRSTDTC PRRNUM_; run;

data pdata.pr(label='Current Cancer Radiotherapy History');
	retain SUBID /*VISIT*/ PRYN PRRNUM PRTYPE PRSTDTC PRENDDTC PRPLOC PRDOSE PRBEST;
	keep  SUBID /*VISIT*/ PRYN PRRNUM PRTYPE PRSTDTC PRENDDTC PRPLOC PRDOSE PRBEST;
	set pr;
run;

