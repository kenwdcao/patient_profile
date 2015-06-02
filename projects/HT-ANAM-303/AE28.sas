
%include '_setup.sas';

*<AE--------------------------------------------------------------------------------------------------------;
%macro concatDT(var=, dts1=, dts2=,newvar=);
if &var >'' and cmiss(&dts1,&dts2)<2 then &newvar= strip(scan(&var,1,','))||': '||strip(&dts1)||'/ '||strip(&dts2);
else if &var >'' then &newvar=&var;
%mend concatDT;

%getdy(indata=source.RD_FRMAE_SCTAEENTRY_ACTIVE,outdata=RD_FRMAE_SCTAEENTRY_ACTIVE,vars=ITMAESTARTDT_DTS);
%getdy(indata=RD_FRMAE_SCTAEENTRY_ACTIVE,outdata=RD_FRMAE,vars=ITMAESTOPDTRES_DTS);
%getdy(indata=RD_FRMAE,outdata=RD_FRMAE_,vars=ITMAESTOPDTRESWSEQ_DTS);


data ae0;
	set RD_FRMAE_(rename=(ITMAERELCHEM=_ITMAERELCHEM  ITMAETRT_ITMAETRTOTH=_ITMAETRT_ITMAETRTOTH
ITMAEOUT=_ITMAEOUT ITMAESEQNUM=_ITMAESEQNUM));
	%adjustvalue(dsetlabel=Adverse Events);
/*	%formatDate(ITMAESTARTDT_DTS);*/
/*	%formatDate(ITMAESTOPDTRES_DTS);*/
/*	 %formatDate(ITMAESTOPDTRESWSEQ_DTS);*/
	 %formatDate(ITMAEINTLASTDT_DTS);
	%formatDate(ITMAEINTRESDT_DTS);
	*-> Modify Variable Label;
	attrib

 	ITMAESEQNUM          		label='AE#Number'
	ITMAEEVENT           		label='Adverse Event'
	ITMAESTARTDT_DTS       		label='Onset Date*'
	ITMAEOUT             		label='End Date/Outcome*'
	ITMAESEV             		label='Severity'
	ITMAEREL             		label='Relationship to Study Drug'
	ITMAERELCHEM         		label='Relationship to Chemotherapy'
	ITMAEACN            length=$200     label='Action Taken'
	ITMAEACNOTH   		length=$200   	label='Treatment required'
	ITMAESER_    		length=$40    	label='Serious AE?'
	ITMAEEQFIRSTDOSE     		label='AE Begin before or after first dose'
	;

	ITMAESEQNUM=ifc(_ITMAESEQNUM=.,'',put(_ITMAESEQNUM,best.));
	if ITMAERELCHEMSPC ^='' then ITMAERELCHEM=ITMAERELCHEMSPC;
	else ITMAERELCHEM= _ITMAERELCHEM;
	%concatSPE(var=_ITMAETRT_ITMAETRTOTH, spe=ITMAETRTOTH, newvar=ITMAETRT_ITMAETRTOTH);
	%concatDT(var=ITMAEACN_ITMAEINTCI, dts1=ITMAEINTLASTDT_DTS , dts2=ITMAEINTRESDT_DTS,newvar=ITMAEACN_ITMAEINTCI_);
	
	if ITMAESTOPDTRES ^=. then ITMAEOUT=strip(scan(_ITMAEOUT,1,','))||': '||ITMAESTOPDTRES_DTS;
	else if ITMAESTOPDTRESWSEQ ^=. then ITMAEOUT=strip(scan(_ITMAEOUT,1,','))||': '||ITMAESTOPDTRESWSEQ_DTS;
	else if index(_ITMAEOUT,'(') >0 then ITMAEOUT=strip(scan(_ITMAEOUT,1,'('));
	else ITMAEOUT=_ITMAEOUT;

	ITMAEACN=catx(', ',ITMAEACN_CITMACNDSNOCHNG,ITMAEACN_CITMACNDRUGWITH,ITMAEACN_ITMAEINTCI_);

	if ITMAESER="No" then ITMAESER_="No";
	else if ITMAESER ^='' then ITMAESER_="Yes";

	if ITMAETRT_CITMHOSREQ ^='' then ITMAETRT_CITMHOSREQ=strip(scan(ITMAETRT_CITMHOSREQ,1,'('));
	if ITMAETRT_CITMMEDTAKE^='' then ITMAETRT_CITMMEDTAKE=strip(scan(ITMAETRT_CITMMEDTAKE,1,'('));
	ITMAETRT_CITMNONE=strip(ITMAETRT_CITMNONE);
	ITMAEACNOTH=catx(', ',ITMAETRT_CITMNONE,ITMAETRT_CITMMEDTAKE,ITMAETRT_CITMHOSREQ,ITMAETRT_ITMAETRTOTH);

	if ITMAEEVENT ^='';
run;

data ae01;
	length SUBJECTNUMBERSTR $20 fdosedt 8 __label $300;
	if _n_=1 then do;
		declare hash h (dataset:'pdata.firstdose');
		rc=h.defineKey('SUBJECTNUMBERSTR');
		rc=h.defineData('fdosedt');
		rc=h.defineDone();
		call missing(SUBJECTNUMBERSTR, fdosedt);
	end;
	set ae0;
	rc=h.find();
		if fdosedt^=. then __label="Adverse Events !{newline 2}!{style[fontsize=7pt foreground=green] *: (DY) is calculated as: Date - First Dose Date+1 if Date is on or after First Dose Date;"
||" Date - First Dose Date if Date precedes First Dose Date}";
		else __label="Adverse Events";
run;

data pdata.ae28(label='Adverse Events');
    retain  &globalvars3  __label ITMAESEQNUM ITMAEEVENT ITMAESTARTDT_DTS ITMAEOUT ITMAESEV ITMAEREL ITMAERELCHEM ITMAEACN ITMAEACNOTH ITMAESER_ ITMAEEQFIRSTDOSE;
	keep    &globalvars3  __label ITMAESEQNUM ITMAEEVENT ITMAESTARTDT_DTS ITMAEOUT ITMAESEV ITMAEREL ITMAERELCHEM ITMAEACN ITMAEACNOTH ITMAESER_ ITMAEEQFIRSTDOSE;
	set ae01;
run;
