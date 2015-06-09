/*********************************************************************
 Program Nmae: RD.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/02/02
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
Ken Cao on 2015/03/04: Display UNK and NULL for RDSTDTC and RDENDTC.
Ken Cao on 2015/03/05: Concatenate --DY to RDSTDTC and RDENDTC.

*********************************************************************/
%include "_setup.sas";

data rd;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;

    set source.rd  (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate));
    length rdstdtc rdendtc $20;
    %subject;
    %concatDateV2(year=rdstyy, month=rdstmm, day=rdstdd, outdate=rdstdtc);
    %concatDateV2(year=rdenyy, month=rdenmm, day=rdendd, outdate=rdendtc);

	rc = h.find();
	%concatDY(rdstdtc);
	%concatDY(rdendtc);
	drop rc;

    rdsite09=strip(put(rdsite09,$checked.));
    rdsite03=strip(put(rdsite03,$checked.));
    rdsite01=strip(put(rdsite01,$checked.));
    rdsite04=strip(put(rdsite04,$checked.));
    rdsite10=strip(put(rdsite10,$checked.));
    rdsite02=strip(put(rdsite02,$checked.));
    rdsite05=strip(put(rdsite05,$checked.));
    rdsite06=strip(put(rdsite06,$checked.));
    rdsite07=strip(put(rdsite07,$checked.));
    rdsite08=strip(put(rdsite08,$checked.));
    rdsite12=strip(put(rdsite12,$checked.));
    keep subject rdstdtc rdendtc rdsite01 rdsite02 rdsite03 rdsite04 rdsite05 rdsite06 rdsite07
         rdsite08 rdsite09 rdsite10 rdsite12 rdsiteio rdsiteo __EDC_TreeNodeID __EDC_EntryDate;

run;

proc sort data=rd;by subject rdstdtc rdendtc;run;

data pdata.rd(label="Prior MZL Radiation");
    retain  __EDC_TreeNodeID __EDC_EntryDate subject rdstdtc rdendtc rdsite09 rdsite03 rdsite01 rdsite04 rdsite10 rdsite02 rdsite05 rdsiteio
         rdsite06 rdsite07 rdsite08 rdsite12 rdsiteo;
    attrib
    rdstdtc     label="Start Date"
    rdendtc     label="Stop Date"
    rdsite09    label="Orbit"
    rdsite03    label="Neck"
    rdsite01    label="Axilla"
    rdsite04    label="Chest"
    rdsite10    label="Abdomen"
    rdsite02    label="Groin"
    rdsite05    label="Unknown"
    rdsiteio    label="Other Location"
    rdsite06    label="Mantle"
    rdsite07    label="Para-Aortic"
    rdsite08    label="Inverted Y"
    rdsite12    label="Unknown"
    rdsiteo     label="Other Location"
    ;
    set rd;
    keep  __EDC_TreeNodeID __EDC_EntryDate subject rdstdtc rdendtc rdsite09 rdsite03 rdsite01 rdsite04 rdsite10 rdsite02 rdsite05 rdsiteio
         rdsite06 rdsite07 rdsite08 rdsite12 rdsiteo;
run;
