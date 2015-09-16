/******************************************************************************

macro: insertDMTitleFooter.sas
    @Author: Ken Cao (yong.cao@q2bi.com)
    @Initial Date: 2014/12/02

    This macro inserts titles and footnotes from demographics dataset

******************************************************************************/

%macro insertDMTitleFooter(subject,demodset);

%local existFooter;
%local existTitle;


%let demodset = %scan(&demodset,1,());


** determine whether title/footnotes existed in demographic dataset **;

%let existFooter   = 0;
%let existTitle    = 0;


data _null_;
    set &PDATALIBRF..&demodset;
    if _n_ = 1 then do;
        pidt=prxparse('/^__TITLE\d?[LCR]?$/i');
        pidf=prxparse('/^__FOOTNOTE\d?[LCR]?$/i');

        array ___char{*} _character_; ** demographics dataset must contain at least one character variable (subject) **;
        do i = 1 to dim(___char);
            if prxmatch(pidt,strip(vname(___char[i]))) = 1 then call symput('existTitle','1');
            else if prxmatch(pidf,strip(vname(___char[i])))>0 then call symput('existFooter','1');
        end;
        stop;
    end;
run;

%if &existTitle = 0 and &existFooter = 0 %then %return;

data _dmhdrft0;
    retain pidt pidf pidtl pidfl pidtc pidfc pidtr pidfr;
    if _n_ = 1 then do;
        pidt=prxparse('/^__TITLE\d?[LCR]?$/i');
        pidf=prxparse('/^__FOOTNOTE\d?[LCR]?$/i');
        pidtl=prxparse('/^__TITLE\d?[L]?$/i');
        pidfl=prxparse('/^__FOOTNOTE\d?[L]?$/i');
        pidtc=prxparse('/^__TITLE\d?C$/i');
        pidfc=prxparse('/^__FOOTNOTE\d?C$/i');
        pidtr=prxparse('/^__TITLE\d?R$/i');
        pidfr=prxparse('/^__FOOTNOTE\d?R$/i');
    end;

    set &PDATALIBRF..&demodset;
    where &subjectvar="&subject";


    length type $1 left center right $1024;

    ** collect all titles **;
    %if &existTitle = 1 %then %do;
        array _titlearray_ {*} $ __title:;
        do i = 1 to dim(_titlearray_);
 
            call missing(left, center, right);

            if prxmatch(pidt, strip(vname(_titlearray_[i]))) = 0 then continue;
            else if _titlearray_[i] = ' ' then continue;
            type = 'T';

            if prxmatch(pidtl, strip(vname(_titlearray_[i]))) = 1 then do;
                left = _titlearray_[i];
            end;
            else if prxmatch(pidtc, strip(vname(_titlearray_[i]))) = 1 then do;
                center = _titlearray_[i];
            end; 
            else if prxmatch(pidtr, strip(vname(_titlearray_[i]))) = 1 then do;
                right = _titlearray_[i];
            end; 

            if prxchange('s/__TITLE(\d?)[LCR]?/$1/i', -1, strip(vname(_titlearray_[i]))) ^= ' ' then 
                seq = input(prxchange('s/__TITLE(\d?)[LCR]?/$1/i', -1, strip(vname(_titlearray_[i]))), best.) / 10 + 3;
            else seq = 3;
            output;
        end;
    %end;

    ** collect all footnote **;
    %if &existFooter = 1 %then %do;
        array _footerarray_ {*} $ __footnote:;
        do i=1 to dim(_footerarray_);

            call missing(left, center, right);

            if prxmatch(pidf, strip(vname(_footerarray_[i]))) = 0 then continue; 
            else if _footerarray_[i] = ' ' then continue;
            type = 'F';

            if prxmatch(pidfl, strip(vname(_footerarray_[i]))) = 1 then do;
                left = _footerarray_[i];
            end;
            else if prxmatch(pidfc, strip(vname(_footerarray_[i]))) = 1 then do;
                center = _footerarray_[i];
            end; 
            else if prxmatch(pidfr, strip(vname(_footerarray_[i]))) = 1 then do;
                right = _footerarray_[i];
            end; 

            if prxchange('s/__FOOTNOTE(\d?)[LCR]?/$1/i', -1, strip(vname(_footerarray_[i]))) ^= ' ' then 
                seq = input(prxchange('s/__FOOTNOTE(\d?)[LCR]?/$1/i', -1, strip(vname(_footerarray_[i]))), best.) / 10 + 2;
            else seq = 2;
            output;
        end;
    %end;
run;

data _dmhdrft1;
    retain pidlbl pidval pidlble pidvale;
    if _n_ = 1 then do;
        pidlbl = prxparse('/\[\w+\]/');
        pidval = prxparse('/<\w+>/');
        pidlble = prxparse('/\\\[\w+\\\]/');
        pidvale = prxparse('/\\<\w+\\>/');
    end;
    set _dmhdrft0;

    array _headfoot{*} left center right;
    length  __varname $1024 __varlbl __value $1024 __left __right $1024;
    
    __dsid = open("&PDATALIBRF..&demodset");

    do i = 1 to dim(_headfoot);
        if _headfoot[i] = ' ' then continue;

        
        if prxmatch(pidlbl, _headfoot[i]) = 0  
           and prxmatch(pidval, _headfoot[i]) = 0 then goto ESCAPE;

        ** resolve [VARNAME] to Variable Label;
        start = 1;
        stop = length(_headfoot[i]);
        call prxnext(pidlbl, start, stop, _headfoot[i], position, length);
        do while(position > 0);
            __varname = substr(_headfoot[i], position+1, length - 2);
            if prxmatch('/^[_a-z][a-z0-9_]{0,31}$/i', trim(__varname)) then do;
                __varnum = varnum(__dsid, __varname);
                put __varname= length=;
                if __varnum > 0 then do;
                    __varlbl = "&escapeChar.{style [fontweight=bold]"||trim(varlabel(__dsid, __varnum))||'}';
                    __left = substr(_headfoot[i], 1, position);
                    __right = substr(_headfoot[i], position+length);
                    if position > 1  then _headfoot[i] = substr(__left, 1, position-1)||trim(__varlbl)||__right;
                    else _headfoot[i] = trim(__varlbl)||__right;
                    put _headfoot[i]=;
                    position = position + length(__varlbl) - length;
                end;
            end;
            stop = length(_headfoot[i]);
            call prxnext(pidlbl, start, stop, _headfoot[i], position, length);
        end;


        ** resolve <VARNAME> to variable value;
        start = 1;
        stop = length(_headfoot[i]);
        call prxnext(pidval, start, stop, _headfoot[i], position, length);
        do while(position > 0);
            __varname = substr(_headfoot[i], position+1, length - 2);
            if prxmatch('/^[_a-z][a-z0-9_]{0,31}$/i', trim(__varname))  then do;
                __varnum = varnum(__dsid, __varname);
                if __varnum > 0 then do;
                    __value = vvaluex(__varname);
                    __left = substr(_headfoot[i], 1, position);
                    __right = substr(_headfoot[i], position+length);
                    if position > 1 then _headfoot[i] = substr(__left, 1, position-1)||trim(__value)||__right;
                    else _headfoot[i] = trim(__value)||__right;
                    position = position + length(__value) - length;
                end;
            end;
            stop = length(_headfoot[i]);
            call prxnext(pidval, start, stop, _headfoot[i], position, length);
        end;

    ESCAPE:
        if prxmatch(pidlble, _headfoot[i]) then do;
            _headfoot[i] = prxchange('s/\\\[/[/', -1, _headfoot[i]);
            _headfoot[i] = prxchange('s/\\\]/]/', -1, _headfoot[i]);
        end;
        if prxmatch(pidvale, _headfoot[i]) then do;
            _headfoot[i] = prxchange('s/\\</</', -1, _headfoot[i]);
            _headfoot[i] = prxchange('s/\\>/>/', -1, _headfoot[i]);
        end;
    end;


    __rc = close(__dsid);

   keep type left center right seq;
run;


proc sort data = _dmhdrft1; by type seq; run;

data _dmhdrft;
    set _dmhdrft1;
        by type seq;
    length _left_ _center_ _right_ $1024;
    retain _left_ _center_ _right_;
    if first.seq then do;
        _left_ = left;
        _center_ = center;
        _right_ = right;
    end;
    else do;
        _left_ = coalescec(_left_, left);
        _center_ = coalescec(_center_, center);
        _right_ = coalescec(_right_, right);
    end;
    if last.seq then do;
        left = _left_  ;
        center = _center_ ;
        right = _right_;
        seq = int(seq);
        output;
    end;


    drop _left_ _center_ _right_;
run;


proc append base = _headft data = _dmhdrft nowarn force; run;

%mend insertDMTitleFooter;
