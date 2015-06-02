/*********************************************************************
 Program Nmae: lab.sas
  @Author: Ken Cao
  @Initial Date: 2015/05/04
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/


%include '_setup.sas';

data lbpreg0;
    length  subject $13 __rfstdtc $10 lbdtc $20;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
    set source.lb;
    %subject;
    %visit2;

    %ndt2cdt(ndt=lbdt, cdt=lbdtc);
    %concatDY(lbdtc);

    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename EDC_EntryDate  = __EDC_EntryDate;
run;


data pdata.lbpreg(label='Pregnancy Test');
    retain __EDC_TreeNodeID __EDC_EntryDate subject lbdtc lbspec lborres lbultres;
    keep __EDC_TreeNodeID __EDC_EntryDate subject lbdtc lbspec lborres lbultres;
    set lbpreg0;

    label lbdtc = 'Collection Date';
run;
