/*********************************************************************
 Program Nmae: SE.sas
  @Author: Taodong Chen
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/05: Concatenate --DY to EXITDTC.
*********************************************************************/
%include '_setup.sas';

proc sort data=source.se out=s_se nodupkey; by _all_; run;

data se01;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;

    length exitdtc  $40;
    set s_se(rename=(EDC_EntryDate=__EDC_EntryDate));
    %subject;
    %ndt2cdt(ndt=dsexitdt, cdt=exitdtc);

    rc = h.find();
	%concatDY(exitdtc);
	drop rc;

    __edc_treenodeid =edc_treenodeid ;
    drop edc_:;
run;

proc sort data=se01; by subject; run;

data pdata.se(label="Study Exit");
    retain __edc_treenodeid __EDC_EntryDate subject exitdtc dsreas dsreaso;
    keep __edc_treenodeid __EDC_EntryDate subject exitdtc dsreas dsreaso;
    set se01;
    label 
        exitdtc = 'Date of Study Exit'
    ;
run;
