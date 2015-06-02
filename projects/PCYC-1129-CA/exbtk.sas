/*********************************************************************
 Program Nmae: exbtk.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/23
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data exbtk1;
    length subject $13  __rfstdtc $10 exstdtc exendtc $20 aenum  dose $200 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;

    set source.exbtk(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate ));

     __excat=strip(EDC_FormLabel);
    label __excat='Ibrutinib Dose Administration';
  
     exdisc_=ifc(exdisc="Checked",'Yes','');
    %subject;

    ** Dose Date;
    label exstdtc = 'Start Date';
    label exendtc = 'End Date';
    %ndt2cdt(ndt=exstdt, cdt=exstdtc);
    %ndt2cdt(ndt=exendt, cdt=exendtc);
    rc = h.find();
    %concatDY(exstdtc);
    %concatDY(exendtc); 
   
    ***other dose**;
    if exadoseo^=. then dose=cat(strip(put(exadoseo,best.)),' mg');
    label dose='Other Dose Administered';
run;

proc sort data = exbtk1; by subject  exstdtc exendtc; run;

data pdata.exbtk(label='Ibrutinib Dose Administration');
    retain __edc_treenodeid __edc_entrydate subject __excat exstdtc exendtc 
           exdisc_ exadose dose exreasad exreasao aenum  ;
    keep __edc_treenodeid __edc_entrydate subject __excat  exstdtc exendtc 
           exdisc_ exadose dose exreasad exreasao  aenum  ;
    set exbtk1;

   label exdisc_='If this was last dose of study drug?';
   label exadose='Dose Administered';
   label exreasad='Rationale for Stopping Treatment';
   label exreasao='If Other Reason, specify';
   label aenum='If Rationale due to Adverse Event provide AE number';
run;


