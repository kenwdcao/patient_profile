%include '_setup.sas';

proc sort data=source.pcs(rename=(ID=ID_ SUBID=SUBID_)) out=s_pcs(keep=subid_ id_ PCSYN); by SUBID_; run;
proc sql;
	create table pcs_0(drop=subid) as
	select a.*, b.*
	from s_pcs as a left join source.pcs1 as b
	on a.subid_=b.subid and a.ID_=b.parent
	;
quit;

proc sort data=pcs_0 out=pcs_1 nodupkey; by SUBID_ ID;run;

data pcs;
	length VISIT PCSYN SGPCDTC SGPLOC $200 SGTYPE $200;
	keep  SUBID VISIT PCSYN SURGPROC SGPCDTC SGPLOC SGTYPE;
	set pcs_1(rename=(
	SUBID_=SUBID
	PCSYN=PCSYN_
/*	SGPCDTC=SGPCDTC_*/
	SGPLOC=SGPLOC_
	));
	if PCSYN_^=. then PCSYN=strip(put(PCSYN_,NOYES.));
	VISIT='Pre-Study';
	SURGPROC=strip(SURGPROC);
/*	if scan(strip(SGPCDTC_),1,'-')='****' and  scan(strip(SGPCDTC_),2,'-')='**' and  scan(strip(SGPCDTC_),3,'-')='**' then SGPCDTC="";*/
/*		else if scan(strip(SGPCDTC_),2,'-')='**' and  scan(strip(SGPCDTC_),3,'-')='**' then SGPCDTC=strip(scan(strip(SGPCDTC_),1,'-'));*/
/*			else if scan(strip(SGPCDTC_),3,'-')='**' then SGPCDTC=strip(substr(strip(SGPCDTC_),1,7));*/
/*				else if index(strip(SGPCDTC_),'*')=0 and SGPCDTC_^='' then SGPCDTC=strip(SGPCDTC_);*/
/*					else SGPCDTC="";*/

	if SGPLOC_=99 and SGPLOCSP^='' then SGPLOC='Other: '||strip(SGPLOCSP);
		else if SGPLOC_=99 then SGPLOC='Other';
			else if SGPLOC_=28 and SGPLOCSP^='' then SGPLOC='Lymph Node(s): '||strip(SGPLOCSP);
				else if SGPLOC_=28 then SGPLOC='Lymph Node(s)';
					else if SGPLOC_^=. then SGPLOC=strip(put(SGPLOC_,SGPLOC.));
	if SGDIAG=1 then SGTYPE='Diagnostic ';
		else if SGTHER=1 then SGTYPE='Therapeutic';
	label VISIT='Visit'
		  PCSYN='Any Surgeries/Procedures for Indicated Cancer?'
		  SURGPROC='Surgery/Procedure Name'
		  SGPCDTC='Procedure Date'
		  SGPLOC='Anatomical Location'
		  SGTYPE='Type of Surgery/Procedure'
		  ;
run;

proc sort data=pcs; by subid SGPCDTC SURGPROC; run;

data pdata.pcs(label='Current Cancer Surgery History');
	retain SUBID /*VISIT*/ PCSYN SURGPROC SGPCDTC SGPLOC SGTYPE;
	keep  SUBID /*VISIT*/ PCSYN SURGPROC SGPCDTC SGPLOC SGTYPE;
	set pcs;
run;

