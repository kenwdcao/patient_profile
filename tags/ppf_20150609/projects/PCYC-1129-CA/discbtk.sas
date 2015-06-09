/*********************************************************************
 Program Nmae: discbtk.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data discbtk0;
length subject $13 __rfstdtc $10 dsdtc $20 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
    set source.discbtk(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate ));
    %subject;
    %ndt2cdt(ndt=LDOSEDT, cdt=dsdtc);
    rc = h.find();
    %concatDY(dsdtc);
run;

proc sort data=discbtk0; by subject dsdtc; run;

data pdata.discbtk(label='Study Drug Discontinuation - Ibrutinib');
    retain __edc_treenodeid __edc_entrydate subject exyn dsdtc discrs aenum wthreaso ;
    keep __edc_treenodeid __edc_entrydate subject exyn dsdtc discrs aenum wthreaso;
    set discbtk0;
    label exyn = 'Did the subject receive any doses of ibrutinib?';
    label dsdtc = 'If Yes, Date of Last Dose';
    label  discrs  = 'Primary reason study drug was permanently discontinued or never administered';
	label  aenum  = 'If Unacceptable Toxicity, provide AE Number';
	label  wthreaso  = 'If Subject or Investigator decision, specify';
run;

