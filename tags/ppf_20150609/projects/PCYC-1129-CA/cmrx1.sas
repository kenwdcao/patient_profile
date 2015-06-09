/*********************************************************************
 Program Nmae: cmrx1.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/
%include "_setup.sas";


data cmrx0;
    set source.cmrx1(rename=(edc_treenodeid=__edc_treenodeid  edc_entrydate=__edc_entrydate visit=__visit));
    %subject;     
run;

proc sort data=cmrx0; by subject  ;run;


************************;
data cmrx2;
    length rxstdtc rxendtc rxprdtc $20 subject $13 __rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set cmrx0;
    rc = h.find();
    drop rc;

    if EDC_FormLabel^='Prior Chronic GVHD Treatment Prompt';
    __rxcat=strip(rxcat);
    label __rxcat ='Prior Chronic GVHD Treatment';

      **  Start Date and End Date;
    label rxstdtc = 'Start Date';
    label rxendtc = 'End Date';
    %concatDate(year=rxstyy, month=rxstmm, day=rxstdd, outdate=rxstdtc);
    %concatDate(year=rxenyy, month=rxenmm, day=rxendd, outdate=rxendtc);
    %concatDY(rxstdtc);
    %concatDY(rxendtc);

   ** Date of Progression;
    label rxprdtc = 'Date of Progression';
    %concatDate(year=rxpryy, month=rxprmm, day=rxprdd, outdate=rxprdtc);
    %concatDY(rxprdtc);
   format  rxprdtuk rxprdtna rxrgnumn checked.;
run;


data pdata.cmrx11(label='Prior Chronic GVHD Treatment Prompt');
    retain __EDC_TreeNodeID __EDC_EntryDate subject __visit rxyn ;
    keep __EDC_TreeNodeID __EDC_EntryDate subject __visit rxyn ;
    set cmrx0;
     if EDC_FormLabel='Prior Chronic GVHD Treatment Prompt';
    label rxyn = 'Does the subject have any prior GVHD related systemic treatment to report?';
run;

proc sort data=cmrx2 out=cmrx12 nodupkey; by subject rxrgnum ;run;
data pdata.cmrx12(label='Prior Chronic GVHD Treatment');
    retain __EDC_TreeNodeID __EDC_EntryDate subject __visit __rxcat rxrgnum rxrgnumn rxresp rxprdtc rxprdtuk rxprdtna rxecpyn  ;
    keep __EDC_TreeNodeID __EDC_EntryDate subject __visit __rxcat rxrgnum rxrgnumn rxresp rxprdtc rxprdtuk rxprdtna rxecpyn   ;
    set cmrx12;
    label rxecpyn ="Did subject receive Extracorporeal Photopheresis (ECP)?";
run;

proc sort data=cmrx2 out=cmrx2_; by subject rxrgnum rxgrid;run;
data pdata.cmrx13(label='Prior Chronic GVHD Treatment (Continued)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject __visit __rxcat rxrgnum rxgrid rxtrt rxstdtc rxendtc;
    keep __EDC_TreeNodeID __EDC_EntryDate subject __visit __rxcat rxrgnum rxgrid rxtrt rxstdtc rxendtc;
    set cmrx2_;
/*  label PreferredDrugName="Preferred Drug Name";*/
    if rxtrt^="";
run;
