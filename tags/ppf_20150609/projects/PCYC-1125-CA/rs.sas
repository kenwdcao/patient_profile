/*********************************************************************
 Program Nmae: PEABN.sas
  @Author: ZSS
  @Initial Date: 2015/03/16
 


 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc sort data=source.rs1 out=s_rs1 nodupkey; by _all_; run;
proc sort data=source.rs2 out=s_rs2 nodupkey; by _all_; run;

data rsall;
      set s_rs1(in=a) s_rs2(in=b);
	  if a then __arm='Arm 1'; 
	  if b then __arm='Arm 2';
run;

**** Response Evaluation ***;
data rs_0;
     length subject $255 rfstdtc $10;
     if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
     end;

      set rsall(rename=(id=__id scspln=in_scspln sclvr=in_sclvr));

	  %subject;
      rc = h.find();
      length rsdtc $20;   
      rsdtc = rsevadtc;
     %concatDY(rsdtc);

	 if lndia^=. then lndia_c=strip(put(lndia, best.));
	 if lndiand^=. then lndiand_c='Not Assessed';
	     diand=strip(catx(': ', lndiand_c, lndiando));
	sumdia=strip(catx(' / ', lndia_c, diand));

	 if rsmct^=. then rsmct_c='CT with Contrast';
	 if rsmctwo^=. then rsmctwo_c='CT without Contrast';
	 if rsmmri^=. then rsmmri_c='MRI';
	 if rsmpetct^=. then rsmpetct_c='PET/CT';
	 if rsmpet^=. then rsmpet_c='PET';
	 if rsmbma^=. then rsmbma_c='Bone Marrow Assessment';
	 if rsmtba^=. then rsmtba_c='Tumor Biopsy Assessment';
	 if rsmpe^=. then rsmpe_c='Physical Exam';
	 if rsmo^=. then rsmo_c='Other';
	  other=strip(catx(': ', rsmo_c, rsosp));
	  rsbase = strip(catx('; ', rsmct_c, rsmctwo_c, rsmmri_c, rsmpetct_c, rsmpet_c, rsmbma_c, rsmtba_c, rsmpe_c, other));

	  if in_scspln^=. then scspln=strip(put(in_scspln, sclvr.));
	  if in_sclvr^=. then sclvr=strip(put(in_sclvr, sclvr.));
	  if rsinvrsp^=. then response=strip(put(rsinvrsp, rsinvrsp.));

      length rstlnum $200;
      if rstl1^=. then rstl1_c=strip(put(rstl1, best.));
      if rstl2^=. then rstl2_c=strip(put(rstl2, best.));
      if rstl3^=. then rstl3_c=strip(put(rstl3, best.));
      if rstl4^=. then rstl4_c=strip(put(rstl4, best.));
      if rstl5^=. then rstl5_c=strip(put(rstl5, best.));
      if rstl6^=. then rstl6_c=strip(put(rstl6, best.));
      rstlnum=strip(catx(', ', rstl1_c, rstl2_c, rstl3_c, rstl4_c, rstl5_c, rstl6_c));

      array rsin{*} rsinctl rsincnt rsincen rsnewly rsnewen rscp;
      array rsinsp{*} rstlnum rscntsp rscens rsnewlys rsnewens rscpsp;
      do i = 1 to dim(rsin);
        if rsin[i] = 1 and rsinsp[i] = ' ' then do;
            rsinsp[i] = 'Yes';
        end;
      end;     

run;

data rs;
      set rs_0;
	  keep __id __arm subject rsdtc sumdia rsbase scspln sclvr response rsnesp rstlnum rscntsp rscens rsnewlys rsnewens rscpsp;

proc sort data=rs; by subject  rsdtc; run;

data pdata.rs1(label="Response Evaluation");
     retain __id subject rsdtc sumdia rsbase scspln sclvr response rsnesp __arm;
     set rs;
	 attrib
     rsdtc              label = "Assessment Date"
     sumdia                label = "Sum of Products of Diameters#(cm)"
     rsbase             label = "Response Based On"
     scspln          label = "Is spleen enlarged by CT or MRI?"
     sclvr          label = "Is liver enlarged by CT or MRI?"
     response          label = "Investigator's Response Assessment by protocol criteria"
     rsnesp          label = "Response Not Evaluable Specify"

	 ;
	 keep __id subject rsdtc sumdia rsbase scspln sclvr response rsnesp __arm;
run;


data pdata.rs2(label="Response Evaluation (Mode of Progression)");
     retain __id subject rsdtc rstlnum rscntsp rscens rsnewlys rsnewens rscpsp __arm;
     set rs;
	 attrib
     rsdtc              label = "Assessment Date"
     rstlnum                label = "Increase in size of existing target lesion(s), specify lesion number(s)"
     rscntsp             label = "Increase in size of existing non-target lesion(s), specify lesion number(s)"
     rscens          label = "Increase in size of existing extranodal site(s)"
     rsnewlys          label = "New lymph node site(s)"
     rsnewens          label = "New extranodal site(s)"
     rscpsp          label = "Clinical progression"
	 ;
    
	 if cmiss(rstlnum, rscntsp, rscens, rsnewlys, rsnewens, rscpsp)=6 then delete;
	 keep __id subject rsdtc rstlnum rscntsp rscens rsnewlys rsnewens rscpsp __arm;
run;
