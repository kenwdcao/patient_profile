/*********************************************************************
 Program Nmae: SP.sas
  @Author: Yan Zhang
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/04: Split variable SPRES and SPRESS.
 Ken Cao on 2015/03/05: Concatenate --DY to SPDTC.

*********************************************************************/
%include "_setup.sas";

data sp;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;
    length spdtc $20 spres $200;
    keep subject spdtc spdesc spdesco  spcyt spsam spsams  spsite spres spresp spress seq __EDC_TreeNodeID __EDC_EntryDate;
    set source.sp (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate));
    if spyn = '';
    /*
    if spress ^='' then spres = strip(spres)||": "||strip(spress);
    else spres = strip(spres);
    */
    %subject;
    %ndt2cdt(ndt=spdt, cdt=spdtc);

	rc = h.find();
	%concatDY(spdtc);
	drop rc;

run;

proc sort data = sp; by subject spdtc spdesc;run;

data pdata.sp(label = 'Surgeries and Procedures');
    keep  __EDC_TreeNodeID __EDC_EntryDate subject spdtc spdesc spdesco  spcyt spsam spsams  spsite spres spresp spress;
    retain  __EDC_TreeNodeID __EDC_EntryDate subject spdtc spdesc spdesco  spcyt spsam spsams  spsite spres spresp spress;
    attrib
    spdtc                    label = 'Date'
    spdesc                   label = 'Surgeries and/or Procedures Description';
    set sp;
	label spress = 'Other Result, Specify';
run;
