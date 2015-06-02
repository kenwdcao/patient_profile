/*********************************************************************
 Program Nmae: DD.sas
  @Author: Huihui Zhang
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/05: Concatenate --DY to LDOSEDTC.
*********************************************************************/
%include '_setup.sas';

proc sort data=source.dd out=s_dd nodupkey; by _all_; run;

data dd01;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
    	declare hash h (dataset:'pdata.rfstdtc');
    	rc = h.defineKey('subject');
    	rc = h.defineData('rfstdtc');
    	rc = h.defineDone();
    	call missing(subject, rfstdtc);
    end;
    length aenumae $20 ldosedtc $19;
    set s_dd(rename=(aenumae=in_aenumae));
     %subject;
    if in_aenumae>. then aenumae=strip(put(in_aenumae,best.)); else aenumae='';
    %ndt2cdt(ndt=ldosedt, cdt=ldosedtc);
    rc = h.find();
    %concatDY(ldosedtc);
    drop rc;
    
    __edc_treenodeid=edc_treenodeid ;
/*    drop edc_:;*/
    rename EDC_EntryDate = __EDC_EntryDate;
run;

proc sort data=dd01; by subject; run;

data pdata.dd(label="Study Drug Discontinuation");
    retain __edc_treenodeid __EDC_EntryDate subject ldoseyn discreas aenumae ldosedtc;
    keep __edc_treenodeid __EDC_EntryDate subject ldoseyn discreas aenumae ldosedtc;
    set dd01;
    label 
        aenumae = 'Adverse Event AE Number'
        ldosedtc = 'Date of Last Dose'
    ;
run;
