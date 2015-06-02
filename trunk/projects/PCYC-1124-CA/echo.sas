/*********************************************************************
 Program Nmae: ECHO.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data echo0;
    set source.echo;
    keep edc_treenodeid edc_entrydate subject echotyp seq echodt echoper visit;
    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;
run;


data echo1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set echo0;
    %subject;
    ** Assessment Date;
    length echodtc $20;
    label echodtc = 'Assessment Date';
    %ndt2cdt(ndt=echodt, cdt=echodtc);
    rc = h.find();
    %concatDY(echodtc);
    drop echodt rc;

    ** visit;
    length cycle $10;
    cycle = cycle; ** make a dummy variable;
    %visit;


run;


data pdata.echo(label='ECHOCARDIOGRAM / MUGA');
    retain __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2  ECHODTC ECHOTYP ECHOPER;
    keep __EDC_TREENODEID __EDC_ENTRYDATE SUBJECT VISIT2  ECHODTC ECHOTYP ECHOPER;
    set echo1;
run;





