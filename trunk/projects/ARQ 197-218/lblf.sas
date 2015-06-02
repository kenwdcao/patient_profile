* Program Name: LBLF.sas;
* Author: Yiqi Diao (yiqi.diao@januscri.com);
* Initial Date: 18/02/2014;


/* -- Modification History --
    Ken on 2014/02/21: derive lab unit from external data lbnr;
*/

%include '_setup.sas';

data lblf0;
    set source.lblf;
    %subjid;
    * numeric date to character date;
    length _LBLFDTC LBLFDTC $28 LBLFTMC $8;
    %numDate2Char(numdate = LBLFDT, chardate = _LBLFDTC);
    LBLFTMC = put(LBLFTM, time8.);
    if length(strip(LBLFTMC)) < 8 then LBLFTMC = '0' || strip(LBLFTMC);
    if _LBLFDTC ^= '' then LBLFDTC = strip(_LBLFDTC) || 'T' || substr(strip(LBLFTMC), 1, 5);
    *handle lab values;
    length N_ASTV N_ALTV N_LDHV N_ALKPHOV N_TOTBILV N_DIRBILV $200;
    label 
        LBLFDTC = 'Date'
        N_ASTV = 'AST(SGOT)'
        N_ALTV = 'ALT(SGPT)'
        N_LDHV = 'LDH'
        N_ALKPHOV = 'Alkaline Phosphatase'
        N_TOTBILV = 'Total Bilirubin'
        N_DIRBILV = 'Direct Bilirubin'
        ;
    %labvalue(value=ASTV, abnfl=ASTS, outvar=N_ASTV);
    %labvalue(value=ALTV, abnfl=ALTS, outvar=N_ALTV);
    %labvalue(value=LDHV, abnfl=LDHS, outvar=N_LDHV);
    %labvalue(value=ALKPHOV, abnfl=ALKPHS, outvar=N_ALKPHOV);
    %labvalue(value=TOTBILV, abnfl=TBILS, outvar=N_TOTBILV);
    %labvalue(value=DIRBILV, abnfl=DBILS, outvar=N_DIRBILV);
    length VISIT $60;
    label VISIT = 'Visit';
    %getCycle;
    VISIT = __visit;

    /* Ken on 2014/02/21: upcase varaible labname and fix typos */
    length labname $100;
    labname = upcase(strip(lblfname));
    
    ** Blow are hard-coded **;
    if labname = 'CLEVELAND CLINIC FLORIDA, HEMATOLOGY/ONCOLOGY LAB.' then
        labname = 'CLEVELAND CLINIC FLORIDA, HEMATOLOGY/ONCOLOGY LAB';
    else if labname = 'EXCELA HEALTH LATROBE' then 
        labname = 'EXCELA HEALTH';
    else if labname = 'KUCC - WESTWOOD LAB' then
        labname = 'KUCC';
    else if labname = 'STANFORD HOSPITALS AND CLINICS- CANCER CENTER' then 
        labname = 'STANFORD CANCER CENTER LAB';
    else if labname = 'STANFORD HOSPITAL AND CLINICS-CC' then
        labname = 'STANFORD CANCER CENTER LAB';
    

/*  %getvnum(visit=VISIT);*/
    if LBLFCLCD = 0 then do;
        if LBLFDTC = '' then LBLFDTC = 'NOT DONE';
            else LBLFDTC = LBLFDTC || ' (NOT DONE)';
    end;
run;

/* get lab unit from exteranl dataset */

%let labtestcd = %str('ALTV', 'ASTV', 'LDHV', 'ALKPHOV', 'TOTBILV', 'DIRBILV');

data _ref0;
    set source.lbnr(rename=(lbtestcd=in_lbtestcd));
    length lbtestcd $40;
    lbtestcd = strip(upcase(in_lbtestcd))||'_U';
    labname = strip(upcase(labname));
    keep siteid labname lbtestcd lbtest lborresu;
    where upcase(in_lbtestcd) in (&labtestcd);
run;

proc sort data = _ref0 nodup; by siteid labname lbtestcd; run;

proc transpose data = _ref0 out = _ref(drop=_:);
    by siteid labname;
    id lbtestcd;
    idlabel lbtest;
    var lborresu;
run;

proc sort data = lblf0;
    by siteid labname subjid __vdate lblfdtc;
run;

data lblf1;
    merge _ref(in=in_ref) lblf0(in = __fromlab);
        by siteid labname;
    length __nounitfg $1;
    if not in_ref then __nounitfg = 'Y';
    if __fromlab;
run;


proc sort data = lblf1;
    by siteid subjid labname __vdate lblfdtc;
run;

data lblf2;
    set lblf1;
        by siteid subjid labname;
    array labtst{*} n_altv n_astv n_ldhv n_alkphov n_totbilv n_dirbilv;
    array labtstu{*} altv_u astv_u ldhv_u alkphov_u totbilv_u dirbilv_u;
    length __unitline $1 __multilab $1;
    retain __multilab;
    /*insert a record before each labname group of each subject*/
    if first.subjid then
        do;
            output;
            __unitline = 'Y';
            __multilab = '';
            do i = 1 to dim(labtst);
                if __nounitfg ^= 'Y' then
                    labtst[i] = strip(vlabel(labtst[i]))||'#('||strip(labtstu[i])||')';
                else
                    labtst[i] = vlabel(labtst[i]);
             end;
             output;
        end;
    else if first.labname then
        do;
            /* subject with multiple lab name */
            __multilab = 'Y';
        end;
    if __multilab = 'Y' then 
        do i =1 to dim(labtst);
            labtst[i] = strip(labtst[i])||' '||strip(labtstu[i]);
        end;
    if not first.subjid then output;

run;


proc sort data = lblf2;
    by siteid subjid descending __unitline __vdate  lblfdtc;
run;

data pdata.lblf (label='Liver Function Tests');
    retain SUBJID __vdate VISIT lblfname LBLFDTC N_ASTV N_ALTV N_LDHV N_ALKPHOV N_TOTBILV N_DIRBILV
            __unitline __multilab __nounitfg;
    keep SUBJID __vdate VISIT lblfname LBLFDTC N_ASTV N_ALTV N_LDHV N_ALKPHOV N_TOTBILV N_DIRBILV 
            __unitline __multilab __nounitfg;
    set lblf2;
run;

