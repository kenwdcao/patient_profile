/*********************************************************************
 Program Nmae: nh.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data nh0;
    set source.nh;
	%subject;
	keep EDC_TreeNodeID SUBJECT VISIT NHSTDY NHSTMO NHSTYR NHHIST NHNA NHHIST1 NHHISTSP NHHIST2 NHHIST3 NHLOCSP NHHIST4
         NHHIST5 NHHIST6 NHOTHSP NHTLOC1 NHTLOC2 NHTLOC3 NHTLOC4 NHTLOC5 NHTLOC6 NHTLOC7 NHTLOC8 NHTLOC9 NHTLOC10 NHTLOC11
         NHTLOC12 NHTLOC13 NHTLOC14 NHTLOC15 NHTLOCSP NHSTAGE NHSTAGET NHSTAGEN NHSTAGEM NHOSTGSP EDC_EntryDate;
run;

data nh1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set nh0;
    
    %let hislab = %nrstr(Subject%'s cancer risks (mark all that apply));
    %let loclab = Gene Mutations and Translocations;
    length nhstdtc $20 _nhna _nhhis1-_nhhis6 _nhloc1-_nhloc15 $255;
    label  nhstdtc = "Date of Initial Diagnosis"
             _nhna = "None@:&hislab"
           _nhhis1 = "Family history of cancer (specify)@:&hislab"
           _nhhis2 = "History of being >30 lbs overweight@:&hislab"
		   _nhhis3 = "Radiation therapy of the body before age 30 (specify location)@:&hislab"
		   _nhhis4 = "Alcohol ingestion@:&hislab"
		   _nhhis5 = "Smoking/Tobacco use@:&hislab"
		   _nhhis6 = "Other (specify)@:&hislab"
          
           _nhloc1 = "EGFR EXON 20 T790M@:&loclab"
           _nhloc2 = "EGFR EXON 21 L858R@:&loclab"
		   _nhloc3 = "EGFR EXON 19 Deletion@:&loclab"
		   _nhloc4 = "EGFR EXON 18 Mutation@:&loclab"
		   _nhloc5 = "EGFR Other Mutation@:&loclab"
		   _nhloc6 = "ALK EML4 Translocation@:&loclab"
		   _nhloc7 = "KRAS GLY12ALA@:&loclab"
		   _nhloc8 = "KRAS GLY12ARG@:&loclab"
		   _nhloc9 = "KRAS GLY12ASP@:&loclab"
		  _nhloc10 = "KRAS GLY12CYS@:&loclab"
		  _nhloc11 = "KRAS GLY12SER@:&loclab"
		  _nhloc12 = "KRAS GLY12VAL@:&loclab"
		  _nhloc13 = "KRAS GLY13ASP@:&loclab"
		  _nhloc14 = "KRAS Other Mutation@:&loclab"
		  _nhloc15 = "Other Receptor@:&loclab"
		  nhtlocsp = "If Other, specify@:&loclab"

		   nhstage = "NSCLC stage at time of enrollment"
		  nhstaget = "Primary Tumor (T)@:Staging"
          nhstagen = "Regional Lymph Nodes (N)@:Staging"
          nhstagem = "Distant Metastases (M):@:Staging"
          nhostgsp = "Other Staging (please describe)"
          ;
	%concatdate(year=nhstyr, month=nhstmo, day=nhstdy, outdate=nhstdtc);
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(nhstdtc);
    drop nhstyr nhstmo nhstdy;
    
	array nhhis(*)nhna nhhist1-nhhist6 nhtloc1-nhtloc15;
    array nhhisr(*)_nhna _nhhis1-_nhhis6 _nhloc1-_nhloc15;
	   do i = 1 to dim(nhhis);
	      if nhhis[i] = 'Checked' then nhhisr[i] = 'Yes';
    end;

	_nhhis1 = catx(': ', _nhhis1, nhhistsp);
    _nhhis3 = catx(': ', _nhhis3, nhlocsp);
    _nhhis6 = catx(': ', _nhhis6, nhothsp);
 
    drop nhna nhhist1-nhhist6 nhtloc1-nhtloc15;
run;


proc sort data = nh1; by subject nhstdtc; run;


data pdata.nh1(label='Disease History - NSCLC (Part 1)');
    retain EDC_TreeNodeID EDC_EntryDate subject visit nhstdtc nhhist _nhna _nhhis1 _nhhis2 _nhhis3 _nhhis4 
           _nhhis5 _nhhis6;
	keep   EDC_TreeNodeID EDC_EntryDate subject visit nhstdtc nhhist _nhna _nhhis1 _nhhis2 _nhhis3 _nhhis4 
           _nhhis5 _nhhis6;

	set nh1;
	rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
	rename          visit = __visit;

run;

data pdata.nh2(label='Disease History - NSCLC (Part 2)');
    retain EDC_TreeNodeID EDC_EntryDate subject visit _nhloc1 _nhloc2 _nhloc3 _nhloc4 _nhloc5 _nhloc6 _nhloc7 _nhloc8 
           _nhloc9 _nhloc10 _nhloc11;
	keep   EDC_TreeNodeID EDC_EntryDate subject visit _nhloc1 _nhloc2 _nhloc3 _nhloc4 _nhloc5 _nhloc6 _nhloc7 _nhloc8 
           _nhloc9 _nhloc10 _nhloc11;
	set nh1;
	rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
	rename          visit = __visit;

run;


data pdata.nh3(label='Disease History - NSCLC (Part 3)');
    retain EDC_TreeNodeID EDC_EntryDate subject visit _nhloc12 _nhloc13 _nhloc14 _nhloc15 nhtlocsp nhstage 
           nhstaget nhstagen nhstagem nhostgsp;
	keep   EDC_TreeNodeID EDC_EntryDate subject visit _nhloc12 _nhloc13 _nhloc14 _nhloc15 nhtlocsp nhstage 
           nhstaget nhstagen nhstagem nhostgsp;
	set nh1;
	rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
	rename          visit = __visit;

run;
 
