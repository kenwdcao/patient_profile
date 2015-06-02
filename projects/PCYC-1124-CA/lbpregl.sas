/********************************************************************************
 Program Nmae: LBPREGL.sas
  @Author: Yan Zhang
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

data lbpregl0;
	length cycle $10 visit $29;
    set source.lbpregl(keep=edc_treenodeid edc_entrydate subject lbcat lborres seq lbdt lbspec);

    %subject;
    length lbdtc $20;
    label lbdtc = 'Collection Date';
    %ndt2cdt(ndt=lbdt, cdt=lbdtc);
    drop lbdt;

    cycle = cycle;
	visit = visit;** in case that cycle is added in the furture.;
	%visit;

    rename edc_treenodeid = __edc_treenodeid;
    rename edc_entrydate = __edc_entrydate;

    ** variable that will be kept but will not be displayed;
    rename lbcat = __lbcat;
run;

data lbpregl1;
    length subject $13 rfstdtc $10;
    length sex $6 __age 8;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        declare hash h2 (dataset:'pdata.dm');
        rc2 = h2.defineKey('subject');
        rc2 = h2.defineData('sex','__age');
        rc2 = h2.defineDone();
        call missing(subject, rfstdtc, sex, __age);
    end;
    set lbpregl0;
    rc = h.find();
    rc2 = h2.find();
    %concatdy(lbdtc);
    drop rc rc2;
run;

proc sort data = lbpregl1; by subject lbdtc visit2; run;

data out.lbpregl(label = 'Pregnancy Test');
	keep __edc_treenodeid __edc_entrydate subject lbdtc visit2 lbspec lborres;
	retain __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbspec lborres;
	set lbpregl1;
run;
