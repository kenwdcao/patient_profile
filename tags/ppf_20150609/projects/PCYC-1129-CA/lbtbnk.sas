/*********************************************************************
 Program Nmae: lbtbnk.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data lbtbnk(rename=(EDC_TREENODEID=__EDC_TREENODEID EDC_ENTRYDATE=__EDC_ENTRYDATE));
    length subject $13 __rfstdtc $10 lbdtc lbcdotm_ lbtm_$20 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set source.lbtbnk;
    %subject;
	 %visit2;
    ** Collection  Date;
    label lbdtc = 'Collection Date';
    label lbtm_ = 'Collection Time';
	label lbcdotm_='Current Day - Ibrutinib Dose Time';
	 if lbcdotm^=. then lbcdotm_=put(lbcdotm, time5.); else lbcdotm_="";
    if lbtm^=. then lbtm_=put(lbtm, time5.); else lbtm_="";
    %ndt2cdt(ndt=lbdt, cdt=lbdtc);
    rc = h.find();
    %concatDY(lbdtc);
	format lbnd lbstat lbcdotmu checked.;
run;

proc sort data = lbtbnk; by subject lbdtc  visit2; run;

data pdata.lbtbnk(label='T/B/NK Cell Counts');
    retain __edc_treenodeid __edc_entrydate subject visit2 lbdtc lbstat lbcdotm_ lbcdotmu lbtpt lbtm_ lbnd lbnds ;
    keep __edc_treenodeid __edc_entrydate subject visit2  lbstat lbdtc lbcdotm_ lbcdotmu  lbtpt lbtm_ lbnd lbnds ;
    set lbtbnk;
	label lbtpt="Collection Period"
	      lbstat="Collection Date Not Done"
	      lbnd="Sample Collection Not Done"
          lbnds="Sample Collection Not Done reason"
          ;
run;


