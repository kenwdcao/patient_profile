/*********************************************************************
 Program Name: LBBIOM1.sas
  @Author: Xiaoli Huang
  @Initial Date: 2015/03/13

 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data biom1;
    length subject $255  rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    keep __id subject visit lbdtc lbtmc lbnd  lbrefid event_no;
    set source.lbbiom1( rename = (lbdtc=__lbdtc) );
    %subject;
    visit = event_id ;
	__id= id;

    length lbdtc $20;
	lbdtc=__lbdtc;

    rc = h.find();
    %concatDY(lbdtc);
    drop rc;
run;
proc sort data = biom1; by subject lbdtc event_no lbtmc ;run;

data pdata.lbbiom1(label= 'Biomarkers - ARM 1 and ARM 2: Screening, CR or PD, SFU');
    keep  __id subject visit lbnd lbdtc lbrefid lbtmc ;
    retain __id  subject visit lbnd lbdtc lbrefid lbtmc ;
    set biom1;
    attrib visit            label = 'Visit'
            lbdtc           label = 'Collection Date'
			lbtmc          label = 'Collection Time';
run;
