/*********************************************************************
 Program Nmae: printSubject.sas
  @Author: Ken Cao
  @Initial Date: 2015/03/30
 

 Universal macro for printing a subject.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 
 Ken Cao on 2015/04/13: Add a cover page.

*********************************************************************/

%macro printSubject(subject, datalist, ods, style);
%local i;
%local ndset;
%local dset;
%local nobs;
%local nobsnew;
%local j;
%local idvar;
%local startpage;
%local subjectlevel;
%local keyvars;
%local label;
%local nodatatext;
%local islabelsubjectlev;
%local noprintwhennodata;
%local keyvarscnt;
%local colstat;
%local ndsetHeader;
%local ndsetFooter;
%local isDelRecExist;
%local chgVars;
%local nchgvar;
%local var;
%local chglbl;
%local nchglbl;
%local split2;
%local varsinnew; ** variable lists in current dataset;
%local getvarlbl;


%local blank;
%local prefix;

%let  blank = ;
%let prefix = L_Patient_Profile;
%let    ods = %upcase(&ods);


** # of dataset to be printed **;
%let ndset = %eval(%sysfunc(countc(&datalist, " ")) + 1);


** records date/time of generation of each patient profile **;
data _null_;
    time=scan(put(time(),is8601dt.),2,'T');
    time=translate(time,":",'-');
    date=put(input("&sysdate9", date9.), yymmdd10.);
    call symput('time', strip(time));
    call symput('date', strip(date));
run;



%if &ods = PS %then %do;
ods ps file="&tempdir\temp.ps" 
    style=&style 
    startpage=no  
    pdfmark 
    bookmarkgen=no
;
%end;
%else %if &ods = PDF %then %do;
ods pdf file="&outputdir\&prefix._&studyid._&subj..pdf" 
    style=&style 
    startpage=no  
;
%end;
%else %if &ods = RTF %then %do;
ods rtf file="&outputdir\&prefix._&studyid._&subj..rtf" style=&style startpage=no notoc_data;
%end;

** print titles and footnotes **;
** Print a Cover Page;
%if &showCoverPage = Y %then %do;

title; footnote;
%*headfoot(&subj, &ods, systemtitle = N, systemfooter = N, user = N);

data _cover;
    length line $1024;
    line = ' '; output;
    line = ' '; output;
    line = ' '; output;
    line = " "; output;
    line = "&escapechar.S={preimage=""&logo"" pretext="" &slogon""}"; output;
    line = ' '; output;
    line = ' '; output;
    line = "&escapeChar.S={fontweight=bold fontsize=36pt}Patient Profile for Study &studyid2"; output;
    line = " "; output;
    line = "&escapeChar.S={fontweight=bold fontsize=20pt}SUBJECT ID: &subj"; output;
    line = ' '; output;
    line = ' '; output;
    line = ' '; output;
    line = ' '; output;
    line = ' '; output;
    line = ' '; output;
    line = ' '; output;
    line = ' '; output;
    line = ' '; output;
    line = ' '; output;
    line = ' '; output;
    %if &displayQ2InCoverPage = Y %then %do;
    line = "&escapeChar.S={fontsize=12pt}DESIGNED AND PRODUCED BY Q2"; output;
    %end;
    %else %do;
    line = ' '; output;
    %end;
    line = "&escapeChar.S={fontsize=12pt}PROPRIETARY AND CONFIDENTIAL"; output;
run;


proc report data = _cover nowd noheader
style(report)=[borderbottomcolor=white bordertopcolor=white borderrightcolor=white borderleftcolor=white]
style(column)=[just=c foreground=&tableheadercolor font=("Times New Roman")
               borderbottomcolor=white bordertopcolor=white borderrightcolor=white borderleftcolor=white]
;
    column line;
run;

ods &ods startpage=now;
%end;

option pageno = 1;

** Table of Contents for RTF output;
%if &ods = RTF %then %do;
title; footnote;
%headfoot(&subj, &ods, systemtitle = Y, systemfooter = Y, user = N);
ods rtf text = "&escapechar.S={foreground=cx1F497D just=c fontweight=bold fontsize=&tableheadersize}Table of Contents";
ods rtf text = "&escapechar.S={outputwidth=100% just=l}{\field{\*\fldinst {\\TOC \\f \\h \\u }}}";
%prtblnktab;
ods rtf startpage=now;
%end;


title; footnote;

%headfoot(&subj, &ods, systemtitle = %if &suppressSysTitle = Y %then N; %else Y;, systemfooter = %if &suppressSysFooter  = Y %then N; %else Y;, user = Y);

** walk through all datasets **;
%do i = 1 %to &ndset;
    %let dset = %upcase(%scan(&datalist, &i, " "));

    %let isDelRecExist = 0;
    
    * read configuration file ;
    data _null_;
        set &DSETCFG;
        where upcase(dset)="&dset";

        call symput('startpage',strip(startpage));
        call symput("subjectlevel",strip(subjectlevel));
        call symput("keyvars",strip(keylist));
        call symput("label",strip(label));
        call symput('nodatatext',strip(nodatext));
        call symput('islabelsubjectlevel',strip(islabelsubjectlevel));
        call symput('noprintwhennodata',strip(upcase(noprintwhennodata)));
        call symput('split2',strip(split));
        call symput('getvarlbl',strip(getvarlbl));

    run;


    %if %length(&split2) = 0 %then %let split2 = &splitChar;

    ** calculate # of key variables **;
    %if %length(&keyvars)=0 %then %let keyvarscnt=0;
    %else %let keyvarscnt=%eval(%sysfunc(countc(&keyvars," "))+1);



    ** extract subject from dataset (output dataset is __prt)**;
    ** macro subset contains an interface where user can customize subsetted dataset **;

    %subset(indata=&PDATALIBRF..&dset,subject=&subj, getvarlbl=&getvarlbl);  ** this macro returns NOBS for subsetted dataset. **;

    %if &compare = Y and &showDeletedRecord = Y %then %do;
        data __prtnew;
            set __prt;
        run;
        %let nobsnew = &nobs;

        proc contents data=__prtnew out=_varsinnew(keep=name) varnum noprint; 
        run;

        %local allval;
        %getAllVal(indata=_varsinnew, invar=name);
        
        %let varsinnew = &allval;


        %subset(indata=&PDATABKLIBRF..&dset,subject=&subj, getvarlbl=&getvarlbl);

        proc sql;
            create table __prtdel as
            select *, 'Y' as ___deleted length = 1
            from __prt
            where ___KEYHASH not in (
                select distinct ___KEYHASH 
                from __prtnew
            ) and ___KEYHASH ^= ' ';
        quit;

        data __prt;
            set __prtnew(in=___new) __prtdel(in=___del);
            if ___del then do;
                __type__   = ' ';
                __mdfnum__ = 0;
                __diff__   = ' ';
            end;
            %if &nobsnew = 0 and &nobs > 0 %then %do;
            if ___new then delete;
            %end;
            if ___del then do;
                __vars__ = ' ';
                __chglbl__ = ' ';
            end;

            keep &varsinnew ___deleted;
        run;

        %let nobs = &nobsnew;

        data _null_;
            set __prt;
            where ___deleted = 'Y';
            call symput('isDelRecExist', '1');
            stop;
        run;
    %end;



    %if &noprintwhennodata = Y and &nobs = 0 %then %goto ENDREPORT;

    %groupColumns(&ods);


    ****************************************************************************;
    ** insert header and footer of a dataset ;
    ****************************************************************************;
    %insertDsetHeadFoot;

    %let ndsetHeader = 0;
    %let ndsetFooter = 0;
    proc sql noprint;
        select count(ifn(type='T', 1, .)), count(ifn(type='F', 1, .))
        into: ndsetHeader, :ndsetFooter
        from _dsetHeadFoot;
    quit;

    %do j = 1 %to &ndsetHeader;
        %local dsetHeader&j;
    %end;

    %do j = 1 %to &ndsetFooter;
        %local dsetFooter&j;
    %end;

    data _null_;
        set _dsetHeadFoot;
        retain hcnt fcnt;
        if _n_ = 1 then do;
            hcnt = 0;
            fcnt = 0;
        end;
        if type = 'T' then do;
            hcnt = hcnt + 1;
            call symput('dsetHeader'||strip(put(hcnt, best.)), strip(headfoot));
        end;
        else if type = 'F' then do;
            fcnt = fcnt + 1;
            call symput('dsetFooter'||strip(put(fcnt, best.)), strip(headfoot));
        end;
    run;
    ****************************************************************************;


    %if &startpage = Y %then %do;
    ods &ods startpage=now;
    %end;
    
    %if &ods = RTF %then %do;
    ods rtf text =  "&escapechar.S={outputwidth=100% just=l} {\tc\f3\fs0\cf8  &label}";
    %end;
    %else %if &ods = PS or &ods = PDF %then %do;
    ods proclabel = "&label";
    %end;

    %let nchgvar = 0;
    %let nchglbl = 0;
    %let chgVars = ;
    %let  chglbl = ;

    data _null_;
        set __prt (obs = 1 keep = __vars__ __chglbl__);
        call symput('nchgvar', ifc(__vars__ = ' ', '0', strip(put(countw(__vars__, &dlmcompare), best.))));
        call symput('nchglbl', ifc(__chglbl__ = ' ', '0', strip(put(countw(__chglbl__, &dlmcompare), best.))));
    run;

    %do j = 1 %to &nchgvar;
        %local chgvar&i;
        %local marker&i;
    %end;

    %do j = 1 %to &nchglbl;
        %local chglblvar&i;
        %local lbl&i;
    %end;

    data _null_;
        set __prt (obs = 1 keep = __vars__ __chglbl__);
        length __var $1024 __marker $1 __lbl $1024;
        do i = 1 to &nchgvar;
            __var    = scan(__vars__, i, &dlmcompare);
            __marker = scan(__var, 2, '()');
            __var    = scan(__var, 1, '()');
            call symput('chgvar'||strip(put(i, best.)), strip(__var));
            call symput('marker'||strip(put(i, best.)), strip(__marker));
        end;
        do i = 1 to &nchglbl;
            __var = scan(__chglbl__, i, &dlmcompare);
            __lbl = substr(__var, index(__var, ":")+1);
            __var = scan(__var, 1, ':');
            put __var= __lbl=;
            call symput('chglblvar'||strip(put(i, best.)), strip(__var));
            call symput('lbl'||strip(put(i, best.)), strip(__lbl));
        end;
    run;

    /*
    %do j = 1 %to &nchgvar;
        %put &&chgvar&j;
        %put &&marker&j;
    %end;

    %do j = 1 %to &nchglbl;
        %put &&chglblvar&j;
        %put &&lbl&j;
    %end;
    */

    proc report data = __prt nowd headskip split="&split2" 
        style(report) = [width = 100%]
        style(column) = [ just = l]
        style(header) = [ just = l]
    ;


        &colstat;

        ** interface for user to customize report defintion **;
        %prt_exception;


        %do j = 1 %to &keyvarscnt;
            %let idvar = %scan(&keyvars,&j," ");
            %if %upcase(&idvar) ne %upcase(&subjectvar) %then %do;
                define &idvar/id;
            %end;
        %end;

        ** all variables begin with __(double undersocre) will not printed **;
        define __:/noprint;
        define __n/order noprint;

        define _numeric_ / display;

        ** hide the borders of the empty row **;
        %if &nobs = 0 %then %do;
            define _all_ / 
                style(column)=[
                    bordertopwidth       = 1
                    borderbottomwidth    = 0 
                    borderleftwidth      = 0 
                    borderrightwidth     = 0
                    bordertopcolor       = colors('border')
                    borderbottomcolor    = white 
                    borderleftcolor      = white 
                    borderrightcolor     = white
                ];
        %end;


        %if &compare = Y %then %do;
            %do j = 1 %to &nchgvar;
                %if "&&marker&j" = "+" %then %do;
                define &&chgvar&j / style(header)=[backgroundcolor=&newcolor];
                %end;
            %end;

            %do j = 1 %to &nchglbl;
                define &&chglblvar&j / "&&lbl&j" style(header)=[backgroundcolor=&mdfvarcolor];
            %end;
        %end;

        ** interface for user to customize compute block **;
        %prt_compute_exception;

        %if &nobs = 0 and &isDelRecExist = 0 %then %do;
        compute before/style=linecontent{just=c};
            line "&nodatatext";
        endcomp;
        %end;
        %else %if &ods = PS or &ods = PDF %then %do;
        compute after/style=linecontent{padding=0 fontsize=1pt};
            line @1 " ";
        endcomp;
        %end;


        ** color code for compare result;
        %if &compare = Y %then %do;
        compute __type__;
            if __type__ = 'M' then call define(_row_, 'style', "style=[backgroundcolor=&mdfcolor]");
            if __type__ = 'N' then call define(_row_, 'style', "style=[backgroundcolor=&newcolor]");
        endcomp;

        compute __mdfnum__;
            length __seg__ $512;
            length __varname__ $32;
            length __value__ $256;
            length __flyover__ $512;
            if __type__ = 'M' then do i = 1 to __mdfnum__;
                __seg__     = scan(__diff__, i, &dlmcompare);
                __varname__ = upcase(scan(__seg__, 1, ':'));
                __value__   = substr(__seg__, index(__seg__, ':')+1);
                
                if __value__ = ' ' then __value__ = '<BLANK>';
                __value__   = tranwrd(__value__, "'", "''");
                __flyover__ = "flyover='"||strip(__value__)||"'";
                
                %if &ods = RTF %then %do;
                __flyover__ = ' ';
                %end;
                %else %if &ods = PS %then %do;
                /* Ken Cao on 2015/05/31: 
                    Somehow, in ODS PS, if flyover text contains round bracket,
                    it will cause problem and it has to be escaped using back slah.
                */;
                __flyover__ = prxchange('s/\(/\(/', -1, __flyover__);
                __flyover__ = prxchange('s/\)/\)/', -1, __flyover__);
                %end;
                
                if __varname__ ^= "%upcase(&subjectvar)" then do;
                    call define(strip(__varname__), 'style', "style=[backgroundcolor=&mdfvarcolor "||strip(__flyover__)||']');
                end;
            end;
        endcomp;

        ** for deleted record;
        %if &showDeletedRecord = Y %then %do;
        compute ___deleted;
            if ___deleted = 'Y' then call define(_row_, 'style', "style=[backgroundcolor=&delcolor textdecoration=line_through]");
        endcomp;
        %end;
        %end;



        ** insert table caption;
        compute before _page_ / style=LineContentBefore{
            /*
            %if &ods = PS or &ods = PDF %then %do;
            bordertopcolor=white 
            %end;
            %else %if &ods = RTF %then %do;
            borderleftwidth=1 borderrightwidth=1 bordertopwidth = 1 borderbottomwidth=1
            borderleftcolor=colors('border') borderrightcolor=colors('border') bordertopcolor=colors('border') borderbottomcolor=colors('border')
            %end;
            */
            borderbottomwidth = 1
            borderbottomcolor = colors('border')
            };

            %if &ods = PDF %then %do;
            line " ";
            line " ";
            %end;
            %else %if &ods = PS %then %do;
            line " ";
            line "&escapeChar{style [foreground=white fontsize=1pt]  }";
            line "&escapeChar{style [foreground=white fontsize=1pt]##TABLE HEADER - &label - TABLE HEADER##}";
            %end;

            line "&escapeChar{style [fontsize=&tableheadersize foreground=&tableheadercolor fontweight=bold]&label}";

            %do j = 1 %to &ndsetHeader;
            %if &j = 1 %then line " " ;;
            line "&&dsetHeader&j";
            %end;
        endcomp;
        
        %if &ndsetFooter > 0 %then %do;
        compute after _page_ / style=LineContentAfter{
            /*
            %if &ods = PDF or &ods = PS %then %do;
            borderbottomcolor=white bordertopcolor=white
            %end;
            %else %if &ods = RTF %then %do;
            vjust = center
            %end;
            */
            bordertopcolor = colors('border')
            bordertopwidth = 1
            };
            %do j = 1 %to &ndsetFooter;
            line "&&dsetFooter&j";
            %end;
        endcomp;
        %end;
    run;

%ENDREPORT: %end;

ods &ods close;

%if &ods ^= PS %then %return;

** extract page number infomation of each dataset;
%local rc;
%local filrf;
%local filrfin;
%local filrfout;
%local totpage;

%let  filrfin = _ps1_;
%let filrfout = _ps2_;
%let    filrf = _ps_;
%let       rc = %sysfunc(filename(filrfin, &tempdir\temp.ps));
%let       rc = %sysfunc(filename(filrfout, &outputdir\&prefix._&studyid._&subj..ps));
%let   totpage = 0;

data _bookmark;
    infile &filrfin lrecl = 32767;
    input;
    length title _title_ $255 ;
    retain pgnum ord title _title_;
    if _n_ = 1 then do;
        pgnum = 0;
        ord = 0;
    end;
    if index(_infile_, '%%Page:') = 1 then pgnum = input(scan(_infile_, 2, ': '), best.);
    if prxmatch('/M \(##TABLE HEADER - .* - TABLE HEADER##\) S/', _infile_) then do;
        title = prxchange('s/(.*)M \(##TABLE HEADER - (.*) - TABLE HEADER##\) S/$2/', -1, _infile_);
        title = tranwrd(title, '\(', '(');
        title = tranwrd(title, '\)', ')');
        if title ^= _title_ then do;
            ord = ord + 1;
            _title_ = title;
            output;
        end;
    end;
    /* sometimes the header is too long*/
    else if prxmatch('/M \(##TABLE HEADER - .*\) S/', _infile_) then do;
        title = prxchange('s/(.*)M \(##TABLE HEADER - (.*)\) S/$2/', -1, _infile_);
        title = tranwrd(title, '\(', '(');
        title = tranwrd(title, '\)', ')');
        put "Header is split into two lines. "  title=;
    end;
    else if prxmatch('/M \(.* - TABLE HEADER##\) S/', _infile_) then do;
        title = strip(title) || prxchange('s/(.*)M \((.*) - TABLE HEADER##\) S/$2/', -1, _infile_);
        title = tranwrd(title, '\(', '(');
        title = tranwrd(title, '\)', ')');
        put "Header is split into two lines. "  title=;
        ord = ord + 1;
        _title_ = title;
        output;
    end;
    if prxmatch('/^%%Pages: \d+$/', _infile_) then do;
        call symput('totpage', strip(prxchange('s/^%%Pages: (\d+)$/$1/', -1, _infile_)));
    end;
    keep pgnum title ord;
run;


%if &showCoverPage = Y %then %let totpage = %eval(&totpage - 1);

data _null_;
    infile &filrfin lrecl = 32767 truncover ;
    file &filrfout lrecl = 32767 ;
    input line $32767.;
    length line : $32767;
    if prxmatch('/Page \d+ of !#!/', _infile_) then do;
        %if %length(&totpage) = 1 %then %do;
        line = prxchange("s/Page (\d+) of !#!/  Page $1 of &totpage/", -1, _infile_);
        %end;
        %else %if %length(&totpage) = 2 %then %do;
        line = prxchange("s/Page (\d+) of !#!/ Page $1 of &totpage/", -1, _infile_);
        %end;
        %else %if %length(&totpage) = 3 %then %do;;
        line = prxchange("s/Page (\d+) of !#!/Page $1 of &totpage/", -1, _infile_);
        %end;
        %else %do;
        %put WARN&blank.ING: Total page number exceeds maximum limits (999).;
        line = prxchange("s/Page (\d+) of !#!/Page $1 of &totpage/", -1, _infile_);
        %end;
    end;
    else line = _infile_;
    len = length(line);
    put line :$varying32767. len;
run;

data _null_;
    file &filrfout mod;
    set _bookmark end = _eof_;
    coord = '21.6 315.8';
    put "[/Title (" title ") /Page " pgnum "/View [/XYZ " coord "null] /OUT pdfmark";
    if _eof_ then do;
        put '[/PageMode /UseOutlines /Page 1 /DOCVIEW pdfmark';
        put '[/DOCINFO pdfmark';
    end;
run;

%let rc = %sysfunc(filename(filrfin));
%let rc = %sysfunc(filename(filrfout));

%mend printSubject;
