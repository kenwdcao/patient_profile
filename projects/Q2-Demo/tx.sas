/*********************************************************************
 Program Nmae: TX.sas
  @Author: Taodong Chen
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 
 BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/04: Display UNK and NULL for variable TXSTDTC and TXENDTC.
 Ken Cao on 2015/03/05: Concatenate --DY to TXSTDTC and TXENDTC.

*********************************************************************/
%include '_setup.sas';

proc sort data=source.tx out=s_tx nodupkey; by _all_; run;

data tx01;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;

    length txstdtc txendtc $19;
    set s_tx(where=(edc_formlabel='New Anticancer Therapy') rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate));
     %subject;
     %concatDateV2(year=txstyy, month=txstmm, day=txstdd, outdate=txstdtc);
     %concatDateV2(year=txenyy, month=txenmm, day=txendd, outdate=txendtc);

    rc = h.find();
    %concatDY(txstdtc);
    %concatDY(txendtc);
    drop rc;

      txongo=put(txongo,$checked.);
      txyn=put(txyn,$checked.);
    drop edc_:;
run;

proc sort data=tx01; by subject; run;

data pdata.ntx(label="New Anticancer Therapy");
    retain  __EDC_TreeNodeID __EDC_EntryDate subject txcat txint txtype txterm txstdtc txendtc txongo;
    keep  __EDC_TreeNodeID __EDC_EntryDate subject txcat txint txtype txterm txstdtc txendtc txongo;
    set tx01;
    label 
        txstdtc = 'Therapy Start Date'
        txendtc = 'Therapy End Date'
    ;
run;

/*data tx02;*/
/*    length txprdtc txstdtc txendtc $19;*/
/*    set s_tx(where=(edc_formlabel='Prior Systemic MZL Therapy'));*/
/*   %subject;*/
/**/
/*   %concatDate(year=txstyy, month=txstmm, day=txstdd, outdate=txstdtc);*/
/*       %concatDate(year=txenyy, month=txenmm, day=txendd, outdate=txendtc);*/
/*       %concatDate(year=txpryy, month=txprmm, day=txprdd, outdate=txprdtc);*/
/**/
/*    txrgnumn=put(txrgnumn,$checked.);*/
/*    txpyn=put(txpyn,$checked.);*/
/*        drop edc_:;*/
/* run;*/
/**/
/*proc sort data=tx02; by subject; run;*/
/**/
/*data pdata.ptx(label="Prior Systemic MZL Therapy");*/
/*    retain subject txcat visit txrgnum txrgnumn txtrt  txstdtc txendtc txresp txpyn txprdtc txpdisc txpdisco;*/
/*    keep  subject txcat visit txrgnum txrgnumn txtrt  txstdtc txendtc txresp txpyn txprdtc txpdisc txpdisco;*/
/*    set tx02;*/
/*    label */
/*      txstdtc = 'Therapy Start Date'*/
/*        txendtc = 'Therapy End Date'*/
/*      txprdtc = 'Date of Progression'*/
/*      visit = 'Visit'*/
/*    ;*/
/*run;*/
