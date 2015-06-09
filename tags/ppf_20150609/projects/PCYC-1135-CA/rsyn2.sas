/*********************************************************************
 Program Nmae: RSYN2.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data rsyn2_1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.rsyn(where=(index(CYCLE, 'FOLLOW')>0));
	%subject;
	%visit2;

run;

proc sort data=rsyn2_1 out=preout; by subject VISIT2; run;

**NOTE: rawdata only provided CYCLE**;

data pdata.rsyn2(label='Response Follow-Up Prompt');
    retain __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 RSYN RSRSNSP;
    keep __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2 RSYN RSRSNSP;
    set preout;
	label RSYN='Will the subject participate in Response Follow-Up?';
	label RSRSNSP='If No, specify reason';
run;


