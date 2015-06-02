/*********************************************************************
 Program Nmae: subdrg.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data subdrg0;
    set source.subdrg;
    %subject;
    keep EDC_TreeNodeID SUBJECT CMSPID CMGRID CMTRT CMSTDY CMSTMO CMSTYR CMENDY CMENMO CMENYR CMONGO
         CMBOR CMPDDY CMPDMO CMPDYR SDRGSEQ EDC_EntryDate;
run;

data subdrg1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set subdrg0;

    length cmstdtc cmendtc cmpddtc $20;
    label cmstdtc = 'Start Date';
	label cmendtc = 'End Date';
	label cmpddtc = 'If PD, Date of Progression';
	%concatdate(year=cmstyr, month=cmstmo, day=cmstdy, outdate=cmstdtc);
	%concatdate(year=cmenyr, month=cmenmo, day=cmendy, outdate=cmendtc);
    %concatdate(year=cmpdyr, month=cmpdmo, day=cmpddy, outdate=cmpddtc);
	if cmongo = 'Checked' then cmendtc = 'Ongoing';
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(cmstdtc);
    %concatDY(cmendtc);

run;

proc sort data=subdrg1; by subject cmstdtc cmendtc cmtrt; run;


data pdata.subdrg(label='Subsequent Anti-Cancer Drug Treatment');

    retain EDC_TreeNodeID EDC_EntryDate subject sdrgseq cmgrid cmspid cmtrt cmstdtc cmendtc cmbor cmpddtc;
    keep   EDC_TreeNodeID EDC_EntryDate subject sdrgseq cmgrid cmspid cmtrt cmstdtc cmendtc cmbor cmpddtc;

    set subdrg1;
    where cmtrt ^= '';
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename        sdrgseq = __sdrgseq;
	label CMSPID = 'Post-treatment Regimen Number';
run;
