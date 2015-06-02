/*********************************************************************
 Program Name: LB.sas
  @Author: Yan Zhang
  @Initial Date: 2015/02/02
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/05: Concatenate --DY to LBDTC.
 Ken Cao on 2015/03/11: Display "standard" unit and range for each 
                        subject in the first two records.

*********************************************************************/
%include "_setup.sas";
proc format;
    value $temp
    'ALK PHOS#MCG/L' = 'CHEMISTRY#ENZYMES#Alkaline Phosphatase#ALP# #SERUM#0'
    'BANDS#K/UL' = 'HEMATOLOGY# #Neutrophils Band Form/Leukocytes#NEUTBLE#%#BLOOD#1'
    'HEMATOCRIT#FRACTION' = 'HEMATOLOGY# #Hematocrit#HCT#fraction#BLOOD#1'
    'HEMATOCRIT#L/L' = 'HEMATOLOGY# #Hematocrit#HCT#fraction#BLOOD#1'
    'PLATELETS#10E3/MCL' = 'HEMATOLOGY# #Platelets#PLAT#10^9/L#BLOOD#1'
    'PLATELETS#K/MM^3' = 'HEMATOLOGY# #Platelets#PLAT#10^9/L#BLOOD#1'
    'PLATELETS#K /MCL' = 'HEMATOLOGY# #Platelets#PLAT#10^9/L#BLOOD#1'
    'RBC#10E6/MCL' = 'HEMATOLOGY# #Erythrocytes#RBC#10^12/L#BLOOD#1'
    'RBC#M /MCL' = 'HEMATOLOGY# #Erythrocytes#RBC#10^12/L#BLOOD#1'
    'RBC#M/MM^3' = 'HEMATOLOGY# #Erythrocytes#RBC#10^12/L#BLOOD#1'
    'RBC#M/ MCL' = 'HEMATOLOGY# #Erythrocytes#RBC#10^12/L#BLOOD#1'
    'WBC#10E3/MCL' = 'HEMATOLOGY# #Leukocytes#WBC#10^9/L#BLOOD#1'
    'WBC#K/MM^3' = 'HEMATOLOGY# #Leukocytes#WBC#10^9/L#BLOOD#1'
    'WBC#10^3/MM^3' = 'HEMATOLOGY# #Leukocytes#WBC#10^9/L#BLOOD#1'
    'WBC#K / MCL' = 'HEMATOLOGY# #Leukocytes#WBC#10^9/L#BLOOD#1'
    'RBC#10^6/MM^3' = 'HEMATOLOGY# #Erythrocytes#RBC#10^12/L#BLOOD#1'
    'PLATELETS#10^3/MM^3' = 'HEMATOLOGY# #Platelets#PLAT#10^9/L#BLOOD#1'
    'PLATELETS#K / MCL' = 'HEMATOLOGY# #Platelets#PLAT#10^9/L#BLOOD#1'
    'ALK PHOS#UKAT/L' = 'CHEMISTRY#ENZYMES#Alkaline Phosphatase#ALP#U/L#SERUM#59.988'
    'ALT (SGPT)#UKAT/L' = 'CHEMISTRY#ENZYMES#Alanine Aminotransferase#ALT#U/L#SERUM#59.988'
    'AST (SGOT)#UKAT/L' = 'CHEMISTRY#ENZYMES#Aspartate Aminotransferase#AST#U/L#SERUM#59.988'
    'LDH#UKAT/L' = 'CHEMISTRY#ENZYMES#Lactate Dehydrogenase#LDH#U/L#SERUM#59.988'
    'WBC#K /MCL' = 'HEMATOLOGY# #Leukocytes#WBC#10^9/L#BLOOD#1'
    'WBC#M/MCL' = 'HEMATOLOGY# #Leukocytes#WBC#10^9/L#BLOOD#1000'
    ;

    value $lbtestcd
    'Albumin' = 'ALBUMIN'
    'ALK PHOS' = 'ALK'
    'ALT (SGPT)' = 'ALT'
    'AST (SGOT)' = 'AST'
    'Bicarbonate' = 'BICAR'
    'Total Bilirubin' = 'TOTBIL'
    'BUN' = 'BUN'
    'Calcium' = 'CALCIUM'
    'Chloride' = 'CHLORIDE'
    'Creatinine' = 'CREAT'
    'Glucose' = 'GLUCOSE'
    'Hepatitis B PCR' = 'HBP'
    'Hepatitis C PCR' = 'HCP'
    'Potassium' = 'POTASS'
    'LDH' = 'LDH'
    'Magnesium' = 'MAGNESIUM'
    'Phosphate' = 'PHOSPHATE'
    'Total Protein' = 'TOTPROT'
    'Sodium' = 'SODIUM'
    'Uric Acid' = 'URICACID'
    'aPTT' = 'APTT'
    'INR' = 'INR'
    'PT' = 'PT'
    'Basophils' = 'BASOPHILS'
    'Eosinophils' = 'EOS'
    'Hematocrit' = 'HEMAT'
    'Hemoglobin' = 'HEMOG'
    'Lymphocytes' = 'LYMPH'
    'Monocytes' = 'MONOCYTE'
    'Neutrophils' = 'NEUTRPH'
    'Bands' = 'BANDS'
    'Platelets' = 'PLATE'
    'RBC' = 'RBC'
    'WBC' = 'WBC'
    'Hepatitis B Core Antibody' = 'HBCA'
    'Hepatitis B Surface Antibody' = 'HBSAB'
    'Hepatitis B Surface Antigen' = 'HBSAG'
    'Hepatitis C Antibody' = 'HCAB'
    'Bilirubin' = 'BILI'
    'Blood' = 'BLOOD'
    'Ketones' = 'KETONES'
    'pH' = 'PH'
    'Protein' = 'PROTEIN'
    'Specific Gravity' = 'SG'
;
run;

data lb;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    length rawcat rawtest $200 lbdtc $20 timec $10 rawunit $40;
    keep __edc_treenodeid edc_treenodeid __EDC_EntryDate subject visit lblnd lbnr lborres lbothyn lbacelyn lbacelsp lboth 
    lbdtc timec lbcode rawcat rawunit rawtest result unit lbsymb _lbtest_;
    set source.lb(rename=(lbcode=code EDC_EntryDate=__EDC_EntryDate));
    if lbcat ^= 'Pregnancy Test';
    %subject;
    lblnd = put(lblnd,$checked.);
    lbnr = put(lbnr,$checked.);
    rawcat = upcase(lbcat);
    if upcase(strip(lborresu)) = 'OTHER' then rawunit = upcase(lbunito);
    else rawunit = upcase(lborresu);

    if upcase(strip(lborresu)) = 'OTHER' then unit = lbunito;
    else unit = lborresu;

    rawtest = upcase(lbtest);
    _lbtest_=lbtest;
    visit = compbl(compress(strip(visit)||" "||strip(put(pdseq,best.))||" "||strip(put(unsseq,best.)),'.'));
    __Result = 0; %IsNumeric(InStr= lborres, Result=__Result);
    if __Result = 1 then result = input(trim(left( lborres)), best.); else result = .;;
    if lborreso ^='' and lborres ^='Other' and lborres ^='' then put "ERR" "OR:" lborres= lborreso = ;
    if lborreso ^=''  then lborres = lborreso;else lborres = lborres;
    if lbsymb ^='' then lborres = strip(lbsymb)||" "||strip(lborres);
    if code ^=. then lbcode = put(code,best.);
    %ndt2cdt(ndt=lbdt, cdt=lbdtc);
    
    rc = h.find();
    %concatDY(lbdtc);
    drop rc;

    %ntime2ctime(ntime=lbtm, ctime=timec);
        __edc_treenodeid=edc_treenodeid ;
run;

proc sort data = lb; by rawcat rawtest rawunit;run;

proc sort data = source.lb_master out = lb_master;
by rawcat rawtest rawunit;
run;

*********************Add convertion factor for lb_master*******;
data lb_modify;
    merge lb(in=a) lb_master(in=b);
    by rawcat rawtest rawunit;
    if a and not b;
run;

proc sort data = lb_modify(keep = rawcat rawtest rawunit) nodupkey; by rawcat rawtest rawunit;run; 

data lb_modify;
    length lbtest lbtestcd lbstresu $40  lbcat lbscat lbspec $200;
    set lb_modify;
    lbcat = scan(put(strip(rawtest)||"#"||strip(rawunit),$temp.),1,"#");
    lbscat = scan(put(strip(rawtest)||"#"||strip(rawunit),$temp.),2,"#");
    lbtest = scan(put(strip(rawtest)||"#"||strip(rawunit),$temp.),3,"#");
    lbtestcd = scan(put(strip(rawtest)||"#"||strip(rawunit),$temp.),4,"#");
    lbstresu = scan(put(strip(rawtest)||"#"||strip(rawunit),$temp.),5,"#");
    lbspec = scan(put(strip(rawtest)||"#"||strip(rawunit),$temp.),6,"#");
    cf = input(scan(put(strip(rawtest)||"#"||strip(rawunit),$temp.),7,"#"),best.);
    if lbtest ^='';
run;

data lb_master_m;
    set lb_master lb_modify;
proc sort; by rawcat rawtest rawunit;
run;
*****************end**************************;

data lb_jn_master;
    merge lb(in=a) lb_master_m(in=b);
    by rawcat rawtest rawunit;
    if a;
    if a and not b then put "WARN" "ING:" subject= rawunit= rawtest=;
    if result ^=. and cf ^=. then lbstresn = result*cf;
run;

*************Get sex age from dm *****************;
proc sort data = lb_jn_master; by subject;run;
data  lb_jn_master_age;
    merge lb_jn_master(in=a) pdata.dm(keep = subject __age __sex);
    by subject;
    if a;
    lbsex = upcase(__sex);
    age = input(scan(__age,2,":"),best.);
run;

data lb_range(
        keep = tcd testcd test cat spec lbmethod sex__ symbol_age_low_ agelow agehigh age_units_ symbol_range_low low symbol_range_high high stresu low_other high_other other_units);
    set source.lb_range;
    rename age_low_ = agelow age_high_=agehigh pcyc_low_range_lbstnrlo_ = low pcyc_high_range_lbstnrhi = high lbcat = cat lbtestcd = tcd lbtest = test
    lbspec = spec _low_range__other_units_ = low_other high_range_other_units_ = high_other from__other_units_ = other_units;
run;

**********Get Low, High from range dataset**************;
proc sort data = lb_range; by tcd testcd test cat spec lbmethod sex__ symbol_age_low_ agelow agehigh age_units_ stresu symbol_range_low low symbol_range_high high descending other_units;run;
 
proc sort data = lb_range nodupkey dupout =aa;
by tcd testcd test cat spec lbmethod sex__ symbol_age_low_ agelow agehigh age_units_ stresu symbol_range_low low symbol_range_high high;
run;

proc sql;
 create table lb_jn_range01 as
 select *
 from (select * from lb_jn_master_age) as a
    left join
    (select * from lb_range) as b 
 on a.lbcat = b.cat and a.lbtestcd = b.tcd and a.lbstresu=b.stresu and (a.lbsex=b.sex__ or b.sex__='BOTH' or b.sex__='') 
    and ((b.symbol_age_low_ = '>' and a.age>b.agelow) or (b.symbol_age_low_ = '<' and a.age<b.agelow) or (b.agelow^=. and b.agehigh=. and a.age>=b.agelow) or (b.agelow^=. and b.agehigh^=. and b.agelow<=a.age<=b.agehigh)
         or (b.agelow=. and b.agehigh=.));
quit;

data lb_jn_range;
    set lb_jn_range01(rename=(low=low_ high=high_));
    if unit = other_units then low=low_other;
    else if low_ ^=. and cf ^=. then low = round(low_/cf,0.001);

    if unit = other_units then high=high_other;
    else if high_ ^=. and cf ^=. then high = round(high_/cf,0.001);
run;

** Ken Cao on 2015/03/11: Get "Standard" unit and range.;
proc sort data = lb_jn_range(keep=subject rawcat _lbtest_ lborres unit low high) nodup out = __std0(drop=lborres);
    by subject rawcat _lbtest_ ;
    where lborres > ' ';
run;

proc sql;
    create table __std1 as
    select distinct subject,rawcat, _lbtest_, unit, low, high, count(*) as ntime
    from __std0
    group by subject, rawcat, _lbtest_, unit;

    create table __std2 as
    select subject, rawcat, _lbtest_, unit, low, high, ntime
    from __std1
    group by subject, rawcat, _lbtest_
    having ntime = max(ntime)
    ;
quit;

proc sort data = __std2; by subject rawcat _lbtest_ unit; run;

data __std3_1;
    set __std2;
        by subject rawcat _lbtest_;
    if first._lbtest_ and not last._lbtest_ then do;
        put "WARN" "ING: More than one frequent units:" subject= rawcat= _lbtest_=;
    end;
    if first._lbtest_;

    length __stdrange $255;
    if n(low, high) > 1 then __stdrange = ifc(low>., strip(put(low, best.)), ' ')||' - '||ifc(high>., strip(put(high, best.)), ' ');
    
    length __stdunit $255;
    __stdunit =  unit;

    keep subject rawcat _lbtest_ __stdunit __stdrange;
run;

proc sort data = __std3_1; by subject rawcat _lbtest_; run;


proc sort data = lb_jn_range(keep=subject rawcat _lbtest_) nodup out = __std3_2;
    by subject rawcat _lbtest_ ;
run;

proc sort data=__std3_2 nodupkey; 
    by subject rawcat _lbtest_ ;
run;

data __std3;
    merge __std3_1 __std3_2;
        by  subject rawcat _lbtest_; 
    
    length lbtestcd $40;
    lbtestcd = put(_lbtest_, $lbtestcd.);
run;

proc sort data=__std3; 
    by subject rawcat lbtestcd ;
run;

proc transpose data = __std3 out = __std;
    by subject rawcat;
    id lbtestcd;
    idlabel _lbtest_;
    var __stdunit __stdrange;
run;


*************Derived LBNRIND ****************************;
data lb_nrind;
    length subject $13 rawcat $200 _lbtest_ $100 __stdunit $255;
    if _n_ = 1 then do;
        declare hash h (dataset:'__std3');
        rc = h.defineKey('subject','rawcat' , '_lbtest_');
        rc = h.defineData('__stdunit');
        rc = h.defineDOne();
        call missing(subject, rawcat, _lbtest_, __stdunit);
    end;

    length lbnrind $8 lbresult $255;
    attrib visit            label = 'Visit'
            _lbtest_            label = 'Test'
            lbdtc           label = 'Collection Date'
            timec           label = 'Collection Time'
            lbresult        label = 'Result'
            lbcode      label = 'Lab Code';

    set lb_jn_range;    
    if lbsymb = '' then do;
    if low_ ^=. and high_ ^=. and lbstresn ^=. then do;
        if lbstresn < low_ then lbnrind = 'L';
        else if lbstresn > high_ then lbnrind = 'H';
        else if low_ <= lbstresn <= high_ then lbnrind = 'NORMAL';
    end;end;
        else if lbsymb = "<" then do;
        if .< lbstresn < low_ then  lbnrind = 'L';
    end;
    ** Ken Cao on 2015/02/20: Add high > .;
    if index(lborres,">=") and cf ^= . and high_ > . and input(compress(lborres,">="),best.)>=(high_/cf) then lbnrind = 'H';

    rc = h.find();
    lbresult = lborres;
    if __stdunit ^= unit and unit > ' ' and lborres > ' ' then lbresult = strip(lborres)||" "||strip(unit);
    if lbnr > ' ' then lbresult = 'Not Reported';

    if lbnrind = 'L' then do;
        lbresult = "&escapechar{style [foreground=&belowcolor]"||strip(lbresult) ||" [L]"||"}";
    end;
    else if lbnrind ='H' then do; 
        lbresult = "&escapechar{style [foreground=&abovecolor]"||strip(lbresult) ||" [H]"||"}";
    end;

    /*
    if lbnrind ='L' then do;
        lbresult = strip(lborres)||" "||strip(unit);
        lbresult = "&escapechar{style [foreground=&belowcolor]"||strip(lbresult) ||" [L]"||"}";
    end;
    else if lbnrind ='H' then do; 
    lbresult = strip(lborres)||" "||strip(unit);
    lbresult = "&escapechar{style [foreground=&abovecolor]"||strip(lbresult) ||" [H]"||"}";
    end;
    else if lborres ^= '' and unit ^='' then lbresult = strip(lborres)||" "||strip(unit);
    else if lborres ^= '' and unit ='' then lbresult = strip(lborres);
    else if lborres = '' and lbnr ^='' then lbresult = 'Not Reported';
    */

    keep __edc_treenodeid __EDC_EntryDate subject visit lbdtc timec lblnd lbcode lbtest lbothyn 
         lboth lbresult lbacelyn lbacelsp rawcat _lbtest_ lborres low high cf unit __stdunit;

run;

/*
data lb_nrind01 lb_nrind02;
    set lb_nrind;
    if lblnd ^='' then output lb_nrind01;
    else output lb_nrind02;
run;
proc sort data = lb_nrind01 nodupkey dupout = aa; by subject rawcat visit;run;

data lb_nrind_all;
    set lb_nrind01(in=a) lb_nrind02;
    if a then do;_lbtest_='';lbresult = 'Not Done';lbtest = '';end;
run;

proc sort data = lb_nrind_all; by subject rawcat lbdtc timec visit lblnd lbcode _lbtest_;run;
*/



data pregnancy;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    keep __edc_treenodeid edc_treenodeid __EDC_EntryDate subject visit lbdtc lbcat lblnd lbspec lbultres lborres;
    set source.lb(rename=(EDC_EntryDate=__EDC_EntryDate));
    if lbcat = 'Pregnancy Test';
    %subject;
    lblnd = put(lblnd,$checked.);
    visit = compress(compbl(strip(visit)||" "||strip(put(pdseq,best.))||" "||strip(put(unsseq,best.))),'.');

    length lbdtc $20;
    %ndt2cdt(ndt=lbdt, cdt=lbdtc);

    rc = h.find();
    %concatDY(lbdtc);
    drop rc;

    __edc_treenodeid = edc_treenodeid;
run;

proc sort data = pregnancy; by subject lbdtc;run;

data pdata.pregnancy(label= 'Pregnancy Test');
    keep __edc_treenodeid __EDC_EntryDate subject visit lbdtc lblnd lbspec lbultres lborres;
    retain __edc_treenodeid __EDC_EntryDate subject visit lbdtc lblnd lbspec lborres lbultres;
    set pregnancy;
    attrib visit            label = 'Visit'
            lbdtc           label = 'Collection Date'
            lbultres        label = 'If Positive, Result of Ultrasound';
run;


/**************************************************************************************
 * Ken Cao on 2015/02/06: Transpose Lab Test
 **************************************************************************************/
data lb_nrind_all;
    set lb_nrind;
    length lbtestcd $40;
    lbtestcd = put(_lbtest_, $lbtestcd.);
run;

proc sort data = lb_nrind_all; by subject lbdtc timec visit lbcode  lbtestcd; run;



/*
proc transpose data=lb_nrind_all out=t_lab(drop=_name_ _label_);
    by subject lbdtc timec lbcode;
    id lbtestcd;
    idlabel _lbtest_;
    var lbresult;
run;
*/


*** Chemistry;

data chem;
    set lb_nrind_all;
    if rawcat = 'SERUM CHEMISTRY LOCAL';
run;


proc transpose data=chem out=t_chem(drop=_name_ _label_);
    by subject lbdtc timec visit lbcode lblnd __edc_treenodeid __EDC_EntryDate;
    id lbtestcd;
    idlabel _lbtest_;
    var lbresult;
run;

data __stdchem;
    length subject $13;
    if _n_ = 1 then do;
        declare hash h (dataset:'t_chem');
        rc = h.defineKey('subject');
        rc = h.defineDone();
        call missing(subject);
    end;
    set __std;
    where rawcat = 'SERUM CHEMISTRY LOCAL';
    rc = h.find();
    if rc = 0;
run;


data pdata.chem1(label= 'Serum Chemistry Local');
    retain __edc_treenodeid __EDC_EntryDate  subject __ord visit lbdtc timec lbcode lblnd sodium potass chloride bicar bun creat glucose ;
    keep __edc_treenodeid __EDC_EntryDate  subject __ord visit lbdtc timec lbcode lblnd sodium potass chloride bicar bun creat glucose ;
    set __stdchem(in=a) t_chem ;
        by subject;
    if a then do;
        if _name_ = '__STDUNIT' then do;
            __edc_treenodeid = ' 0-'||strip(subject)||'-Unit'; 
            __ord = 0;
        end;
        else if _name_ = '__STDRANGE'  then do;
            __edc_treenodeid = ' 1-'||strip(subject)||'-NR'; 
            __ord = 1;
        end;
    end;
    else __ord = 2;
run;

data pdata.chem2(label= 'Serum Chemistry Local (Continued)');
    retain __edc_treenodeid __EDC_EntryDate subject __ord visit lblnd calcium totprot albumin ast alt alk totbil ldh magnesium phosphate uricacid;
    keep __edc_treenodeid __EDC_EntryDate subject __ord visit lblnd calcium totprot albumin ast alt alk totbil ldh magnesium phosphate uricacid;
    set __stdchem(in=a) t_chem;
        by subject;
    if a then do;
        if _name_ = '__STDUNIT' then do;
            __edc_treenodeid = ' 0-'||strip(subject)||'-Unit'; 
            __ord = 0;
        end;
        else if _name_ = '__STDRANGE'  then do;
            __edc_treenodeid = ' 1-'||strip(subject)||'-NR'; 
            __ord = 1;
        end;
    end;
    else __ord = 2;
    rename lblnd = __lblnd;
run;


*** Hematology;

data hem;
    set lb_nrind_all;
    if rawcat = 'HEMATOLOGY LOCAL';
run;

proc transpose data=hem out=t_hem(drop=_name_ _label_);
    by subject lbdtc timec  visit lbcode lblnd lbacelyn lbacelsp __edc_treenodeid __EDC_EntryDate;
    id lbtestcd;
    idlabel _lbtest_;
    var lbresult;
run;

data __stdhem;
    length subject $13;
    if _n_ = 1 then do;
        declare hash h (dataset:'t_hem');
        rc = h.defineKey('subject');
        rc = h.defineDone();
        call missing(subject);
    end;
    set __std;
    where rawcat = 'HEMATOLOGY LOCAL';
    rc = h.find();
    if rc = 0;
run;

data pdata.hem1(label= 'Hematology Local');
    retain __edc_treenodeid __EDC_EntryDate subject __ord visit lbdtc timec  lbcode lblnd wbc rbc HEMOG HEMAT PLATE NEUTRPH ;
    keep __edc_treenodeid __EDC_EntryDate subject __ord visit lbdtc timec  lbcode lblnd  wbc rbc HEMOG HEMAT PLATE NEUTRPH;
    set __stdhem(in=a) t_hem;
        by subject;
    if a then do;
        if _name_ = '__STDUNIT' then do;
            __edc_treenodeid = ' 0-'||strip(subject)||'-Unit'; 
            __ord = 0;
        end;
        else if _name_ = '__STDRANGE'  then do;
            __edc_treenodeid = ' 1-'||strip(subject)||'-NR'; 
            __ord = 1;
        end;
    end;
    else __ord = 2;

run;

data pdata.hem2(label= 'Hematology Local (Continued)'); ** Ken Cao on 2015/02/20: Fixed a typo(Contined --> Continued);
    retain __edc_treenodeid __EDC_EntryDate subject __ord visit lblnd bands lymph monocyte  eos basophils  lbacelyn lbacelsp;
    keep __edc_treenodeid __EDC_EntryDate subject __ord visit lblnd bands lymph monocyte  eos basophils  lbacelyn lbacelsp;
    set __stdhem(in=a) t_hem;
        by subject;
    if a then do;
        if _name_ = '__STDUNIT' then do;
            __edc_treenodeid = ' 0-'||strip(subject)||'-Unit'; 
            __ord = 0;
        end;
        else if _name_ = '__STDRANGE'  then do;
            __edc_treenodeid = ' 1-'||strip(subject)||'-NR'; 
            __ord = 1;
        end;
    end;
    else __ord = 2;

    rename lblnd = __lblnd;
run;

*** Serology Local;

data sero;
    set lb_nrind_all;
    if rawcat = 'SEROLOGY LOCAL';
run;

proc transpose data=sero out=t_sero(drop=_name_ _label_);
    by subject lbdtc timec visit lbcode lblnd __edc_treenodeid __EDC_EntryDate;
    id lbtestcd;
    idlabel _lbtest_;
    var lbresult;
run;


data pdata.sero(label= 'Serology Local');
    retain __edc_treenodeid __EDC_EntryDate subject  visit  lbdtc timec lbcode lblnd hbsag hbsab hbca hcab hbp hcp;
    keep __edc_treenodeid  __EDC_EntryDate subject  visit  lbdtc timec lbcode lblnd hbsag hbsab hbca hcab hbp hcp;
    set t_sero;
    /*
    set __stdsero(in=a) t_sero;
        by subject;
    if a then do;
        if _name_ = '__STDUNIT' then do;
            __edc_treenodeid = ' 0-'||strip(subject)||'-Unit'; 
            __ord = 0;
        end;
        else if _name_ = '__STDRANGE'  then do;
            __edc_treenodeid = ' 1-'||strip(subject)||'-NR'; 
            __ord = 1;
        end;
    end;
    else __ord = 2;
    */
run;


*** Urine;
data urine;
    set lb_nrind_all;
    if rawcat = 'URINALYSIS';
run;

proc transpose data=urine out=t_urine(drop=_name_ _label_);
    by subject lbdtc  timec visit lbcode lblnd __edc_treenodeid __EDC_EntryDate;
    id lbtestcd;
    idlabel _lbtest_;
    var lbresult;
run;


data __stdurine;
    length subject $13;
    if _n_ = 1 then do;
        declare hash h (dataset:'t_urine');
        rc = h.defineKey('subject');
        rc = h.defineDone();
        call missing(subject);
    end;
    set __std;
    where rawcat = 'URINALYSIS';
    rc = h.find();
    if rc = 0;
run;


data pdata.urine(label= 'Urinalysis Local');
    retain __edc_treenodeid __EDC_EntryDate subject __ord visit lbdtc timec lbcode lblnd sg ph glucose bili ketones blood protein;
    keep __edc_treenodeid __EDC_EntryDate subject __ord visit lbdtc timec lbcode lblnd sg ph glucose bili ketones blood protein;
    set __stdurine(in=a) t_urine;
        by subject;
    if a then do;
        if _name_ = '__STDUNIT' then do;
            __edc_treenodeid = ' 0-'||strip(subject)||'-Unit'; 
            __ord = 0;
        end;
        else if _name_ = '__STDRANGE'  then do;
            __edc_treenodeid = ' 1-'||strip(subject)||'-NR'; 
            __ord = 1;
        end;
    end;
    else __ord = 2;

    if subject = '047-004' then delete;
run;



** Coagulation;
data coag;
    set lb_nrind_all;
    if rawcat = 'COAGULATION LOCAL';
run;

proc sort data=coag; by subject lbdtc timec visit lbcode lbothyn lboth; run;


proc transpose data=coag out=t_coag(drop=_name_ _label_);
    by subject lbdtc timec visit lbcode lblnd lbothyn lboth __edc_treenodeid __EDC_EntryDate;
    id lbtestcd;
    idlabel _lbtest_;
    var lbresult;
run;


data __stdcoag;
    length subject $13;
    if _n_ = 1 then do;
        declare hash h (dataset:'t_coag');
        rc = h.defineKey('subject');
        rc = h.defineDone();
        call missing(subject);
    end;
    set __std;
    where rawcat = 'COAGULATION LOCAL';
    rc = h.find();
    if rc = 0;
run;



data pdata.coag(label= 'Coagulation Local');
    retain __edc_treenodeid __EDC_EntryDate subject __ord visit lbdtc timec lbcode lblnd  pt aptt inr lbothyn lboth ;
    keep __edc_treenodeid __EDC_EntryDate subject __ord visit lbdtc timec lbcode lblnd pt aptt inr lbothyn lboth ;
    set __stdcoag(in=a) t_coag;
        by subject;
    if a then do;
        if _name_ = '__STDUNIT' then do;
            __edc_treenodeid = ' 0-'||strip(subject)||'-Unit'; 
            __ord = 0;
        end;
        else if _name_ = '__STDRANGE'  then do;
            __edc_treenodeid = ' 1-'||strip(subject)||'-NR'; 
            __ord = 1;
        end;
    end;
    else __ord = 2;
run;
