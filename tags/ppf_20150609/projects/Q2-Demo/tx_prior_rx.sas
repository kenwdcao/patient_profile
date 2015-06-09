/*********************************************************************
 Program Nmae: TX_PRIOR_RX.sas
  @Author: Taodong Chen
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/02/25: Drop TXCAT from final dataset.
 Ken Cao on 2015/03/04: Display UNK and NULL for variable TXSTDTC,TXENDTC
                        and TXPRDTC
 Ken Cao on 2015/03/05: Concatenate --DY to TXSTDTC, TXENDTC and TXPRDTC.
*********************************************************************/
%include '_setup.sas';

proc sort data=source.tx_prior_rx_1 out=s_tx_prior_rx_1 nodupkey; by _all_; run;
proc sort data=source.tx_prior_rx_2 out=s_tx_prior_rx_2 nodupkey; by _all_; run;
proc sort data=source.tx_prior_rx_3 out=s_tx_prior_rx_3 nodupkey; by _all_; run;
proc sort data=source.tx_prior_rx_4 out=s_tx_prior_rx_4 nodupkey; by _all_; run;
proc sort data=source.tx_prior_rx_5 out=s_tx_prior_rx_5 nodupkey; by _all_; run;
proc sort data=source.tx_prior_rx_6 out=s_tx_prior_rx_6 nodupkey; by _all_; run;
proc sort data=source.tx(where=(edc_formlabel='Prior Systemic MZL Therapy')) out=s_tx nodupkey; by _all_; run;


** Ken Cao on 2015/02/20: Comment out drop clause in set statement. Those variables does not exist in 2014Dec05 transfer;
data tx_all;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;

    length txprdtc txstdtc txendtc $19;
    set s_tx_prior_rx_1(/*drop=EDITEDTERM DRUGNAME ATCTEXT1 ATCTEXT3*/ rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate))
         s_tx_prior_rx_2(/*drop=EDITEDTERM DRUGNAME ATCTEXT1 ATCTEXT3*/  rename = (EDC_TreeNodeID = __EDC_TreeNodeID  EDC_EntryDate=__EDC_EntryDate))
         s_tx_prior_rx_3(/*drop=EDITEDTERM DRUGNAME ATCTEXT1 ATCTEXT3*/ rename = (EDC_TreeNodeID = __EDC_TreeNodeID  EDC_EntryDate=__EDC_EntryDate))
         s_tx_prior_rx_4(/*drop=EDITEDTERM DRUGNAME ATCTEXT1 ATCTEXT3*/ rename = (EDC_TreeNodeID = __EDC_TreeNodeID  EDC_EntryDate=__EDC_EntryDate))
         s_tx_prior_rx_5(/*drop=EDITEDTERM DRUGNAME ATCTEXT1 ATCTEXT3*/ rename = (EDC_TreeNodeID = __EDC_TreeNodeID  EDC_EntryDate=__EDC_EntryDate))
         s_tx_prior_rx_6(/*drop=EDITEDTERM DRUGNAME ATCTEXT1 ATCTEXT3*/ rename = (EDC_TreeNodeID = __EDC_TreeNodeID  EDC_EntryDate=__EDC_EntryDate))
         s_tx(/*drop=EDITEDTERM DRUGNAME ATCTEXT1 ATCTEXT3*/ rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate ))
;
     %subject;

     %concatDateV2(year=txstyy, month=txstmm, day=txstdd, outdate=txstdtc);
     %concatDateV2(year=txenyy, month=txenmm, day=txendd, outdate=txendtc);
     %concatDateV2(year=txpryy, month=txprmm, day=txprdd, outdate=txprdtc);

	 rc = h.find();
    %concatDY(txstdtc);
    %concatDY(txendtc);
    %concatDY(txprdtc);
	 drop rc;

      txrgnumn=put(txrgnumn,$checked.);
      txpyn=put(txpyn,$checked.);
      if txtrt ^='';
 keep  subject txrgnum txcat visit txrgnum txrgnumn txtrt  txstdtc txendtc txresp txpyn txprdtc txpdisc txpdisco __EDC_TreeNodeID __EDC_EntryDate;
 run;
proc sort data=tx_all out=tx_all_dup nodupkey; by _all_; run;

proc sort data=tx_all_dup; by subject txstdtc txendtc txrgnum visit txtrt txresp txpyn txprdtc txpdisc; run;

data pdata.tx_prior_rx(label="Prior Systemic MZL Therapy");
    retain  __EDC_TreeNodeID __EDC_EntryDate subject  txrgnum txrgnumn txtrt  txstdtc txendtc txresp txpyn txprdtc txpdisc txpdisco; 
    keep  __EDC_TreeNodeID __EDC_EntryDate subject   txrgnum txrgnumn txtrt  txstdtc txendtc txresp txpyn txprdtc txpdisc txpdisco;
    set tx_all_dup;
    label 
        txstdtc = 'Therapy Start Date'
        txendtc = 'Therapy Stop Date'
        txprdtc = 'If Yes, Date of Progression'
        txpdisc = 'If No, why was therapy discontinued?'
        visit = 'Visit'
    ;
run;
