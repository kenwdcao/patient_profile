/*********************************************************************
 Program Nmae: UP.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/21
*********************************************************************/
%include "_setup.sas";

data up_;
         length subject $13  ;
         set source.up(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate));
        %subject;
        unsnun09=.;unsnun14=.;unsnun19=.;
run;

proc sort data=up_; by subject __edc_treenodeid __edc_entrydate; run;

proc transpose data=up_ out=up1_;
     var unsnun01-unsnun27;
     by subject __edc_treenodeid __edc_entrydate;
run;

data up;
       length col $10 label $150;
         set up1_(where=(col1^=.));
         if col1=1 then col='Yes';
		 label=strip(tranwrd(_label_,'Unsch Form',''));
         label label = 'Indicate the form(s) needed at this visit';
run;

proc sort data=up;by subject ;run;

data pdata.up (label="Unscheduled Forms");
    retain __edc_treenodeid __edc_entrydate subject  label;
    set up;
    keep __edc_treenodeid __edc_entrydate subject  label;
run;






