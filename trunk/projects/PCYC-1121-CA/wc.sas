/*********************************************************************
 Program Nmae: WC.sas
  @Author: Taodong Chen
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/05: Concatenate --DY to IEWDTC1 and IEWDTC2.
*********************************************************************/
%include '_setup.sas';

proc sort data=source.wc out=s_wc nodupkey; by _all_; run;

data wc01;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;
    length iewdtc1 iewdtc2 $19;
    set s_wc (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate)); 
    %subject;
    %ndt2cdt(ndt=iewdt1, cdt=iewdtc1);
    %ndt2cdt(ndt=iewdt2, cdt=iewdtc2);

    rc = h.find();
    %concatDY(iewdtc1);
    %concatDY(iewdtc2);
    drop rc;


      iena=put(iena,$checked.);
      iewcon1=put(iewcon1,$checked.);
      iewcon2=put(iewcon2,$checked.);
    drop edc_:;
run;

proc sort data=wc01; by subject; run;

data pdata.wc(label="Withdrawal of Consent");
    retain __edc_treenodeid __EDC_EntryDate subject iena iewcon1 iewdtc1 iewcon2  iewdtc2 ;
    keep __edc_treenodeid __EDC_EntryDate subject iena iewcon1 iewdtc1 iewcon2  iewdtc2;
    set wc01;
    label 
        iewdtc1 = 'Date Withdrew Consent Tissue Collection'
        iewdtc2 = 'Date Withdrew Consent for Sample Testing'
    ;
run;
