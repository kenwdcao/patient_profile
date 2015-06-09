/*********************************************************************
 Program Nmae: subrad.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data subrad0;
    set source.subrad;
	%subject;
    keep EDC_TreeNodeID SUBJECT SUBRADDY SUBRADMO SUBRADYR SRADTDOS SRADLOC1 SRADLOC2 SRADLOC3 SRADLOC4 SRADLOC5
         SRADLOC6 SRADLOC7 SRADLOC8 SRADLOC9 SRADSEQ EDC_EntryDate;
run;

data subrad1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set subrad0;

    length subradtc $20;
    label subradtc = 'Radiation Date';
	%concatdate(year=subradyr, month=subradmo, day=subraddy, outdate=subradtc);
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(subradtc);
    drop subradyr subradmo subraddy;

	   
	%let loclab = @:Check all treated fields:;
	length _radloc1-_radloc9 $40;
	label sradtdos = "Total Amount (Gy)";
	label _radloc1 = "Primary tumor&loclab";
    label _radloc2 = "Lymph Node&loclab";
	label _radloc3 = "Lung&loclab";
	label _radloc4 = "Liver&loclab";
	label _radloc5 = "Bone&loclab";
	label _radloc6 = "Brain&loclab";
	label _radloc7 = "Skin&loclab";
	label _radloc8 = "Other soft tissue&loclab";
	label _radloc9 = "Other site&loclab";
	array rloc(*) sradloc1-sradloc9;
	array loc(*) _radloc1-_radloc9;
	do i = 1 to dim(rloc);
        if rloc[i] = 'Checked' then loc[i] = 'Yes';
    end;
	drop sradloc:; 
 run;

proc sort data = subrad1; by subject subradtc; run;

data pdata.subrad(label='Subsequent Anti-Cancer Radiation');
    retain EDC_TreeNodeID EDC_EntryDate subject sradseq subradtc sradtdos _radloc1-_radloc9;
	keep   EDC_TreeNodeID EDC_EntryDate subject sradseq subradtc sradtdos _radloc1-_radloc9;

	set subrad1;
    
	rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
	rename   sradseq = __sradseq;
run;
