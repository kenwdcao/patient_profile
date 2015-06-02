/*********************************************************************
 Program Nmae: DISC.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/15
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 
*********************************************************************/

%include '_setup.sas';

data disc;
    length subject $13 rfstdtc $10 dis $200;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set source.disc(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate));
    
    %subject;
/*    label cycle='Cycle';*/
/*  label visit='Visit';*/

    ** Date of Last Dose;
    length ldosedtc $20;
    label ldosedtc = 'Date of Last Dose';
    %ndt2cdt(ndt=ldosedt, cdt=ldosedtc);
    rc = h.find();
    %concatDY(ldosedtc);

    **dis reason**;
     label dis = 'Primary reason Ibrutinib was permanently discontinued';
     if aenumae^=. then dis=cat(strip(discreas),' (AE Number: ',strip(put(aenumae,best.)),')');
        else if othreas^='' then dis=cat('Other: ',strip(othreas));
        else if wthreas^='' then dis=cat(strip(discreas),': ',strip(wthreas));
        else if invreas^='' then dis=cat(strip(discreas),': ',strip(invreas));
        else dis=strip(discreas);

        **drug**;
        length drug $50;
        label drug='Study Drug';
        drug=strip(scan(EDC_FormLabel,-1,'-'));
run;

proc sort data=disc; by subject ldosedtc; run;

data pdata.disc(label='Study Drug Discontinuation');
    retain __edc_treenodeid __edc_entrydate subject drug exyn ldosedtc discreas wthreas invreas othreas aenumae ;
    keep __edc_treenodeid __edc_entrydate subject drug exyn ldosedtc discreas wthreas invreas othreas aenumae;
    set disc;

    label dis = 'Primary reason drug was permanently discontinued';
run;


/*
%let k=%str(__edc_treenodeid __edc_entrydate subject exyn ldosedtc dis);

data pdata.disc1(label='Study Drug Discontinuation - Ibrutinib');
    retain &k;
    set disc(where=(EDC_FormLabel='Study Drug Discontinuation - Ibrutinib'));
    keep &k;
run;

data pdata.disc2(label='Study Drug Discontinuation - Rituximab');
    retain &k;
    set disc;
    where EDC_FormLabel='Study Drug Discontinuation - Rituximab';
    keep &k;
run;

data pdata.disc3(label='Study Drug Discontinuation - Lenalidomide');
    retain &k;
    set disc;
    where EDC_FormLabel='Study Drug Discontinuation - Lenalidomide';
    keep &k;
run;
*/
