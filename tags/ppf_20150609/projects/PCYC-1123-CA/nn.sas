/********************************************************************************
 Program Nmae: RS.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/13
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/

%include '_setup.sas';


data nn;
length nndtc nnmeas1_ nnmeas2_ nnpdiam_ $20; 
    set source.nn (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
	%visit2;
    seq = .;

   if nndt ^= . then nndtc = put(nndt, YYMMDD10.);
   if nnmeas1 > . then nnmeas1_ =strip( put(nnmeas1,best.));
   else if nnmeas2 > . then  nnmeas2_ =strip( put(nnmeas2,best.));
   if nnpdiam ^= . then nnpdiam_ =strip( put(nnpdiam, best.));
   format nnnd checked.;
run;

proc sort; by subject nnnum nndtc  visit2 ;run; 

data nn;
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set nn; 
       rc = h.find();
       %concatdy(nndtc); 
       drop rc;
run;

data pdata.nn1(label='Nodal Non-Target Lesion Assessment');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 nndtc nnnum nnsite nnsitesp nnnd nnstus nnmeas1_ nnmeas2_ nnpdiam_ nnmeth nnmethsp nnpetyn ;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 nndtc nnnum nnsite nnsitesp nnnd nnstus nnmeas1_ nnmeas2_ nnpdiam_ nnmeth nnmethsp nnpetyn;
    label  nndtc ="Assessment Date"
    nnmeas1_  = 'Long Axis#(cm)@:Lesion Measurement'
    nnmeas2_  = 'Short Axis#(cm)@:Lesion Measurement'
    nnpdiam_  = 'Product of Diameters#(cm&escapechar{super 2})@:Lesion Measurement'
    nnmeth    = 'Method@:Lesion Measurement'
    nnmethsp   = 'Method Specify@:Lesion Measurement';
    set nn;
run;

data pdata.nn2(label='Nodal Non-Target Lesion Assessment Comment');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 nnnum nncom;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 nnnum nncom;
    label nndtc = "Assessment Date";
    set nn;
    if nncom ^= ''; 
run;
