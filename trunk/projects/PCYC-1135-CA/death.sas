/*********************************************************************
 Program Nmae: death.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/24
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data death0;
    set source.death;
	%subject;
    keep EDC_TreeNodeID SUBJECT DEATHCS ILLNESSP DEATHSP DEATHDAT EDC_EntryDate;
run;


data death1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set death0;

    length dthdtc $20;
	label   dthdtc = 'Date of Death';
	%ndt2cdt(ndt=deathdat, cdt=dthdtc);
	rc = h.find();
	drop rc rfstdtc;
   %concatDY(dthdtc);
   label deathcs = 'Cause of Death'
         illnessp = 'If Intercurrent Illness, Specify'
         deathsp = 'If Other, Specify'
		 ;
run;

proc sort data=death1; by subject; run;

data pdata.death(label='Death Report');

    retain EDC_TreeNodeID EDC_EntryDate subject dthdtc deathcs illnessp deathsp;
    keep   EDC_TreeNodeID EDC_EntryDate subject dthdtc deathcs illnessp deathsp;

    set death1;
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
run;


