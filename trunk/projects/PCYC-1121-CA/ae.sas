/*********************************************************************
 Program Nmae: AE.sas
  @Author: Yan Zhang
  @Initial Date: 2015/01/29
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/09: Add EDC_TREENODEID to output dataset as key variable.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/02/25: Drop aeacno05 in AE2.
 Ken Cao on 2015/03/04: 1) Display UNK and NULL for AESTDTC and AEENDTC.
                        2) Concatenate --DY to AESTDTC and AEENDTC.

*********************************************************************/
%include "_setup.sas";
data ae;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    length aestdtc aeendtc $20;
    keep edc_treenodeid site subject aeterm aestdtc aeendtc aeout aeser aespec aesev aerel aerelp aeduedp aeacn01 aeacn03 aeacn04 aeacn05 
    aeacno01 aeacno02 aeacno03 aeacno04 aeacno05 aeacnoth aenum EDC_EntryDate;
    set source.ae_coded;
    if aeyn = '';
    aeacn01 = put(aeacn01,$checked.);
    aeacn03 = put(aeacn03,$checked.);
    aeacn04 = put(aeacn04,$checked.);
    aeacn05 = put(aeacn05,$checked.);

    aeacno01 = put(aeacno01,$checked.);
    aeacno02 = put(aeacno02,$checked.);
    aeacno03 = put(aeacno03,$checked.);
    aeacno04 = put(aeacno04,$checked.);
    aeacno05 = put(aeacno05,$checked.);

    %concatDateV2(year=aestyy, month=aestmm, day=aestdd, outdate=aestdtc);
    %concatDateV2(year=aeenyy, month=aeenmm, day=aeendd, outdate=aeendtc);
    %subject;

    rc = h.find();
    %concatDY(aestdtc);
    %concatDY(aeendtc);
    rename EDC_TREENODEID = __EDC_TREENODEID EDC_EntryDate = __EDC_EntryDate;
run;

proc sort data = ae; by subject aestdtc aeendtc aeterm;run;

data pdata.ae1(label = 'Adverse Event');
    keep __edc_treenodeid __EDC_EntryDate subject aenum aeterm aestdtc aeendtc aeout aeser aespec aesev aerel aerelp aeduedp;
    retain __edc_treenodeid __EDC_EntryDate subject aenum aeterm aestdtc aeendtc aeout aeser aespec aesev aerel aerelp aeduedp;
    attrib
    aeterm                       label = 'Reported Term'
    aestdtc                      label = 'Start Date'
    aeendtc                      label = 'End Date';
    set ae;
run;

data pdata.ae2(label = 'Adverse Event (Continued)');
    keep __edc_treenodeid __EDC_EntryDate  subject aenum aeterm aeacn01 aeacn03 aeacn04 aeacn05 aeacno01 aeacno02 aeacno03 aeacno04  aeacnoth;
    retain __edc_treenodeid __EDC_EntryDate subject aenum aeterm aeacn01 aeacn03 aeacn04 aeacn05     aeacno01 aeacno02 aeacno03 aeacno04  aeacnoth;
    attrib
    aeterm                       label = 'Reported Term'
    aeacn01                      label = 'None'
    aeacn03                      label = 'Dose Reduced'
    aeacn04                      label = 'Dose Delayed'
    aeacn05                      label = 'Permanently Withdrawn'
    aeacno01                     label = 'None'
    aeacno02                     label = 'Medication'
    aeacno03                     label = 'Non-drug therapy'
    aeacno04                     label = 'Hospitalization'
    aeacno05                     label = 'Other'
    aeacnoth                     label = 'Other specify';
    set ae;
run;
