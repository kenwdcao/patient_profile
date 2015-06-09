/*********************************************************************
 Program Nmae: DR.sas
  @Author: Taodong Chen
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/04: Display UNK and NULL for DTHDTC..
 Ken Cao on 2015/03/05: Concatenate --DY to DTHDTC.

*********************************************************************/
%include '_setup.sas';

proc sort data=source.dr out=s_dr nodupkey; by _all_; run;

data dr01;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
    	declare hash h (dataset:'pdata.rfstdtc');
    	rc = h.defineKey('subject');
    	rc = h.defineData('rfstdtc');
    	rc = h.defineDone();
    	call missing(subject, rfstdtc);
    end;
    length dthdtc  $40;
    set s_dr(rename=(EDC_EntryDate=__EDC_EntryDate));
     %subject;
     %concatDateV2(year=deathyy, month=deathmm, day=deathdd, outdate=dthdtc);
    rc = h.find();
    %concatDY(dthdtc);
    drop rc;

     __edc_treenodeid=edc_treenodeid ;
    drop edc_:;
run;

proc sort data=dr01; by subject; run;

data pdata.dr(label="Death Report");
    retain __edc_treenodeid __EDC_EntryDate subject dthdtc deathcs deathsp;
    keep __edc_treenodeid __EDC_EntryDate subject dthdtc deathcs deathsp;
    set dr01;
    label 
        dthdtc = 'Date of Death'
    ;
run;
