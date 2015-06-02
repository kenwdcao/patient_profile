/********************************************************************************
 Program Nmae: RS.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/13
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';


data tl_;
length tldtc tlmeas1_ tlmeas2_ $20; 
    set source.tl(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    seq = .;
    %subject;
     %visit2;
  
    if tlmeas1 > . then tlmeas1_ =strip( put(tlmeas1,best.));
    if tlmeas2 > . then  tlmeas2_ =strip( put(tlmeas2,best.));
    if tlpdiam ^= . then tlpdiam_ =strip( put(tlpdiam, best.));
    if tldt ^= . then tldtc = put(tldt, YYMMDD10.);
	format TLND checked.;
run;


proc sort data=tl_; by subject tlnum tldt visit2;run; 

data tl; 
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set tl_; 
       rc = h.find();
       %concatdy(tldtc); 
       drop rc;
    run;

data pdata.tl1(label='Target Lesion Assessment');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 tldtc tlnum tltype tlsite tlsitesp tlnd tlstus tlmeas1_ tlmeas2_ tlpdiam_ tlmeth tlmeths tlpetyn;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 tldtc tlnum tltype tlsite tlsitesp tlnd tlstus tlmeas1_ tlmeas2_ tlpdiam_ tlmeth tlmeths tlpetyn;
    label tldtc = "Assessment Date"
    tlmeas1_  = 'Long Axis#(cm)@:Lesion Measurement'
    tlmeas2_  = 'Short Axis#(cm)@:Lesion Measurement'
    tlpdiam_  = "Product of Diameters#(cm&escapechar{super 2})@:Lesion Measurement"
    tlmeth    = 'Method@:Lesion Measurement'
    tlmeths   = 'Method Specify@:Lesion Measurement';
    set tl;
    label tlsite = 'If Lymph Node, Site';
run;

data pdata.tl2(label='Target Lesion Assessment Comment');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 tlnum tlcom;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 tlnum tlcom;
    set tl;
    if tlcom ^= ''; 
run;
