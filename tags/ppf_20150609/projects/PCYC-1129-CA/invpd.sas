/********************************************************************************
 Program Nmae: INVPD.sas
  @Author: Ken Cao
  @Initial Date: 2015/06/04
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
%include '_setup.sas';

data invpd0;
    set source.INVPD;
    %subject;
    %visit2;
    array ndt  PDEYEDT  PDLUNDT  PDPLDT  PDSKDT  PDMODT  PDGASTDT  PDLIV2DT  PDLIV1DT;
    array cdt  $20 PDEYEDTC  PDLUNDTC  PDPLDTC  PDSKDTC  PDMODTC  PDGASTDTC  PDLIV2DTC  PDLIV1DTC;
    do over ndt;
    if ndt^=. then cdt = put(ndt, YYMMDD10.);
    end;
/*    drop PDEYEDT  PDLUNDT  PDPLDT  PDSKDT  PDMODT  PDGASTDT  PDLIV2DT  PDLIV1DT;*/
run;


data invpd1;
    set invpd0;
    keep EDC_TREENODEID EDC_ENTRYDATE subject visit2 criteria date;
    length criteria $255 date $20;
    criteria="Skin (percent of body surface) e - s = 25?"; 
    DATE=PDSKDTC; 
    output;
    criteria="Eye s - e >= 5 mm?"; 
    DATE=PDEYEDTC; 
    output;
    criteria="Mouth (15point Schubert scale) e - s >= 3?"; 
    DATE=PDMODTC; 
    output;
    criteria="Platelet count s - e >= 50,000/uL and e < LLN?"; 
    DATE=PDPLDTC; 
    output;
    criteria="Gastrointestinal (and other 0 - 3 scales) e - s >= 1?"; 
    DATE=PDGASTDTC; 
    output;
    criteria="Liver (ALT, alkaline phosphatase and bilirubin), eosinophil count, if s >= 3x ULN, is e - s >= 3 x ULN?"; 
    DATE=PDLIV2DTC; 
    output;
    criteria="Liver (ALT, alkaline phosphatase and bilirubin), eosinophil count, if s < 3x ULN, is e – s >= 2 x ULN?"; 
    DATE=PDLIV2DTC; 
    output;
    criteria="Lungs (12point Lung Function Scale) e - s >= 3?";
    DATE=PDLUNDTC;
    output;
run;


data invpd2;
    length  subject $13 __rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
    set invpd1;
    rename EDC_TREENODEID = __EDC_TREENODEID;
    rename EDC_ENTRYDATE = __EDC_ENTRYDATE;
    rc = h.find();
    %concatDY(date);
    drop rc;
run;


data pdata.invpd(label='Disease Progression (PD) by Investigator');
    retain __EDC_TREENODEID __EDC_ENTRYDATE subject visit2 criteria date;
    keep __EDC_TREENODEID __EDC_ENTRYDATE subject visit2 criteria date;
    set invpd2;
    label criteria = 'Indicate criteria used to determine PD (mark all that apply)';
    label date = 'Assessment Date';
    label visit2 = 'Visit';
run;
