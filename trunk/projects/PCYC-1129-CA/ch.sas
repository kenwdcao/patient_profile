/*********************************************************************
 Program Nmae: ch.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/
%include "_setup.sas";

data ch;
    length subject $13 __rfstdtc $10 chstdtc $20 ;
	 if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
    set source.ch(rename=( edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate));
    %subject;
    %visit2;
    %concatDate(year=chstyy, month=chstmm, day=chstdd, outdate=chstdtc);
	rc = h.find();
    %concatDY(chstdtc);
run;

proc sort data=ch;by subject chstdtc;run;

data pdata.ch (label="Transplant History");
    retain __edc_treenodeid __edc_entrydate subject visit2 chstdtc chtype chdonrel chdonhla chsource chsexsou;
    keep __edc_treenodeid __edc_entrydate subject visit2 chstdtc chtype chdonrel chdonhla chsource chsexsou;
    set ch;
	label chstdtc="Date of Transplant";
	label chdonhla="HLA matching of cell graft between donor and recipient";
run;


