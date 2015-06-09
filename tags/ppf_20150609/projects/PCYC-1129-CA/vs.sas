/*********************************************************************
 Program Nmae: VS.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data vs0;
    set source.vs;
	length VSORRES_ $100;
	if VSND ^=''  and VSORRES="" then do;VSORRES_="Not Done";end;
	 else if vstest in ("Heart Rate", "Respiratory Rate", "Systolic Blood Pressure","Diastolic Blood Pressure") then VSORRES_=VSORRES;
	else if vstest in ("Height", "Weight", "Body Temperature") and VSORRES^="" and VSORRESU^="" then 
    VSORRES_=strip(VSORRES) || " " || strip(VSORRESU);
	else VSORRES_=VSORRES;
	%subject;
    %visit2;
	vsnd=ifc(vsnd^='' ,put(vsnd,$checked.),'');
run;

proc sort data=vs0; by subject visit2 vsdt edc_treenodeid edc_entrydate;run;

proc transpose data=vs0 out=vs1(rename=(body_temperature=temp  heart_rate=heart respiratory_rate=resp systolic_blood_pressure=sysbp
        diastolic_blood_pressure=diabp edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate) drop=_name_);
       by subject  visit2 vsdt edc_treenodeid edc_entrydate;
       id vstest ;
       var vsorres_;
run;

data vs2;
 length subject $13 __rfstdtc $10 vsdtc $20;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
    set vs1;

  label VSdtc = 'Assessment Date';
    %ndt2cdt(ndt=VSdt, cdt=VSdtc);
    rc = h.find();
   %concatDY(vsdtc);
run;

proc sort data=vs2; by SUBJECT VSDTC  visit2;run;

data pdata.vs(label='Vital Signs, Height, and Weight');
         retain __EDC_TREENODEID __EDC_EntryDate subject visit2 VSDTC  temp heart sysbp diabp resp weight height;
         keep  __EDC_TREENODEID  __EDC_EntryDate subject visit2 VSDTC  temp heart sysbp diabp resp weight height;
        set vs2;
        label
       WEIGHT="Weight"
	   HEIGHT="Height"
       HEART="Heart Rate (beats/min)"
       RESP="Respiratory Rate (breaths/min)"
       TEMP="Body Temperature"
       SYSBP="Systolic Blood Pressure (mmHg)"
       DIABP="Diastolic Blood Pressure (mmHg)"
       VSDTC="Assessment Date";
run;



