/********************************************************************************
 Program Nmae: MH.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/14
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


********************************************************************************/
%include '_setup.sas';

data mh;
length mhstdtc mhendtc  $20; 
    set source.mh (rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
    if mhterm ^= ''; 
    
    length _mhterm $512;
    label _mhterm = "System Organ Class/#Preferred Term/#Verbatim Term";

    /*
    _mhterm = "&escapeChar{style [foreground=#000000]"||strip(mhbodsys)||'}/'||"&escapeChar.n"||
              "&escapeChar{style [foreground=#000000]"||strip(mhdecod)||'}/'||"&escapeChar.n"||
              "&escapeChar{style [foreground=#000000]"||strip(mhterm)||'}';
    */
    _mhterm = strip(mhbodsys)||"/&escapeChar.n"||
              strip(mhdecod) ||"/&escapeChar.n"||
              strip(mhterm);

    %subject;
    %concatDate(year=mhstyy, month=mhstmm, day=mhstdd, outdate=mhstdtc);
    %concatDate(year=mhenyy, month=mhenmm, day=mhendd, outdate=mhendtc);
    if mhstdatu ^= . then mhstdatu_ = 'Yes'; 
    if mhongo ^= . then mhongo_ = 'Yes'; 
	run;


proc sort; by subject mhstdtc mhendtc mhterm;
run; 

data mh;
     length subject $13 rfstdtc $10;
     if _n_ = 1 then do;
     declare hash h (dataset:'pdata.rfstdtc');
     rc = h.defineKey('subject');
     rc = h.defineData('rfstdtc');
     rc = h.defineDone();
     call missing(subject, rfstdtc);
     end;
       set mh; 
       rc = h.find();
       %concatdy(mhstdtc); 
       %concatdy(mhendtc);
       drop rc;
    run;

data pdata.mh(label='Medical History');
    retain __EDC_TreeNodeID __EDC_EntryDate subject mhnum _mhterm mhstdtc mhstdatu_ mhendtc mhongo_  mhtoxgr mhoccur; 
    keep __EDC_TreeNodeID __EDC_EntryDate subject mhnum _mhterm mhstdtc mhstdatu_ mhendtc mhongo_  mhtoxgr mhoccur;
    label  mhstdtc ="Start Date"
           mhendtc ="End Date"
           mhstdatu_ =">1 year prior to 1st dose/year unknown"
           mhongo_ ="Ongoing?";
    set mh;

    label mhtoxgr = "If 'ongoing/Active', provide toxicity grade at screening";
    label mhoccur = 'Is subject taking medication for this condition?';
run;
