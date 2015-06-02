/*
    Program Name: VS.sas
    @Author: Xiu Pan
    @Initial Date: 2015/01/30

    Revision History:
    Ken Cao on 2015/02/05: Transpose Vital Signs Test
                           Add VSSTAT in final dataset
    Ken Cao on 2015/02/06: Combine VSND into VSORRES
    BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
    Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
    Ken Cao on 2015/03/05: Concatenate --DY to VSDTC.
*/

%include '_setup.sas';

proc format;
    value $vnum
    'Screening' = '200000'
    'Day 1' = '200001'
    'Day 2' = '200002'
    'Day 8' = '200008'
    'Week 5' = '200050'
    'Week 9' = '200090'
    'Week 13' = '200130'
    'Week 17' = '200170'
    'Week 21' = '200210'
    'Week 25' = '200250'
    'Week 29' = '200290'
    'Week 33' = '200370'
    'Week 37' = '200410'
    'Week 41' = '200450'
    'Week 45' = '200045'
    'Week 49' = '200049'
    'Week 53' = '200053'
    'Week 57' = '200057'
    'Week 61' = '200061'
    'Week 65' = '200065'
    'Week 69' = '200069'
    'Week 73' = '200071'
    'Week 77' = '200077'
    'Suspected PD / Early Termination 1' = '299999.1'
    'Suspected PD / Early Termination 2' = '299999.2'
    'End of Treatment' = '300000'
    'Unscheduled Assessments 1' = '900000.1'
    'Unscheduled Assessments 2' = '900000.2'
    'Unscheduled Assessments 3' = '900000.3'
    'Unscheduled Assessments 4' = '900000.4'
    'Unscheduled Assessments 5' = '900000.5'
    'Unscheduled Assessments 6' = '900000.6'
    /* Ken Cao on 2015/02/20: Add two new items */
    'Unscheduled Assessments 7' = '900000.7'
    'Unscheduled Assessments 8' = '900000.8'
    ;

run;

data vs;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.vs(rename=(visit=visit_ vstest=in_vstest EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate));
    length vsdtc $20;
    %ndt2cdt(ndt=vsdt, cdt=vsdtc);
    %subject;

    rc = h.find();
    %concatDY(vsdtc);
    drop rc;

   if pdseq^=. then visitnum=input(put(strip(visit_)||''||strip(put(pdseq,best.)),$vnum.),best.);
        else if unsseq^=. then visitnum=input(put(strip(visit_)||''||strip(put(unsseq,best.)),$vnum.),best.);
            else visitnum=input(put(visit_,$vnum.),best.);
    if pdseq^=. then visit=strip(visit_)||''||strip(put(pdseq,best.));
        else if unsseq^=. then visit=strip(visit_)||''||strip(put(unsseq,best.));
            else visit=strip(visit_);

    if vsorres^='' and vsorresu^='' then orres=strip(vsorres)||' '||strip(vsorresu);
        else if vsorres^='' and vsorresu='' then orres=strip(vsorres);

    length vstest $40;
    vstest = strip(in_vstest);

    vsstat = put(vsstat, $checked.);
    keep subject visit vstest vsorres vsorresu vsnd vsdt vsdtc vsstat orres vsstat __EDC_TreeNodeID __EDC_EntryDate;
run;

proc sort data=vs; by subject vsdt vstest __EDC_TreeNodeID;run;


** Ken Cao on 2015/02/05: Transpose Vital Signs Test;
proc format;
    value $vstestcd
    'Diastolic Blood Pressure' = 'DBP'
    'Pulse' = 'PULSE'
    'Respiratory Rate' = 'RP'
    'Systolic Blood Pressure' = 'SBP'
    'Temperature' = 'TEMP';
run;

data vs2;
    set vs;
    label
    orres='Result (Unit)'
    vsdtc='Assessment Date'
    visit='Visit'
    ;
    length vstestcd $8;
    vstestcd = put(vstest, $vstestcd.);

    if vstestcd ^= 'TEMP' then orres = vsorres;

    ** Ken Cao on 2015/02/06: Combine VSND into VSORRES;
    if vsnd > ' ' then orres = 'Not Done';
    
    ** concatenate unit with test;
    if vstest = 'Diastolic Blood Pressure' then vstest = 'Diastolic Blood Pressure#(mmHg)';
    else if vstest = 'Pulse' then vstest = 'Pulse#(beats/min)';
    else if vstest = 'Respiratory Rate' then vstest = 'Respiratory Rate#(breaths/min)';
    else if vstest = 'Systolic Blood Pressure' then vstest = 'Systolic Blood Pressure#(mmHg)';

run;

proc sort data = vs2; by subject vsdtc visit vsstat __EDC_TreeNodeID; run;

proc transpose data = vs2 out = t_vs;
    by subject vsdtc visit vsstat __EDC_TreeNodeID __EDC_EntryDate;
    id vstestcd;
    idlabel vstest;
    var orres;
run;

data pdata.vs(label='Vital Signs');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit vsdtc vsstat temp pulse sbp dbp rp ;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit vsdtc vsstat temp pulse sbp dbp rp;
    set t_vs;
run;
