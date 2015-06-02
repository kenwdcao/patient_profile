
%include '_setup.sas';

data cm0;
    length cmfreq cmroute $200;
    set source.gg_concomitant_medicationsconm12;
    %subjid;
    if aeser='1' then aeser='Y'; else if aeser='2' then aeser='N';
	cmfreq=strip(freq_label);
	cmroute=strip(route_label);
	if freqoth^='' then do; cmfreq=strip(cmfreq)||": "||strip(freqoth); end;
	if routeoth^='' then do; cmroute=strip(cmroute)||": "||strip(routeoth); end;
	if aecm='1' then aecm='Y'; else if aecm='2' then aecm='N';
	keep ssoid subjid cmtrt cmindc doseu cmfreq freqoth cmroute routeoth cmstdt_min cmenddt_max item_group_repeat_key AECM;
run;

proc sql;
   create table cm as
   select a.*, b.__fdosedt from cm0 as a inner join pdata.dm as b on a.subjid=b.subjid;
quit;

data cm;
   length cmstdy cmendy $20;
   set cm;
   call missing(_dy);  %dy(cmstdt_min, mmddyy10.); cmstdy_ = _dy;
   call missing(_dy);  %dy(cmenddt_max, mmddyy10.); cmendy_ = _dy;
   if cmstdy_^=. then cmstdy=strip(put(cmstdy_, best.));
   if cmendy_^=. then cmendy=strip(put(cmendy_, best.));
run;

proc sort data=cm; by subjid cmstdy_ cmtrt cmendy_; run;

data pdata.cm(label='Concomitant Medication');
    retain subjid cmtrt cmindc doseu cmfreq cmroute cmstdy cmendy aecm druglvl;
    attrib
        cmtrt    length = $200 label = 'Medication'
        cmindc    length = $200  label = 'Indication'
        doseu    length = $200  label = 'Dose&Units'
        cmfreq     length = $200  label = 'Frequency'
        cmroute       length = $200  label = 'Route'
        cmstdy     length = $20  label = 'Start#Day'
        cmendy     length = $20   label = 'Stop#Day'
        aecm     length = $20   label = 'Treat#for AE?'
        druglvl   length = $100  label = 'Investigational#Drug Level (mg)'
    ;
	set cm;
	druglvl='';
    keep subjid cmtrt cmindc doseu cmfreq cmroute cmstdy cmendy aecm druglvl;
run;
