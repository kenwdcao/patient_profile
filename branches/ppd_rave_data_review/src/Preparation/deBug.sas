
/*
	Program Name: deBug.sas
		@Author: Ken Cao (yong.cao@q2bi.com)
		@Initial Date: 2013/03/15
*/

%macro debug;
	%if %upcase(&debugMode)^=Y %then
	%do;
		option nomprint nomlogic;
	%end;
	%else
	%do;
		option mprint mlogic;
	%end;
%mend debug;

