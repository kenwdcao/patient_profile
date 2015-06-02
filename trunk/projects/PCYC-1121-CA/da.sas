/*********************************************************************
 Program Nmae: DA.sas
  @Author: Huihui Zhang
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

Ken Cao on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
Ken Cao on 2015/03/05: Concatenate --DY to DADTC.


*********************************************************************/
%include '_setup.sas';

proc sort data=source.da out=s_da nodupkey; by _all_; run;

proc sort data=s_da; by subject daseq datest; run;

data da01;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
    	declare hash h (dataset:'pdata.rfstdtc');
    	rc = h.defineKey('subject');
    	rc = h.defineData('rfstdtc');
    	rc = h.defineDone();
    	call missing(subject, rfstdtc);
    end;
    length darefid $200 dadtc $19;
    set s_da(rename=(darefid=in_darefid));
    by subject daseq datest;
    retain darefid;
    if first.daseq then darefid=in_darefid;
        else darefid=darefid;
     %subject;
    if datest='Returned' then darefid="&escapechar{style [fontstyle=italic]"||strip(darefid)||"}";
    %ndt2cdt(ndt=dadt, cdt=dadtc);
    rc = h.find();
    %concatDY(dadtc);
    drop rc;
    *drop edc_:;

    rename EDC_TREENODEID = __EDC_TREENODEID;
    rename EDC_EntryDate  = __EDC_EntryDate;
run;

/*proc sort data=da01; by subject darefid datest dadtc; run;*/

data pdata.da(label="Study Drug Accountability");
    retain __edc_treenodeid __EDC_EntryDate subject datest darefid daorres daorresu dadtc dareas;
    keep __edc_treenodeid __EDC_EntryDate subject datest darefid daorres daorresu dadtc dareas;
    set da01;
    label 
        darefid = 'Treatment Label ID'
        dadtc = 'Date of Accountability Assessment'
        daorresu = 'Unit'
    ;
run;
