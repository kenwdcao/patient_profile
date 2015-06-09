/*********************************************************************
 Program Nmae: ds.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data ds0;
    set source.ds;
    %subject;
    keep EDC_TreeNodeID SUBJECT	DSRSN DSOTHSP DSEXTDAT EDC_EntryDate;
run;


data ds1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set ds0;
	
    length dsextdtc $20;
	label   dsextdtc = 'Date of Study Exit';
	%ndt2cdt(ndt=dsextdat, cdt=dsextdtc);
	rc = h.find();
	drop rc rfstdtc;
    %concatDY(dsextdtc);
	label dsrsn = 'Primary reason subject exited the study'
	      dsothsp = 'Comment'
		  ;
run;

proc sort data = ds1; by subject dsextdtc; run;

data pdata.ds(label='Study Exit');
    retain EDC_TreeNodeID EDC_EntryDate subject dsextdtc dsrsn dsothsp; 
    keep   EDC_TreeNodeID EDC_EntryDate subject dsextdtc dsrsn dsothsp; 

    set ds1;
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;

run;
