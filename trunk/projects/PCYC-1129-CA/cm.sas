/*********************************************************************
 Program Nmae: cm.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/24
*********************************************************************/
%include "_setup.sas";


data cm0(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate cmcat = __cmcat cmseq = __cmseq));
     length  bsp grow cmreas02 cmreas03 $255 cmdosu_ cmdosfrq_ cmroute_ cmcat prior $100 cmstdtc cmendtc $60 ;
     set source.cm;

    %subject;
	label cmtrt='Medication Name';
    label cmnum='Medication Number';
    label cmprior='or if > 1 month prior to first dose study drug and year unknown';
    label cmreas01="Prophylaxis/Preventative treatment@:Primary reason for treatment";


      **combine bspig**; 
	 bsp=ifc(bspigyn='Yes',cat('Yes. ',strip(bspig)),strip(bspigyn));
	label bsp='Blood Supportive Product and/or IVIG';

	 **combine growth**; 
	grow=ifc(growthyn='Yes',cat('Yes. ',strip(growth)),strip(growthyn));
	label grow='Considered a Growth Factor';

   
	**dose**;
		if cmdoseuk="Checked" then cmdose="Unknown";

    **  Unit ;
    label cmdosu_ = 'Unit';
     cmdosu_ = ifc(cmdosus > ' ', cat(strip(cmdosu), ': ', strip(cmdosus)),strip(cmdosu)) ;
    
    ** Frequency ;
    label cmdosfrq_ = 'Frequency'; 
    cmdosfrq_ = ifc(cmdosfrs > ' ', cat(strip(cmdosfrq),': ',strip(cmdosfrs)),strip(cmdosfrq));

    ** Route ;
    label cmroute_ = 'Route';
    cmroute_ = ifc(cmroutes > ' ', cat(strip(cmroute),': ',strip(cmroutes)),strip(cmroute));




    **combine mh number**; 
	 cmreas02=catx(", ",put(CMMHNO01,best.),put(CMMHNO02,best.),put(CMMHNO03,best.));
    label cmreas02 = 'Medical History (provide Med Hx Number(s))@:Primary reason for treatment';
   **combine ae number**; 
	cmreas03=catx(", ",put(CMAENO01,best.),put(CMAENO02,best.),put(CMAENO03,best.));
    label cmreas03= 'Adverse Event (Provide AE Number(s))@:Primary reason for treatment';
   
	** CMSTDTC and CMENDTC;
    label cmstdtc = "Start Date or Year Unknown";
    label cmendtc = "End Date or Ongoing";
    %concatDate(year=cmstyy, month=cmstmm, day=cmstdd, outdate=cmstdtc);
    %concatDate(year=cmenyy, month=cmenmm, day=cmendd, outdate=cmendtc);

		** Combine CMPRIOR into CMSTDTC;
     prior = ifc(cmprior="Checked",'> 1 month prior to first dose study drug and year unknown','');
	 label prior='>1 Month Prior to First Dose Study Drug';
     cmstdtc = ifc(prior^='',strip(prior),strip(cmstdtc)) ;

    ** Combine CMONGO into CMENDTC;
      cmendtc = ifc(cmongo="Checked",'Ongoing',strip(cmendtc)) ;

     cmcat=strip(EDC_FormLabel);
	 label cmcat='Concomitant Medications / Products';
	 format cmreas01 cmongo cmprior cmdoseuk checked.;
run;

    
***DY**;
data cm1;
    length subject $13 __rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
    set cm0;
    rc = h.find();
    %concatdy(cmstdtc); 
    %concatdy(cmendtc); 
    drop rc;
run;

proc sort data=cm1;by subject cmstdtc cmendtc cmtrt  ;run;

data pdata.cm1 (label="Concomitant Medications / Products Prompt");
    retain __edc_treenodeid __edc_entrydate __cmcat  subject cmyn ;
    keep   __edc_treenodeid __edc_entrydate __cmcat  subject cmyn ;
    set cm1;
    if  EDC_FormLabel='Concomitant Medications / Products Prompt';
	label cmyn='Does subject have any prior/concomitant medications to report?';
run;


data pdata.cm2 (label="Concomitant Medications / Products");
    retain __edc_treenodeid __edc_entrydate __cmcat subject cmnum __cmseq cmtrt cmindc  bsp grow systrtyn cmreas01 cmreas02 cmreas03 ;
    set cm1;
	keep   __edc_treenodeid __edc_entrydate __cmcat subject cmnum __cmseq cmtrt cmindc bsp grow systrtyn cmreas01 cmreas02 cmreas03 ;
/*	label PreferredDrugName="Preferred Drug Name";*/
	if  EDC_FormLabel='Concomitant Medications / Products';
run;

data pdata.cm3 (label="Concomitant Medications / Products (Continued)");
    retain __edc_treenodeid __edc_entrydate __cmcat subject cmnum __cmseq cmtrt cmstdtc cmendtc cmdose cmdosu_ cmdosfrq_ cmroute_;   
    set cm1;
    keep __edc_treenodeid __edc_entrydate __cmcat subject cmnum __cmseq cmtrt cmstdtc cmendtc cmdose cmdosu_ cmdosfrq_ cmroute_;
    if  EDC_FormLabel='Concomitant Medications / Products';
	label cmdose="Dose or Unknown"
          cmdosu_="Unit, if other, specify" 
          cmdosfrq_="Frequency, if other, specify"
          cmroute_="Route, if other,specify"
           ;
run;





