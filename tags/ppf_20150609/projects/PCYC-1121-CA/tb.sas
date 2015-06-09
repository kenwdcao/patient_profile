/*********************************************************************
 Program Nmae: TB.sas
  @Author: Yan Zhang
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:

 BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/05: Concatenate --DY to TBDTC.


*********************************************************************/
%include "_setup.sas";

data tb;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;

    length tbdtc  $20;
    keep subject pdseq visit  tbnd tbdtc tbrefid  __EDC_TreeNodeID __EDC_EntryDate;
    set source.tb (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate));
    %subject;
    tbnd = put(tbnd,$checked.);
    if unsseq ^=. then visit = strip(visit)||" "||strip(put(unsseq,best.));
    else if pdseq^=. then visit = strip(visit)||" "||strip(put(pdseq,best.));
    %ndt2cdt(ndt=tbdt, cdt=tbdtc);

    rc = h.find();
	%concatDY(tbdtc);
	drop rc;

run;

proc sort data = tb; by subject tbdtc;run;

data pdata.tb(label = 'Optional Tumor Tissue Biopsy');
    keep  __EDC_TreeNodeID __EDC_EntryDate subject visit  tbnd tbdtc tbrefid ;
    retain  __EDC_TreeNodeID __EDC_EntryDate subject visit  tbnd tbdtc tbrefid;
    attrib
    tbdtc                    label = 'Collection Date'
    visit                        label = 'Visit';
    set tb;
run;
