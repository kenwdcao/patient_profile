/*********************************************************************
 Program Nmae: ECOG.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/10
 
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
    %ndt2cdt(ndt=qsdt, cdt=qsdtc);
    rc = h.find();
    %concatDY(qsdtc);
    drop rc qsdt;
run;

proc sort data=ecog1; by subject qsdtc  visit2 ; run;

data pdata.ecog(label='ECOG Performance Status');
    retain __edc_treenodeid __edc_entrydate subject visit2 qsdtc qscat qstest qsorres;
    keep __edc_treenodeid __edc_entrydate subject visit2 qsdtc qscat qstest qsorres;
    set ecog1;
    ** hide variable QSCAT and QSTEST;
    rename qscat = __qscat;
    rename qstest = __qstest;

    label qsorres = 'ECOG Result';
run;
