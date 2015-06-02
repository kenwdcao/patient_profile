/*
    Program Name: PE.sas
    @Author: Xiu Pan
    @Initial Date: 2015/01/29

    Revision History
    Ken Cao on 2015/02/05: Tranpose PETEST
    Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
    Ken Cao on 2015/03/04: Use normalized structure. Only keeps records with annormal findings.
    Ken Cao on 2015/03/05: Concatenate --DY to PEDTC.
*/

%include '_setup.sas';

proc format;
    value $vnum
    'Suspected PD / Early Termination 1' = '299999.1'
    'Suspected PD / Early Termination 2' = '299999.2'
    'End of Treatment' = '300000'
    ;

run;

data pe;
	length subject $13 rfstdtc $10;
	if _n_ = 1 then do;
		declare hash h (dataset:'pdata.rfstdtc');
		rc = h.defineKey('subject');
		rc = h.defineData('rfstdtc');
		rc = h.defineDone();
		call missing(subject, rfstdtc);
	end;
    set source.pe(rename=(visit=visit_));
    where peorres = 'Abnormal';
    length pedtc $20 visit $60;
    %ndt2cdt(ndt=pedt, cdt=pedtc);
    %subject;

	rc = h.find();
	%concatDY(pedtc);
	drop rc;

    if pdseq^=. then visitnum=input(put(strip(visit_)||''||strip(put(pdseq,best.)),$vnum.),best.);
        else if visit='End of Treatment' then visitnum=input(put(visit_,$vnum.),best.);
    if pdseq^=. then visit=strip(visit_)||''||strip(put(pdseq,best.));
        else if unsseq^=. then visit=strip(visit_)||''||strip(put(unsseq,best.));
            else visit=strip(visit_);

    pestat = put(pestat, $checked.);

    rename edc_treenodeid = __edc_treenodeid;
    rename EDC_EntryDate = __EDC_EntryDate;
run;

data pe_;
    length orres $200 height weight $60 test $255;
    set pe(rename=(height=height_ weight=weight_));
    orres=strip(peorres);
    * if petest = 'Other' and orres ^= 'Not Done' and orres > ' ' then orres = strip(peorreso)||': '||strip(orres);

    if height_^='' then height=strip(height_)||' '||strip(heightu);
    if weight_^='' then weight=strip(weight_)||' '||strip(weightu);
    if peorreso^='' then test=strip(petest)||': '||strip(peorreso);
    else test=strip(petest);
    keep __edc_treenodeid __EDC_EntryDate subject visit visitnum petest peorres orres pecom peabn pedt pedtc pestat height weight test peorreso pestat;
run;


data pdata.peabn(label='Physical Exam (Abnormal Finding)');
    retain __edc_treenodeid __EDC_EntryDate subject visit pedtc height weight test orres pecom peabn ;
    keep __edc_treenodeid __EDC_EntryDate subject visit pedtc height weight test orres pecom peabn ;
    set pe_;
    label
    weight='Weight'
    height='Height'
    orres='Result'
    test='Test'
    pedtc='Assessment Date'
    visit='Visit'
    ;
run;
