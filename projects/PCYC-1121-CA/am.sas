/*********************************************************************
 Program Nmae: AM.sas
  @Author: Yan Zhang
  @Initial Date: 2015/01/30
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/02/25: Drop AMDTC in AM2.
 Ken Cao on 2015/03/04: Change MHNUM label to "Related Med Hx Number".
 Ken Cao on 2015/03/05: Concatenate --DY to AMDTC.

*********************************************************************/
%include "_setup.sas";

data am;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    length amdtc $20;
    set source.am;
    if amyn = '';
    %subject;
    amtrt2 = put(amtrt2,$checked.);
    %ndt2cdt(ndt=amdt, cdt=amdtc);
    rc = h.find();
    %concatDY(amdtc);
    drop rc;
    if AMRELNR^='' then AMRELSP="Not Reported";
    else AMRELSP=AMRELSP;
    if AMCYTONR^='' then AMCYTO="Not Reported";
    else AMCYTO=AMCYTO;
    if mhnum1 ^=. then mhnum1_= strip(put(mhnum1,best.));
    if mhnum2 ^=. then mhnum2_= strip(put(mhnum2,best.));
    if mhnum3 ^=. then mhnum3_= strip(put(mhnum3,best.));
    mhnum = catx(",",mhnum1_, mhnum2_, mhnum3_);

    __EDC_TREENODEID=EDC_TREENODEID ;
    rename EDC_EntryDate = __EDC_EntryDate;
    keep subject amterm ambpyn ambpynsp amstgt amstgn amstgm amstgnr amstgos amtrt1 amtrt2 amtrtd2 amtrt3 amtrtd3 amtrt4 amtrtd4 amtrt5 amtrtd5 amtrt6 amtrtd6 
            amout amcuri amrel amrelsp amrelnr amcyto amcytonr amrisk1 amrisk2 amriskd2 amrisk3 amriskd3 amrisk4 amriskd4 amrisk5 amriskd5 amrisk6 amriskd6 amrisk7 amriskd7
            amdtc mhnum __edc_treenodeid EDC_EntryDate;
run;

proc sort data = am; by subject amdtc amterm;run;

data pdata.am1(label = 'Other Malignancy');
    keep __edc_treenodeid __EDC_EntryDate subject amterm amdtc ambpyn ambpynsp amstgt amstgn amstgm amstgnr amstgos amtrt1 amtrtd2 amtrtd3 
        amtrtd4 amtrtd5 amtrtd6 ;
    retain __edc_treenodeid __EDC_EntryDate subject amterm amdtc ambpyn ambpynsp amstgt amstgn amstgm amstgnr amstgos amtrt1 amtrtd2 amtrtd3
        amtrtd4 amtrtd5 amtrtd6 ;
    attrib
    amstgt                  label = 'T'
    amstgn                  label = 'N'
    amstgm                  label = 'M'
    amstgnr                 label = 'Not Reported'
    amstgos                 label = 'Other'
    amdtc                   label = 'Date of Diagnosis'
    amtrt1                  label = 'None'
    amtrtd2                 label = 'Surgery'
    amtrtd3                 label = 'Chemotherapy'
    amtrtd4                 label = 'Hormonal Therapy'
    amtrtd5                 label = 'Radiation Therapy'
    amtrtd6                 label = 'Other'
    ;
    set am;
run;

data pdata.am2(label = 'Other Malignancy (Continued)');
    keep __edc_treenodeid __EDC_EntryDate subject amterm amout  amcuri amrel amrelsp amcyto amrisk1 amriskd2 amriskd3 amriskd4 amriskd5 amriskd6 amriskd7 mhnum;
    retain __edc_treenodeid __EDC_EntryDate subject amterm amout  amcuri amrel amrelsp amcyto amrisk1 amriskd2 amriskd3 amriskd4 amriskd5 amriskd6 amriskd7
            mhnum;
    attrib
    amdtc                   label = 'Date of Diagnosis'
    amrisk1                      label = 'None'
    amriskd2                     label = 'Family History'
    amriskd3                     label = 'Overweight'
    amriskd4                     label = 'Radiation Therapy'
    amriskd5                     label = 'Alcohol Ingestion'
    amriskd6                     label = 'Smoking'
    amriskd7                     label = 'Other'
    amrelsp                     label = 'Specify Related Therapy'
    amcyto                  label = 'Specify Related Cytogenetics'
    mhnum                       label = 'Related Med Hx Number';

    set am;
run;
