/*********************************************************************
 Program Nmae: CMRAD.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/09
*********************************************************************/
%include "_setup.sas";


data cm0(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate cmcat = __cmcat seq = __seq));
     length  cmloc $255  cmcat $100 cmstdtc cmendtc site: $60 ;
    set source.cmrad;
    %subject;
/*	label cmtrt='Medication Name';*/
/*    cmtrt='';*/
	  cmcat=strip(EDC_FormLabel);
	  label cmcat='Prior DLBCL Radiation';
    
    **combine location**; 
    site01=ifc(RDSITE01=1,'Axilla - Right','');
    site02=ifc(RDSITE02=1,'Axilla - Left','');
    site03=ifc(RDSITE03=1,'Groin - Right','');
    site04=ifc(RDSITE04=1,'Groin - Left','');
    site05=ifc(RDSITE05=1,'Neck Supraclavicular - Right','');
    site06=ifc(RDSITE06=1,'Neck Supraclavicular - Left','');
    site07=ifc(RDSITE07=1,'Neck Cervical - Right','');
    site08=ifc(RDSITE08=1,'Neck Cervical - Left','');
    site09=ifc(RDSITE09=1,'Neck Preauricular - Right','');
    site10=ifc(RDSITE10=1,'Neck Preauricular - Left','');
    site11=ifc(RDSITE11=1,'Mediastinum','');
    site12=ifc(RDSITE12=1,cat('Other: ',strip(RDSITEO)),'');
    site13=ifc(RDSITE13=1,'Mantle','');
    site14=ifc(RDSITE14=1,'Para-aortic','');
    site15=ifc(RDSITE15=1,'Inverted Y','');

    cmloc=strip(catx(', ', of site01-site15));
    label cmloc='All Fields Previously Treated with Radiation';

	
		** CMSTDTC and CMENDTC;
    label cmstdtc = "Start Date";
    label cmendtc = "End Date";
    %concatDate(year=rdstyy, month=rdstmm, day=rdstdd, outdate=cmstdtc);
    %concatDate(year=rdenyy, month=rdenmm, day=rdendd, outdate=cmendtc);

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

proc sort data=cm1;by subject cmstdtc cmendtc ;run;

data pdata.cmrad (label="Prior DLBCL Radiation");
    retain __edc_treenodeid __edc_entrydate __cmcat  subject  __seq  cmloc cmstdtc cmendtc;
    keep __edc_treenodeid __edc_entrydate __cmcat subject  __seq  cmloc cmstdtc cmendtc ;
    set cm1;
run;





