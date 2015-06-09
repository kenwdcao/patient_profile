/*********************************************************************
 Program Nmae: RSYN1.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data RSYN1_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.RSYN(where=(index(CYCLE, 'FOLLOW')=0));
	%subject;
	%visit2;

	** Assessment Date;
	length rsdtc $20;
	label rsdtc = 'If Yes, provide Visit Date';
	if RSDAT^=. then rsdtc=put(RSDAT,yymmdd10.);else rsdtc="";
	rc = h.find();
	%concatDY(rsdtc);
	drop RSDAT rc;

run;

proc sort data=RSYN1_1 out=preout; by subject rsdtc VISIT2; run;

**NOTE: rawdata only provided CYCLE**;

data pdata.rsyn1(label='Response Evaluation Prompt');
    retain __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 RSYN RSDTC RSRSNSP;
    keep __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 RSYN RSDTC RSRSNSP;
    set preout;
	label RSYN='Was a response evaluation completed at this time point?';
	label RSRSNSP='If No, specify reason';
run;


