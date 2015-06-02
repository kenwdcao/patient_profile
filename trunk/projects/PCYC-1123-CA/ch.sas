/*********************************************************************
 Program Nmae: CH.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/15
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/
%include "_setup.sas";

data ch;
    length subject $13 rfstdtc $10 chstdtc $20 chcateg $200;
	if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set source.ch(rename=(chcateg=chcateg_ edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate));
    %subject;
    %concatDate(year=chstyy, month=chstmm, day=chstdd, outdate=chstdtc);
	rc = h.find();
    %concatDY(chstdtc);
    if chcatego^="" then chcateg='Other: '||chcatego;else chcateg=chcateg_;
run;

proc sort data=ch;by subject chstdtc;run;

data pdata.ch (label="DLBCL Disease History");
    retain __edc_treenodeid __edc_entrydate subject chstdtc chcateg chstatus chregnum;
    attrib
    chcateg   label="DLBCL Category" ;
	label chstatus = 'Disease status at completion of treatment regimen preceding entry into the study';
    label chregnum = 'Number of prior regimens';
	label chstdtc = 'Initial DLBCL Diagnosis Date';
    set ch;
    keep __edc_treenodeid __edc_entrydate subject chstdtc chcateg chstatus chregnum;
run;

