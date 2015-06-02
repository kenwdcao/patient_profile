/*********************************************************************
 Program Nmae: DSEOT.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/13
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include '_setup.sas';

data dseot0;
length subject $13 rfstdtc $10 dsdtc $20 eotdis $200;
if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set source.dseot(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate ));
    %subject;

    label dsdtc = 'Date of End of Treatment Visit';
    %ndt2cdt(ndt=eotdt, cdt=dsdtc);
    rc = h.find();
    %concatDY(dsdtc);

    eotdis=ifc(eotvs='No', cat(strip(eotvs),', ',strip(eotreas)),strip(eotvs));
    label eotdis='Was an End of Treatment Visit conducted after the last dose of study drug?';
run;

proc sort data=dseot0; by subject dsdtc; run;

data pdata.dseot(label='End of Treatment Visit Prompt');
    retain __edc_treenodeid __edc_entrydate subject  eotvs eotreas dsdtc;
    keep __edc_treenodeid __edc_entrydate subject  eotvs eotreas dsdtc;
    set dseot0;

    label eotvs = 'Was an End-of-Treatment Visit conducted after the last dose of study drug?';
    label eotreas = 'If No, specify reason';
    label dsdtc = 'If Yes, please provide date of End of Treatment Visit';
run;
