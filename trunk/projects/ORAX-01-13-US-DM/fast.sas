%include '_setup.sas';

data fast0;
  length subjid $20 part visit fastsol fastsolt fastliq fastliqt fastpost fastptm $40;
  set source.drug_fasting(rename=(fastsol=fastsol_ fastliq=fastliq_ fastpost=fastpost_));
  if ssid^='' then subjid=strip(ssid);
  part=strip(drugpartf_label);
  if drugcycf_label^='' and drugdayf_label^='' then visit='Cycle '||strip(drugcycf_label)||' Day '||strip(drugdayf_label);
  fastsol=strip(fastsol_label);
  if cmiss(fasttim, faststptim)^=2 then fastsolt=strip(fasttim)||'/'||strip(faststptim); else fastsolt='';
  fastliq=strip(fastliq_label);
  if cmiss(fastliqstrt, fastliqstop)^=2 then fastliqt=strip(fastliqstrt)||'/'||strip(fastliqstop); else fastliqt='';
  fastpost=strip(fastpost_label);
  if cmiss(faststrt, faststp)^=2 then fastptm=strip(faststrt)||'/'||strip(faststp); else fastptm='';
/*  if cmiss(datefast, fastsol, fastsolt, fastliq, fastliqt, fastpost, fastptm)^=7;*/
run;

proc sort data = fast0; by subjid admindtf datefast; run;

data pdata.fast(label='Drug Fasting');
  retain SUBJID ADMINDTF PART VISIT DATEFAST FASTSOL FASTSOLT FASTLIQ FASTLIQT FASTPOST FASTPTM;
   set fast0;
   label subjid='Subject No.'
		  admindtf='Date of Drug Administration'
          part='Part'
		  visit='Visit'
          datefast='Date of Fasting'
		  fastsol='Fast for Solids 8 Hours Prior to Dose?'
		  fastsolt='Pre Dosing Solids Fast Start/Stop Time'
		  fastliq='Fast for Liquids 2 Hours Prior to Dose?'
		  fastliqt='Pre Dosing Liquids Fast Start/Stop Time'
		  fastpost='Fast for 1 Hour Post Dosing (Except Liquids)?'
		  fastptm='Post Dosing Fast Start/Stop Time';

  keep subjid admindtf part visit datefast fastsol fastsolt fastliq fastliqt fastpost fastptm;
run;
