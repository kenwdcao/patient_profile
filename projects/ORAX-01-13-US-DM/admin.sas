%include '_setup.sas';

data ex0;
  length subjid $20 part visit doseadm drugred drugtype $40;
  set source.drug_administration(rename=(doseadm=doseadm_ drugred=drugred_));
  if ssid^='' then subjid=strip(ssid);
  if admintyp_label^='' then drugtype=strip(admintyp_label);
  if drugpart_label^='' then part=strip(drugpart_label);
  if drugcyc_label^='' and drugday_label^='' then visit='Cycle '||strip(drugcyc_label)||' Day '||strip(drugday_label);
  if doseadm_^=. then doseadm=strip(put(doseadm_, best.));
  if drugred_label^='' then drugred=strip(drugred_label);
run;

proc sort data = ex0; by subjid admindt admintm descending drugtype; run;

data pdata.admin(label='Study Drug Admin');
  retain SUBJID DRUGTYPE PART VISIT ADMINDT ADMINTM DOSEADM DRUGRED;
   set ex0;
   label subjid='Subject No.'
          drugtype='Administration Type'
          part='Part'
		  visit='Visit'
		  admindt='Date of Administration'
          admintm='Time of Administration'
		  doseadm='Dose Administered'
		  drugred='Was Drug Reduced?';
  keep subjid drugtype part visit admindt admintm doseadm drugred;
run;
