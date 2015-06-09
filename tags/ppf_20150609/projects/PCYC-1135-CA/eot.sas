/*********************************************************************
 Program Nmae: eot.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data eot0;
    set source.eot;
    %subject;
    keep EDC_TreeNodeID SUBJECT VISIT EOTCAT EOTYN EOTRSNSP EOTDAT EDC_EntryDate;
run;


data eot1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set eot0;
	
    length eotdtc $20;
	label   eotdtc = 'If Yes, provide Visit Date';
	%ndt2cdt(ndt=eotdat, cdt=eotdtc);
	rc = h.find();
	drop rc rfstdtc;
    %concatDY(eotdtc);
run;

proc sort data = eot1; by subject eotdtc eotcat; run;

data pdata.eot(label='End of Treatment - Visit Prompt');
    retain EDC_TreeNodeID EDC_EntryDate subject visit eotcat eotyn eotdtc eotrsnsp; 
    keep   EDC_TreeNodeID EDC_EntryDate subject visit eotcat eotyn eotdtc eotrsnsp; 

    set eot1;
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
	rename          visit = __visit;

	label     eotyn = "Was an End of Treatment &splitchar.visit completed?";
	label  eotrsnsp = 'If No, specify reason';
	label    eotcat = 'Drug Name Category';
run;
