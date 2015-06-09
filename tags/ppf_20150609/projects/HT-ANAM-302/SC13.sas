
%include '_setup.sas';

*<SC----------------------------------------------------------------------------------------;
data sc0;
	set source.RD_FRMBMIWTHX;
	%adjustvalue(dsetlabel=BMI/Weight Loss History);
	%informatDate(DOV);
	%formatDate(ITMBMIWTHXPRWGHTDT_DTS);
	label
		A_DOV='Visit Date'
		SCRBMI='Screening BMI#<kg/m2>'
		BMIWTH='Weight Loss'
		ITMBMIWTHXPRWGHTDT_DTS='Date of prior weight'
		WEIGHT='Weight#<kg>'
		ITMBMIWTHXWEIGHTMTH='Method Weight Documented'
	;
    BMIWTH=strip(put(ITMBMIWTHXLT20_C,$BMIWTH.));
	%char(var=ITMBMIWTHXSCRBMI,newvar=SCRBMI);
	%char(var=ITMBMIWTHXWEIGHT,newvar=WEIGHT);

run; 
 proc sql;
	create table scvs as 
	select a.*,b.ITMVSWEIGHT,b.ITMVSHEIGHT
	from (select * from sc0) as a
			left join 
          (select * from source.RD_FRMVS1) as b
	on a.SUBJECTNUMBERSTR=b.SUBJECTNUMBERSTR;
quit;
data scvs1;
	length SCWEIGHT $100 __label $400 WEIGHT SCRBMI $100 ;
	label
		SCRBMI='Screening BMI#<kg/m2>'
		WEIGHT='Weight#<kg>'
	;
	set scvs(rename=(WEIGHT=WEIGHT1 SCRBMI=SCRBMI1));
	%char(var=ITMVSWEIGHT,newvar=SCWEIGHT);
	if WEIGHT1^='' and SCWEIGHT^='' then LW=((ITMBMIWTHXWEIGHT-ITMVSWEIGHT)/ITMBMIWTHXWEIGHT)*100;
	LW1=ifc(LW^=.,strip(put(LW,10.1)),'');
	if LW^=. and LW<5 then WEIGHT=strip(WEIGHT1)||" ^{style [foreground=&abovecolor] ("|| strip(LW1)||"%) }";
	else WEIGHT=WEIGHT1;

	if ITMVSWEIGHT^=. and ITMVSHEIGHT^=. then VSBMI=ITMVSWEIGHT/((ITMVSHEIGHT/100)*(ITMVSHEIGHT/100));
	VSBMI1=ifc(VSBMI^=.,strip(put(VSBMI,10.1)),'');
	if ITMBMIWTHXSCRBMI^=. and VSBMI^=. then do;
		if (ITMBMIWTHXSCRBMI-VSBMI)/VSBMI>0.01 or (ITMBMIWTHXSCRBMI-VSBMI)/VSBMI<-0.01 then SCRBMI="^{style [foreground=&abovecolor textdecoration=line_through]"|| strip(SCRBMI1)
	||"}"||' '||"^{style [foreground=&norangecolor] "|| strip(VSBMI1)||"}";
			else SCRBMI=SCRBMI1; 
	end;

	if index(SCRBMI,'^')>0 then do;
	if SCWEIGHT^='' then __label="BMI/Weight Loss History "||"^{style [foreground=&norangecolor](Weight at screening visit: " 
	|| strip(SCWEIGHT)||"kg)}"||"^{newline 2}^{style[fontsize=7pt foreground=green]NOTE: }"||
	"^{style[fontsize=7pt foreground=red textdecoration=line_through]incorrect value}"||
	"^{style[fontsize=7pt foreground=green] correct value by Q2}";
		else __label="BMI/Weight Loss History "||"^{style [foreground=&norangecolor] (Weight at screening visit: NA)}^{newline 2}
^{style[fontsize=7pt foreground=green]NOTE: }^{style[fontsize=7pt foreground=red textdecoration=line_through]incorrect value}
^{style[fontsize=7pt foreground=green] correct value by Q2}";end;
	else do;
	if SCWEIGHT^='' then __label="BMI/Weight Loss History "||"^{style [foreground=&norangecolor](Weight at screening visit: " 
	|| strip(SCWEIGHT)||"kg)}";
	else __label="BMI/Weight Loss History "||"^{style [foreground=&norangecolor] (Weight at screening visit: NA)}";end;
run;
data pdata.sc13(label='BMI/Weight Loss History');
	retain &GlobalVars1 SCRBMI BMIWTH ITMBMIWTHXPRWGHTDT_DTS WEIGHT ITMBMIWTHXWEIGHTMTH __label;
	keep &GlobalVars1 SCRBMI BMIWTH ITMBMIWTHXPRWGHTDT_DTS WEIGHT ITMBMIWTHXWEIGHTMTH __label;
	set scvs1;
run;
