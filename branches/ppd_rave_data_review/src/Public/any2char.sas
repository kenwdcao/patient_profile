******************************************************************************;
* Module: Data Processing                                                    *;
* Type: Sas Macro                                                            *;
* Program Name: dvp_m_getvarlbl.sas                                          *;
* Function: Convert input variable to character value.                       *;
* Initial Date: 2013-01-16                                                   *;
* Author: Ken Cao (yong.cao@q2bi.com)                                        *;
******************************************************************************;

*
<-- NOTE:
1. This macro converts an character/numeric variable into a character variable __char.
2. Format of original variable will be considered.
-->
*;

*
<--
1. Ken on 2013/02/06: If character variable, then format will not be used.
-->
*;

%macro any2char(invar=,indata=);
	%local dsid;
	%local rc;
	
	%local vartype varnum varfmt;
	%getvarinfo(indata=&indata,invar=&invar,getvarnum=Y,getvarfmt=Y,getvartype=Y);
	%put &varfmt;

	length _charval $200;
	%if &vartype=C %then _charval=&invar;
	%else %if &vartype=N %then %do;
		if &invar=. then _charval='';
		else do;
			%if %length(&varfmt)=0 %then %do;
				_charval=strip(put(&invar,best.));
			%end;
			%else %do;
				_charval=strip(put(&invar,&varfmt));
			%end;
		end;
	%end;
%mend any2char;

