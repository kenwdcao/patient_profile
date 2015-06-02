/********************************************************************************
 Program Nmae: PT.sas
  @Author: Feifei Bai
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/03/23: Change label of PTORRES column to Other Specify and only 
                        fill the column if site = “Other positive non-tracked disease site”.
********************************************************************************/
%include '_setup.sas';

data pt;
length ptdtc $20 ptres ptorres $200; 
    set source.pt (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
    %visit;
    ptres=catx(": ",ptres,ptressp);
    ptorres=put(ptorres,$checked.);
    *ptorres=catx(": ",ptorres,ptorreso);
    if ptorreso > ' ' then ptorres = ptorreso;
    if ptdt ^= . then ptdtc = put(ptdt, YYMMDD10.);
proc sort; by subject ptdtc;
run; 

data pt; 
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set pt; 
       rc = h.find();
       %concatdy(ptdtc); 
       drop rc;
    run;



proc sort data = pt out = pt1 nodupkey; by subject ptdtc visit2 ptres ptressp ptasyn;
run;

data pdata.pt1(label='Imaging by PET');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 ptdtc ptres ptressp ptasyn;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 ptdtc ptres ptressp ptasyn;
    label   ptdtc ="Assessment Date";
    set pt1;
    label ptressp = 'If Indeterminate, specify';
    label ptasyn = 'Any metabolically active sites in addition to target and non-target lesions?';
run;


proc sort data = pt out = pt2; by subject ptdtc visit2 pttest;
    where ptorres ^= ' ';
run;

data pdata.pt2(label='Imaging by PET (Individual Sites)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 ptdtc pttest ptorres;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 ptdtc pttest ptorres;
    label   ptdtc ="Assessment Date";
    set pt2;
    label ptorres = 'Other Specify';
    if pttest ^= 'Other positive non-tracked disease site' then ptorres = ' ';
run;
