/*********************************************************************
 Program Nmae: ex.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data ex0;
    set source.ex;
    %subject;
    keep EDC_TreeNodeID SUBJECT CYCLE VISIT EXSTDY EXSTMO EXSTYR EXENDY EXENMO EXENYR LASTDOSE EXDSTXT EXDOSU EXOTDOSP EXOTDOSU 
         EXADJYN EXADJRSN EXOTHSP EXSEQ EXAENO01 EXAENO02 EXAENO03 EDC_EntryDate;
run;

data ex1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set ex0;

	if lastdose = 'Checked' then lastdose = 'Yes';
	label lastdose = 'Last dose of study drug';
    length exstdtc $20 exendtc $20;
	label exstdtc = 'Start Date';
	label exendtc = 'End Date';
    %concatdate(year=exstyr, month=exstmo, day=exstdy, outdate=exstdtc);
    %concatdate(year=exenyr, month=exenmo, day=exendy, outdate=exendtc);
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(exstdtc);
    %concatDY(exendtc);
    drop exstyr exstmo exstdy exenyr exenmo exendy;

	length exno01 exno02 exno03 exaeno $255;
	label  exaeno = "If Dose Modification Type is 'Adverse Event', please specify AE Number (s)";
	label exothsp = "If Dose Modification Type is 'Other', please specify";
	** Reason the Dose Was Adjusted;
	array t(3)exaeno01 exaeno02 exaeno03;
    array d(3)exno01 exno02 exno03;
	 do i = 1 to 3;
	   if t(i) ^= . then d(i) = strip(put(t(i), best.));
	 end;

	exaeno = catx(', ', exno01, exno02, exno03);
    drop exaeno0: exno:;
	%visit2;
run; 

proc sort data=ex1; by subject exstdtc exendtc ;run;

data pdata.ex(label='Study Drug Administration - Ibrutinib');

    retain EDC_TreeNodeID EDC_EntryDate subject exseq visit2 exstdtc exendtc lastdose exdstxt exdosu exotdosp 
           exotdosu exadjyn exadjrsn exaeno exothsp;
    keep   EDC_TreeNodeID EDC_EntryDate subject exseq visit2 exstdtc exendtc lastdose exdstxt exdosu exotdosp 
           exotdosu exadjyn exadjrsn exaeno exothsp;

    set ex1;

	label   exdstxt = 'Dose per Administration'
	       exotdosp = 'If Other Dose, specify'
            exadjyn = 'Was the Dose adjusted from planned?'
	       exadjrsn = 'What was the reason the dose was adjusted?'
		   ;
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename          exseq = __exseq;

run;

