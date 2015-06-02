/*********************************************************************
 Program Nmae: EXBTK.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/10
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

data exbtk1;
    length subject $13 rfstdtc   $10 exstdtc exendtc $20 exrea_ exlot_ dose $200 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.exbtk(rename = (EDC_TreeNodeID = __EDC_TreeNodeID EDC_EntryDate = __EDC_EntryDate seq=__seq));

     __excat=strip(EDC_FormLabel);
    extrt=strip(excat);
    label extrt='Catgory';
    label __excat='Ibrutinib Dose Administration';

    ****reason for modify**;
     label exrea_ = 'Dose Rationale';
     if aenum^=. then exrea_=cat(strip(exreasad),' (AE Number: ',strip(put(aenum,best.)),')');
        else if exreasao^='' then exrea_=cat('Other: ',strip(exreasao));
        else exrea_=strip(exreasad);

     exdisc_=ifc(exdisc=1,'Yes','');
     label exdisc_='Ibrutinib Dosing Discontinued';
     
     ***lot number**;
     exlot_=ifc(exna=1,'NA',strip(exlot));
     label exlot_='Lot Number';


    exspid=exlnnum;
     label EXSPID = 'Day';
    %subject;

    ** Dose Date;
    label exstdtc = 'Start Date';
    label exendtc = 'End Date';
    %ndt2cdt(ndt=exstdt, cdt=exstdtc);
    %ndt2cdt(ndt=exendt, cdt=exendtc);
    rc = h.find();
    %concatDY(exstdtc);
    %concatDY(exendtc); 
   
    ***modify dose 2015/04/15**;
    if exadose^=''  then dose=strip(exadose);
    else if exadoseo^=. then dose=cat(strip(put(exadoseo,best.)),'mg');
    label dose='Dose per Administration';
run;

proc sort data = exbtk1; by subject  exstdtc exendtc; run;

data pdata.exbtk(label='Ibrutinib Dose Administration');
    retain __edc_treenodeid __edc_entrydate subject __excat  exspid __seq exstdtc exendtc 
           exdisc_ dose exrea_  exlot_;
    keep __edc_treenodeid __edc_entrydate subject __excat  exspid __seq exstdtc exendtc 
           exdisc_ dose exrea_  exlot_;
    set exbtk1;
run;


