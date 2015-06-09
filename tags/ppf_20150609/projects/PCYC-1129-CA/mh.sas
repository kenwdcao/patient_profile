/*********************************************************************
 Program Nmae: mh.sas
  @Author: Yuxiang Ni
  @Initial Date: 2015/04/23
 

 This program is originally from PCYC-1129-CA patient profile.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

** Ken Cao on 2015/06/04: Use MH as source dataset, get MHBODSYS and MHDECOD from MH_CODED;
data _mh0;
    length EDC_TREENODEID $36 MHDECOD MHBODSYS $200;
    if _n_ = 1 then do;
        declare hash h (dataset:'source.mh_coded');
        rc = h.defineKey('EDC_TREENODEID');
        rc = h.defineData('MHDECOD', 'MHBODSYS');
        rc = h.defineDone();
        call missing(EDC_TREENODEID, MHDECOD, MHBODSYS);
    end;
    set source.mh;
    rc = h.find();
    drop rc;
run;

data s_mh;
  length MHITEM $200 MHSTDTC $19 MHENDTC $19;
  keep EDC_TreenodeID EDC_EntryDate SUBJECT VISIT2 MHNUM MHBODSYS MHDECOD MHTERM MHSTDD MHSTMM MHSTYY MHENDD MHENMM 
       MHENYY MHSTDATU MHONGO MHTOXGR MHMED MHITEM MHSTDTC MHENDTC;
  set _mh0(rename=(MHSTDATU=MHSTDATU_in0  MHONGO=MHONGO_in0));
  MHITEM = strip(MHBODSYS)||'/'||"&escapechar.n"||strip(MHDECOD)||'/'||"&escapechar.n"||strip(MHTERM);

  %concatDate(year=MHSTYY, month=MHSTMM, day=MHSTDD, outdate=MHSTDTC);
  %concatDate(year=MHENYY, month=MHENMM, day=MHENDD, outdate=MHENDTC);
  if MHSTDATU_in0 = 'Checked' then  MHSTDATU = 'Yes';
  if MHONGO_in0 = 'Checked' then MHONGO = 'Yes';
  %subject;
  %visit2;
run;

proc sort data = s_mh; by SUBJECT MHSTDTC MHITEM; run;

************* Derive MHSTDY & MHENDY ***********;
data mh_dm;
  merge s_mh(in=_in1)
        pdata.dm(in=_in2  keep=SUBJECT __RFSTDTC);
     by SUBJECT;
  if _in1;
  %concatdy(MHSTDTC);
  %concatdy(MHENDTC);
run;

data pdata.mh(label="Medical History");
  retain __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 MHNUM MHITEM MHSTDTC MHSTDATU MHENDTC MHONGO MHTOXGR MHMED;
  keep __EDC_TreenodeID __EDC_EntryDate SUBJECT VISIT2 MHNUM MHITEM MHSTDTC MHSTDATU MHENDTC MHONGO MHTOXGR MHMED;
  set mh_dm(rename=(EDC_TreenodeID=__EDC_TreenodeID  EDC_EntryDate=__EDC_EntryDate));
  if not missing(MHNUM);
  label MHNUM  = "MH Record Number";
  label MHITEM = "System Organ Class/#Preferred Term/#Verbatim Term";
  label MHSTDTC  = "Start Date";
  label MHSTDATU  = ">1 year prior to 1st dose/year unknown";
  label MHENDTC  = "End Date";
  label MHONGO  = "Ongoing?";
  label MHTOXGR  = "If Ongoing/Active? provide toxicity grade at screening";
  label MHMED  = "Is subject taking medication for this condition?";
run;

