/*********************************************************************
 Program Nmae: FU.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/15
*********************************************************************/
%include "_setup.sas";

data fu;
     length subject $13  fucontdtc $20 rfstdtc $10;
     ***long term fu**;
    if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;

    set source.fu (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    %subject;
  
**contact**;
   label fucontdt = 'Date of Contact';
    %ndt2cdt(ndt=fucontdt, cdt=fucontdtc);
    rc = h.find();
    %concatDY(fucontdtc);

**death**;
    %ndt2cdt(ndt=deathdat, cdt=deathdatc);
    rc = h.find();
    %concatDY(deathdatc);

**alive**;
    %ndt2cdt(ndt=fulalvdt, cdt=fulalvdtc);
    rc = h.find();
    %concatDY(fulalvdtc);

run;

data pdata.fu1(label='Long Term Follow-Up Visit Prompt');
    retain __EDC_TreeNodeID __EDC_EntryDate subject funy fureas;
    keep __EDC_TreeNodeID __EDC_EntryDate subject funy fureas;
    set fu;
    where EDC_FormLabel='Long Term Follow-Up Visit Prompt';
run;

data pdata.fu2(label='Long Term Follow-Up');
    retain __EDC_TreeNodeID __EDC_EntryDate subject  fucontdtc fualive deathdatc fulalvdt;
    keep __EDC_TreeNodeID __EDC_EntryDate subject  fucontdtc fualive deathdatc fulalvdt;
    set fu;
    where EDC_FormLabel^='Long Term Follow-Up Visit Prompt';
    label fucontdtc = 'Date of Contact';
    label fualive = 'Is subject alive?';
    label deathdatc = 'If No, provide date of death';
    label fulalvdt = 'If Lost to follow-up, date subject was last known to be alive';
run;
