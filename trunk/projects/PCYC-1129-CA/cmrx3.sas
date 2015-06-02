/*********************************************************************
 Program Nmae: cmrx3.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/
%include "_setup.sas";

data cmrx000;
    set source.cmrx3(rename=(edc_treenodeid=__edc_treenodeid  edc_entrydate=__edc_entrydate visit=__visit VISDAY=__VISDAY));
    %subject;     
run;

************************;
data cmrx2;
    length rxstdtc rxendtc  $20 subject $13 __rfstdtc $10  rxfreqd $100;

    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set cmrx000;
    rc = h.find();
    drop rc;

    __rxcat=strip(rxcat);
   
      **  Start Date and End Date;
    label rxstdtc = 'Start Date';
    label rxendtc = 'End Date';
    %concatDate(year=rxstyy, month=rxstmm, day=rxstdd, outdate=rxstdtc);
    %concatDate(year=rxenyy, month=rxenmm, day=rxendd, outdate=rxendtc);
    %concatDY(rxstdtc);
    %concatDY(rxendtc);

	if rxtrtoth^="" then rxtrt=strip(rxtrt)||": " ||strip(rxtrtoth);
/*	if  PreferredDrugName_RXTRTOTH^="" then PreferredDrugName_RXTRT=strip(PreferredDrugName_RXTRT)||": " ||strip(PreferredDrugName_RXTRTOTH);*/
/*   */
    ** Frequency pecific Days;
	label rxfreqd ='Frequency Specific Days';
	if  rxfreqd1="" and rxfreqd2="" and rxfreqd3="" and rxfreqd4="" and  rxfreqd5="" and rxfreqd6="" and rxfreqd7="" 
    then rxfreqd=""; else rxfreqd=cat(",", of rxfreqd1-rxfreqd7);
run;

proc sort data=cmrx2; by subject rxstdtc rxendtc rxtrt ;run;

data pdata.cmrx3(label='Systemic Glucocorticoid Therapy');
    retain __EDC_TreeNodeID __EDC_EntryDate subject __visit __VISDAY __rxcat rxtrt  rxstdtc rxendtc rxdose rxdoseu rxfreq rxfreqo rxfreqd rxchange;
    keep __EDC_TreeNodeID __EDC_EntryDate subject __visit __VISDAY __rxcat rxtrt rxstdtc rxendtc rxdose rxdoseu rxfreq rxfreqo rxfreqd rxchange;
    set cmrx2;
/*	 label PreferredDrugName_RXTRT="Preferred Drug Name"*/
	 label rxdoseu="Unit"
     rxfreq="Frequency"
     rxfreqo="Other Frequency, specify"
	 rxchange="Does this represent a change in dose from last visit?"
     ;
run;


