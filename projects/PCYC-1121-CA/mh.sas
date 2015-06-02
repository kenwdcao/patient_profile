/*********************************************************************
 Program Nmae: MH.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/03/05: Concatenate --DY to MHSTDTC and MHENDTC.
*********************************************************************/
%include "_setup.sas";

data mh;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;

    length mhstdtc mhendtc $20;
    set source.mh;
    if mhterm^='';
    %subject;
    %concatDateV2(year=mhstyy, month=mhstmm, day=mhstdd, outdate=mhstdtc);
    %concatDateV2(year=mhenyy, month=mhenmm, day=mhendd, outdate=mhendtc);

	rc = h.find();
	%concatDY(mhstdtc);
	%concatDY(mhendtc);
	drop rc;

    mhongo=strip(put(mhongo,$checked.));
    mhstdatu = strip(put(mhstdatu,$checked.));
    __edc_treenodeid=edc_treenodeid;
    rename EDC_EntryDate = __EDC_EntryDate;
    keep subject mhterm mhstdtc mhendtc mhongo mhtoxgr mhstdatu __edc_treenodeid EDC_EntryDate;
run;

proc sort data=mh;by subject mhstdtc mhendtc mhterm;run;

data pdata.mh (label="Medical History");
    retain  __edc_treenodeid __EDC_EntryDate subject mhterm mhstdtc mhstdatu mhendtc mhongo mhtoxgr;
    attrib 
    mhstdtc label="Start Date"
    mhendtc label="End Date"
    mhongo  label="Ongoing?";
    set mh;
    keep __edc_treenodeid __EDC_EntryDate subject mhterm mhtoxgr mhstdtc mhendtc mhongo mhstdatu;
run;
