/*********************************************************************
 Program Nmae: EXLEN.sas
  @Author: Juan Liu
  @Initial Date: 2015/04/10
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/


%include '_setup.sas';

data exlen1;
    length subject $13 rfstdtc   $10 exstdtc exendtc $20 exrea_ exlot_ $200 ;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    set source.exlen;
    rename EDC_TREENODEID = __EDC_TREENODEID;
    rename EDC_ENTRYDATE = __EDC_ENTRYDATE;
	 __excat=strip(EDC_FormLabel);
	extrt=strip(excat);
	label extrt='Catgory';
    label __excat='Lenalidomide Dose Administration';
	**cycle or visit**;
	label cycle='Cycle';


    ****reason for modify**;
	 label exrea_ = 'Dose Rationale';
	 if aenum^=. then exrea_=cat(strip(exreasad),' (AE Number: ', strip(put(aenum,best.)), ')');
	    else if exreasao^='' then exrea_=cat('Other: ',strip(exreasao));
		else exrea_=strip(exreasad);

     exdisc_=ifc(exdisc=1,'Yes','');
	 label exdisc_='Lenalidomide Dosing Discontinued';
     
	 ***lot number**;
	 exlot_=ifc(exna=1,'NA',strip(exlot));
	 label exlot_='Lot Number';


	exspid=exlnnum;
	 label EXSPID = 'Line';
    %subject;

    ** Dose Date;
    label exstdtc = 'Start Date';
	label exendtc = 'End Date';
    %ndt2cdt(ndt=exstdt, cdt=exstdtc);
	%ndt2cdt(ndt=exendt, cdt=exendtc);
    rc = h.find();
    %concatDY(exstdtc);
	%concatDY(exendtc); 

	**modify 2015/04/14:order by cycle exspid**;
	%EXVISITN(CYCLE, EXSPID);

	***modify dose 2015/04/15**;
	if exadose^=''  then dose=strip(exadose);
	else if exadoseo^=. then dose=cat(strip(put(exadoseo,best.)),'mg');
	label dose='Dose per Administration';
run;

proc sort data = exlen1; by subject __visitn exstdtc exendtc; run;

data pdata.exlen(label='Lenalidomide Dose Administration');
    retain __edc_treenodeid __edc_entrydate subject __excat cycle exspid  exstdtc exendtc 
           exdisc_ dose exrea_  exlot_;
    keep __edc_treenodeid __edc_entrydate subject __excat cycle exspid  exstdtc exendtc 
           exdisc_ dose exrea_  exlot_;
    set exlen1;
run;


