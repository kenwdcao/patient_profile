

%let abovecolor    = red;   
%let belowcolor    = blue;  
%let norangecolor  = green;


*initialization: create a container to collect all tables;
%macro init;
	data _visit0;
		retain subjectnumberstr dov_c visitmnemonic source;
		keep subjectnumberstr dov_c visitmnemonic source;
		set source.rd_frmchem;
		where 0;
		length dov_c $10 source $32;
		call missing(source, dov_c);
	run;
%mend init;

*insert visit and visit date;
%macro insertdov(dset);
	proc sql;
		insert into _visit0
		select distinct subjectnumberstr, ifc(dov=.,'',scan(put(dov,is8601dt.),1,'T')), visitmnemonic, "%upcase(&dset)"
		from source.&dset
		;
	quit;
%mend insertdov;


%macro getVNUM(indata=,out=);
		proc sql;
		create table &out as
		select a.*, b.visitnum, b.visitmnemonic
		from &indata(rename=(visitmnemonic=in_visitmnemonic)) as a left join pdata._visitindex as b
		on a.subjectnumberstr=b.subjectnumberstr and scan(put(a.dov,is8601dt.),1,'T')=b.dov_c
		and a.in_visitmnemonic=b.in_visitmnemonic;
	quit;
%mend getVNUM;

/*
%macro getVisitLabel;
	%local allname;
	%local alllabel;
	%local i;

	data _null_;
		set __prt(obs=1);
		array var{*} $ _character_;
		length allname $1024 alllabel $2048;
		call missing(allname,alllabel);
		do i=1 to dim(var);
			allname=strip(allname)||ifc(allname='','','@')||vname(var[i]);
			alllabel=strip(alllabel)||ifc(alllabel='','','@')||ifc(var[i]='','.',var[i]);
		end;
		call symput('allname',strip(allname));
		call symput('alllabel',strip(alllabel));
	run;

	%put &allname;
	%put &alllabel;

	%let cnt=%sysfunc(countc(&allname,@));
	%let cnt=%eval(&cnt+1);

	%put &cnt;

	%do i=1 %to &cnt;
		%local var&i label&i;
		%let var&i=%upcase(%scan(&allname,&i,@));
		%let label&i=%scan(%bquote(&alllabel),&i,@);
		%let label&i=%sysfunc(strip(%bquote(&&label&i)));
	%end;

	data __prt;
		set __prt(firstobs=2);
		%do i=1 %to &cnt;
			%put &&label&i;
			%if "&&label&i"^="." %then
			%do;
				label &&var&i = "&&label&i";
			%end;
			%else
			%do;
				%if %index(&&var&i,D)>0 %then
				%do;
					drop &&var&i;
				%end;
				%else 
				%do;
					label &&var&i = "&escapechar{style [foreground=white]i}";
				%end;
			%end;			
		%end;
	run;
%mend getVisitLabel;*/


%macro getVisitLabel();
	%local allvar;
	%local alllabel;
	%local nvisit;
	%local i;

	data _null_;
		set __prt (obs=1);
		array vst{*} V_:;
		length _allvar_ _alllabel_ $32767;
		call missing(_allvar_, _alllabel_);
		do i = 1 to dim(vst);
			vst[i] = prxchange('s/"/""/', -1, vst[i]);
			if vst[i] = ' ' then vst[i] = '<DROP THIS VISIT>';
			_allvar_=ifc(_allvar_ = ' ', vname(vst[i]), strip(_allvar_)||'@'||vname(vst[i]));
			_alllabel_=ifc(_alllabel_ = ' ', vst[i], strip(_alllabel_)||'@'||vst[i]);
		end;
		call symput('allvar', strip(_allvar_));
		call symput('alllabel', strip(_alllabel_));
		call symput('nvisit', strip(put(dim(vst), best.)));
	run;

	%do i = 1 %to &nvisit;
		%local var&i;
		%local label&i;

		%let var&i = %scan(&allvar, &i, @);
		%let label&i=%scan(%bquote(&alllabel), &i, @);
		%let label&i=%sysfunc(strip(%bquote(&&label&i)));
	%end;

	data __prt;
		set __prt (firstobs = 2);
		%do i = 1 %to &nvisit;
			label &&var&i = "&&label&i";
			%if "&&label&i" = "<DROP THIS VISIT>" %then drop &&var&i;;
		%end;
	run;

%mend getVisitLabel;

%macro nullcolumn;
	data __prt;
		set __prt;
			label 
				V_910 = " "
				V_920 = " "
				V_930 = " "
			;
		V_910='';
		V_920='';
		V_930='';
	run;
%mend nullcolumn;


%macro getVisitLabelqs;
	%local allname;
	%local alllabel;
	%local i;

	data _null_;
		set __prt(obs=1);
		array var{*} $ _character_;
		length allname $1024 alllabel $2048;
		call missing(allname,alllabel);
		do i=1 to dim(var);
			allname=strip(allname)||ifc(allname='','','@')||vname(var[i]);
			alllabel=strip(alllabel)||ifc(alllabel='','','@')||ifc(var[i]='','.',var[i]);
		end;
		call symput('allname',strip(allname));
		call symput('alllabel',strip(alllabel));
	run;

	%put &allname;
	%put &alllabel;

	%let cnt=%sysfunc(countc(&allname,@));
	%let cnt=%eval(&cnt+1);

	%put &cnt;

	%do i=1 %to &cnt;
		%local var&i label&i;
		%let var&i=%upcase(%scan(&allname,&i,@));
/*		%put %scan(%bquote(&alllabel),&i,@);*/
		%let label&i=%scan(%bquote(&alllabel),&i,@);
		%let label&i=%sysfunc(strip(%bquote(&&label&i)));
	%end;

	data __prt;
		set __prt(firstobs=2);
		%do i=1 %to &cnt;
			%put &&label&i;
			%if "&&label&i"^="." %then
			%do;
				%if %index(%bquote(&&label&i),UNS)>0 %then %LET label&i=UNS;
				label &&var&i = "&&label&i";
			%end;
			%else
			%do;
				%if %index(&&var&i,D)>0 %then
				%do;
					drop &&var&i;
				%end;
				%else 
				%do;
					label &&var&i = "&escapechar{style [foreground=white]i}";
				%end;
			%end;			
		%end;
	run;
%mend getVisitLabelqs;


%macro adjustVisitVarOrder(indata=,othvars=);
	%local visitvarnamelist;

	*get all visit variable names into dataset;
	proc contents data=&indata 
		out=_visitvarnamelist(keep=name where=(upcase(name) like 'V_%'))
		noprint;
	run;

	*sort visit variables in based on visitnum;
	proc sort data=_visitvarnamelist sortseq=linguistic(numeric_collation=on);
		by name;
	run;

	*get all visit variable names into macro variable;
	data _null_;
		set _visitvarnamelist end=_eof_;
		retain visitvarnamelist;
		length visitvarnamelist $512;
		if _n_=1 then visitvarnamelist=name;
		else visitvarnamelist=strip(visitvarnamelist)||' '||name;
		if _eof_ then
		do;
			call symput('visitvarnamelist',strip(visitvarnamelist));
		end;
	run;

	*adjust variable order;
	data &indata;
		retain &othvars &visitvarnamelist;
		keep   &othvars &visitvarnamelist;
		set &indata;
	run;

%mend adjustVisitVarOrder;



%macro adjustvalue(dsetlabel=);
	length __CRFNAME $200 VISIT $60;
	label VISIT='Visit'
	      __VISITNUM='VISITNUM'
		  __CRFNAME = 'Form Name';
	__VISITNUM=input(VISITMNEMONIC,VNUM.);
	__CRFNAME="&dsetlabel";
	VISIT=put(VISITMNEMONIC,$visit.);
%mend adjustvalue;

%macro adjustvalue1(dsetlabel=);
	length __CRFNAME $200 VISIT $60;
	label VISIT='Visit'
	      __VISITNUM='VISITNUM'
		  __CRFNAME = 'Form Name';
	__VISITNUM=input(IN_VISITMNEMONIC,VNUM.);
	__CRFNAME="&dsetlabel";
	VISIT=put(IN_VISITMNEMONIC,$visit.);
%mend adjustvalue1;

%macro IsNumeric(InStr=, Result=);
	length __InStr $200;
   &Result = 1;
   __PeriodCount = 0;

   __InStr = trim(left(&InStr));
   if substr(__InStr, 1, 1) in ('-', '+') then __InStr = trim(left(substr(__InStr, 2)));

   do __n = 1 to length(__InStr);
      if substr(__InStr, __n, 1) not in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.') then
	     &Result = 0;
      if substr(__InStr, __n, 1) = '.' then __PeriodCount = __PeriodCount + 1;
   end;
   if __PeriodCount > 1 then &Result = 0;
%mend IsNumeric;

%macro formatDate(date);
	length __Day $10 __Month $10 __Year $10;
	* - > Get Year/Month/Day Component ;
	__Year=strip(scan(&date,1,'-'));
	__Month=strip(scan(&date,2,'-'));
	__Day=strip(scan(&date,3,'-'));

	* -> Numeric Month Value to 3-char value;
	__Result=0;
	%IsNumeric(InStr=__Month, Result=__Result);
/*	if upcase(__Month) not in ('UN','UNK','UK','NK','') then*/
	if __Result=1 then 
		__Month=substr(put(input('1960-'||strip(__Month)||'-01',yymmdd10.),date9.),3,3);
	else if __Month='' then __Month='UNK';
	__Month=propcase(__Month);

	* -> 4-digt year value to 2-digt year value;
	if length(__Year)=4 then __Year=substr(__Year,3);
	else if __Year='' then __Year='UU';

	* -> Handle unknown Day value;
	__Result=0;
	%IsNumeric(InStr=__Day, Result=__Result);
	if __Result=0 and __Day='' then __Day='UU';

	* -> New Date Format;
	&date=strip(__Day)||ifc(__Month>'','-','')||strip(__Month)||ifc(__Year>'','-','')||strip(__Year);
	if &date='UU-Unk-UU' then &date='';
%mend formatDate;

%macro informatDate(date);
	length __Day $10 __Month $10 __Year $10;
	* - > Get Year/Month/Day Component ;
	if strip(PUT(&date,DATETIME20.))^='' and strip(PUT(&date,DATETIME20.))^='.' then do;
	__Year=substr(strip(PUT(&date,DATETIME20.)),8,2);
	__Month=propcase(substr(strip(PUT(&date,DATETIME20.)),3,3));
	__Day=substr(strip(PUT(&date,DATETIME20.)),1,2);
	* -> New Date Format;
	A_&date=strip(__Day)||ifc(__Month>'','-','')||strip(__Month)||ifc(__Year>'','-','')||strip(__Year);end;
	else do;A_&date='';end;
%mend informatDate;

%macro concatoth(var=,oth=,newvar=);
		if &oth>'' then &newvar=propcase(strip(&var))||': '||strip(&oth);
		else &newvar=propcase(strip(&var));
%mend concatoth;

%macro concatyn(var=,oth=,newvar=);
		if &oth>'' then &newvar=strip(&var)||': '||&oth;
		else &newvar=strip(&var);
%mend concatyn;

%macro char(var=,newvar=);
		&newvar=ifc(&var^=.,strip(put(&var,best.)),'');
/*		if &var^=. then &newvar=strip(put(&var,best.));*/
/*		else &newvar='';*/
%mend char;

%macro ENRF1(ongo=,stopdate=, newvar=);
	if upcase(&ongo)='YES' then &stopdate='Ongoing';
%mend ENRF1;

%macro ENRF(ongo=,stopdate=, newvar=);
	if strip(&ongo)='Ongoing' then &newvar='Ongoing';
	else &newvar=&stopdate;
%mend ENRF;

%macro concatSPE(var=, spe=, newvar=);
	if &spe>'' then &newvar=strip(scan(&var,1,','))||': '||strip(&spe);
	else if &var >'' then &newvar=&var;
%mend concatSPE;

%macro concatVAR(var1=, var2=,newvar=);
	if &var1 >'' then &newvar=&var1;
	else &newvar=&var2;
%mend concatVAR;


%macro notInLowHigh(orres=,low=,high=,stresc=);
	%local i;
	%local var1 var2 var3;
	%local nvar1 nvar2 nvar3;

 	length __orres __low __high 8 __orresc $200 __color $40;
	call missing(__orres, __low, __high,  __orresc, __color);
	if _n_=1 then do;
		%let var1=&orres; %let nvar1=__orres;
		%let var2=&low;   %let nvar2=__low;
		%let var3=&high;  %let nvar3=__high;
	end;
	%do i=1 %to 3;
		if vtype(&&var&i)='C' then do;
			__result=0; 
			%IsNumeric(InStr=&&var&i,Result=__Result);
			if __result=1 then &&nvar&i=input(&&var&i,best.);;
		end;
		else do;
			&&nvar&i=&&var&i;
		end;
	%end;
	__orresc=ifc(__orres=.,'',strip(put(__orres,best.)));
	if not(__low<=__orres<=__high) and n(__low,__high)>0 and __orres>. then do;
		if __orres<__low then __color="&belowcolor";
		else if __orres>__high then __color="&abovecolor";
	end;
	else if n(__low,__high)=0 and __orres>. then do;
		__color="&norangecolor";
	end;
	if __color>'' then &stresc='^{style [foreground='||strip(__color)||' fontweight=bold]'||strip(__orresc)||'}';
	else &stresc=strip(__orresc);
%mend notInLowHigh;

%macro ageint(RFSTDTC=, BRTHDTC=, AGE=);
   __RFSTDTC = &RFSTDTC;
   __BRTHDTC = &BRTHDTC;
   if __RFSTDTC ^= '' and length(compress(__RFSTDTC)) = 10 and __BRTHDTC ^= '' and length(compress(__BRTHDTC)) = 10 then
      &AGE._=int((input(substr(__RFSTDTC, 1, 10), yymmdd10.) - input(substr(__BRTHDTC, 1, 10), yymmdd10.) + 1)/365.25);
	%char(var=&AGE._,newvar=&AGE);
%mend ageint; 

%global globalVars1;
%global globalVars2;
%global globalVars3;
%global globalVars4;
* -> With Visit; 
%let GlobalVars1=%str(SUBJECTNUMBERSTR __VISITNUM VISIT A_DOV __CRFNAME);
* -> Without Visit date(If VIISTDT is blank); 
%let GlobalVars2=%str(SUBJECTNUMBERSTR __VISITNUM VISIT __CRFNAME);
* -> Without Visit (If Visit is removed, then VIISTDT is also removed); 
%let GlobalVars3=%str(SUBJECTNUMBERSTR __CRFNAME);
* -> Use %getVNUM; 
%let GlobalVars4=%str(SUBJECTNUMBERSTR __visitnum visitmnemonic A_DOV);


%macro getdy(indata=,outdata=,vars=);
data &outdata;
	length SUBJECTNUMBERSTR $20 fdosedt 8;
	if _n_=1 then do;
		declare hash h (dataset:'pdata.firstdose');
		rc=h.defineKey('SUBJECTNUMBERSTR');
		rc=h.defineData('fdosedt');
		rc=h.defineDone();
		call missing(SUBJECTNUMBERSTR, fdosedt);
	end;
	set &indata;
	rc=h.find();
	%formatDate(&vars);
	if index(&vars,'UU') OR index(&vars,'Unk') or &vars='' or fdosedt=. then do;DY=.;end;
	else do;
	if input(&vars,date9.)>=fdosedt then DY=input(&vars,date9.)-fdosedt+1;
	else DY=input(&vars,date9.)-fdosedt;end;
	&vars=ifc(dy=.,strip(&vars),strip(&vars)||' ('||strip(put(DY,best.))||')');
	drop fdosedt DY;
run;
%mend getdy;

%macro wrap(invar=,maxlen=10, linefeed=);
	&invar=prxchange("s/(.{&maxlen})/$1&linefeed/",-1,strip(&invar));
%mend;

%macro wraplbname;
	%local dsid;
	%local nvar;
	%local rc;

	%let dsid=%sysfunc(open(__prt));
	%let nvar=%sysfunc(attrn(&dsid,nvars));
	%let rc=%sysfunc(close(&dsid));

	%if &nvar>=8 %then 
	%do;
		data __prt;
			set __prt;
			if _n_^=2 then output;
			else 
			do;
				array vst{*} V_:;
				do i=1 to dim(vst);
					%wrap(invar=vst[i],maxlen=11,linefeed=&escapechar.n);
				end;
				drop i;
				output;
			end;
		run;
	%end;
%mend wraplbname;


%macro wraplbname1;
	%local dsid;
	%local nvar;
	%local rc;

	%let dsid=%sysfunc(open(__prt));
	%let nvar=%sysfunc(attrn(&dsid,nvars));
	%let rc=%sysfunc(close(&dsid));

	%if &nvar>=8 %then 
	%do;
		data __prt;
			set __prt;
			if _n_^=1 then output;
			else 
			do;
				array vst{*} V_:;
				do i=1 to dim(vst);
					%wrap(invar=vst[i],maxlen=11,linefeed=&escapechar.n);
				end;
				drop i;
				output;
			end;
		run;
	%end;
%mend wraplbname1;


%macro wrapword(instr=,outstr=, MAXCHAR=, odsEscapeChar=, dlm = %str( ));

    /*
        while length of string is less than MAXCHAR
            get a word from INSTR
        concatenate string to OUTSTR        
    */


    length __dlm__ $%length(&dlm);
    __dlm__ = "&dlm";


    * get a word from INSTR starting at given position;
    %macro getword(instr=, startpos=, MAXCHAR=);
        %local IN;
        %local OUT;

        length __char__ $1 __state__ 8;

        %let IN  = 1;
        %let OUT = 0;

        __state__   = -1;
        __endword__ = 0;

        __charCNT__ = 0;
        __word__    = ' ';
        __wordLen__ = 0;

        do __i__ = &startpos to length(&instr);
            __char__ = substr(&instr,__i__, 1);
            __charCNT__ = __charCNT__ + 1;

            if index(__dlm__, __char__) = 0 then __state__ = &IN; /* within a word */
            else if __state__ = &IN then do;
                __state__   = &OUT; /* out of a word */
                __endword__ = 1;
            end;

            if __charCNT__ > &MAXCHAR then __endword__ = 1;

            if not __endword__ then do;
                * return a word:;
                if __charCNT__ > 1 then __word__ = substr(__word__, 1, __charCNT__-1)||__char__;
                else __word__ = __char__;
            end;
            else leave;
        end;

        * return word length;
        __wordLen__ = __i__ - &startpos;

        if __i__ >= length(&instr) then __eof__ = 1;
    %mend getword;

    %macro push2stack();
        * if stack is null and input string start with a blank, then truncate first blank;
        * __wordLen__ cannot be substracted by 1 because pointer __pInstr__ needs its original value;
        if __stack__ = ' ' and substr(__word__, 1, 1) = ' ' then do;
            __word__ = substr(__word__, 2);
            __rmfb__ = 1;
        end;
        else __rmfb__ = 0;
        if __pStack__ > 1 then __stack__  = substr(__stack__, 1, __pStack__ - 1)||__word__;
        else __stack__ = __word__;
        __pStack__  = __pStack__ + __wordLen__ ;
        if __rmfb__ then __pStack__ = __pStack__ - 1;
    %mend push2stack;

    %macro clearStack();

        /*
        * remove (first) leading blank;
        if substr(__stack__,1, 1) = ' ' then do;
            __stack__  = substr(__stack__, 2);
            __pStack__ = __pStack__ - 1;
        end;
        */
        if __pStack__ = 1 then __pStack__ = 2; /* make __pStack__ - 1 greater than 0*/
        if __pOutstr__ > 1 then &outstr = substr(&outstr, 1, __pOutstr__ - 1)||substr(__stack__, 1, __pStack__ - 1)||"&odsEscapeChar.n";
        else &outstr = substr(__stack__, 1, __pStack__ - 1)||"&odsEscapeChar.n";
        __pOutstr__ = __pOutstr__ + __pStack__ - 1 + 2;
        __stack__   = ' ';
        __pStack__  = 1;
    %mend clearStack;



    length __stack__ $%eval(&MAXCHAR+1); /* stack for containing word piece */
    length __pStack__ 8; /* pointer of stack */
    length __word__ $%eval(&MAXCHAR+1); /* a single word */
    length __wordLen__ 8; /* length of a word*/
    length __pInstr__ 8; /* pointer of start position of uncopied character of Instr*/
    length __pOutstr__ 8; /* pointer of start position of unused character of Outstr*/
    length __eof__ 8; /* end of input string */

    __stack__   = ' ';
    __word__    = ' ';
    __pStack__  = 1;
    __wordLen__ = 0;
    __pInstr__  = 1;
    __pOutstr__ = 1;
    __eof__     = 0;

    * initialization;
    %getword(instr=&instr, startpos=__pInstr__, MAXCHAR=&MAXCHAR);

    do while(1);
        do until(__pInstr__ - 1 = length(&instr)); 
            %push2stack;
            __pInstr__ = __pInstr__ + __wordLen__;
/*            put __stack__= __word__= __pStack__=;*/
            %getword(instr=&instr, startpos=__pInstr__, MAXCHAR=&MAXCHAR);
            if __pStack__ + ifn((__stack__ = ' ' and substr(__word__, 1, 1) = ' '), __wordLen__ - 1, __wordLen__) > lengthc(__stack__) then leave;
        end;

        %clearStack;

        if __pInstr__ >= length(&instr) then leave;
    end;

    * remove trailing new line feed;
    &outstr=substr(&outstr, 1, length(&outstr)-2);

%mend wrapword;



