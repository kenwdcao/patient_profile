/*********************************************************************
 Program Nmae: EXPEG.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/03/10: Sort exposure dataset by CYCLE and EXSPID.

*********************************************************************/

%include '_setup.sas';

data expeg0;
    set source.expeg;
    keep EDC_TreeNodeID SUBJECT CYCLE EXCAT EXADOSE EXREAS EXMDOTH EXSEQ EXDT EXTM EXADOSEO AENUM EDC_EntryDate;
    rename EDC_TREENODEID = __EDC_TREENODEID;
    rename EDC_ENTRYDATE = __EDC_ENTRYDATE;
run;

data expeg1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set expeg0;
    
    %subject;

    ** Dose Administration Date;
    length exdtc $20;
    label exdtc = 'Dose Administration Date';
    %ndt2cdt(ndt=exdt, cdt=exdtc);
    rc = h.find();
    %concatDY(exdtc);
    drop exdt rc;


    ** Dose Administration Time;
    length extmc $10;
    label extmc = 'Dose Administration Time'
                exadoseo  = 'Other Dose per Administration#(mg)';;
    %ntime2ctime(ntime=extm, ctime=extmc);
    drop extm;

    %exvisitn(cycle, exseq);
run;

proc sort data = expeg1; by subject __visitn; run;

data pdata.expeg(label='Pegfilgrastim Dose Administration');
    retain __edc_treenodeid __edc_entrydate excat subject cycle exseq exdtc extmc
           exadose exadoseo exreas exmdoth aenum;
    keep   __edc_treenodeid __edc_entrydate excat subject cycle exseq exdtc extmc
           exadose exadoseo exreas exmdoth aenum;
    set expeg1;
    
    ** hide EXCAT and EXSEQ;
    rename excat = __excat;
    rename exseq = __exseq;

    label cycle = 'Cycle';
    label exmdoth = 'If Dosing Rationale is Other, specify';
    label aenum = 'If Dosing Rationale is AE, specify AE Number';
run;
