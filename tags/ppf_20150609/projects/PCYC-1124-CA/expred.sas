/*********************************************************************
 Program Nmae: EXPRED.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/03/10: Sort exposure dataset by CYCLE and EXSPID.

*********************************************************************/



%include '_setup.sas';

data expred0;
    set source.expred;
    keep edc_treenodeid subject cycle exdose exdoseau exreas exreaso exseq exspid exdt 
         exdoseo exdosea aenum edc_entrydate;
    rename EDC_TREENODEID = __EDC_TREENODEID;
    rename EDC_ENTRYDATE = __EDC_ENTRYDATE;
run;

data expred1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set expred0;
    
    %subject;

    ** Dose Date;
    length exdtc $20;
    label exdtc = 'Dose Date';
    %ndt2cdt(ndt=exdt, cdt=exdtc);
    rc = h.find();
    %concatDY(exdtc);
    drop exdt rc;

    label EXSPID = 'Day';

    ** Put dose unit into variable label;
    label exdosea = 'Actual Dose Administered#(mg)'
              exdoseo = 'Other Dose Administered#(mg/m2)';
    drop exdoseau;

    %exvisitn(cycle, exspid);

run;

proc sort data = expred1; by subject __visitn exdtc; run;

data pdata.expred(label='Prednisone Dose Administration');
    retain __edc_treenodeid __edc_entrydate subject cycle exspid exdtc exseq exdose 
           exdoseo exdosea exreas exreaso aenum ;
    keep   __edc_treenodeid __edc_entrydate subject cycle exspid exdtc exseq exdose 
           exdoseo exdosea exreas exreaso aenum ;
    set expred1;
    rename exseq = __exseq;

    label cycle = 'Cycle';
    label exreaso = 'If Other Reason, specify';
    label aenum = 'If Adverse Event provide Primary AE number';
run;
