%include '_setup.sas';

data ex0;
  length subjid $20 dispamt retamt drugtype $40;
  set source.drug_dispensed;
  if ssid^='' then subjid=strip(ssid);
  if capdisp^=. then dispamt=strip(put(capdisp, best.));
  if capret^=. then retamt=strip(put(capret, best.));
  if drugtyp_label^='' then drugtype=strip(drugtyp_label);
/*  if datedisp^='';*/
run;

/*proc sort data = ex0; by subjid datedisp descending drugtype dateret; run;*/
proc sort data = ex0; by subjid datedisp event_start_date descending drugtype dateret dispamt; run;

data pdata.da(label='Drug Dispensed and Returned');
   retain SUBJID DRUGTYPE DATEDISP DISPAMT DATERET RETAMT;
   set ex0;
   label subjid='Subject No.'
          drugtype='Drug Type'
          datedisp='Date Dispensed'
		  dispamt='Capsules Dispensed'
		  dateret='Date Returned'
          retamt='Capsules Returned';
  keep subjid datedisp dateret dispamt retamt drugtype;
run;
