/********************************************************************************
 Program Nmae: VS.sas
  @Author: Feifei Bai
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/23: Calculate and Add BSA column in the Vital Signs table.
                        Formula: Body Surface Area = 0.20247 x Height(m)exp 0.725 x Weight(kg)exp 0.425

********************************************************************************/
%include '_setup.sas';

proc format;
    value $vstestcd
    'Diastolic Blood Pressure' = 'DBP'
    'Respiratory Rate' = 'RP'
    'Systolic Blood Pressure' = 'SBP'
    'Body Temperature' = 'TEMP'
    'Weight' = 'WEIGHT'
    'Heart Rate' = 'HR'
    'Height' = 'HEIGHT';
run;

data vs;
length vsdtc vsorres $20 vstest $60 vstestcd $8 ; 
    set source.vs;
    %visit;
    %subject;
    vstestcd = put(vstest, $vstestcd.);
    if vsnd = 'Checked' and vsorres = '' then vsorres = 'Not Done';
    if vstest in ('Body Temperature', 'Weight' 'Height') then vsorres = strip(vsorres) || " " || strip(vsorresu);
    else if vstest in ("Diastolic Blood Pressure"  "Heart Rate" "Respiratory Rate" "Systolic Blood Pressure" ) then
    vstest = strip(vstest) || "# (" || strip(vsorresu) || ")";
    vsdtc = put(vsdt, YYMMDD10.);
proc sort; by subject vsdt vsdtc visit2 EDC_TreeNodeID EDC_EntryDate vstestcd;
run; 

proc transpose data = vs out = vs_nm (drop = _name_ _label_);
    by subject vsdt vsdtc visit2 EDC_TreeNodeID EDC_EntryDate; 
    id vstestcd;
    idlabel vstest;
    var vsorres;
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
       set vs_nm (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate)); 
       rc = h.find();
       %concatdy(vsdtc); 
       drop rc;


    ** Ken Cao on 2015/03/23: Derive BSA;
    length bsa __height __weight 8 _bsa __heightu __weightu $10;
    label _bsa = "BSA#0.20247 x (Height&escapechar{super 0.725} x Weight&escapechar{super 0.425})";
    label _bsa = 'BSA';

    if height > ' ' and weight > ' ' then do;
        __height = input(scan(height, 1, ' '), best.);
        __heightu = upcase(scan(height, 2, ' '));
        __weight = input(scan(weight, 1, ' '), best.);
        __weightu = upcase(scan(weight, 2, ' '));
        if __heightu = 'IN'  then __height = __height*2.54/100;
        else __height = __height/100;
        if __weightu = 'LB'  then __weight = __weight * 0.4535924;
        bsa = 0.20247*__height**0.725*__weight**0.425;
        _bsa = strip(put(round(bsa, 0.01), best.));
    end;

run;

data pdata.vs(label='Vital Signs');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 vsdtc temp hr sbp dbp rp weight height _bsa;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 vsdtc temp hr sbp dbp rp weight height _bsa;
    label vsdtc = "Assessment Date";
    set vs2;
run;
