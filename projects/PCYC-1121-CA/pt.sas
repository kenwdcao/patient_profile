/*********************************************************************
 Program Nmae: PT.sas
  @Author: Huihui Zhang
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/02/06: Split PT into two datasets. One for overall result
                        and the other for specific sites.
 BFF on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/04: 1) Split PTRES and PTRESSP .
                       2) Drop PTASYN.
 Ken Cao on 2015/03/05: Concatenate --DY to PTDTC.
*********************************************************************/
%include '_setup.sas';

proc sort data=source.pt out=s_pt nodupkey; by _all_; run;

data pt01;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;
    length ptdtc $19 ptres ptorres $200;
    set s_pt(rename=(ptorres=in_ptorres EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate=__EDC_EntryDate));
    %subject;
    * ptres=catx(": ",ptres,ptressp);
    ptorres=put(in_ptorres,$checked.);
    ptorres=catx(": ",ptorres,ptorreso);
    if ptnd='Checked' then ptnd='Not Done';
    if crseq^=. then visit=strip(visit)||" "||strip(put(crseq,best.));
    else if unsseq^=. then visit=strip(visit)||" "||strip(put(unsseq,best.));
    else visit=visit;
    %ndt2cdt(ndt=ptdt, cdt=ptdtc);

	rc = h.find();
	%concatDY(ptdtc);
	drop rc;


    drop edc_:;
    label 
        ptdtc = 'PET Assessment Date'
        ptorres = 'Result'
        visit = 'Visit'
        ptressp = 'If Indeterminate, specify'
    ;

run;


/*
proc sort data=pt01; by subject ptdtc pttest; run;


data pdata.pt(label="Imaging by PET");
    retain subject visit ptdtc ptnd ptres ptasyn pttest ptorres ;
    keep subject visit ptdtc ptnd ptres ptasyn pttest ptorres ;
    set pt01;
    label 
        ptdtc = 'PET Assessment Date'
        ptorres = 'Result'
        visit = 'Visit'
    ;
run;
*/

proc sort data=pt01(keep=subject visit ptdtc ptnd ptres ptressp ptasyn __EDC_TreeNodeID __EDC_EntryDate) out=pt1 nodupkey;
    by subject ptdtc visit  ptnd ptres ptasyn __EDC_TreeNodeID;
run;

data pdata.pt1(label="Imaging by PET");
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit ptdtc ptnd ptres ptressp   PTASYN;
    keep __EDC_TreeNodeID __EDC_EntryDate subject visit ptdtc ptnd ptres ptressp  PTASYN ;
    set pt1;
    rename ptasyn = __ptasyn;
run;

proc sort data=pt01(keep=subject visit ptdtc pttest ptorres __EDC_TreeNodeID __EDC_EntryDate) out=pt2 nodupkey;
    by subject visit ptdtc pttest ptorres __EDC_TreeNodeID;
    where ptorres > ' ' ;
run;

data pdata.pt2(label="Imaging by PET (Individual Sites)");
    retain __EDC_TreeNodeID __EDC_EntryDate subject visit ptdtc pttest ptorres;
    keep __EDC_TreeNodeID __EDC_EntryDate  subject visit ptdtc pttest ptorres;
    set pt2;
run;

