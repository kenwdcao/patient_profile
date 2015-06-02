/********************************************************************************
 Program Nmae: NE.sas
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

data ne;
length nedtc nemeas1_ nemeas2_ nepdiam_ $20; 
    set source.ne (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
    seq = .;
    %visit;
    if nedt ^= . then nedtc = put(nedt, YYMMDD10.);
    ** Ken Cao on 2015/02/27: remove dot;
    if tlmeas1n ^= '' then nemeas1_ = "Not Reported"; else if nemeas1>. then nemeas1_ =strip( put(nemeas1,best.));
    if tlmeas2n ^= '' then nemeas2_ = "Not Reported"; else if nemeas2>. then  nemeas2_ =strip( put(nemeas2,best.));
    if nepdiam ^= . then nepdiam_ =strip( put(nepdiam, best.));
proc sort; by subject nenum nedtc visit2 ;
run; 

data ne;
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set ne; 
       rc = h.find();
       %concatdy(nedtc); 
       drop rc;
    run;

data pdata.ne1(label='Extranodal Non-Target Lesion Assessment');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 nedtc nenum nesitesp nend nestus nemeas1_ nemeas2_ nepdiam_ nemeth nemethsp nepetyn;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 nedtc nenum nesitesp nend nestus nemeas1_ nemeas2_ nepdiam_ nemeth nemethsp nepetyn;
    label  nedtc ="Assessment Date"
    nemeas1_  = 'Long Axis#(cm)'
    nemeas2_  = 'Short Axis#(cm)'
    nepdiam_  = "Product of Diameters#(cm&escapechar{super 2})";;
    set ne;
run;

data pdata.ne2(label='Extranodal Non-Target Lesion Assessment Comment');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 nenum necom;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 nenum necom;
    label nedtc = "Assessment Date";
    set ne;
    if necom ^= ''; 
run;
