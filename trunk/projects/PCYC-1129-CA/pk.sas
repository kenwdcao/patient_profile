/*********************************************************************
 Program Nmae: pk.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/
%include '_setup.sas';

data pk;
length unk pkdtc  pktm_  $20 subject $13 __rfstdtc $10;
    if _n_ = 1 then do;
       declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set source.pk (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
      attrib
     unk label='Current Ibrutinib Dose Time Unknown'
     pktm_ label='Collection Time'
     PKCDOTM_ label='Current Ibrutinib Dose Time'
     PKTPT label='Collection Period'
     pknd label='Not Done'
     pknds label='Specify reason if not done';

    %subject;
    %visit2;
    unk=ifc( pkcdotmu^='',put(pkcdotmu,$checked.),'');
  
    ***date**;
    label pkdtc = 'PK Sample Collection Date';
    %ndt2cdt(ndt=pkdt, cdt=pkdtc);
    rc = h.find();
    %concatDY(pkdtc);

    **time**;
    if PKCDOTM^=. then PKCDOTM_=put(PKCDOTM, time5.);
    if PKTM ^= . then PKTM_ = put(PKTM, time5.);


    ** For sorting PKTPT;
    if pktpt = 'Pre-Dose' then pktptnum = -1;
    else if prxmatch('/\d Hour[s]* Post-Dose/', pktpt) then pktptnum = input(substr(pktpt, 1,1), best.);
run;

proc sort data=pk; by subject pkdtc visit2 pktptnum;run; 

data pdata.pk(label='Pharmacokinetics (PK)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 pkdtc PKCDOTM_ unk  PKTPT  pktm_ pknd pknds ;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 pkdtc PKCDOTM_ unk  PKTPT  pktm_ pknd pknds ;
    set pk;
run;
