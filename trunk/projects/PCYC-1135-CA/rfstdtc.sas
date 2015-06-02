/*********************************************************************
 Program Nmae: RFSTDTC.sas
  @Author: Dongguo Liu
  @Initial Date: 2015/04/24
 
 Derive first dose date for each subject.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data ex;
    length exstdtc $19; 
    set source.ex;
    format exstdt date9.;
    if EXSTMO ne '' then EXSTMO = strip(put( EXSTMO, $mon.));
    if cmiss(EXSTYR, EXSTMO, EXSTDY) < 3 then do;
        exstdtc = strip(EXSTYR)||'-'||strip(EXSTMO)||'-'||strip(EXSTDY);
    end;
    if exstdtc ne '' then exstdt = input( exstdtc, yymmdd10.); 
    keep SUBJECT exstdtc exstdt;
run;

proc sql;
    create table fdose0 as
    select subject, put(min(exstdt), yymmdd10.) as rfstdtc length=10 label = 'First Dose Date'
    from ex
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
