/********************************************************************************
 Program Nmae: MH.sas
  @Author: Feifei Bai
  @Initial Date: 2015/02/26
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/23: Include SOC and PT with medical history terms.

********************************************************************************/
%include '_setup.sas';

data mh;
length mhstdtc mhendtc $20; 
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
    if mhstdatu ^= '' then mhstdatu = 'Yes'; 
    if mhongo ^= '' then mhongo = 'Yes'; 

proc sort; by subject mhstdtc mhterm;
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
    retain __EDC_TreeNodeID __EDC_EntryDate subject mhnum _mhterm mhstdtc mhstdatu mhendtc mhongo mhtoxgr mhmed; 
    keep __EDC_TreeNodeID __EDC_EntryDate subject mhnum _mhterm mhstdtc mhstdatu mhendtc mhongo mhtoxgr mhmed;
    label  mhstdtc ="Start Date"
           mhendtc ="End Date"
           mhongo ="Ongoing?";
    set mh;

    label mhtoxgr = "If ‘Ongoing/Active? provide toxicity grade at screening";
    label mhmed = 'Is subject taking medication for this condition?';
run;
