/*********************************************************************
 Program Nmae: PEABN.sas
  @Author: ZSS
  @Initial Date: 2015/03/17
 


 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc sort data=source.pkcyp out=s_pkcyp nodupkey; by _all_; run;

data pkcyp;
     length subject $255 rfstdtc $10;
     if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
     end;

      set s_pkcyp(rename=(id=__id pknd=in_pknd pkdtc=in_pkdtc));

	  %subject;
      rc = h.find();
      length pkdtc $20;   
      pkdtc = in_pkdtc;
     %concatDY(pkdtc);
     
	 length pktpt pktm pktptnd pkndsp $200;
	  **** PK not done ****;
      pktpt=''; pktptn=. ; pktm=''; pktptnd=''; pkndsp='';
      if in_pknd=1 then pknd="Yes";
	  if pknd^='' then output;

	  **** pre-dose ****;
      pktpt=''; pktptn=. ; pktm=''; pktptnd=''; pkndsp='';
	  pktpt='Pre-Dose'; pktptn=0;
	  pktm=strip(pktm1c);
	  if pknd1^=. then pktptnd='Yes';
	  pkndsp=strip(pkndsp1);
	  if cmiss(pktm, pktptnd, pkndsp)<3 then output;

	  **** 1 hour post dose ****;
      pktpt=''; pktptn=. ; pktm=''; pktptnd=''; pkndsp='';
	  pktpt='1 Hour Post-Dose'; pktptn=1;
	  pktm=strip(pktm2c); 
	  if pknd2^=. then pktptnd='Yes';
	  pkndsp=strip(pkndsp2);
	  if cmiss(pktm, pktptnd, pkndsp)<3 then output;

	  **** 2 Hour Post-Dose ****;
      pktpt=''; pktptn=. ; pktm=''; pktptnd=''; pkndsp='';
	  pktpt='2 Hour Post-Dose'; pktptn=2;
	  pktm=strip(pktm3c);
	  if pknd3^=. then pktptnd='Yes';
	  pkndsp=strip(pkndsp3);
	  if cmiss(pktm, pktptnd, pkndsp)<3 then output;

	  **** 4 Hour Post-Dose ****;
      pktpt=''; pktptn=. ; pktm=''; pktptnd=''; pkndsp='';
	  pktpt='4 Hour Post-Dose'; pktptn=4;
	  pktm=strip(pktm4c);
	  if pknd4^=. then pktptnd='Yes';
	  pkndsp=strip(pkndsp4);
	  if cmiss(pktm, pktptnd, pkndsp)<3 then output;

      keep __id subject event_no event_id pknd pkdtc pkrefid pkpdstmc pkdostmc pksm pktpt pktptn pktm pktptnd pkndsp;
run;


proc sort data=pkcyp; by subject  pkdtc event_no  pktptn; run;

data pdata.pkcyp(label="PK - Strong/Moderate CYP3A4/5 Inhibitors");
     retain __id subject __event_no event_id pknd pkdtc pkrefid pkpdstmc pkdostmc pksm pktpt __pktptn pktm pktptnd pkndsp;
     set pkcyp (rename=(event_no=__event_no pktptn=__pktptn));
	 attrib
     event_id            label = "Visit"
     pknd                 label = "PK Not Done"
     pkdtc                label = "Collection Date"
     pkrefid              label = "Accession Number"
     pkpdstmc          label = "Previous Day Dose Time"
     pkdostmc          label = "Today's Dose Time"
     pksm                label = "Concomitant Medication Name"
     pktpt                 label = "Collection Period"
     pktm                 label = "Collection Time"
     pktptnd             label = "Not Done"
     pkndsp              label = "Reason Sample Not Done"
	 ;
	 keep __id subject __event_no event_id pknd pkdtc pkrefid pkpdstmc pkdostmc pksm pktpt __pktptn pktm pktptnd pkndsp;
run;

