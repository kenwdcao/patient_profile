/*********************************************************************
 Program Nmae: survyn.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data survyn0;
    set source.survyn;
    %subject;
    keep EDC_TreeNodeID SUBJECT SURVYN SURRSNSP EDC_EntryDate;
run;

data survyn1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set survyn0;
run;


data pdata.survyn(label='Survival Follow-Up Prompt');
    retain EDC_TreeNodeID EDC_EntryDate subject survyn surrsnsp; 
    keep   EDC_TreeNodeID EDC_EntryDate subject survyn surrsnsp; 

    set survyn1;
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
	label   survyn = 'Will the subject participate in Survival Follow-Up?'
	      surrsnsp = 'If No, specify reason'
		  ;
run;
