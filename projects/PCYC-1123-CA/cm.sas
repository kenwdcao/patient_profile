/*********************************************************************
 Program Nmae: CM.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/08
*********************************************************************/
%include "_setup.sas";


data cm0(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate cmcat = __cmcat cmseq = __cmseq));
     length bsp grow cmreas02 cmreas03  CMREAS_ $255 cmdosu_ cmdosfrq_ cmroute_ cmcat prior $100 cmstdtc cmendtc $60 ;
     set source.cm;
	 if cmyn='';
 
    %subject;
	label cmtrt='Medication Name';

    **combine bspig**; 
	 bsp=ifc(bspigyn='Yes',cat('Yes. ',strip(bspig)),strip(bspigyn));
	label bsp='Blood Supportive Product and/or IVIG';

	 **combine growth**; 
	grow=ifc(growthyn='Yes',cat('Yes. ',strip(growth)),strip(growthyn));
	label grow='Considered a Growth Factor';

	**combine ae number**; 
	aenum=catx(", ",CMAENO01,CMAENO02,CMAENO03);
    label cmreas03 = 'Reason for treatment Adverse Event';
    cmreas03 = ifc( aenum > ' ', cat(strip(cmreas), ' (AE Number: ', strip(aenum), ')'),'');


    **combine mh number**; 
	mhnum=catx(", ",CMMHNO01,CMMHNO02,CMMHNO03);
    label cmreas02 = 'Reason for Treatment Medical History';
    cmreas02= ifc(mhnum > ' ', cat(strip(cmreas), ' (Med Hx Number: ', strip(mhnum), ')'),'');
   
	**modify 2015/04/14:combine  all**;

    CMREAS_=coalescec(cmreas02,cmreas03,cmreas);
	label cmreas_='Primary Reason for Treatment';

	**dose**;
		if cmdoseuk=1 then cmdose="Unknown";

    **  Unit ;
    label cmdosu_ = 'Unit';
     cmdosu_ = ifc(cmdosuo > ' ', cat(strip(cmdosu), ': ', strip(cmdosuo)),strip(cmdosu)) ;
    
    ** Frequency ;
    label cmdosfrq_ = 'Frequency'; 
    cmdosfrq_ = ifc(cmdosfro > ' ', cat(strip(cmdosfrq),': ',strip(cmdosfro)),strip(cmdosfrq));

    ** Route ;
    label cmroute_ = 'Route';
    cmroute_ = ifc(cmrouteo > ' ', cat(strip(cmroute),': ',strip(cmrouteo)),strip(cmroute));

	
		** CMSTDTC and CMENDTC;
    label cmstdtc = "Start Date";
    label cmendtc = "End Date";
    %concatDate(year=cmstyy, month=cmstmm, day=cmstdd, outdate=cmstdtc);
    %concatDate(year=cmenyy, month=cmenmm, day=cmendd, outdate=cmendtc);

	** Combine CMPRIOR into CMSTDTC;
     prior = ifc(cmprior=1,'> 1 month prior to first dose study drug','');
	 label prior='>1 Month Prior to First Dose Study Drug';
     cmstdtc = ifc(prior^='',strip(prior),strip(cmstdtc)) ;

    ** Combine CMONGO into CMENDTC;
      cmendtc = ifc(cmongo=1,'Ongoing',strip(cmendtc)) ;

	  cmcat=strip(EDC_FormLabel);
	  label cmcat='Concomitant Medications / Products';
run;

    
***DY**;
data cm1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set cm0;
    rc = h.find();
    %concatdy(cmstdtc); 
    %concatdy(cmendtc); 
    drop rc;
run;

proc sort data=cm1;by subject cmstdtc cmtrt  __cmseq ;run;

data pdata.cm1 (label="Concomitant Medications / Products");
    retain __edc_treenodeid __edc_entrydate __cmcat  subject cmnum __cmseq cmtrt cmindc bsp grow CMREAS_ ;
    set cm1;
	 by subject cmstdtc cmtrt  __cmseq ;
	 keep   __edc_treenodeid __edc_entrydate __cmcat  subject cmnum __cmseq cmtrt cmindc bsp grow CMREAS_ ;
run;

data pdata.cm2 (label="Concomitant Medications / Products(Continued)");
    retain __edc_treenodeid __edc_entrydate __cmcat  subject cmnum __cmseq cmtrt cmstdtc cmendtc cmdose cmdosu_ cmdosfrq_ cmroute_;
    set cm1;
    keep __edc_treenodeid __edc_entrydate __cmcat subject cmnum __cmseq cmtrt cmstdtc cmendtc cmdose cmdosu_ cmdosfrq_ cmroute_;
run;





