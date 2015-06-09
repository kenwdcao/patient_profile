/*********************************************************************
 Program Nmae: prirad.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data prirad0;
    set source.prirad;
	%subject;
    keep EDC_TreeNodeID SUBJECT VISIT RADSTDY RADSTMO RADSTYR RADENDY RADENMO RADENYR RADLOC01 RADLOC02 RADLOC03 RADLOC04 RADLOC05
         RADLOC06 RADLOC07 RADLOC08 RADLOC09 PRADSEQ EDC_EntryDate;
run;

data prirad1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set prirad0;


    length radstdtc radendtc $20;
    label radstdtc = 'Start Date';
	label radendtc = 'End Date';
	%concatdate(year=radstyr, month=radstmo, day=radstdy, outdate=radstdtc);
	%concatdate(year=radenyr, month=radenmo, day=radendy, outdate=radendtc);
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(radstdtc);
    %concatDY(radendtc);
    drop radstyr radstmo radstdy radenyr radenmo radendy;
     
	%let loclab = @:Please check all fields previously treated with radiation (mark all that apply);
	length _radloc1-_radloc9 $40;
	label _radloc1 = "Primary tumor&loclab";
    label _radloc2 = "Lymph Node&loclab";
	label _radloc3 = "Lung&loclab";
	label _radloc4 = "Liver&loclab";
	label _radloc5 = "Bone&loclab";
	label _radloc6 = "Brain&loclab";
	label _radloc7 = "Skin&loclab";
	label _radloc8 = "Other soft tissue&loclab";
	label _radloc9 = "Other site&loclab";
	%let loclab = All fields previously treated with radiation;
	array rloc(*) radloc01-radloc09;
	array loc(*) _radloc1-_radloc9;
	do i = 1 to dim(rloc);
        if rloc[i] = 'Checked' then loc[i] = 'Yes';
    end;
	drop radloc0:; 
run;

proc sort data = prirad1; by subject radstdtc radendtc; run;

data pdata.prirad(label='Prior Cancer Radiation');
    retain EDC_TreeNodeID EDC_EntryDate subject pradseq radstdtc radendtc _radloc1-_radloc9;
	keep   EDC_TreeNodeID EDC_EntryDate subject pradseq radstdtc radendtc _radloc1-_radloc9;

	set prirad1;
	rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
	rename        pradseq = __pradseq;
run;
