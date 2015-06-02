%include '_setup.sas';
**** ECOG Performance Status (Cycle 1 Day 1) ****;
proc format;
  value ESPS
      0 = 'Fully Active'
      1 = 'Restricted in Physical Strenuous Activity'
      2 = 'Ambulatory and Capable of Self-care'
      3 = 'Capable of Only Limited Self-care'
      4 = 'Completely Disabled'
      5 = 'Dead'
      . = " "
   ;
run;
data es1;
    length STATUS $100;
    set source.es;
    %formatDate(ESDTC);
    format _all_;
    label 
        ESDTC='Assessment Date'
        STATUS='Performance Status'
        VISIT='Visit'
    ;
    ** Ken Cao on 2014/11/24: Add grade number to ECOG status **;
    STATUS='Grade '||strip(put(ESPS, best.))||' - '||strip(put(ESPS,ESPS.));
    VISIT=strip(put(EVENT_ID,$VISIT.));
    if esyn=1;
    keep SUBID VISIT ESDTC STATUS;
run;
proc sort data=es1;by SUBID ESDTC;run;
data pdata.ecog(label='ECOG Performance Status');
    retain SUBID VISIT ESDTC STATUS; 
    keep SUBID VISIT ESDTC STATUS;
    set es1;
run; 
