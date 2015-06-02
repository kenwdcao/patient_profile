/*********************************************************************
 Program Nmae: mh.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/
%include '_setup.sas';

data mh0; 
    set source.mh_coded;
	%subject;
	keep EDC_TreeNodeID SUBJECT VISIT MHTERM MHSTDY MHSTMO MHSTYR MHSTDTUN MHENDY MHENMO MHENYR MHONGO MHTOXGR MHSEQ MedDRA_v 
         MHBODSYS MHLLT MHSOC MHHLGT MHHLT MHDECOD MHBDSYCD MHLLTCD MHSOCCD MHHLGTCD MHPTCD MHHLTCD COMMENTS EDC_EntryDate;
run;
 
data mh1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set mh0;
  
    length mhstdtc $20 mhendtc _mhstdtu _mhongo $20;
	label  mhstdtc = "Start Date";
    label  mhendtc = "End Date";
    label _mhstdtu = 'Unknown';
	label  _mhongo = 'Ongoing';
    %concatdate(year=mhstyr, month=mhstmo, day=mhstdy, outdate=mhstdtc);
    %concatdate(year=mhenyr, month=mhenmo, day=mhendy, outdate=mhendtc);
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(mhstdtc);
    %concatDY(mhendtc);

	if mhstdtun = 'Checked' then _mhstdtu = 'Yes'; 
    if mhongo = 'Checked' then _mhongo = 'Yes';
    drop mhstyr mhstmo mhstdy mhenyr mhenmo mhendy mhstdtun mhongo;


    length _mhterm $512;
    label _mhterm = "System Organ Class/&splitchar.Preferred Term/&splitchar.Verbatim Term";
    _mhterm = strip(mhbodsys) || "/&escapeChar.n" || strip(mhdecod) || "/&escapeChar.n" || strip(mhterm); 
run;


proc sort data = mh1; by subject mhstdtc mhendtc mhterm; run; 


data pdata.mh(label='Medical History');
    retain EDC_TreeNodeID EDC_EntryDate subject mhseq _mhterm mhterm mhdecod mhbodsys mhstdtc _mhstdtu mhendtc _mhongo mhtoxgr
           mhsoc mhllt mhhlgt mhhlt; 
    keep   EDC_TreeNodeID EDC_EntryDate subject mhseq _mhterm mhterm mhdecod mhbodsys mhstdtc _mhstdtu mhendtc _mhongo mhtoxgr
           mhsoc mhllt mhhlgt mhhlt;   
    set mh1;
    
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename          mhseq = __mhseq;
    rename          mhllt = __mhllt;
    rename          mhhlt = __mhhlt;
    rename         mhhlgt = __mhhlgt;
    rename          mhsoc = __mhsoc;
    rename         mhterm = __mhterm;
    rename        mhdecod = __mhdecod;
    rename       mhbodsys = __mhbodsys;

run;
