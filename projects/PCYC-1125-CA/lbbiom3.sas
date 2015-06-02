/*********************************************************************
 Program Name: LBBIOM3.sas
  @Author: Xiaoli Huang
  @Initial Date: 2015/03/13
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data biom3;
    length subject $255  rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    keep __id subject visit lbdtc lbtmc lbnd lbrefid lbdostmc event_no ;
    set source.lbbiom3( rename = (lbdtc=__lbdtc) );
    %subject;
    visit = event_id ;
	__id= id;

    length lbdtc $20;
	lbdtc=__lbdtc;

    rc = h.find();
    %concatDY(lbdtc);
    drop rc;
run;
proc sort data = biom3; by subject lbdtc event_no lbtmc ;run;

data pdata.lbbiom3(label= 'Biomarkers - ARM 1: Week 9 and 13, Treatment Termination; ARM 2: Week 16 and 20, Treatment Termination');
    keep  __id subject visit lbnd  lbdtc lbrefid lbdostmc lbtmc ;
    retain __id subject visit lbnd  lbdtc lbrefid lbdostmc lbtmc ;
    set biom3;
    attrib visit            label = 'Visit'
            lbdtc           label = 'Collection Date'
			lbtmc          label = 'Pre-Dose Collection Time'
            lbdostmc     label = 'Ibrutinib Dose Time';
run;
