/*********************************************************************
 Program Nmae: PEABN.sas
  @Author: ZSS
  @Initial Date: 2015/03/17
 


 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc sort data=source.visit out=s_visit nodupkey; by _all_; run;

data sv;
     length subject $255 rfstdtc $10;
     if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
     end;

      set s_visit(rename=(id=__id  svstdtc=in_svstdtc));

	  %subject;
      rc = h.find();
      length svstdtc $20;   
      svstdtc = in_svstdtc;
     %concatDY(svstdtc);
     
      keep __id subject event_no event_id svstdtc ;
run;


proc sort data=sv; by subject  svstdtc event_no ; run;

data pdata.sv(label="Visit Date");
     retain __id subject __event_no event_id svstdtc;
     set sv (rename=(event_no=__event_no));
	 attrib
     event_id            label = "Visit"
     svstdtc              label = "Visit Date"
	 ;
	 keep __id subject __event_no event_id svstdtc;
run;

