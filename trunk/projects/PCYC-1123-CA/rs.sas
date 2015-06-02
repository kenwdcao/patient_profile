/********************************************************************************
 Program Nmae: RS.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/13
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

data rs_;
length rsdtc rssumd_ $20; 
    set source.rs(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
     %visit2;
    if rsdt ^= . then rsdtc = put(rsdt, YYMMDD10.);
    rssumd = coalesce(rssumd, rssumds);
    if rssumdna ^= . then rssumd_ = "Not Assessed";
        else if rssumd ^= . then rssumd_ = strip(put(rssumd, best.)); 
    if rstrb1^=. then trb1="CT with contrast";
    if rstrb2^=. then trb2="CT without contrast";
    if rstrb3^=. then trb3="PET/CT";
    if rstrb4^=. then trb4="MRI";
    if rstrb5^=. then trb5="PET";
    if rstrb6^=. then trb6="Bone Marrow Assessment";
    if rstrb7^=. then trb7="Tumor Biopsy Assessment";
    if rstrb8^=. then trb8="Physical Exam";
    if rstrb9^=. and rstrbs^='' then trb9="Other: "||strip(rstrbs);
    rstrb=catx(', ',trb1,trb2,trb3,trb4,trb5,trb6,trb7,trb8,trb9);
    
    if rspdtl1^=. then pdtl1='TL1';
    if rspdtl2^=. then pdtl2='TL2';
    if rspdtl3^=. then pdtl3='TL3';
    if rspdtl4^=. then pdtl4='TL4';
    if rspdtl5^=. then pdtl5='TL5';
    if rspdtl6^=. then pdtl6='TL6';
    if rspdtl^=. then rspdtl_=catx(', ',pdtl1,pdtl2,pdtl3,pdtl4,pdtl5,pdtl6);

	if RSPDNTS^=. then PDNTS='NN01';
    if RSPDNT2^=. then PDNT2='NN02';
    if RSPDNT3^=. then PDNT3='NN03';
    if RSPDNT4^=. then PDNT4='NN04';
	if RSPDNT^=. then  RSPDNT_=catx(', ',PDNTS,PDNT2,PDNT3,PDNT4);



if RSPDEXNS^=. then PDEXNS='NE01';
if RSPDEXN2^=. then PDEXN2='NE02';
if RSPDEXN3^=. then PDEXN3='NE03';
if RSPDEXN4^=. then PDEXN4='NE04';
if RSPDEXN^=. then RSPDEXN_=catx(', ',PDEXNS,PDEXN2,PDEXN3,PDEXN4);
run;


proc sort data=rs_; by subject rsdt visit2;run; 

data rs; 
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set rs_; 
       rc = h.find();
       %concatdy(rsdtc); 
       drop rc;
    run;

data pdata.rs1(label='Response Evaluation');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 rsnd rsdtc rssumd_  rstrb rsrsp rsrspsp;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 rsnd rsdtc rssumd_  rstrb rsrsp rsrspsp;
    label   rsdtc ="Assessment Date"
            rssumd_ = "Sum of Products of Diameters # (cm2)"
            rsnd = "Not Done"
            rstrb = "Overall Tumor Response Based On"
            rsrsp = "Overall Tumor Response";
    set rs;
	if rseval='';
run;

data pdata.rs2(label='Response Evaluation (Mode of Progression)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 rsdtc rspdtl_ rspdnt_ rspdexn_ rspdlns rspdnexs rspdcps rspdoths;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 rsdtc rspdtl_ rspdnt_ rspdexn_ rspdlns rspdnexs  rspdcps rspdoths;
    label rsdtc ="Assessment Date"
    rspdtl_  = "Increase in Size of Target Lesion#(Lesion ID)"
    rspdnt_ = "Increase in Size of Other Nodal Non-target Lesion" 
    rspdexn_ = "Increase in Size of Other Extranodal Non-target Lesion"
    rspdlns = "New Lymph Node Lesion"
    rspdnexs = "New Extranodal Site Lesion"
    rspdcps = 'Clinical progression'
    rspdoths = "Other"
    ;
    set rs;
	if rseval='';   
run;


data pdata.rs3(label='Response Follow-up Visit Prompt');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 rseval rsevalr;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 rseval rsevalr;
    label rsdtc ="Assessment Date"
    ;
    set rs;
	if rseval^='';
run;
