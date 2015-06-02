%include "_setup.sas";

data cm;
  set source.gg_concomitant_medicationscm;
  subjid= strip(ssid);
  freq_ = strip(freq_label);
  route_ = strip(route_label);
  aecm_ = strip(aecm_label);
  continue_ = strip(continue_label);
  if strip(cmstdt_min) = strip(cmstdt_max) then cmstdt= strip(cmstdt_min) ; 
	else if substr(strip(cmstdt_min),1,7) = substr(strip(cmstdt_max),1,7) then cmstdt= substr(strip(cmstdt_min),1,7) ;
	else if  substr(strip(cmstdt_min),1,4) = substr(strip(cmstdt_max),1,4) then cmstdt= substr(strip(cmstdt_min),1,4) ;

  if strip(cmenddt_min) = strip(cmenddt_max) then cmenddt= strip(cmenddt_min) ; 
	else if substr(strip(cmenddt_min),1,7) = substr(strip(cmenddt_max),1,7) then cmenddt= substr(strip(cmenddt_min),1,7) ;
	else if  substr(strip(cmenddt_min),1,4) = substr(strip(cmenddt_max),1,4) then cmenddt= substr(strip(cmenddt_min),1,4) ;

  keep subjid cmtrt doseu freq_ freqoth route_ routeoth cmindc aecm_ cmstdt cmenddt continue_;
  run;

proc sql;
create table cm_ as
select a.* from cm as a where subjid in (select distinct b.subjid from pdata.dm as b);
quit;

proc sort data = cm_ nodupkey;  by subjid cmstdt cmtrt continue_ cmenddt cmindc doseu freq_ freqoth route_ routeoth aecm_;run;

data pdata.cm(label='Concomitant Medications');
  retain subjid cmtrt doseu freq_ freqoth route_ routeoth cmindc aecm_ cmstdt cmenddt continue_;
  attrib
  CMTRT      label = "Medication"   
  DOSEU      label = "Dose & Units"
  FREQ_      label = "Freq"
  FREQOTH      label = "Other Freq"
  ROUTE_      label = "Route"
  ROUTEOTH      label = "Other Route"
  CMINDC      label = "Primary Indication"
  AECM_      label = "Given for AE?"
  CMSTDT      label = "Start Date"
  CMENDDT      label = "Stop Date"
  CONTINUE_      label = "Continuing?";
  set cm_;
  keep subjid cmtrt doseu freq_ freqoth route_ routeoth cmindc aecm_ cmstdt cmenddt continue_;
run;


