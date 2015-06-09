/*********************************************************************
 Program Nmae: PEABN.sas
  @Author: ZSS
  @Initial Date: 2015/03/16
 


 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc sort data=source.tbp out=s_tbp nodupkey; by _all_; run;

**** Tumor Tissue Biopsy ***;
data tbp;
     length subject $255 rfstdtc $10;
     if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
     end;

      set s_tbp(rename=(id=__id tbpnd=in_tbpnd tbpdtc=in_tbpdtc));

	  %subject;
      rc = h.find();
      length tbpdtc $20;   
      tbpdtc = in_tbpdtc;
     %concatDY(tbpdtc);

      if in_tbpnd=1 then tbpnd="Yes";
/*      if tbptrgt^=. then check=strip(put(tbptrgt, tbptrgt.));*/
      if tbptrgt^=. then check="Yes";


run;

proc sort data=tbp; by subject  tbpdtc  event_no ; run;

data pdata.tbp(label="Tumor Tissue Biopsy");
     retain __id subject __event_no event_id  tbpdtc tbpnd tbploc check;
     set tbp (rename=(event_no=__event_no));
	 attrib
     event_id          label = "Visit"
     tbpdtc              label = "Collection Date"
     tbpnd               label = "Not Done"
     tbploc              label = "Biopsy Site"
     check              label = "Check if from a target lesion"
	 ;

	 keep __id subject __event_no event_id tbpdtc tbpnd tbploc check;
run;




