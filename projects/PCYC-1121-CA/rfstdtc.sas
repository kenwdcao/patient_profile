/*********************************************************************
 Program Nmae: RFSTDTC.sas
  @Author: Ken Cao
  @Initial Date: 2015/03/04
 
 Derive first dose date for each subject.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc sql;
    create table fdose0 as
    select subject, put(min(exstdt), yymmdd10.) as rfstdtc length=10 label = 'First Dose Date'
    from source.ex
    group by subject
    ;
quit;

data fdose;
    set fdose0;
    %subject;
run;


data pdata.rfstdtc(label = 'Reference Start Date for --DY');
    retain subject rfstdtc;
    keep subject rfstdtc;
    set fdose;
run;
