/*********************************************************************
 Program Nmae: ex.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/23
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/


%include '_setup.sas';

data ex1;
     length subject $13  __rfstdtc  $10 FDOSEDTc $20  aenum $200 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set source.ex(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
  
    __excat=strip(excat);
    **Date**;
    %ndt2cdt(ndt=EXDOSFDT, cdt=FDOSEDTC);
    rc = h.find();
    %concatDY(FDOSEDTC);

    *****received drug**;
	if AENUM1^=. or AENUM2=. or AENUM3^=. then AENUM=cat(put(AENUM1, best.),put(AENUM2, best.),put(AENUM2, best.));
    %subject;
run;

proc sort data = ex1; by subject fdosedtc; run;

data pdata.ex(label='First Dose Study Drug');
    retain __edc_treenodeid __edc_entrydate subject __excat exdosef fdosedtc exreas exreaso aenum;     
    keep __edc_treenodeid __edc_entrydate subject __excat exdosef fdosedtc exreas exreaso aenum;     
    set ex1;

    label exdosef = 'Did the subject receive first dose of ibrutinib?';
    label fdosedtc = 'If ''Yes'' please provide Date of First Dose';
    label exreas = 'If ''No'', please indicate reason';
	label exreaso='Specify reason';
    label aenum = 'If reason is AE, please provide AE Number(s)';
run;


