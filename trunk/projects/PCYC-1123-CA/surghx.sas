/*********************************************************************
 Program Nmae: SURGHX.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/14
*********************************************************************/
%include "_setup.sas";

data surghx;
     length SURGDTc  $20  subject  $13 rfstdtc $10 desc $200;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
 
    set source.surghx(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate EDC_FormLabel=__EDC_FormLabel));
    %subject;
  
    ** dtc;
    label SURGDTc = "Surgery / Procedure Date";
    %ndt2cdt(ndt=SURGDT, cdt=SURGDTc);
    rc = h.find();
    %concatDY(SURGDTc);

    desc=ifc(surgdeso^='',cat(strip(scan(surgdesc,1,'(')),': ',strip(surgdeso)),strip(surgdesc));
	label desc='Surgery/Procedure Description';

run;

proc sort data=surghx; by subject SURGDTc desc;run;

data pdata.surghx1(label='Surgeries and Procedures Prompt');
    retain __EDC_TreeNodeID __EDC_EntryDate subject SURGYN ;
    keep __EDC_TreeNodeID __EDC_EntryDate subject SURGYN ;
    set surghx;
	where __EDC_FormLabel='Surgeries and Procedures Prompt';
run;


data pdata.surghx2(label='Surgeries and Procedures');
    retain __EDC_TreeNodeID __EDC_EntryDate subject SURGDTc surgdesc surgdeso;
    keep __EDC_TreeNodeID __EDC_EntryDate subject SURGDTc surgdesc surgdeso;
    set surghx;
	where __EDC_FormLabel='Surgeries and Procedures';
run;
