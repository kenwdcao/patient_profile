/*********************************************************************
 Program Nmae: CM.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/02/25
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/02/27: 1) Add --DY to CMSTDTC and CMENDTC
                        2) Combine three output datasets into one.
 Ken Cao on 2015/02/28: 1) Split CM into two datasets.
                        2) Fix truncation in CMSTDTC and CMENDTC.
 Ken Cao on 2015/03/11: Display "Yes" for BSPIG and GROWTH

*********************************************************************/
%include "_setup.sas";

data cm;
    set source.cm(keep=edc_treenodeid subject cmcat cmtrt cmindc cmyn bspigyn bspig growthyn growth
                       cmreas01 cmreas02 cmreas03 cmstdd cmstmm cmstyy cmprior cmendd cmenmm cmenyy 
                       cmongo cmdose cmdoseuk cmdosu cmdosus cmdosfrq cmdosfrs cmroute cmroutes cmseq
                       cmnum cmmhno01 cmmhno02 cmmhno03 cmaeno01 cmaeno02 cmaeno03 edc_entrydate
    );

    if cmyn='';
    drop cmyn;

    %subject;



    ** Ken Cao on 2015/02/27: Combine BSPIGYN / BSPIG and GROWTHYN and GROWTH;
    if bspigyn = 'No' then bspig = 'No';
    else if bspigyn = 'Yes' then bspig = 'Yes. '||strip(bspig);
    drop bspigyn;
    label bspig = 'Blood Supportive Product and/or IVIG';

    if growthyn = 'No' then growth = 'No';
    else if growthyn = 'Yes' then growth = 'Yes. '||strip(growth);
    drop growthyn;
    label growth = 'Considered a Growth Factor';
    
    cmreas01=strip(put(cmreas01,$checked.));
    cmreas02=strip(put(cmreas02,$checked.));
    cmreas03=strip(put(cmreas03,$checked.));

    ** Ken Cao on 2015/02/27: Combine CMREAS02 and CMMHO01 - CMMHO03;
    if cmmhno01^=. then mhno01=strip(put(cmmhno01,best.));
    if cmmhno02^=. then mhno02=strip(put(cmmhno02,best.));
    if cmmhno03^=. then mhno03=strip(put(cmmhno03,best.));
    mhnum=catx(", ",mhno01,mhno02,mhno03);
    drop cmmhno01 - cmmhno03 mhno01-mhno03;

    length cmreas02_ $255;
    label cmreas02_ = 'Reason for Treatment Medical History';
    cmreas02_ = cmreas02;
    if mhnum > ' ' then cmreas02_ = strip(cmreas02_)||' (MedHx #: '||strip(mhnum)||')';
    drop cmreas02 mhnum;


    ** Ken Cao on 2015/02/27: Combine CMREAS03 and CMAENO01 - CMAENO03;
    if cmaeno01^=. then aeno01=strip(put(cmaeno01,best.));
    if cmaeno02^=. then aeno02=strip(put(cmaeno02,best.));
    if cmaeno03^=. then aeno03=strip(put(cmaeno03,best.));
    aenum=catx(",",aeno01,aeno02,aeno03);
    drop cmaeno01 - cmaeno03 aeno01-aeno03;

    length cmreas03_ $255;
    label cmreas03_ = 'Reason for Treatment Adverse Event';
    cmreas03_ = cmreas03;
    if aenum > ' ' then cmreas03_ = strip(cmreas03_)||' (AE #: '||strip(aenum)||')';
    drop cmreas03 aenum;

    label  cmreas01 = "Prophylaxis/#Preventative";
    label cmreas02_ = "Medical History";
    label cmreas03_ = "Adverse Event";

    ** CMSTDTC and CMENDTC;
    length cmstdtc cmendtc $60;
    label cmstdtc = "Start Date";
    label cmendtc = "End Date";
    %concatDate(year=cmstyy, month=cmstmm, day=cmstdd, outdate=cmstdtc);
    %concatDate(year=cmenyy, month=cmenmm, day=cmendd, outdate=cmendtc);
    drop cmstyy cmstmm cmstdd;
    drop cmenyy cmenmm cmendd;

    cmprior=strip(put(cmprior,$checked.));
    cmongo=strip(put(cmongo,$checked.));

    if cmdoseuk^='' then cmdose="Unknown";
    drop cmdoseuk;
    /*
    if cmdose='' and cmdoseuk^='' then dose='Unk';
    else dose=cmdose;
    */

    **  Unit ;
    length cmdosu_ $255;
    label cmdosu_ = 'Unit';
    cmdosu_ = cmdosu;
    if cmdosus  > ' ' then cmdosu_ = strip(cmdosu_)||': '||cmdosus;
    drop cmdosu cmdosus ;

    ** Frequency ;
    length cmdosfrq_ $255;
    label cmdosfrq_ = 'Frequency'; 
    cmdosfrq_ = cmdosfrq;
    if cmdosfrs > ' ' then cmdosfrq_ = strip(cmdosfrq_)||': '||cmdosfrs;
    drop cmdosfrq cmdosfrs ;

    ** Route ;
    length cmroute_ $255;
    label cmroute_ = 'Route'; 
    cmroute_ = cmroute;
    if cmroutes > ' ' then cmroute_ = strip(cmroute_)||': '||cmroutes;
    drop cmroute cmroutes;


    rename edc_treenodeid = __edc_treenodeid; 
    rename edc_entrydate = __edc_entrydate;

run;


** Ken Cao on 2015/02/27: Add --DY to CMSTDTC and CMENDTC;
data cm1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set cm;
    rc = h.find();
    %concatdy(cmstdtc); 
    %concatdy(cmendtc); 
    drop rc;

    ** Combine CMPRIOR into CMSTDTC;
    if cmprior > ' ' then cmstdtc = strip(cmstdtc)||' '||'> 1 month prior to first dose and year unknown' ;
    drop cmprior;

    ** Combine CMONGO into CMENDTC;
    if cmongo > ' ' then cmendtc = strip(cmendtc)||' '||'Ongoing' ;
    drop cmongo;
run;


proc sort data=cm1;by subject cmstdtc cmendtc ;run;

/*
data out.cm (label="Concomitant Medications / Products");
    retain __edc_treenodeid __edc_entrydate cmcat subject cmnum cmseq cmtrt cmindc bspig growth 
          cmreas01 cmreas02_ cmreas03_ cmstdtc cmendtc cmdose cmdosu_ cmdosfrq_ cmroute_;

    keep __edc_treenodeid __edc_entrydate cmcat subject cmnum cmseq cmtrt cmindc bspig growth 
          cmreas01 cmreas02_ cmreas03_ cmstdtc cmendtc cmdose cmdosu_ cmdosfrq_ cmroute_;

    set cm1;

    ** Ken Cao on 2015/02/27: Hide CMCAT and CMSEQ;
    rename cmcat = __cmcat;
    rename cmseq = __cmseq;
run;
*/

data pdata.cm1 (label="Concomitant Medications / Products");
    retain __edc_treenodeid __edc_entrydate cmcat subject cmnum cmseq cmtrt cmstdtc cmendtc cmdose cmdosu_ cmdosfrq_ cmroute_;
    keep __edc_treenodeid __edc_entrydate cmcat subject cmnum cmseq cmtrt cmstdtc cmendtc cmdose cmdosu_ cmdosfrq_ cmroute_;
    set cm1;
    rename cmcat = __cmcat;
    rename cmseq = __cmseq;
run;

data pdata.cm2 (label="Concomitant Medications / Products (Continued)");
    retain __edc_treenodeid __edc_entrydate cmcat subject cmnum cmseq cmtrt cmindc bspig growth cmreas01 cmreas02_ cmreas03_ ;
    keep __edc_treenodeid __edc_entrydate cmcat subject cmnum cmseq cmtrt cmindc bspig growth cmreas01 cmreas02_ cmreas03_ ;
    set cm1;
    rename cmcat = __cmcat;
    rename cmseq = __cmseq;
run;
