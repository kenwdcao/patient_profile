%include '_setup.sas';
**** Dosing Discontinuation ****;
proc format;
   value SDDCRN
      1 = 'Adverse Event/SAE'
      2 = 'Lost to Follow-up'
      3 = 'Death'
      4 = 'Protocol Violation'
      5 = 'Subject Withdrew Conset'
      6 = 'Termination of Study By the Sponsor, FDA, or Other Regulatory Authorities'
      7 = 'Radiographic Disease Progression'
      8 = 'Clinical Disease Progression'
      9 = 'Physician Decision'
      99 = 'Other'
      . = " "
   ;
run;
data sd1;
    length RNDC $200;
    set source.sd;
    %formatDate(DSDDCDTC);
    %formatDate(SDAESTDC);
    format _all_;
    label 
        DSDDCDTC='Date Drug Permanently Discontinued'
        RNDC='Reason Drug Permanently Discontinued'
        SDAESTDC='AE Onset Date'
    ;
    RNDC=strip(put(SDDCRN,SDDCRN.));
    if SDDCRNSP^='' then RNDC=strip(RNDC)||': '||strip(SDDCRNSP);
    if SDAESP^='' then RNDC=strip(RNDC)||': '||strip(SDAESP);
    if DSDDCDTC^='' or RNDC^='';
    keep SUBID DSDDCDTC RNDC SDAESTDC SDDCRNSP SDAESP; 
run;
proc sort data=sd1;by SUBID;run;
data pdata.exdis(label='Dosing Discontinuation');
    retain SUBID DSDDCDTC RNDC SDDCRNSP SDAESP SDAESTDC; 
    keep SUBID DSDDCDTC RNDC SDDCRNSP SDAESP  SDAESTDC;
    set sd1;
run; 

