/*********************************************************************
 Program Nmae: lbbio.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data lbbio(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 __rfstdtc $10 lbdtc $20 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set source.lbbio;
    %subject;
	 %visit2;
    ** Collection  Date;
    label lbdtc = 'Collection Date';
    %ndt2cdt(ndt=lbdt, cdt=lbdtc);
    rc = h.find();
    %concatDY(lbdtc);
	format lbnd checked.;
run;


proc sort data = lbbio; by subject lbdtc visit2 ; run;

data pdata.lbbio(label='Biomarkers');
    retain __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbnd;
    keep __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbnd   ;
    set lbbio;
	label lbnd="Collection Date Not Done";
run;


