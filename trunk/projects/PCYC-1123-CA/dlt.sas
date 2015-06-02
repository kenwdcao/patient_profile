/*********************************************************************
 Program Nmae: DLT.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/15
*********************************************************************/
%include "_setup.sas";


data dlt;
    length subject $13  dlt $200;
    set source.dlt(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate));
    %subject;

    **combine ae number**; 
    aenum=catx(", ", strip(vvaluex('aenum01')),strip(vvaluex('aenum02')),strip(vvaluex('aenum03')));
    label dlt = 'Did the subject experience a dose limiting toxicity (DLT)?';
    dlt = ifc( aenum > ' ', cat(strip(dltyn), ' (AE Number: ', strip(aenum), ')'), strip(dltyn));
run;

proc sort data=dlt; by subject ; run;

data pdata.dlt(label='DLT Assessment');
    retain __edc_treenodeid __edc_entrydate subject dltyn aenum01 aenum02 aenum03;
    keep __edc_treenodeid __edc_entrydate subject dltyn aenum01 aenum02 aenum03;
    set dlt;

    label dltyn = 'Did the subject experience a dose limiting toxicity (DLT)?';
    label aenum01 = 'AE Number 1@:If yes, specify AE number(s):';
    label aenum02 = 'AE Number 2@:If yes, specify AE number(s):';
    label aenum03 = 'AE Number 3@:If yes, specify AE number(s):';
run;
