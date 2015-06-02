/*********************************************************************
 Program Nmae: ECOG.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data ecog0;
    set source.ecog;
    keep edc_treenodeid edc_entrydate subject yr visit cycle qscat qstest qsorres seq qsdt ;
    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;
    rename yr = __yr;
run;

data ecog1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set ecog0;

    %subject;
    
    ** Assessment Date;
    length qsdtc $20;
    label qsdtc = 'Assessment Date';
    %ndt2cdt(ndt=qsdt, cdt=qsdtc);
    rc = h.find();
    %concatDY(qsdtc);
    drop rc qsdt;

    ** VISIT;
    %visit;
run;

proc sort data=ecog1; by subject qsdtc visit2; run;

data pdata.ecog(label='ECOG');
    retain __edc_treenodeid __edc_entrydate subject visit2 qsdtc qscat qstest qsorres;
    keep __edc_treenodeid __edc_entrydate subject visit2 qsdtc qscat qstest qsorres;
    set ecog1;
    ** hide variable QSCAT and QSTEST;
    rename qscat = __qscat;
    rename qstest = __qstest;

    label qsorres = 'ECOG Result';
run;
