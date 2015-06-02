/*********************************************************************
 Program Name: LBBIOM2.sas
  @Author: Xiaoli Huang
  @Initial Date: 2015/03/13
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data biom2;
    length subject $255  rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    keep __id subject visit lbdtc lbnd lbrefid lbdostmc lbtm1c lbnd1 lbndsp1 lbtm2c lbnd2 lbndsp2 event_no;
    set source.lbbiom2( rename = (lbdtc=__lbdtc) );
    %subject;
    visit = event_id ;
	__id= id;

    length lbdtc $20;
	lbdtc=__lbdtc;

    rc = h.find();
    %concatDY(lbdtc);
    drop rc;
run;
proc sort data = biom2; by subject lbdtc event_no lbdostmc ;run;

data pdata.lbbiom2(label= 'Biomarkers - ARM 1: Week 1 and 3; ARM 2: Week 1, 3, 9, and 11');
    keep  __id subject visit lbnd lbdtc lbrefid lbdostmc lbtm1c lbnd1 lbndsp1 lbtm2c lbnd2 lbndsp2;
    retain __id subject visit lbnd lbdtc lbrefid lbdostmc lbtm1c lbnd1 lbndsp1 lbtm2c lbnd2 lbndsp2;
    set biom2;
    attrib visit            label = 'Visit'
            lbdtc           label = 'Collection Date'
            lbdostmc           label = 'Ibrutinib Dose Time'
            lbtm1c           label = 'Pre-Dose Collection Time'
            lbtm2c           label = '4 Hour Post-Dose Collection Time';
run;
