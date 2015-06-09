/*********************************************************************
 Program Nmae: disc.sas
  @Author: Meiping Wu
  @Initial Date: 2015/05/04
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data disc0;
    set source.disc;
    %subject;
    keep EDC_TreeNodeID SUBJECT DISCCAT DOSEYN DISCRSN WDCNTSP DISDLTYN LDOSEDAT EDC_EntryDate;
run;


data disc1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set disc0;
	
    length ldosedtc $20;
	label   ldosedtc = 'Date of Last Dose';
	%ndt2cdt(ndt=ldosedat, cdt=ldosedtc);
	rc = h.find();
	drop rc rfstdtc;
    %concatDY(ldosedtc);
run;

proc sort data = disc1; by subject ldosedtc disccat; run;

data pdata.disc(label='Study Drug Discontinuation');
    retain EDC_TreeNodeID EDC_EntryDate subject disccat doseyn ldosedtc discrsn wdcntsp disdltyn; 
    keep   EDC_TreeNodeID EDC_EntryDate subject disccat doseyn ldosedtc discrsn wdcntsp disdltyn; 

    set disc1;
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
	
	label    disccat = 'Study Drug Category';
	label     doseyn = "Did the subject receive any doses of study drug?";
	label    discrsn = 'Primary reason study drug was permanently discontinued or never administered';
	label    wdcntsp = 'If Withdrawal of consent or Investigator decision, specify';
	label   disdltyn = 'Was reason for study drug discontinuation considered a Dose Limiting Toxicity (DLT)?';
run;

