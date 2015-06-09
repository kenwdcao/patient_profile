/********************************************************************************
 Program Nmae: TL.sas
  @Author: Feifei Bai
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 
 Ken Cao on 2015/02/27: Remove dot from varaible that was converted from numeric
                        variable

 Ken Cao on 2015/03/10: Sort dataset by lesion number and then by date.
********************************************************************************/
%include '_setup.sas';

data tl;
length tldtc tlmeas1_ tlmeas2_ $20; 
    set source.tl (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    seq = .;
    %subject;
    %visit; 
    ** Ken Cao on 2015/02/27: remove dot;
    if tlmeas1n ^= '' then tlmeas1_ = "Not Reported"; else if tlmeas1 > . then tlmeas1_ =strip( put(tlmeas1,best.));
    if tlmeas2n ^= '' then tlmeas2_ = "Not Reported"; else if tlmeas2 > . then  tlmeas2_ =strip( put(tlmeas2,best.));
    if tlpdiam ^= . then tlpdiam_ =strip( put(tlpdiam, best.));
    if tldt ^= . then tldtc = put(tldt, YYMMDD10.);

proc sort; by subject tlnum tldt visit2;
run; 

data tl; 
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set tl; 
       rc = h.find();
       %concatdy(tldtc); 
       drop rc;
    run;

data pdata.tl1(label='Target Lesion Assessment');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 tlnum tltype tlsite tlsitesp tlnd tldtc tlstus tlmeas1_ tlmeas2_ tlpdiam_ tlmeth tlmethsp tlpetyn;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 tlnum tltype tlsite tlsitesp tlnd tldtc tlstus tlmeas1_ tlmeas2_ tlpdiam_ tlmeth tlmethsp tlpetyn;
    label tldtc = "Assessment Date"
    tlmeas1_  = 'Long Axis#(cm)'
    tlmeas2_  = 'Short Axis#(cm)'
    tlpdiam_  = "Product of Diameters#(cm&escapechar{super 2})";
    set tl;
    label tlsite = 'If Lymph Node, Site';
run;

data pdata.tl2(label='Target Lesion Assessment Comment');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 tlnum tlcom;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 tlnum tlcom;
    label tldtc = "Assessment Date";
    set tl;
    if tlcom ^= ''; 
run;
