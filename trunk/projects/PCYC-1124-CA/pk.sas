/********************************************************************************
 Program Nmae: Pk.sas
  @Author: Feifei Bai
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

data pk;
length pkdtc pkdostm_ pktm_ $20; 
	set source.pk (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
	%subject;
	%visit;
	if pkdostm ^= . then pkdostm_ = put(pkdostm, time5.);
		else if pkdostmu ^= '' then pkdostm_ = 'Unknown';
	if pktm ^= . then pktm_ = put(pktm, time5.);
		else if pknd ^= '' then pktm_ = 'Not Done';
	if pkdt ^= . then pkdtc = put(pkdt, YYMMDD10.);
proc sort; by subject pkdtc;
run; 

data pk;
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set pk; 
       rc = h.find();
       %concatdy(pkdtc); 
       drop rc;
    run;

data pdata.pk(label='Pharmacokinetics (PK)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 pkdtc pkrefid pkdostm_ pktpt pktm_ pknds;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 pkdtc pkrefid pkdostm_ pktpt pktm_ pknds;
	label   pkdtc ="Collection Date"
			pkdostm_ ="Ibrutinib Dose Time"
			pktm_ ="Collection Time";
    set pk;
run;
