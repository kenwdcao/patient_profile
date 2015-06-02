/*********************************************************************
 Program Nmae: surghx.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/27
*********************************************************************/
%include "_setup.sas";

data surghx;
     length SURGDTC  $20  subject $13  __rfstdtc $10 desc $200;
   	   if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
    set source.surghx_coded(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate EDC_FormLabel=__EDC_FormLabel));
    %subject;
  
    ** dtc;
    label SURGDTC = "Surgery/Procedure Date";
    %ndt2cdt(ndt=SURGDT, cdt=SURGDTC);
    rc = h.find();
    %concatDY(SURGDTC);

    desc=ifc(surgdeso^='',cat(strip(scan(surgdesc,1,'(')),': ',strip(surgdeso)),strip(surgdesc));
	label desc='Surgery/Procedure Description';
run;

proc sort data=surghx; by subject SURGDTC desc;run;

data pdata.surghx1(label='Surgeries / Procedures Prompt');
    retain __EDC_TreeNodeID __EDC_EntryDate subject surgyn;
    keep __EDC_TreeNodeID __EDC_EntryDate subject surgyn;
    set surghx;
	where __EDC_FormLabel='Surgeries / Procedures Prompt';
	label surgyn="Does subject have any surgery and/or procedures to report?";
run;

data pdata.surghx2(label='Surgeries / Procedures');
    retain __EDC_TreeNodeID __EDC_EntryDate subject surgnum surgdtc surgdesc surgdeso;
    keep __EDC_TreeNodeID __EDC_EntryDate subject surgnum surgdtc surgdesc surgdeso;
    set surghx;
	where __EDC_FormLabel='Surgeries / Procedures';
run;
