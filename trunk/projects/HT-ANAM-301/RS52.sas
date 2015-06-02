%include '_setup.sas';

*<RS----------------------------------------------------------------------------------------;
%getVNUM(indata=source.RD_FRMTMRASS, out=RD_FRMTMRASS);
data rs0;
	set RD_FRMTMRASS(rename=(visitnum=__visitnum));
	%informatDate(DOV);
	%formatDate(ITMTMRASSDT_DTS);
	label
		A_DOV='Visit Date'
		ITMTMRASSDT_DTS='Date of assessment'
		NTARCD='Was there new target lesions found?'
		ITMTMRASSTARRSP='Response of Target Lesions'
		NONTARLES='Was there new non-target lesions found?'
		ITMTMRASSNONTARRSP='Response of Non-Target Lesions'
		ITMTMRASSOVERALL='According to RECIST 1.1 Criteria'
	;
	%concatyn(var=ITMTMRASSTARLES,oth=ITMTMRASSNTARCD_ITMTMRASST_1,newvar=NTARCD);
	if index(ITMTMRASSNTARCD_ITMTMRASSN_1,'and')>0 then x=compress(TRANSLATE(ITMTMRASSNTARCD_ITMTMRASSN_1,',','and'));
		else x=ITMTMRASSNTARCD_ITMTMRASSN_1;
	%concatyn(var=ITMTMRASSNONTARLES,oth=x,newvar=NONTARLES);
run;
data pdata.rs52(label='Target and Non-Target Lesions Assessment');
	retain &GlobalVars4 ITMTMRASSDT_DTS NTARCD ITMTMRASSTARRSP NONTARLES ITMTMRASSNONTARRSP ITMTMRASSOVERALL;
	keep &GlobalVars4 ITMTMRASSDT_DTS NTARCD ITMTMRASSTARRSP NONTARLES ITMTMRASSNONTARRSP ITMTMRASSOVERALL;
	set rs0;
run;
*------------------------------------------------------------------------------------------>;
