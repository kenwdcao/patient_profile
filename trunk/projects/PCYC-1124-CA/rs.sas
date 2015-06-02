/********************************************************************************
 Program Nmae: RS.sas
  @Author: Feifei Bai
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

data rs;
length rsdtc rssumd_ $20; 
    set source.rs (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
    %visit; 
    if rsdt ^= . then rsdtc = put(rsdt, YYMMDD10.);
    rssumd = coalesce(rssumd, rssumds);
    if rssumdna ^= '' then rssumd_ = "Not Assessed";
        else if rssumd ^= . then rssumd_ = strip(put(rssumd, best.)); 
    rsnd=strip(put(rsnd,$checked.));
    if rstrb1^='' then trb1="CT with contrast";
    if rstrb2^='' then trb2="CT without contrast";
    if rstrb3^='' then trb3="PET/CT";
    if rstrb4^='' then trb4="MRI";
    if rstrb5^='' then trb5="PET";
    if rstrb6^='' then trb6="Bone Marrow Assessment";
    if rstrb7^='' then trb7="Tumor Biopsy Assessment";
    if rstrb8^='' then trb8="Physical Exam";
    if rstrb9^='' and rstrbs^='' then trb9="Other: "||strip(rstrbs);
    rstrb=catx(', ',trb1,trb2,trb3,trb4,trb5,trb6,trb7,trb8,trb9);

    if rspdtl1^='' then rspdtl1='TL1';
    if rspdtl2^='' then rspdtl2='TL2';
    if rspdtl3^='' then rspdtl3='TL3';
    if rspdtl4^='' then rspdtl4='TL4';
    if rspdtl5^='' then rspdtl5='TL5';
    if rspdtl6^='' then rspdtl6='TL6';
    if rspdtl^='' then rspdtl_=catx(', ',rspdtl1,rspdtl2,rspdtl3,rspdtl4,rspdtl5,rspdtl6);

proc sort; by subject rsdt visit2;
run; 

data rs; 
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set rs; 
       rc = h.find();
       %concatdy(rsdtc); 
       drop rc;
    run;

data pdata.rs1(label='Response Evaluation');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 rsnd rsdtc rssumd_ rssumdns rstrb rsrsp rsrspsp;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 rsnd rsdtc rssumd_ rssumdns rstrb rsrsp rsrspsp;
    label   rsdtc ="Assessment Date"
            rssumd_ = "Sum of Products of Diameters # (cm2)"
            rsnd = "Not Done"
            rstrb = "Overall Tumor Response Based On"
            rsrsp = "Overall Tumor Response";
    set rs;
run;

data pdata.rs2(label='Response Evaluation (Mode of Progression)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 rsdtc rspdtl_ rspdnts rspdexns rspdlns rspdnexs rspdbmis rspdcps rspdoths;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 rsdtc rspdtl_ rspdnts rspdexns rspdlns rspdnexs rspdbmis rspdcps rspdoths;
    label rsdtc ="Assessment Date"
        rspdtl_  = "Increase in Size of Target Lesion#(Lesion ID)"
    rspdnts = "Increase in Size of Other Nodal Non-target Lesion" 
    rspdexns = "Increase in Size of Other Extranodal Non-target Lesion"
    rspdlns = "New Lymph Node Lesion"
    rspdnexs = "New Extranodal Site Lesion"
    rspdbmis = "Bone Marrow Involvement"
    rspdcps = 'Clinical progression'
    rspdoths = "Other"
    ;
    set rs;
run;
