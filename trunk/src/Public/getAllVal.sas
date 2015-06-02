******************************************************************************;
* Module: Other                                                              *;
* Type: Sas Macro                                                            *;
* Program Name: DVP_m_getallval.sas                                          *;
* Function: Get all unique value of a variable                               *;
* Initial Date: 2013-01-17                                                   *;
* Author: Ken Cao (yong.cao@q2bi.com)                                        *;
******************************************************************************;

*
<-- NOTE: 
1. This macro collects all unique value from a variable in given dataset, and count number of unique value.
2. Collected unique value will be separated by value of &dlm, and default value (if not given) is blank.
3. Macro will return collected unique value and number of unique value via macro variable &allval and &count.
   The two value must be defined as LOCAL in parent macro who calls this macro.
-->
*;

%macro getallval(indata=,invar=, dlm=%str( ));
	data _null_;
		set &indata end=_eof_;
		length allvalue $20000;
		retain allvalue;
		if _n_=1 then allvalue=&invar;
		else if findw(strip(allvalue),strip(&invar),"&dlm")=0 then allvalue=strip(allvalue)||"&dlm"||&invar;
		if _eof_ then do;
			call symput('allval',strip(allvalue));
		end;
	run;

	%if %length(&allval)=0 %then %let count=0;
	%else %let count=%eval(%sysfunc(countc(&allval,"&dlm"))+1);
	
	%put &count;
%mend getallval;
