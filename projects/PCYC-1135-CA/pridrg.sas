/*********************************************************************
 Program Nmae: pridrg.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data pridrg0;
    set source.pridrg;
    %subject;
    keep EDC_TreeNodeID SUBJECT CMSPID CMIDYN CMLPRDRG CMGRID CMTRT CMSTDY CMSTMO CMSTYR CMENDY CMENMO CMENYR
         CMBOR CMPDDY CMPDMO CMPDYR CMPDNA CMDISRSN CMRSNOSP PDRGSEQ CMCYCLE EDC_EntryDate;
run;

data pridrg1;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set pridrg0;

    length _cmidyn _cmlprdrg $8;
    label _cmidyn = 'Do not include in regimen count';
    label _cmlprdrg = 'Last prior therapy before first dose study drug';
    if cmidyn = 'Checked' then _cmidyn = 'Yes';
    if cmlprdrg = 'Checked' then _cmlprdrg = 'Yes';


    length cmstdtc cmendtc cmpddtc _cmpdna $20;
    label cmstdtc = 'Start Date';
    label cmendtc = 'End Date';
    label cmpddtc = 'Date of Progression';
    label _cmpdna = 'Not Applicable';
    %concatdate(year=cmstyr, month=cmstmo, day=cmstdy, outdate=cmstdtc);
    %concatdate(year=cmenyr, month=cmenmo, day=cmendy, outdate=cmendtc);
    %concatdate(year=cmpdyr, month=cmpdmo, day=cmpddy, outdate=cmpddtc);
    if cmpdna = 'Checked' then _cmpdna = 'Yes';
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(cmstdtc);
    %concatDY(cmendtc);

    label cmdisrsn = 'Reason for discontinuation of this regimen';
    label cmrsnosp = 'If other, specify';
run;

proc sort data=pridrg1; by subject cmspid cmgrid cmstdtc cmendtc cmtrt; run;


data pdata.pridrg(label='Prior Cancer Therapy');

    retain EDC_TreeNodeID EDC_EntryDate subject pdrgseq cmspid   _cmidyn cmcycle _cmlprdrg cmgrid cmtrt 
           cmstdtc cmendtc cmbor cmpddtc _cmpdna cmdisrsn cmrsnosp;

    keep   EDC_TreeNodeID EDC_EntryDate subject pdrgseq cmspid _cmidyn cmcycle _cmlprdrg cmgrid cmtrt 
           cmstdtc cmendtc cmbor cmpddtc _cmpdna cmdisrsn cmrsnosp;

    set pridrg1;
    where cmtrt ^= '';
    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename        pdrgseq = __pdrgseq;

run;
