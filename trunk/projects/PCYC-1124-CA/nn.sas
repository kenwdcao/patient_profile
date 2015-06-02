/********************************************************************************
 Program Nmae: NN.sas
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

data nn;
length nndtc nnmeas1_ nnmeas2_ nnpdiam_ $20; 
    set source.nn (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
    seq = .;
    %visit;
    if nndt ^= . then nndtc = put(nndt, YYMMDD10.);
    ** Ken Cao on 2015/02/27: remove dot;
    if tlmeas1n ^= '' then nnmeas1_ = "Not Reported"; else if nnmeas1 > . then nnmeas1_ =strip( put(nnmeas1,best.));
    if tlmeas2n ^= '' then nnmeas2_ = "Not Reported"; else if nnmeas2 > . then  nnmeas2_ =strip( put(nnmeas2,best.));
    if nnpdiam ^= . then nnpdiam_ =strip( put(nnpdiam, best.));
proc sort; by subject nnnum nndtc visit2 ;
run; 

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
    nnmeas1_  = 'Long Axis#(cm)'
    nnmeas2_  = 'Short Axis#(cm)'
    nnpdiam_  = "Product of Diameters#(cm&escapechar{super 2})";;
    set nn;
run;

data pdata.nn2(label='Nodal Non-Target Lesion Assessment Comment');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 nnnum nncom;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 nnnum nncom;
    label nndtc = "Assessment Date";
    set nn;
    if nncom ^= ''; 
run;
