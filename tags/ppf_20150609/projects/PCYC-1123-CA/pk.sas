/*********************************************************************
 Program Nmae: pk.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/09
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/
%include '_setup.sas';

data pk;
length pkdtc  pktm_  LBIHCDTC  lbna_$20; 
	set source.pk (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
	%subject;
    %visit2;
	if lbtm ^= . then pktm_ = put(lbtm, time5.);
		else if lbna ^= . then lbtm_ = 'Not Done';
	if lbdt ^= . then pkdtc = put(lbdt, YYMMDD10.); else pkdtc ="";
	if LBIHCDT^=. then LBIHCDTC=put(LBIHCDT,YYMMDD10.);else LBIHCDTC="";
	if lbna^=. then lbna_="Yes" ; else lbna_="";
run;

proc sort; by subject pkdtc visit2 lbcat lbrefid;run; 

data pk1;
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

data pdata.pk(label='Sample Collection');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 lbna_ lbrefid EDC_FormLabel lbcat pkdtc pktm_ lborres lbihcdtc ;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 lbna_ lbrefid EDC_FormLabel lbcat pkdtc pktm_ lborres lbihcdtc ;
	label   pkdtc ="Collection Date"
			pktm_ ="Collection Time"
            lbna_="Not Done"
			EDC_FormLabel="Sample Type"
			lbihcdtc="IHC Subtype Result Date";
    set pk1;
run;
