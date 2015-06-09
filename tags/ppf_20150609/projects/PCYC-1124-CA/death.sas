/*********************************************************************
 Program Nmae: DEATH.sas
  @Author: Ken Cao
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/04: Change label of variable DSAE .
 
*********************************************************************/

%include '_setup.sas';

data death0;
    set source.death;
    keep EDC_TREENODEID EDC_ENTRYDATE SUBJECT DEATHDD DEATHMM DEATHYY DSAE DEATHCS DSAENUM ;
    rename EDC_TREENODEID = __EDC_TREENODEID;
    rename EDC_ENTRYDATE = __EDC_ENTRYDATE;
run;

data death1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set death0;

    %subject;

    ** death date;
    length deathdtc $20;
    label deathdtc = 'Date of Death';
    %concatDate(year=deathyy, month=deathmm, day=deathdd, outdate=deathdtc);
    drop deathyy deathmm deathdd;

    rc = h.find();
    %concatdy(deathdtc);
    drop rc;

    label dsae = 'Was Date of Death within 30 days of any study drug administration (within AE Reporting Period)?';
run;

proc sort data = death1; by subject; run;

data pdata.death(label='Death');
    retain __edc_treenodeid __edc_entrydate subject deathdtc dsae deathcs dsaenum;
    keep __edc_treenodeid __edc_entrydate subject deathdtc dsae deathcs dsaenum;
    set death1;
    label deathcs = 'If Yes, provide Cause of Death';
run;
