/*********************************************************************
 Program Nmae: PEABN.sas
  @Author: ZSS
  @Initial Date: 2015/03/16
 


 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc sort data=source.ecog out=s_ecog nodupkey; by _all_; run;

**** ECOG status ***;
data ecog;
     length subject $255 rfstdtc $10;
     if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
     end;

      set s_ecog(rename=(id=__id qsnd=in_qsnd qsorres=in_qsorres qsdtc=in_qsdtc));

	  %subject;
      if in_qsnd=1 then qsnd="Yes";
      if in_qsorres^=. then qsorres=strip(put(in_qsorres, gsorres.));

      rc = h.find();
      length qsdtc $20;   
      qsdtc = in_qsdtc;
     %concatDY(qsdtc);

run;

proc sort data=ecog; by subject  qsdtc  event_no ; run;

data pdata.ecog(label="ECOG");
     retain __id subject __event_no event_id qsnd qsdtc qsorres;
     set ecog (rename=(event_no=__event_no));
	 attrib
     event_id          label = "Visit"
     qsdtc              label = "Assessment Date"
     qsnd                label = "ECOG Not Done"
     qsorres             label = "ECOG Result"
	 ;
	 keep __id subject __event_no event_id qsdtc qsnd qsorres;
run;




