/*********************************************************************
 Program Nmae: ic.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data ic0;
    set source.ic;
    %subject;
    keep EDC_TreeNodeID SUBJECT VISIT ICRCYN ICCAT ICPRTVR ICSEQ ICDAT ICPRTSP EDC_EntryDate;
run;


data ic1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set ic0;

    length icdtc $20;
    %ndt2cdt(ndt=icdat, cdt=icdtc);
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(icdtc);

    length icprtvrp $255 icprtspc $20;
    label icprtvrp = 'Protocol Version'; 
    if icprtsp > . then icprtspc = cats(icprtsp);
    if icprtspc ^= '' then icprtvrp = catx(': ', icprtvr, icprtspc);
       else icprtvrp = strip(icprtvr);
run;

proc sort data=ic1; by subject iccat; run;

data pdata.ic1(label='Informed Consent');

    retain EDC_TreeNodeID EDC_EntryDate subject visit icseq iccat icdtc icprtvr icprtsp;
    keep   EDC_TreeNodeID EDC_EntryDate subject visit icseq iccat icdtc icprtvr icprtsp;

    set ic1;
    label  icdtc = 'Date of informed consent';
    label icprtsp = 'Amendment (specify)';
    where iccat = 'Informed Consent';
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename          visit = __visit;
    rename          icseq = __icseq;
    rename          iccat = __iccat;
run;

data pdata.ic2(label='Re-Consent');

    retain EDC_TreeNodeID EDC_EntryDate subject visit icseq iccat icrcyn icdtc icprtvr icprtsp;
    keep   EDC_TreeNodeID EDC_EntryDate subject visit icseq iccat icrcyn icdtc icprtvr icprtsp;

    set ic1;
    label  icdtc = 'Date of re-consent';
    label icprtsp = 'Amendment (specify)';
    where iccat = 'Informed Re-Consent';
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename          visit = __visit;
    rename          icseq = __icseq;
    rename          iccat = __iccat;
run;

