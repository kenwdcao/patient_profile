/*********************************************************************
 Program Nmae: EG.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data eg1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.eg;
	%subject;
	%visit2;
	** Assessment Date;
	length egdtc $20;
	label egdtc = 'Assessment Date';
	if egdat^=. then egdtc=put(egdat,yymmdd10.);else egdtc="";
	rc = h.find();
	%concatDY(egdtc);
	drop egdat rc;

    ** Assessment Time;
	length egtmc $10;
	label egtmc = 'Assessment Time';

	if EGTIM ^=. then egtmc=put(EGTIM, time5.); else egtmc="";
/*	if EGTIMUNK ^= '' then egtmc = 'Unknown';*/
/*	drop EGTIM EGTIMUNK; */
	drop EGTIM; 

    ** QTc/Ventricular Rate/RR Interval/PR Interval/QRS Interval;
	label QTC = 'QTc Result (msec)';
	label VENTRATE = 'Ventricular Rate (beats/min)';
	label RR = 'RR Interval (msec)';
	label PR = 'PR Interval (msec)';
	label QRS = 'QRS Interval (msec)';

	length QTC VENTRATE RR PR QRS $20;
	if EGQTC eq '' and EGQTCND ne '' then QTC = 'Not Reported'; else
		if EGQTC ne '' and EGQTCND eq '' then QTC = strip( EGQTC);
	if EGVT eq '' and EGVTND ne '' then VENTRATE = 'Not Reported'; else
		if EGVT ne '' and EGVTND eq '' then VENTRATE = strip( EGVT);
	if EGRR eq '' and EGRRND ne '' then RR = 'Not Reported'; else
		if EGRR ne '' and EGRRND eq '' then RR = strip( EGRR);
	if EGPR eq '' and EGPRND ne '' then PR = 'Not Reported'; else
		if EGPR ne '' and EGPRND eq '' then PR = strip( EGPR);
	if EGQRS eq '' and EGQRSND ne '' then QRS = 'Not Reported'; else
		if EGQRS ne '' and EGQRSND eq '' then QRS = strip( EGQRS);

    ** QTc Formula (specify);
	length EGQTCFRO $200;
	label EGQTCFRO = 'QTc Formula';
	if upcase( EGQTCFR) eq 'OTHER' then EGQTCFRO = catx(': ', EGQTCFR, EGQTCFSP); else
		if upcase( EGQTCFR) ne 'OTHER' then EGQTCFRO = strip( EGQTCFR);
run;

proc sort data = eg1; by subject egdtc egtmc visit2 EGSEQ; run;

data pdata.eg(label='Electrocardiogram');
    retain __EDC_TREENODEID __EDC_ENTRYDATE EGSEQ SUBJECT VISIT2 EGDTC EGTMC EGTIMUNK QTC EGQTCFRO
		VENTRATE RR PR QRS EGFIND EGFINDSP;
    keep __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT EGSEQ VISIT2 EGDTC EGTMC EGTIMUNK QTC EGQTCFRO
		VENTRATE RR PR QRS EGFIND EGFINDSP;
	rename EGSEQ = __EGSEQ;
    set eg1;
	label EGFIND = 'Were there clinically significant abnormalities?';
	label EGFINDSP = 'If Yes, please specify';
	label EGTIMUNK = 'Time Unknown';
run;

