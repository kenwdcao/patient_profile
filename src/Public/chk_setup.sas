/*

	Program Name: chk_setup.sas
		@Author: Ken Cao (yong.cao@q2bi.com)
		@Intial Date: 2013/04/02

	***********************************************************
	Purpose:
	1. Check integrity of _setup.sas
	2. There are a lot of parameters related to customizing
	patient profile. Those parameter give user some control 
	on the layout of patient profile. However, default value
	machanism should be provided in case of user erase the 
	default value in the template setup and want to get recover.
	********************************************************

*/

%macro chk_setup();

	*default value of user-customized parameter on patient profile layout;
	%if %length(&newcolor)=0 or "%upcase(&newcolor)"="DEFAULT" %then 
		%let newcolor=#DDDDDD;
	%if %length(&mdfcolor)=0 or "%upcase(&mdfcolor)"="DEFAULT" %then
		%let mdfcolor=YELLOW;
	%if %length(&abovecolor)=0 or "%upcase(&abovecolor)"="DEFAULT" %then
		%let abovecolor=RED;
	%if %length(&belowcolor)=0 or "%upcase(&belowcolor)"="DEFAULT" %then
		%let belowcolor=BLUE;
	%if %length(&norangecolor)=0 or "%upcase(&norangecolor)"="DEFAULT" %then
		%let norangecolor=GREEN;
	%if %length(&sectionheadercolor)=0 or "%upcase(&sectionheadercolor)"="DEFAULT" %then
		%let sectionheadercolor=#1F497D;
	%if %length(&sectionheaderfsize)=0 or "%upcase(&sectionheaderfsize)"="DEFAULT" %then
		%let mdfcolor=9pt;
	%if %length(&appendixheadercolor)=0 or "%upcase(&appendixheadercolor)"="DEFAULT" %then
		%let appendixheadercolor=GREEN;
	%if %length(&appendixheaderfsize)=0 or "%upcase(&appendixheaderfsize)"="DEFAULT" %then
		%let appendixheaderfsize=GREEN;
	%if %length(&tableheaderbgcolor)=0 or "%upcase(&tableheaderbgcolor)"="DEFAULT" %then
		%let tableheaderbgcolor=cxF5F7F1;
	%if %length(&tablebordercolor)=0 or "%upcase(&tablebordercolor)"="DEFAULT" %then
		%let tablebordercolor=cxC1C1C1;
	%if %length(&nblanklinesbetweentable)=0 or "%upcase(&nblanklinesbetweentable)"="DEFAULT" %then
		%let nblanklinesbetweentable=cxC1C1C1;
	%if %length(&usrdefinedheadfootfsize)=0 or "%upcase(&usrdefinedheadfootfsize)"="DEFAULT" %then
		%let usrdefinedheadfootfsize=cxC1C1C1;

%mend chk_setup;
