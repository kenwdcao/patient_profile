/********************************************************************************
 Program Nmae: TX.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/10
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data tx;
     length cmstdtc cmendtc $20  subject  $13 rfstdtc $10 type typ int $200;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
 
    set source.tx
    (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate EDC_FormLabel=__EDC_FormLabel txcat=__txcat));
    %subject;
  
    ** CMSTDTC and CMENDTC;
    label cmstdtc = "Start Date";
    label cmendtc = "End Date";
    %concatDate(year=txstyy, month=txstmm, day=txstdd, outdate=cmstdtc);
    %concatDate(year=txenyy, month=txenmm, day=txendd, outdate=cmendtc);

    rc = h.find();
    %concatdy(cmstdtc); 
    %concatdy(cmendtc); 
    drop rc;
    ** Combine CMONGO into CMENDTC;
    *cmendtc = ifc(txongo=1,'Ongoing',strip(cmendtc)) ;

    label txyn='Has the subject received any anti-cancer therapy related to DLBCL including chemotherapy, immunotherapy, and/or stem cell transplant that were administered after last dose of study drug?';

    ***type**;
    type=ifc(TXTYPE^=.,put(TXTYPE,type.),'');
    label type='Type of therapy';

    typ=ifc(TXTTYP^=.,put(TXTTYP,type.),'');
    label typ='Stem Cell Transplant Type';

    int=ifc(TXINT^=.,put(TXINT,type.),'');
    label int='Intent';

run;

data pdata.tx(label='Subsequent Anti-Cancer Therapy');
    retain __EDC_TreeNodeID __EDC_EntryDate subject  __txcat txyn type typ int txterm cmstdtc cmendtc txongo; 
    keep __EDC_TreeNodeID __EDC_EntryDate subject  __txcat txyn type typ int txterm cmstdtc cmendtc txongo;
    set tx;
    
    label typ = 'If Stem Cell Transplant, select Type';

    format txongo checked.;

run;

