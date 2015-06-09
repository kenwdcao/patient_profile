/*********************************************************************
 Program Nmae: RS.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/02/03
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

Ken Cao on 2015/02/05: Changed dataset label of RS2.
BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
Ken Cao on 2015/02/25: Drop RSDTC from RS2.
Ken Cao on 2015/03/05: Concatenate --DY to RSDTC.


*********************************************************************/
%include "_setup.sas";

data rs;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;

    length rsdtc $20 trb1-trb9 rstrb rspdtl_ $200 rsorres $50;
    set source.rs (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate));
    %subject;
    if pdseq^=. then visit=strip(visit)||" "||strip(put(pdseq,best.));
    else if crseq^=. then visit=strip(visit)||" "||strip(put(crseq,best.));
    else if unsseq^=. then visit=strip(visit)||" "||strip(put(unsseq,best.));
    else visit=visit;

    *if rsdt^=. then rsdtc=put(rsdt,yymmdd10.);	

    %ndt2cdt(ndt=rsdt, cdt=rsdtc);
    rc = h.find();
	%concatDY(rsdtc);
	drop rc;

    if rssumd^=. then rsorres=strip(put(rssumd,best.))||' '||strip(rssumdu);
    else if rssumdna^='' then rsorres="Not Assessed";
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

    keep subject visit rsdtc rsorres rsnd rstrb rsrsp rsrspsp rspdtl_ rspdnts rspdexnl rspdexns
         rspdlns rspdnexs rspdcps rspdoths __EDC_TreeNodeID __EDC_EntryDate;
run;

proc sort data=rs;by subject rsdtc;run;

data pdata.rs1(label="Response Evaluation");
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit rsdtc rsorres rsnd rstrb rsrsp rsrspsp ;
    attrib
    rsdtc       label="Date"
    visit       label="Visit"
    rsorres     label="Sum of Products of Diameters"
    rsnd        label="Not Done"
    rstrb       label="Overall Tumor Response Based On"
    rsrsp       label="Overall Tumor Response"    
    ;
    set rs;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit rsdtc rsorres rsnd rstrb rsrsp rsrspsp ;
run;


** Ken Cao on 2015/02/05: Changed dataset label;
data pdata.rs2(label="Response Evaluation (Mode of Progression)");
    retain __EDC_TreeNodeID __EDC_EntryDate  subject visit  rspdtl_ rspdnts rspdexnl rspdexns rspdlns rspdnexs rspdcps rspdoths ;
    attrib
    rsdtc       label="Date"
    visit       label="Visit"
    rspdtl_     label="Increase in size of target lesion#(Lesion ID)"
    rspdnts     label="Specify tracked lesion ID" 
    rspdexnl    label="and/or describe location of non-tracked nodal lesion(s):" 
    rspdexns    label="Increase in Size of Other Extranodal Site#(Lesion ID)"
    rspdlns     label="New lymph node lesion"
    rspdnexs    label="New extranodal site lesion"
    rspdcps     label="Clinical progression"
    rspdoths    label="Other"
    ;
    set rs;
    keep __EDC_TreeNodeID __EDC_EntryDate  subject visit  rspdtl_ rspdnts rspdexnl rspdexns rspdlns rspdnexs rspdcps rspdoths ;
run;


