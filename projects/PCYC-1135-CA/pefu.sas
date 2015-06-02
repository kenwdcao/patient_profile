/*********************************************************************
 Program Nmae: PEFU.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data pefu1_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.pefu;
	%subject;
	%visit2;

	** Assessment Date;
	length pedtc $20;
	label pedtc = 'Assessment Date';
	if PEDAT^=. then pedtc=put(PEDAT,yymmdd10.);else pedtc="";
	rc = h.find();
	%concatDY(pedtc);
	drop PEDAT rc;

run;

proc sort data=pefu1_1 out=preout; by subject pedtc VISIT2; run;

data pdata.pefu(label='Physical Exam - Follow Up');
    retain __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 PEPERF PEDTC;
    keep __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 PEPERF PEDTC;
    set preout;
	label PEPERF='Are there any new or worsening physical exam findings?';
run;

