%include '_setup.sas';

data ae0;
  length subjid dlt aeser aemederr lababn $20 aesev aeout aerel aeacn $40 saecat aeacnoth acnothsp $200;
  set source.adverse_event_kxevents(rename=(aeser=aeser_ aemederr=aemederr_ lababn=lababn_));
/*  where aeterm^='';*/
  if ssid^='' then subjid=strip(ssid);
  dlt=strip(doselim_label);
  aesev=strip(sev_label);
  aeout=strip(outcm_label);
  aerel=strip(rel_label);
  aeser=strip(aeser_label);
  aeacn=strip(can_label);
  aeacnoth=strip(acnoth_label);
  acnothsp=strip(acnothspcfy);
  aemederr=strip(aemederr_label);
  lababn=strip(lababn_label);
  if cat_not_applicable^='' then aesna='Not Applicable';
  if cat_death^='' then aesdth='Death';
  if cat_life_threatening^='' then aeslife='Life Threatening';
  if cat_new_or_prolonged_hospitaliz0^='' then aeshosp='New or Prolonged Hospitalization';
  if cat_persistent_or_significant_d0^='' then aesdisab='Persistent or Significant Disability/Incapacity';
  if cat_congenital_anomaly_birth_de0^='' then aescong='Congenital Anomaly/Birth Defect';
  if cat_other_important_medical_even^='' then aesmie='Other Important Medical Event';
  saecat=catx(', ', aesna, aesdth, aeslife, aeshosp, aesdisab, aescong, aesmie);
run;

proc sort data = ae0; by subjid aestdt aesttm aeenddt aeendtm aeterm; run;

data pdata.ae1(label='Adverse Event Part 1');
   retain SUBJID AETERM AESTDT AESTTM AEENDDT AEENDTM DLT AESEV AEOUT AEREL AESER SAECAT;
   set ae0;
   label subjid='Subject No.'
          aeterm='AE Term'
          aestdt='Date of Onset'
		  aesttm='Time of Onset'
		  aeenddt='Date of Resolution'
          aeendtm='Time of Resolution'
		  dlt='DLT?'
          aesev='Severity'
          aeout='Outcome'
		  aerel='Relationship'
          aeser='Serious?'
		  saecat='SAE Category';
  keep subjid aeterm aestdt aesttm aeenddt aeendtm dlt aesev aeout aerel aeser saecat;
run;

data pdata.ae2(label='Adverse Event Part 2');
   retain SUBJID AETERM AESTDT AESTTM AEENDDT AEENDTM AEACN AEACNOTH ACNOTHSP AEMEDERR LABABN;
   set ae0;
   label subjid='Subject No.'
          aeterm='AE Term'
          aestdt='Date of Onset'
		  aesttm='Time of Onset'
		  aeenddt='Date of Resolution'
          aeendtm='Time of Resolution'
		  aeacn='Action Taken'
          aeacnoth='Other Action Taken'
          acnothsp='Other Action, Specify'
		  aemederr='Medication Error?'
		  lababn='Lab Abnormality?';
  keep subjid aeterm aestdt aesttm aeenddt aeendtm aeacn aeacnoth acnothsp aemederr lababn;
run;
