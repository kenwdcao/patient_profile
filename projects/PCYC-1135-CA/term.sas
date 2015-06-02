/*********************************************************************
 Program Nmae: term.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data term0;
    set source.term;
    %subject;
    keep EDC_TreeNodeID SUBJECT VISIT TERMYN TERMDAT EDC_EntryDate;
run;


data term1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set term0;
	
    length termdtc $20;
	label  termdtc = 'If Yes, provide Visit Date';
	%ndt2cdt(ndt=termdat, cdt=termdtc);
	rc = h.find();
	drop rc rfstdtc;
    %concatDY(termdtc);
    label termyn = 'Was a Treatment Termination visit completed?';
run;

proc sort data = term1; by subject termdtc; run;

data pdata.term(label='Treatment Termination Prompt');
    retain EDC_TreeNodeID EDC_EntryDate subject termyn termdtc; 
    keep   EDC_TreeNodeID EDC_EntryDate subject termyn termdtc; 

    set term1;
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;

run;
