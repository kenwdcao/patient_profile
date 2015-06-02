/*********************************************************************
 Program Nmae: PS.sas
  @Author: Huihui Zhang
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
Ken Cao on 2015/03/04: Display UNK and NULL for psdtc.
 Ken Cao on 2015/03/05: Concatenate --DY to PSDTC.
*********************************************************************/
%include '_setup.sas';

proc sort data=source.ps out=s_ps nodupkey; by _all_; run;

data ps01;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;
    length psdtc $19;
    set s_ps (rename=(EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate));
    %subject;
    %concatDateV2(year=psyy, month=psmm, day=psdd, outdate=psdtc);

	rc = h.find();
	%concatDY(psdtc);
	drop rc;

    drop edc_:;
run;

proc sort data=ps01; by subject psdtc; run;

data pdata.ps(label="Prior MZL Surgery");
    retain __EDC_TreeNodeID __EDC_EntryDate subject psterm psdtc ;
    keep __EDC_TreeNodeID __EDC_EntryDate subject psterm psdtc ;
    set ps01;
    label 
        psdtc = 'Date of Procedure'
    ;
run;
