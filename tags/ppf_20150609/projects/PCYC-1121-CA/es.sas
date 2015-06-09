/*********************************************************************
 Program Nmae: ES.sas
  @Author: Taodong Chen
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/02/25: Drop QSTEST and QSCAT from ES.
 Ken Cao on 2015/03/05: Concatenate --DY to QSDTC.

*********************************************************************/
%include '_setup.sas';

proc format;
    value $vnum
    'Suspected PD / Early Termination 1' = '299999.1'
    'Suspected PD / Early Termination 2' = '299999.2'
    'End of Treatment' = '300000'
    ;

run;

proc sort data=source.es out=s_es nodupkey; by _all_; run;

data es01;

    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
    	declare hash h (dataset:'pdata.rfstdtc');
    	rc = h.defineKey('subject');
    	rc = h.defineData('rfstdtc');
    	rc = h.defineDone();
    	call missing(subject, rfstdtc);
    end;

    length qsdtc $19 visit $60;
    set s_es(rename=(visit=visit_ EDC_EntryDate = __EDC_EntryDate));
     %subject;
    %ndt2cdt(ndt=qsdt, cdt=qsdtc);

    rc = h.find();
    %concatDY(qsdtc);
    drop rc;

        if pdseq^=. then visitnum=input(put(strip(visit_)||''||strip(put(pdseq,best.)),$vnum.),best.);
        else if visit='End of Treatment' then visitnum=input(put(visit_,$vnum.),best.);
    if pdseq^=. then visit=strip(visit_)||''||strip(put(pdseq,best.));
        else if unsseq^=. then visit=strip(visit_)||''||strip(put(unsseq,best.));
            else visit=strip(visit_);
      qsstat=put(qsstat,$checked.);
      __edc_treenodeid=edc_treenodeid;
    drop edc_:;
run;

proc sort data=es01; by subject qsdtc visit; run;

data pdata.es(label="ECOG Performance Status");
    retain __edc_treenodeid __EDC_EntryDate subject visit qsdtc qscat qsstat qstest qsorres;
    keep  __edc_treenodeid __EDC_EntryDate subject qscat qstest qsorres qsstat qsdtc visit;
    set es01;
    label 
        qsdtc = 'Date of ECOG'
        visit = 'Visit'
    ;
    rename qscat = __qscat;
    rename qstest = __qstest;
run;
