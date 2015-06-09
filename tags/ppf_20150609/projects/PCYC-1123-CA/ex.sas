/*********************************************************************
 Program Nmae: EX.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/10
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/


%include '_setup.sas';

data ex1;
     length subject $13 rfstdtc   $10 FDOSEDTc $20  drugyn $200 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.ex(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate));
     __excat=strip(EDC_FormLabel);
    extrt=strip(excat);
    label extrt='Catgory';
    label __excat='First Dose Study Drug';

    **cycle or visit**;
/*  label cycle='Cycle';*/

       **Date**;
    label FDOSEDTc = 'Date of First Dose';
    %ndt2cdt(ndt=FDOSEDT, cdt=FDOSEDTc);
    rc = h.find();
    %concatDY(FDOSEDTc);

    *****received drug**;
    if exdosed='Yes' then drugyn=cat('Yes. ', strip(FDOSEDTc));
       else if exdosed='No' then drugyn=cat('No. ', strip(EXREAS));
       else drugyn=strip(exdosed);
    label drugyn='Did the subject receive first dose?';
    %subject;
run;

proc sort data = ex1; by subject fdosedtc; run;

data pdata.ex(label='First Dose Study Drug');
    retain __edc_treenodeid __edc_entrydate subject __excat extrt exdosed fdosedtc exreas ;     
    keep __edc_treenodeid __edc_entrydate subject __excat extrt exdosed fdosedtc exreas ;     
    set ex1;

    label extrt = 'Study Drug';
    label exdosed = 'Did the subject receive first dose of ibrutinib?';
    label fdosedtc = 'If ''Yes'' please provide Date of First Dose';
    label exreas = 'If ''No'', please specify reason';
run;


