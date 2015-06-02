/*********************************************************************
 Program Nmae: CMPS.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data cmps0;
    set source.cmps;
    keep edc_treenodeid edc_entrydate subject psterm psdd psmm psyy visit seq;
    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;
run;

data cmps1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set cmps0;
    %subject;
    
    ** Date of Procedure;
    length psdtc $20;
    label psdtc = 'Date of Procedure';
    %concatDate(year=psyy, month=psmm, day=psdd, outdate=psdtc);
    rc = h.find();
    %concatDY(psdtc);
    drop psyy psmm psdd rc;

    ** Visit;
    length cycle $10;
    cycle = cycle;
    %visit;
run;

data pdata.cmps(label='Prior DLBCL Surgery');
    retain __edc_treenodeid __edc_entrydate subject visit2 psdtc psterm;
    keep __edc_treenodeid __edc_entrydate subject visit2 psdtc psterm;
    set cmps1;
    rename visit2 = __visit;
run;
