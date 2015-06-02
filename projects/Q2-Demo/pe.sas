/*
    Program Name: PE.sas
    @Author: Xiu Pan
    @Initial Date: 2015/01/29

    Revision History
    Ken Cao on 2015/02/05: Tranpose PETEST
    Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.

*/

%include '_setup.sas';

proc format;
    value $vnum
    'Suspected PD / Early Termination 1' = '299999.1'
    'Suspected PD / Early Termination 2' = '299999.2'
    'End of Treatment' = '300000'
    ;

run;

data pe;
    set source.pe(rename=(visit=visit_));
    length pedtc $10 visit $60;
    %ndt2cdt(ndt=pedt, cdt=pedtc);
    %subject;
    if pdseq^=. then visitnum=input(put(strip(visit_)||''||strip(put(pdseq,best.)),$vnum.),best.);
        else if visit='End of Treatment' then visitnum=input(put(visit_,$vnum.),best.);
    if pdseq^=. then visit=strip(visit_)||''||strip(put(pdseq,best.));
        else if unsseq^=. then visit=strip(visit_)||''||strip(put(unsseq,best.));
            else visit=strip(visit_);

    pestat = put(pestat, $checked.);

    __edc_treenodeid=edc_treenodeid;

    rename EDC_EntryDate = __EDC_EntryDate;
run;

data pe_;
    length orres $200 height weight $60 test $60;
    set pe(rename=(height=height_ weight=weight_));
    orres=strip(peorres);
    if petest = 'Other' and orres ^= 'Not Done' and orres > ' ' then orres = strip(peorreso)||': '||strip(orres);

    if height_^='' then height=strip(height_)||' '||strip(heightu);
    if weight_^='' then weight=strip(weight_)||' '||strip(weightu);
    if peorreso^='' then test=strip(petest)||': '||strip(peorreso);
    else test=strip(petest);
    keep __edc_treenodeid __EDC_EntryDate subject visit visitnum petest peorres orres pecom peabn pedt pedtc pestat height weight test peorreso pestat;
run;


** Ken Cao on 2015/02/05: Transpoe PETEST;
proc format;
    value $petestcd
    'Abdomen' = 'ABDOMEN'
    'Cardiovascular' = 'CARD'
    'Extremities' = 'EXTREM'
    'General Appearance' = 'GA'
    'HEENT' = 'HEENT'
    'Lymphatic' = 'LYMPHATIC'
    'Musculoskeletal' = 'MUSC'
    'Nervous' = 'NERVOUS'
    'Other' = 'OTHER'
    'Respiratory' = 'RESP'
    'Skin' = 'SKIN'
;
run;

data pe2;
    set pe_;
    length petestcd $8;
    petestcd = put(petest, $petestcd.);
run;

proc sort data=pe2; by subject pedtc visit height weight __edc_treenodeid;run;

proc transpose data=pe2 out=t_pe;
    by subject pedtc visit height weight pestat __edc_treenodeid __EDC_EntryDate;
    id petestcd;
    idlabel petest;
    var orres;
run;

data pdata.pe1(label='Physical Exam');
    keep __edc_treenodeid __EDC_EntryDate subject visit  pedtc pestat height weight ga skin heent resp card abdomen extrem ;
    retain __edc_treenodeid __EDC_EntryDate subject visit  pedtc pestat height weight ga skin heent resp card abdomen extrem;
    set t_pe;
    label
    weight='Weight'
    height='Height'
    pedtc='Date of Examination'
    visit='Visit'
    ;
run;


data pdata.pe2(label='Physical Exam (Continued)');
    keep __edc_treenodeid __EDC_EntryDate subject visit  pedtc pestat musc lymphati nervous other;
    retain __edc_treenodeid __EDC_EntryDate subject visit  pedtc pestat musc lymphati nervous other;
    set t_pe;
    label
    pedtc='Date of Examination'
    visit='Visit'
    ;
run;


/*
data pdata.pe(label='Physical Exam (with Height and Weight)');
    retain subject visit pedtc height weight test orres pecom peabn ;
    keep subject visit pedtc height weight test orres pecom peabn ;
    set pe_;
    label
    weight='Weight (Unit)'
    height='Height (Unit)'
    orres='Physical Exam Result'
    test='Physical Exam Test'
    pedtc='Date of Examination'
    visit='Visit'
    ;
run;
*/
