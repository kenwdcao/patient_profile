/*
    Program Name: SC.sas
    @Author: Xiu Pan
    @Initial Date: 2015/01/30

 Modification History:

BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
Ken Cao on 2015/03/05: Concatenate --DY to PKTPT.

*/

%include '_setup.sas';

data sc;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;

    set source.sc(rename=(visit=visit_ pktm=pktm_ pkptm=pkptm_ pkttm=pkttm_  EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate));
    length pkdtc $20 pktm $200 pkptm pkttm $20;
    %ndt2cdt(ndt=pkdt, cdt=pkdtc);
    %subject;

    rc = h.find();
	%concatDY(pkdtc);
	drop rc;

   /*if pdseq^=. then visitnum=input(put(strip(visit_)||''||strip(put(pdseq,best.)),$vnum.),best.);
        else if unsseq^=. then visitnum=input(put(strip(visit_)||''||strip(put(unsseq,best.)),$vnum.),best.);
            else if crseq^=. then visitnum=input(put(strip(visit_)||''||strip(put(crseq,best.)),$vnum.),best.);
                else visitnum=input(put(visit_,$vnum.),best.);*/
    if pdseq^=. then visit=strip(visit_)||''||strip(put(pdseq,best.));
        else if unsseq^=. then visit=strip(visit_)||''||strip(put(unsseq,best.));
            else if crseq^=. then visit=strip(visit_)||''||strip(put(crseq,best.));
                else visit=strip(visit_);
    if pktm_^=. then pktm=put(pktm_,time5.);
    if pkptm_^=. then pkptm=put(pkptm_,time5.);
    if pkttm_^=. then pkttm=put(pkttm_,time5.);
    drop edc_:;
run;

data sc_;
    length previous today $60 cmnum1 cmnum2 cmnum3 cmnum $20;
    set sc(rename=(cmnum1=cmnum1_ cmnum2=cmnum2_ cmnum3=cmnum3_));
    if pknd^='' and pkdesc^='' and pktm='' then pktm='Not Done'||', '||strip(pkdesc);
        else if pknd^='' and pkdesc='' and pktm='' then pktm='Not Done';
    if pkptm^='' then previous=strip(pkptm);
        else if pkptmna^='' then previous='N/A-not dosed previous day';
    if pkttm^='' then today=strip(pkttm);
        else if pknodose^='' then today='Not Dosed';
    cmnum1=ifc(cmnum1_^=.,strip(put(cmnum1_,best.)),'');
    cmnum2=ifc(cmnum2_^=.,strip(put(cmnum2_,best.)),'');
    cmnum3=ifc(cmnum3_^=.,strip(put(cmnum3_,best.)),'');

    cmnum=catx(', ',cmnum1,cmnum2,cmnum3);
    drop cmnum1_ cmnum2_ cmnum3_;
run;

data sc_nd sc_sc;
    set sc_;
    if pkstat='Checked' then output sc_nd;
        else output sc_sc;
run;

proc sort data=sc_nd out=s_sc_nd nodupkey; by subject visit __EDC_TreeNodeID;run;

data sc_nd_1;
    set s_sc_nd;
    pktm='Not Done';
    pkgrpid='';pktpt='';
run;

data sc_all;
    set sc_sc sc_nd_1;
run;

proc sort data=sc_all; by subject /*visitnum*/ pkdt pkgrpid;run;

data pdata.sc(label='Central Lab Sample Collection for PK and Biomarkers');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit pktpt pkgrpid pkdtc pktm pkcat pkrefid previous today cmnum ;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit pkdtc pktm pkcat pkrefid pktpt pkgrpid previous today cmnum ;
    set sc_all;
    label
    pkdtc='Collection Date'
    pktm='Time of Sample'
    previous='Previous Day’s Ibrutinib Dose Time'
    today='Today’s Ibrutinib Dose Time'
    cmnum='Con Med Number'
    visit='Visit'
    ;
run;
