/*********************************************************************
 Program Nmae: CH.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/02/25
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/02/27: 1) Add label for variable CHSTDTC;
                        2) Fix CHCATEG;


*********************************************************************/
%include "_setup.sas";

data ch;
    length chstdtc $10 chcateg $200;
    set source.ch(rename=(chcateg=chcateg_));
    %subject;
    label chstdtc = 'Initial DLBCL Diagnosis Date';
    %concatDate(year=chstyy, month=chstmm, day=chstdd, outdate=chstdtc);
    ** Ken Cao on 2015/02/27: Fix e r r o r;
/*    if chcatego^="" then chcateg=chcateg_;else chcateg=chcateg_;*/
    if chcatego^="" then chcateg='Other: '||chcatego;else chcateg=chcateg_;
    
    __edc_treenodeid=edc_treenodeid ;
    __edc_entrydate=edc_entrydate;
    keep __edc_treenodeid __edc_entrydate subject chstdtc chcateg chstatus chref;
run;

proc sort data=ch;by subject chstdtc;run;

data pdata.ch (label="DLBCL Disease History");
    retain __edc_treenodeid __edc_entrydate subject chstdtc chcateg chstatus chref;
    attrib
    chcateg     label="DLBCL Category"
    ;
    set ch;
    keep __edc_treenodeid __edc_entrydate subject chstdtc chcateg chstatus chref;

    label chstatus = 'Disease status at completion of treatment regimen preceding entry into the study';
    label chref = 'If Refractory';
run;

