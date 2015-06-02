/********************************************************************************
 Program Nmae: PT.sas
   @Author: Yuanmei Wang
  @Initial Date: 2015/04/13
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


********************************************************************************/

%include '_setup.sas';

data pt_;
length ptdtc $20 ptres ptorres_ $200; 
    set source.pt (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
     %visit2;
    ptres=catx(": ",ptres,ptressp);
    ptorres_=put(ptorres,best.);
    if ptorreso > ' ' then ptorres_ = ptorreso;
    if ptdt ^= . then ptdtc = put(ptdt, YYMMDD10.);
/*  pttest=left(translate(pttest, " ", '09'x));*/
    format  ptnd checked.;
run;

proc sort data=pt_; by subject ptdtc;run; 

data pt; 
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set pt_; 
       rc = h.find();
       %concatdy(ptdtc); 
       drop rc;
run;

proc sort data = pt out = pt1 nodupkey; by subject ptdtc visit2 ptres ptressp ptasyn;run;

data pdata.pt1(label='Imaging by PET');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 ptnd  ptdtc ptres ptressp ptasyn;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 ptnd  ptdtc ptres ptressp ptasyn;
    label   ptdtc ="Assessment Date";
    set pt1;
    label ptressp = 'If Indeterminate, specify';
    label ptasyn = 'Any metabolically active sites in addition to target and non-target lesions?';
    label ptnd = 'Not Done';
run;


proc sort data = pt out = pt2; by subject ptdtc visit2 pttest;
    where ptorres_ ^= ' ';
run;

data pdata.pt2(label='Imaging by PET (Individual Sites)');
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit2 ptdtc pttest ptorres_;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit2 ptdtc pttest ptorres_;
    label   ptdtc ="Assessment Date";
    set pt2;
    label ptorres_ = 'Other Specify';
    if pttest ^= 'Other positive non-tracked disease site' then ptorres_ = ' ';
run;
