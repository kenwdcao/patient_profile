/********************************************************************************
 Program Nmae: RS.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/13
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';


data ne_;
length nedtc nemeas1_ nemeas2_ nepdiam_ $20; 
    set source.ne (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
    %visit2;
    if nedt ^= . then nedtc = put(nedt, YYMMDD10.);
    if nemeas1>. then nemeas1_ =strip( put(nemeas1,best.));
    if nemeas2>. then  nemeas2_ =strip( put(nemeas2,best.));
    if nepdiam ^= . then nepdiam_ =strip( put(nepdiam, best.));
	  format nend checked.;
run;

proc sort data=ne_; by subject nenum nedtc  visit2 ;run; 

data ne;
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set ne_; 
       rc = h.find();
       %concatdy(nedtc); 
       drop rc;
    run;

data pdata.ne1(label='Extranodal Non-Target Lesion Assessment');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 nedtc nenum nesitesp nend nestus nemeas1_ nemeas2_ nepdiam_ nemeth nemethsp nepetyn;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 nedtc nenum nesitesp nend nestus nemeas1_ nemeas2_ nepdiam_ nemeth nemethsp nepetyn;
    label  nedtc ="Assessment Date"
    nemeas1_  = 'Long Axis#(cm)@:Lesion Measurement'
    nemeas2_  = 'Short Axis#(cm)@:Lesion Measurement'
    nepdiam_  = 'Product of Diameters#(cm&escapechar{super 2})@:Lesion Measurement'
	nemeth    = 'Method@:Lesion Measurement'
    nemethsp   = 'Method Specify@:Lesion Measurement';
    set ne;
run;

data pdata.ne2(label='Extranodal Non-Target Lesion Assessment Comment');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 nenum necom;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 nenum necom;
    label nedtc = "Assessment Date";
    set ne;
    if necom ^= ''; 
run;
