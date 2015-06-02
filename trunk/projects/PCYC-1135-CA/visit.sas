/*********************************************************************
 Program Nmae: visit.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data visit0;
    set source.visit;
    %subject;
    keep EDC_TreeNodeID SUBJECT	CYCLE VISIT	VISITND	VISNDRSN UNSSEQ	VISITDAT EDC_EntryDate;
run;

data visit1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set visit0;
	
    length visitdtc $20;
	label visitdtc = 'Date of Visit';
	%ndt2cdt(ndt=visitdat, cdt=visitdtc);
	rc = h.find();
    drop rc rfstdtc;
    %concatDY(visitdtc);
	%visit2;
	label  visitnd = 'Check box if assessments within this visit were not done';
	label visndrsn = 'Specify reason visit was not done';
run;

proc sort data = visit1; by subject visitdtc; run;

data pdata.visit(label='Date of Visit');
    retain EDC_TreeNodeID EDC_EntryDate subject visit2 visitnd visitdtc visndrsn; 
    keep   EDC_TreeNodeID EDC_EntryDate subject visit2 visitnd visitdtc visndrsn; 

    set visit1;

    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
run;


