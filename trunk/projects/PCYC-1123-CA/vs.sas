/*********************************************************************
 Program Nmae: vs.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/09
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data vs0;
    set source.vs;
	length VSORRES_ $100;
	if VSND ^=.  and VSORRES="" then do;VSORRES_="Not Done";end;
	 else if vstest in ("Heart Rate", "Respiratory Rate", "Systolic Blood Pressure","Diastolic Blood Pressure") then VSORRES_=VSORRES;
	else if vstest in ("Height", "Weight", "Body Temperature") and VSORRES^="" and VSORRESU^="" then 
    VSORRES_=strip(VSORRES) || " " || strip(VSORRESU);
	else VSORRES_=VSORRES;
	%subject;
    %visit2;
	format VSSTAT checked.;
    keep EDC_TreeNodeID SUBJECT visit2 VSSTAT VSTEST VSORRES_ VSORRES VSORRESU VSDT VSND EDC_EntryDate;
run;

proc sort data=vs0; by SUBJECT VSSTAT visit2 VSDT EDC_TreeNodeID EDC_EntryDate;run;

proc transpose data=vs0 out=vs1(rename=(BODY_TEMPERATURE=TEMP  HEART_RATE=HEART RESPIRATORY_RATE=RESP SYSTOLIC_BLOOD_PRESSURE=SYSBP
DIASTOLIC_BLOOD_PRESSURE=DIABP EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE) drop=_NAME_);
by SUBJECT VSSTAT visit2 VSDT EDC_TreeNodeID EDC_EntryDate;
id VSTEST ;
var VSORRES_;
run;

data vs2;
 length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
 set vs1;
   length vsdtc $20;

 if vsdt^=. then vsdtc=put(vsdt,yymmdd10.);else vsdtc="";
  rc = h.find();
    drop rc rfstdtc;
%concatDY(vsdtc);
run;

proc sort data=vs2; by SUBJECT VSDTC  visit2;run;
data pdata.vs(label='Vital Signs');
retain __EDC_TREENODEID __EDC_EntryDate subject visit2 VSSTAT  VSDTC temp heart sysbp diabp resp weight height;
keep  __EDC_TREENODEID  __EDC_EntryDate subject visit2 VSSTAT  VSDTC temp heart sysbp diabp resp weight height;
set vs2;
label
WEIGHT="Weight"
HEIGHT="Height"
HEART="Heart Rate (beats/min)"
RESP="Respiratory Rate (breaths/min)"
TEMP="Body Temperature"
SYSBP="Systolic Blood Pressure (mmHg)"
DIABP="Diastolic Blood Pressure (mmHg)"
VSDTC="Assessment Date"
vsstat = 'Not Done'
;
run;



