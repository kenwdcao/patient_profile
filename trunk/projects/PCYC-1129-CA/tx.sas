/********************************************************************************
 Program Nmae: tx.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';


data tx;
     length cmstdtc cmendtc $20  subject $13  __rfstdtc $10 ;
    	   if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
 
    set source.tx
    (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate ));
    %subject;
  
    ** CMSTDTC and CMENDTC;
    label cmstdtc = "Start Date";
    label cmendtc = "Stop Date";
    %concatDate(year=txstyy, month=txstmm, day=txstdd, outdate=cmstdtc);
    %concatDate(year=txenyy, month=txenmm, day=txendd, outdate=cmendtc);

    rc = h.find();
    %concatdy(cmstdtc); 
    %concatdy(cmendtc); 
    drop rc;
run;

proc sort data=tx; by subject cmstdtc cmendtc txtype;run;

data pdata.tx1(label='Subsequent Chronic GVHD Therapy Prompt');
    retain __EDC_TreeNodeID __EDC_EntryDate subject txyn ; 
    keep __EDC_TreeNodeID __EDC_EntryDate subject txyn;
    set tx; 
	if EDC_FormLabel="Subsequent Chronic GVHD Therapy Prompt";
   label txyn ="Has the subject received any therapies related to cGVHD that were administered after the last dose of study drug?";
run;

data pdata.tx2(label='Subsequent Chronic GVHD Therapy');
    retain __EDC_TreeNodeID __EDC_EntryDate subject txtype txsys txttyp txoth cmstdtc cmendtc txongo; 
    keep __EDC_TreeNodeID __EDC_EntryDate subject txtype txsys txttyp txoth cmstdtc cmendtc txongo;
    set tx;
    format txongo checked.;
	if EDC_FormLabel="Subsequent Chronic GVHD Therapy Prompt";
	label txoth ="If Other type of therapy, describe";
run;

