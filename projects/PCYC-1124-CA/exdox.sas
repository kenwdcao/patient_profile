/*********************************************************************
 Program Nmae: EXDOX.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/02/27: Combine some variables so that all varaibles 
                        can fit in one dataset.
 Ken Cao on 2015/03/10: Sort exposure dataset by CYCLE and EXSEQ.

*********************************************************************/

%include '_setup.sas';

data exdox0;
    set source.exdox;
    keep edc_treenodeid subject cycle excat exyn exynr exyno exdose exdoseu exdosea exdoseau exdoser 
         exdoseo exinf exinfi exinfrs exinfr exdosel exdoselu exseq aenum01 exdt exsttm exendt exentm aenum02 edc_entrydate;
    rename edc_treenodeid = __edc_treenodeid;
    rename EDC_ENTRYDATE = __EDC_ENTRYDATE;
run;


data exdox1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set exdox0;
    
    %subject;

    ** Dose Date;
    length exdtc exendtc $20;
    label exdtc = 'Dose Date'
             exendtc = 'End Dose Date';
    %ndt2cdt(ndt=exdt, cdt=exdtc);
    %ndt2cdt(ndt=exendt, cdt=exendtc);
    rc = h.find();
    %concatDY(exdtc);
    %concatDY(exendtc);
    drop exdt exendt rc;

    ** Infusion Time;
    length exsttmc exentmc $20;
    label exsttmc = 'Infusion Start Time';
    label exentmc = 'Infusion Stop Time';
    %ntime2ctime(ntime=exsttm, ctime=exsttmc);
    %ntime2ctime(ntime=exentm, ctime=exentmc);
    drop exsttm exentm;

    ** Put dose unit into variable label;
    label exdose = 'Dose Intended#(mg)';
    drop exdoseu;

/*  Change Label exdosea  - CTD 27FEB2015*/
        label exdosea = 'Dose Administered#(mg)';
    drop exdoseau;
    label exdosel = 'Dose Level#(mg/m2/day)';
    drop exdoselu;

    ** Ken Cao on 2015/02/27: Combine some variables;
    length exynr_ $255;
    label exynr_ = 'Reason Doxorubicin not Administered';
    exynr_ = exynr;
    if aenum01 > . then exynr_ = strip(exynr_)||', AE #: '||strip(vvaluex('aenum01'));
    if exyno > ' '  then exynr_ = strip(exynr_)||', '||exyno;
    drop aenum01 exyno;
    
    length exdoser_ $255;
    label exdoser_ = 'Reason of Dose Administered not the Same as Dose Intended';
    exdoser_ = exdoser;
    if aenum02 > . then exdoser_ = strip(exdoser_)||', AE #: '||strip(vvaluex('aenum02'));
    if exdoseo > ' ' then exdoser_ = strip(exdoser_)||', '||exdoseo;
    drop aenum02 exdoseo;

    %exvisitn(cycle, exseq);

run;


proc sort data = exdox1; by subject __visitn exdtc; run;

data pdata.exdox1(label='Doxorubicin Dose Administration');
    retain __edc_treenodeid __edc_entrydate excat subject cycle exseq exynr_  exdtc exsttmc exendtc
            exentmc exdosel;
    keep __edc_treenodeid __edc_entrydate excat subject cycle exseq exynr_  exdtc exsttmc exendtc
            exentmc exdosel;
    set exdox1;
    rename excat = __excat;
    rename exseq = __exseq;

    label cycle = 'Cycle';
    label exynr_ = 'If Not Administrated, Provide Reason';

run;

data pdata.exdox2(label='Doxorubicin Dose Administration (Continued)');
    retain __edc_treenodeid __edc_entrydate excat subject cycle exseq     
              exdose exdosea exdoser_ exinf exinfi exinfrs exinfr;
    keep __edc_treenodeid __edc_entrydate excat subject cycle exseq
         exdose exdosea exdoser_ exinf exinfi exinfrs exinfr;
    set exdox1;
    rename excat = __excat;
    rename exseq = __exseq;

    label cycle = 'Cycle';

run;

/*
data pdata.exdox1(label='Doxorubicin Dose Administration');
    retain __edc_treenodeid __edc_entrydate excat subject cycle exseq exyn exynr aenum01 exyno exdtc exsttmc 
            exentmc exdosel exdose exdosea ;
    keep __edc_treenodeid __edc_entrydate excat subject cycle exseq exyn exynr aenum01 exyno exdtc exsttmc 
            exentmc exdosel exdose exdosea;
    set exdox1;
    rename excat = __excat;
    rename exseq = __exseq;
run;


data pdata.exdox2(label='Doxorubicin Dose Administration (Continued)');
    retain __edc_treenodeid __edc_entrydate excat subject cycle exseq exdoser aenum02 exdoseo exinf exinfi
          exinfrs exinfr ;
    keep __edc_treenodeid __edc_entrydate excat subject cycle exseq exdoser aenum02 exdoseo exinf exinfi
          exinfrs exinfr ;
    set exdox1;
    rename excat = __excat;
    rename exseq = __exseq;
run;
*/
