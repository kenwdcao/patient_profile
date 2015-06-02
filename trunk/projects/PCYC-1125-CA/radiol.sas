/*********************************************************************
 Program Nmae: PEABN.sas
  @Author: ZSS
  @Initial Date: 2015/03/16
 


 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc sort data=source.radiol out=s_radiol nodupkey; by _all_; run;

**** Imaging by CT/MRI (Baseline) ***;
data radiol;
     length subject $255 rfstdtc $10;
     if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
     end;

      set s_radiol(rename=(id=__id scandtc=in_scandtc scmeth=in_scmeth scmri=in_scmri scspln=in_scspln sclvr=in_sclvr));

	  %subject;
      rc = h.find();
      length scandtc $20;   
      scandtc = in_scandtc;
     %concatDY(scandtc);

	 if in_scmeth^=. then scmeth=strip(put(in_scmeth, scmeth.));
	 if in_scmri^=. then scmri=strip(put(in_scmri, scmeth.));
	 if in_scspln^=. then scspln=strip(put(in_scspln, noyes.));
	 if in_sclvr^=. then sclvr=strip(put(in_sclvr, noyes.));

run;

proc sort data=radiol; by subject  scandtc; run;

data pdata.radiol(label="Imaging by CT/MRI (Baseline)");
     retain __id subject scandtc scmeth scmri scmrisp scspln sclvr;
     set radiol;
	 attrib
     scandtc              label = "Assessment Date"
     scmeth                label = "CT/MRI Assessment"
     scmri             label = "If MRI, specify reason"
     scmrisp          label = "Other reason, specify"
     scspln          label = "Is spleen enlarged by CT or MRI"
     sclvr          label = "Is liver enlarged by CT or MRI"
	 ;
	 keep __id subject  scandtc scmeth scmri scmrisp scspln sclvr;
run;




