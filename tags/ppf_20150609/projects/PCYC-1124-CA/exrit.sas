/*********************************************************************
 Program Nmae: EXRIT.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/02/27: Combine some variables so that all varaibles 
                        can fit in one dataset.

 Ken Cao on 2015/03/10: Sort exposure dataset by CYCLE and EXSEQ.

 Ken Cao on 2015/03/23: Remove Dose Rationale Column as per client's comments.

*********************************************************************/

%include '_setup.sas';

data exrit0;
    set source.exrit;
    keep edc_treenodeid subject cycle excat exyn exynr exyno exdose exdoseu exdosea exdoseau exdoser 
         exdoseo exinf exinfi exinfrs exinfr exseq aenum01 exdt exsttm exentm aenum02 edc_entrydate;
    rename edc_treenodeid = __edc_treenodeid;
    rename EDC_ENTRYDATE = __EDC_ENTRYDATE;
run;

data exrit1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set exrit0;
    
    %subject;

    ** Dose Date;
    length exdtc $20;
    label exdtc = 'Dose Date';
    %ndt2cdt(ndt=exdt, cdt=exdtc);
    rc = h.find();
    %concatDY(exdtc);
    drop exdt rc;

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
    label exdosea = 'Dose Administered#(mg)';
    drop exdoseau;

    ** Ken Cao on 2015/02/27: Combine some variables;
    length exynr_ $255;
    
    ** CTD on 2015/02/27: Change label name of exynr_;
    label exynr_ = 'Reason Rituximab not Administered';
    exynr_ = exynr;
    if aenum01 > . then exynr_ = strip(exynr_)||', AE #: '||strip(vvaluex('aenum01'));
    if exyno > ' '  then exynr_ = strip(exynr_)||', '||exyno;
    drop aenum01 exyno;
    
    length exdoser_ $255;
    label exdoser_ = 'Dose Rationale';
    exdoser_ = exdoser;
    if aenum02 > . then exdoser_ = strip(exdoser_)||', AE #: '||strip(vvaluex('aenum02'));
    if exdoseo > ' ' then exdoser_ = strip(exdoser_)||', '||exdoseo;
    drop aenum02 exdoseo;

    %exvisitn(cycle, exseq);

run;


proc sort data = exrit1; by subject __visitn exdtc; run;



data pdata.exrit(label='Rituximab Dose Administration');
    retain __edc_treenodeid __edc_entrydate excat subject cycle exseq exynr_  exdtc exsttmc 
            exentmc  exdose exdosea exdoser_ exinf exinfi exinfrs exinfr;
    keep __edc_treenodeid __edc_entrydate excat subject cycle exseq exynr_  exdtc exsttmc 
            exentmc  exdose exdosea exdoser_ exinf exinfi exinfrs exinfr;
    set exrit1;
    rename excat = __excat;
    rename exseq = __exseq;

    rename exdoser_ = __exdoser_;

    label cycle = 'Cycle';
    label exynr_ = 'If Not Administrated, Provide Reason';
    label exdoser_ = 'Reason Dose Administrated not the same as Dose Intended';
run;

/*
data pdata.exrit1(label='Rituximab Dose Administration');
    retain __edc_treenodeid __edc_entrydate excat subject cycle exseq exyn exynr aenum01 exyno exdtc exsttmc 
            exentmc  exdose exdosea ;
    keep __edc_treenodeid __edc_entrydate excat subject cycle exseq exyn exynr aenum01 exyno exdtc exsttmc 
            exentmc  exdose exdosea;
    set exrit1;
    rename excat = __excat;
    rename exseq = __exseq;
run;


data pdata.exrit2(label='Rituximab Dose Administration (Continued)');
    retain __edc_treenodeid __edc_entrydate excat subject cycle exseq exdoser aenum02 exdoseo exinf exinfi
          exinfrs exinfr ;
    keep __edc_treenodeid __edc_entrydate excat subject cycle exseq exdoser aenum02 exdoseo exinf exinfi
          exinfrs exinfr ;
    set exrit1;
    rename excat = __excat;
    rename exseq = __exseq;
run;
*/
