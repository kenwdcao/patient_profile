/*********************************************************************
 Program Name: LBPREG.sas
  @Author: Xiaoli Huang
  @Initial Date: 2015/03/13

 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data pregnancy;
    length subject $255  rfstdtc $10 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    keep __id subject visit lbdtc lbtmc lbcode lbnd lbspec lbultres lborres lbtmunk;
    set source.lbpregl( rename = (lbdtc=__lbdtc) );
/*    lbcat = 'Pregnancy Test';*/
    %subject;
    visit = event_id ;
	__id= id;

    length lbdtc $20;
	lbdtc=__lbdtc;

    rc = h.find();
    %concatDY(lbdtc);
    drop rc;

run;

proc sort data = pregnancy; by subject lbdtc lbtmc ;run;

data pdata.lbpreg(label= 'Pregnancy Test Local');
    keep  __id subject visit lbnd lbcode lbdtc lbtmc lbtmunk lbspec lbultres lborres;
    retain __id subject visit lbnd lbcode lbdtc lbtmc lbtmunk lbspec lborres lbultres;
    set pregnancy;
    attrib visit            label = 'Visit'
            lbdtc           label = 'Collection Date'
			lbtmc          label = 'Collection Time'
			LBORRES     label ='Result'
            lbultres        label = 'If Positive, Result of Ultrasound';
run;
