/********************************************************************************
 Program Nmae: survival.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data survival;
     length contdtc lalvdtc $20  subject $13  __rfstdtc $20 ;
    	   if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
 
     set source.survival
    (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate EDC_FormLabel=__EDC_FormLabel));
    %subject;
  
    ** contdtc and lalvdtc;
    label contdtc = "If Yes, what was the Date of Contact?";
    label lalvdtc = "If patient/caregiver was not contacted, provide the Date Last Known Alive?";

   %ndt2cdt(ndt=FUCONTDT, cdt=contdtc);
   %ndt2cdt(ndt=FULALVDT, cdt=lalvdtc);
   rc = h.find();
   %concatdy(contdtc); 
   %concatdy(lalvdtc); 
   drop rc;
run;

proc sort data=survival; by subject contdtc;run;

data pdata.survival(label='Survival Sweep');
    retain __EDC_TreeNodeID __EDC_EntryDate subject fucont contdtc fualive lalvdtc; 
    keep __EDC_TreeNodeID __EDC_EntryDate subject  fucont contdtc fualive lalvdtc;
    set survival;  
    label  fucont="Was the patient and/or caregiver contacted?";
    label  fualive="If Yes, is the patient alive?";
run;

