/*********************************************************************
 Program Nmae: TT.sas
  @Author: Yan Zhang
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/05: Concatenate --DY to TTDTC and TTSDTC.
*********************************************************************/
%include "_setup.sas";

data tt;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;

    length ttdtc ttsdtc  $20;
    keep subject  ttyn ttdtc ttsdtc __EDC_TreeNodeID __EDC_EntryDate;
    set source.tt (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate));
/*  if ttyn = 'Yes';*/
    %subject;
    %ndt2cdt(ndt=ttdt, cdt=ttdtc);
    %ndt2cdt(ndt=ttsdt, cdt=ttsdtc);
    
	rc = h.find();
	%concatDY(ttdtc);
	%concatDY(ttsdtc);
	drop rc;

run;

proc sort data = tt; by subject ttdtc;run;

data pdata.tt(label = 'Archived Tumor Tissue');
    keep  __EDC_TreeNodeID __EDC_EntryDate subject  ttyn ttdtc ttsdtc;
    retain  __EDC_TreeNodeID __EDC_EntryDate subject  ttyn ttdtc ttsdtc;
    attrib
    ttdtc                    label = 'Date Sample Collected'
    ttsdtc                   label = 'Date Shipped';
    set tt;
run;
