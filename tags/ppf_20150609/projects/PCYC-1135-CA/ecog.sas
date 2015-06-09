/*********************************************************************
 Program Nmae: ECOG.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';


data ecog1(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set source.ecog;

    %subject;
    %visit2;
    ** Assessment Date;
    length qsdtc $20;
    label qsdtc = 'Assessment Date';
    %ndt2cdt(ndt=EPDAT, cdt=qsdtc);
    rc = h.find();
    %concatDY(qsdtc);
    drop rc EPDAT;
run;

proc sort data=ecog1; by subject qsdtc visit2 ; run;

data pdata.ecog(label='ECOG Performance Status');
    retain __edc_treenodeid __edc_entrydate subject visit2 qsdtc eporres eptest;
    keep __edc_treenodeid __edc_entrydate subject visit2 qsdtc eptest eporres;
    set ecog1;
    ** hide variable eptest;
    rename EPORRES = qsorres;
    rename EPTEST = __qstest;

    label EPORRES = 'ECOG Result';
run;
