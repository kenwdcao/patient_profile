/*********************************************************************
 Program Nmae: EXBTK.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/03/10: Sort exposure dataset by CYCLE and EXSPID.

*********************************************************************/

%include '_setup.sas';

data exbtk0;
    set source.exbtk;
    keep edc_treenodeid subject cycle exdisc exdose exreas exreaso exlot exseq exspid exdt 
         exdoseo aenum edc_entrydate;
    rename EDC_TREENODEID = __EDC_TREENODEID;
    rename EDC_ENTRYDATE = __EDC_ENTRYDATE;
run;

data exbtk1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set exbtk0;
    
    %subject;

    ** Dose Date;
    length exdtc $20;
    label exdtc = 'Dose Date';
    %ndt2cdt(ndt=exdt, cdt=exdtc);
    rc = h.find();
    %concatDY(exdtc);
    drop exdt rc;

    ** if this was last dose of ibrutinib;
    format exdisc $checked.;

    label EXSPID = 'Day';

    %exvisitn(cycle, exspid);
run;

proc sort data = exbtk1; by subject __visitn exdtc; run;

data pdata.exbtk(label='Ibrutinib Dose Administration');
    retain __edc_treenodeid __edc_entrydate subject cycle exspid exdtc exdisc exdose exdoseo exreas
           exreaso aenum exlot;
    keep __edc_treenodeid __edc_entrydate subject cycle exspid exdtc exdisc exdose exreas
           exreaso exdoseo aenum exlot;
    set exbtk1;
    label cycle = 'Cycle';
    label aenum = 'If Adverse Event provide Primary AE number';
    label exdoseo = 'If Other Reason, specify';
run;


