/*********************************************************************
 Program Nmae: EYE.sas
  @Author: Huihui Zhang
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/05: Concatenate --DY to EYTESTDTC..

*********************************************************************/
%include '_setup.sas';

proc sort data=source.eye out=s_eye nodupkey; by _all_; run;

data eye01;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;
    length eytestdtc $19;
    set s_eye(rename=(EDC_EntryDate=__EDC_EntryDate));
     %subject;
    /*if visit>'' then visitnum=input(put(visit,$vnum.),best.);*/
    %ndt2cdt(ndt=eytestdt, cdt=eytestdtc);
    
	rc = h.find();
	%concatDY(eytestdtc);
	drop rc;

    visit = compress(compbl(strip(visit)||" "||strip(put(pdseq,best.))||" "||strip(put(unsseq,best.))),'.');
    __edc_treenodeid=edc_treenodeid;
    drop edc_:;
    if eyoccur^='' or eytest^='';
run;

proc sort data=eye01; by subject eytestdtc visit eytest; run;

data pdata.eye(label="Eye-Related Symptoms");
    retain __edc_treenodeid __EDC_EntryDate subject visit eytestdtc eyoccur eytest eyorres ;
    keep __edc_treenodeid __EDC_EntryDate subject visit eytestdtc eyoccur eytest eyorres ;
    set eye01;
    label 
        eytestdtc = 'Assessment Date'
        visit = 'Visit';
run;
