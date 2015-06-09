/*********************************************************************
 Program Nmae: SS.sas
  @Author: Yan Zhang
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/04: Change SSLALVDTC label to "If Lost to FU, Date Last Known Alive".
 Ken Cao on 2015/03/05: Concatenate --DY to SSCONTDTC and SSLALVDTC .
*********************************************************************/
%include "_setup.sas";

data ss;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;
    length sscontdtc  sslalvdtc $20;
    keep subject visit sscontp sscontpo ssalive seq sscontdtc sslalvdtc __EDC_TreeNodeID __EDC_EntryDate;
    set source.ss (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate));
    %subject;
    %ndt2cdt(ndt=sscontdt, cdt=sscontdtc);
    %ndt2cdt(ndt=sslalvdt, cdt=sslalvdtc);

	rc = h.find();
	%concatDY(sscontdtc);
	%concatDY(sslalvdtc);
	drop rc;

    visit = compbl(compress(strip(visit)||" "||strip(put(seq,best.)||" "||strip(put(unsseq,best.))),'.'));
run;

proc sort data = ss; by subject sscontdtc seq;run;

data pdata.ss(label = 'Survival Status');
    keep  __EDC_TreeNodeID __EDC_EntryDate subject visit sscontp sscontpo ssalive sscontdtc sslalvdtc;
    retain  __EDC_TreeNodeID __EDC_EntryDate subject visit sscontdtc sscontp sscontpo ssalive sslalvdtc;
    attrib
    sscontdtc                    label = 'Date of Contact'
    sslalvdtc                    label = 'Date Last Known Alive'
    visit                           label = 'Visit'
    sslalvdtc                    label = 'If Lost to FU, Date Last Known Alive';
    ;
    set ss;
run;
