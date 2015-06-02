/*********************************************************************
 Program Nmae: surv.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data surv0;
    set source.surv;
    %subject;
    keep EDC_TreeNodeID SUBJECT VISIT SSALIVE SEQ SSDAT SSALVDAT EDC_EntryDate;
run;


data surv1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set surv0;
	
    length ssdtc ssalvdtc $20;
	label     ssdtc = 'Date of Contact';
	label   ssalive = 'Is the Subject Alive?';
	label  ssalvdtc = 'Date Last Known Alive';
	%ndt2cdt(ndt=ssdat, cdt=ssdtc);
    %ndt2cdt(ndt=ssalvdat, cdt=ssalvdtc);
	rc = h.find();
	drop rc rfstdtc;
    %concatDY(ssdtc);
    %concatDY(ssalvdtc);
run;

proc sort data = surv1; by subject ssdtc; run;

data pdata.surv(label='Survival Status');
    retain EDC_TreeNodeID EDC_EntryDate subject visit seq ssdtc ssalive ssalvdtc; 
    keep   EDC_TreeNodeID EDC_EntryDate subject visit seq ssdtc ssalive ssalvdtc; 

    set surv1;
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
	rename          visit = __visit;
	rename            seq = __seq;
run;
