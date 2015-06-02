/*********************************************************************
 Program Nmae: cmrx2.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/
%include "_setup.sas";


data cmrx00;
    set source.cmrx2(rename=(edc_treenodeid=__edc_treenodeid  edc_entrydate=__edc_entrydate));
    %subject;     
run;

proc sort data=cmrx00; by subject  ;run;


************************;
data cmrx2;
    length rxstdtc rxendtc $20 subject $13 __rfstdtc $10 ;

    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set cmrx00;
    rc = h.find();
    drop rc;

    if EDC_FormLabel^='Immunosuppressive Therapy Prompt';
    __rxcat=strip(rxcat);
    label __rxcat ='Immunosuppressive Therapy';

      **  Start Date and End Date;
    label rxstdtc = 'Start Date';
    label rxendtc = 'Stop Date';
    %concatDate(year=rxstyy, month=rxstmm, day=rxstdd, outdate=rxstdtc);
    %concatDate(year=rxenyy, month=rxenmm, day=rxendd, outdate=rxendtc);
    %concatDY(rxstdtc);
    %concatDY(rxendtc);
run;

proc sort data=cmrx2; by subject rxstdtc rxendtc ;run;

data pdata.cmrx21(label='Immunosuppressive Therapy Prompt');
    retain __EDC_TreeNodeID __EDC_EntryDate subject  rxyn ;
    keep __EDC_TreeNodeID __EDC_EntryDate subject rxyn ;
    set cmrx00;
     if EDC_FormLabel='Immunosuppressive Therapy Prompt';
    label rxyn = 'Is the subject receiving other immunosuppressive therapies in addition to glucocorticoids?';
run;


data pdata.cmrx22(label='Immunosuppressive Therapy');
   retain __EDC_TreeNodeID __EDC_EntryDate subject __rxcat rxtrt PreferredDrugName rxstdtc rxendtc rxdose rxdosena 
        rxdoseu rxdoseuo rxfreq rxfreqo;
   keep __EDC_TreeNodeID __EDC_EntryDate subject __rxcat rxtrt PreferredDrugName rxstdtc rxendtc rxdose rxdosena 
       rxdoseu rxdoseuo rxfreq rxfreqo;
   set cmrx2;
 label PreferredDrugName="Preferred Drug Name";
 label rxdoseu="Dose Unit";
 label rxdoseuo="If Other Dose Unit,specify";
 label rxfreq="Dosing Frequency";
 label rxfreqo="If Other Dosing Frequency,specify";
run;

