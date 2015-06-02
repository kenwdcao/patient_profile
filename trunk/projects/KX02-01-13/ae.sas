
%include '_setup.sas';

data ae0;
    length aerel aeacn aeout treat $200;
    set source.adverse_event_kamevents;
    %subjid;
	if aeterm^='';
    if aeser='1' then aeser='Y'; else if aeser='2' then aeser='N';
	aerel=strip(rel_label);
	aeacn=strip(can_label);
    treat=strip(acnoth_label);
	aeout=strip(outcm_label);
	if acnothspcfy^='' then do; treat=strip(treat)||": "||strip(acnothspcfy); end;
	keep ssoid subjid aeterm aestdt aesttm aeenddt aeendtm sev aeser aerel aeacn treat acnothspcfy aeout item_group_repeat_key;
run;

proc sql;
   create table ae as
   select a.*, b.__fdosedt from ae0 as a inner join pdata.dm as b on a.subjid=b.subjid;
quit;

data ae;
   length aestdy aeendy $20;
   set ae;
   call missing(_dy);  %dy(aestdt, mmddyy10.); aestdy_ = _dy;
   call missing(_dy);  %dy(aeenddt, mmddyy10.); aeendy_ = _dy;
   if aestdy_^=. then aestdy=strip(put(aestdy_, best.));
   if aeendy_^=. then aeendy=strip(put(aeendy_, best.));
run;

proc sort data=ae; by subjid aestdy_ aeterm aeendy_; run;

data pdata.ae(label='Adverse Events');
    retain subjid aeterm aestdy aeendy sev aeser aerel aeacn treat aeout druglvl;
    attrib
        aeterm    length = $200 label = 'Reported Term'
        aestdy    length = $20  label = 'Start#Day'
        aeendy    length = $20  label = 'Stop#Day'
        sev     length = $20  label = 'CTCAE#Grade'
        aeser       length = $20  label = 'AE#Serious?'
        aerel     length = $200  label = 'Relation#to Study#Treatment'
        aeacn     length = $200   label = 'Action Taken#with Study#Drug'
        treat     length = $200  label = 'Treatment'
		aeout     length = $200   label = 'Outcome'
        druglvl   length = $100  label = 'Investigational#Drug Level (mg)'
    ;
	set ae;
	druglvl='';
    keep subjid aeterm aestdy aeendy sev aeser aerel aeacn treat aeout druglvl;
run;
