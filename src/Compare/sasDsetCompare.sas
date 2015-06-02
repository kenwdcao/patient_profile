/***********************************************************************************************************
 Program: sasDsetCompare.sas
    @Author: Ken Cao (yong.cao@q2bi.com)
    @Initial Date: 2014/12/23

 
 This is a all-in-one SAS macros to compare SAS datasets in different versions.



 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 Paramter: 

    OLDDIR: Required. Directory of old datasets (base).
    NEWDIR: Required. Directory of new datasets (compare).
    OUTDIR: Required when parameter genReport is se to Y or parameter REPLACE is set to N.
   REPLACE: Optional. Default value is N. When set to Y, compare result will be appended to datasets 
            in NEWDIR. When set to N, compare result will be generated in OUTDIR.
 GENREPORT: Optional. Default value is Y. When set to Y, a summary report will be generated.
    CONFIG: Optional. User can define key variables and compare variables (variables to be compared) for 
            individual dataset.

 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 Revision History:
    2014/12/26 Ken Cao: Add dataset duplication checking. When duplication detected, dataset name will be 
                        marked with a asterisk (a corresponding footnote will be added).
    2015/02/25 Ken Cao: Keep dataset label in output dataset.
    2015/03/17 Ken Cao: Expand summary report to subject level.
    2015/05/19 Ken Cao: Fix a error in concatenating added/deleted varaibles.


 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 Example:



***********************************************************************************************************/



%macro sasDsetCompare(olddir=, newdir=, genReport=Y, outdir=, config=);

%local blank;
%local isErr;

%let blank =;
%let isErr = 0;


******************************************************************************;
* general-purpose macros
******************************************************************************;

** return # of observations of a SAS dataset;
%local nobs;
%macro getNOBS(data);

%local dsid;
%local rc;

%let nobs = 0; ** initialiation;

%let dsid = %sysfunc(open(&data));
%if &dsid = 0 %then %do;
    %put %sysfunc(sysmsg());
    %return;
%end;
%let nobs = %sysfunc(attrn(&dsid, nlobsf));

%let rc = %sysfunc(close(&dsid));
%mend getNOBS;



* returns dataset label of a SAS dataset;
%local dsetlbl;
%macro getDsetLabel(data);

%local dsid;
%local rc;

%let dsid = %sysfunc(open(&data));
%if &dsid = 0 %then %do;
    %put %sysfunc(sysmsg());
    %return;
%end;
%let dsetlbl = %sysfunc(attrc(&dsid, label));

%let rc = %sysfunc(close(&dsid));
%mend getDsetLabel;



** generate hash value (using SAS function MD5()) based on specified variables;
%macro GenHash(varlist);

%local nvar;
%local i;
%local var;
%local concat;


** compress blank spaces and remove leading blank;
%let varlist = %sysfunc(prxchange(s/\s+/ /, -1, &varlist));
%let varlist = %sysfunc(prxchange(s/^\s+//, -1, &varlist));


%if %length(&varlist) = 0 %then %do;
    call symput('isErr', '1');
    put "ERR" "OR: Hash value could not be generated due to no variables specified.";
    return;
%end;

%let varlist = %sysfunc(strip(&varlist));

%let nvar   = 0;
%let nvar   = %eval(%sysfunc(countc(&varlist, " ")) + 1);
%let concat = ' ';

%do i = 1 %to &nvar;
    %let var    = %scan(&varlist, &i, " ");
    %let concat = &concat||'01'x||strip(vvalue(&var));
%end;

___hash = put(md5(strip(&concat)), $hex32.);    

drop ___hash;

%mend GenHash;



** Ken Cao on 2015/02/07: Add a parameter REPLACE;
%macro chkYN(mvar, mval, default);
    %let default = %upcase(&default);
    %if &mval ne Y and &mval ne N %then %do;
        %put WARN&blank.ING: Invalid value of parameter %upcase(&mvar). %upcase(&mvar) will be set as &default;
        %let &mvar = &default;
    %end;
%mend chkYN;



******************************************************************************;
* deal with apparent E R R O R S
******************************************************************************;

** check required parameters;
%if %length(&olddir) = 0 %then %do;
    %put ERR&blank.OR: Required parameter OLDDIR is blank.;
    %return;
%end;

%if %length(&newdir) = 0 %then %do;
    %put ERR&blank.OR: Required parameter NEWDIR is blank.;
    %return;
%end;

%if %length(&outdir) = 0 and &genReport = Y %then %do;
    %if &genReport = Y %then %put ERR&blank.OR: Parameter genReport is set to Y while OUTDIR is blank.;
    %return;
%end;


** check existence of directories;
%local isDirExist;
%macro IsDirExist(dir);
* return 1 if direcotry exists, 0 if not;
* return variable isDirExist;
%let IsDirExist = 1;
%mend IsDirExist;

%isDirExist(&olddir);
%if &isDirExist = 0 %then %do;
    %put ERR&blank.OR: Directory(OLDDIR) &olddir does not exists!;
    %return;
%end;

%isDirExist(&newdir);
%if &isDirExist = 0 %then %do;
    %put ERR&blank.OR: Directory(NEWDIR) &newdir does not exists!;
    %return;
%end;

%if %length(&outdir) > 0 %then %do;
    %isDirExist(&outdir);
    %if &isDirExist = 0 %then %do;
        %put ERR&blank.OR: Directory(OUTDIR) &outdir does not exists!;
        %return;
    %end;
%end;





******************************************************************************;
* get dataset name list
******************************************************************************;

libname __old "&olddir";
libname __new "&newdir";

%if %length(&outdir) > 0 %then %do;
libname __out "&outdir";
%end;

%local ndset;
%local i;

** _VCOLUMN contains all dataset names and variable names for dataset in __NEW;
proc contents data=__new._all_ out=_vcolumn(keep=memname name label) noprint;
run;

** _TABLE contains all dataset names for dataset in __NEW;
proc sort data = _vcolumn out = _vtable(keep=memname) nodupkey; 
    by memname;
run;

** _VCOLUMN contains all dataset names for dataset in __OLD;
proc contents data=__old._all_ out=_vcolumnOLD(keep=memname name label) noprint;
run;

** _TABLE contains all dataset names for dataset in __OLD;
proc sort data = _vcolumnOLD out = _vtableOLD(keep=memname) nodupkey; 
    by memname;
run;


%getNOBS(_vtable);
%let ndset = &nobs;
%let nobs = 0;

%do i = 1 %to &ndset;
    %local dset&i;
%end;

data _null_;
    set _vtable;
    call symput('dset'||strip(put(_n_, best.)), strip(upcase(memname)));
run;




******************************************************************************;
* import configuration file ;
******************************************************************************;

data _compcfg0;
    length dsetname $32 keyvars $1024 compvars $1024;
    call missing(dsetname, keyvars, compvars);
    if 0;
run;

%macro readCFG(config);

%local rc;
%local filrf;   
%local maxlen;  ** maximum length of a line in configuration file;

%let filrf  = cfg;
%let maxlen = 32767;

%if %length(&config) = 0 %then %return; ** no configuration file specified;
%let rc = %sysfunc(filename(filrf, &config));



data _compcfg0(compress=yes);
    infile &filrf lrecl = &maxlen;
    length line $&maxlen;
    informat line $&maxlen..;
    input line;

    *******************************************************************;
    * <SAS-DATASET-NAME>: <KEY VARAIBLES>: <VARIABLES TO BE COMPARED>
    *
    * Example 1 - Use USUBJID and AESPID as key variables, variables 
    * to be compared are AETERM, AESTDTC and AEENDTC:
    * AE: USUBJID AESPID : AETERM AESTDTC AEENDTC 
    *
    * Example 2 - Use USUBIJID and AESPID as key variables, compare
    * all (other) variables
    * AE: USUBJID AESPID :
    *
    * Example 3 - Leave key variables and compare variables blank. In 
    * this case, any modification will be treated as new reocrds. The 
    * output can only point out new records.
    * AE: :
    *
    * Example 4 - Specify AETERM as compare variable, leave key variable
    * blank. In this case, program will use variables other than AETERM
    * to generate key hash and use AETERM to generate value hash.
    * AE: : AETERM
    *
    * Special NOTE for example 04: Use it with caution because it may
    * lead to uncessary duplicate.
    *
    * Skip any blank line or line starting with * (comment);
    *******************************************************************;
    line = upcase(strip(_infile_));
    if length(line) = 0 or substr(line, 1, 1) = '*' then return;
    
    retain pid;
    if _n_ = 1 then pid = prxparse('/\w+\s*:\s*(\w+\s*)*(\w+\s*)?:\s*(\w+\s*)*(\w+\s*)?/');
    ** if a incorrect-syntax line encounterred, skip this line and put a E R R O R message;
    if prxmatch(pid , line) = 0 then do; 
        put "ERR" "OR: Configuation synatax is incorrect: " line;
        return;
    end; 

    length dsetname $32 keyvars $32767 compvars $32767;
    keep dsetname keyvars compvars;

    dsetname = scan(line, 1, ':');
    keyvars  = scan(line, 2, ':');
    compvars = scan(line, 3, ':');

    
    /*
    ** skip rows that has compare variables but does not has key variables;
    if keyvars = ' ' and compvars > ' ' then do;
        put "WARN" "ING: It is not allowed to specify compared variables without key variables --- " @@;
        put line;
        delete;
    end;
    */
run;
%mend readCFG;

%readCFG(&config);

data _compcfg(compress=yes);
    set _compcfg0;
    nkey = 0; ** # of key variables;
    ncomp = 0; ** # of compare variables;

    ** convert dataset/variable name to upper case;
    dsetname = upcase(dsetname);
    keyvars  = upcase(keyvars);
    compvars = upcase(compvars);


    ** compress blank spaces and remove leading blank;
    keyvars  = prxchange('s/\s+/ /', -1, keyvars);
    compvars = prxchange('s/\s+/ /', -1, compvars);
    keyvars  = strip(keyvars);
    compvars = strip(compvars);

    if keyvars > ' ' then nkey  = countc(strip(keyvars), " ") + 1;
    if compvars > ' ' then ncomp = countc(strip(compvars), " ") + 1;
run;



** check configuration file;
data _null_;
    length memname $32 name $32;
    if _n_ = 1 then do;
        declare hash h1 (dataset:'_vtable');
        rc1 = h1.defineKey('memname');
        rc1 = h1.defineDone();
        declare hash h2 (dataset:'_vcolumn');
        rc2 = h2.defineKey('memname', 'name');
        rc2 = h2.defineDone();
        call missing(memname,name);
    end;
    set _compcfg;
    memname = dsetname;
    rc1 = h1.find();
    ** if incorrect dataset name;
    if rc1 > 0 then do;
        put "ERR" "OR: Dataset " memname "not found in &newdir";
        call symput("isErr", "1");
        return;
    end;
    
    nkey = 0;
    rc2 = h2.find();
   
    length allvars $2048 var $32;
    allvars = strip(keyvars)||' '||compvars;

    put allvars=;

    do i = 1 to nkey+ncomp;
        var = scan(allvars, i, " ");
        name = var;
        put var = ;
        rc2 = h2.find();
        if rc2 > 0 then do;
            put "ERR" "OR: Inv" "alid configuration: DATASET=" memname "VARIABLE=" var;
            call symput("isErr", "1");
            return;
        end;
    end;
run;

%if &isErr = 1 %then %return;




******************************************************************************;
* compare datasets one by one.
******************************************************************************;
%local renamecompvarsnew;
%local renamecompvarsold;
%local var;
%local j;
%local dup;
%local dupkey;

%local keyvars;
%local nkey;
%macro getKey(data);
%let nkey = 0;
%let keyvars =;
data _null_;
    set _compcfg;
    where upcase(dsetname) = "%upcase(&data)";
    call symput('nkey', strip(put(nkey, best.)));
    call symput('keyvars', strip(upcase(keyvars)));
run;

%if %length(&keyvars) > 0 %then %let keyvars = %sysfunc(strip(&keyvars)); ** remove trailing blanks;
%mend getKey;


%local compvars;
%local ncomp;
%macro getComp(data);
%let ncomp = 0;
%let compvars =;
data _null_;
    set _compcfg;
    where upcase(dsetname) = "%upcase(&data)";
    call symput('ncomp', strip(put(ncomp, best.))); 
    call symput('compvars', strip(upcase(compvars))); 
run;
%if %length(&compvars) > 0 %then %let compvars = %sysfunc(strip(&compvars)); ** remove trailing blanks;
%mend getComp;


** Ken Cao on 2015/02/07: Only get variables that exists in both datasets;
%local allvars;
%local nvar;
%macro getAllvars(data);
%let nvar = 0;
%let allvars =;

%let data = %upcase(%sysfunc(strip(&data)));

proc sql;
    create table _allvars as
    select a.name
    from _vcolumn as a
    where a.memname = "&data"
        and exists (
            select name
            from _vcolumnold as b
            where b.memname = "&data"
                and b.name = a.name
            );
quit;

data _null_;
    set _allvars end = _eof_;
    where name  ^=: '__' /* Ken Cao on 2015/02/08: Trying to exclude variables starts with double underscore */
    /*
    not in (
    '___RECHASH',
    '___VALHASH',
    '___KEYHASH',
    '__TYPE__',
    '__DIFF__',
    )
    */
    ;
    nvar+1;
    length allvars $32767;
    retain allvars;
    allvars = strip(allvars)||' '||name;
    if _eof_ then do;
        call symput('nvar', strip(put(nvar, best.))); 
        call symput('allvars', strip(upcase(allvars))); 
    end;
run;

%if %length(&allvars) > 0 %then %let allvars = %sysfunc(strip(&allvars)); ** remove trailing blanks;
%mend getAllvars;


%local addedvars;
%local naddedvar;
%macro getAddedVars(data);
%let addedvars =;
%let naddedvar = 0;

proc sql;
    create table _addedvars0 as
    select a.name
    from _vcolumn as a
    where a.memname = "&data"
        and not exists (
            select name
            from _vcolumnold as b
            where b.memname = "&data"
                and b.name = a.name
            );
quit;

data _addedvars;
    set _addedvars0 end = _eof_;
    where name  ^=: '__';

    nvar+1;
    length addedvars $1024;
    retain addedvars;
    addedvars = strip(addedvars)||ifc(addedvars^=' ', &dlmcompare, ' ')||strip(name)||'(+)';
    if _eof_ then do;
        call symput('naddedvar', strip(put(nvar, best.))); 
        call symput('addedvars', strip(upcase(addedvars)));
        output; 
    end;

    keep addedvars;
    rename addedvars = __addedvars__;
run;

%if %length(&addedvars) > 0 %then %let addedvars = %sysfunc(strip(&addedvars)); ** remove trailing blanks;
%mend getAddedVars;


%local delvars;
%local ndelvar;
%macro getDelVars(data);
%let delvars = ;
%let ndelvar = 0;

proc sql;
    create table _delvars0 as
    select a.name
    from _vcolumnold as a
    where a.memname = "&data"
        and not exists (
            select name
            from _vcolumn as b
            where b.memname = "&data"
                and b.name = a.name
            );
quit;

data _delvars;
    set _delvars0 end = _eof_;
    where name  ^=: '__';

    nvar+1;
    length delvars $1024;
    retain delvars;
    delvars = strip(delvars)||ifc(delvars ^= ' ', &dlmcompare, ' ')||strip(name)||'(-)';
    if _eof_ then do;
        call symput('ndelvar', strip(put(nvar, best.))); 
        call symput('delvars', strip(upcase(delvars))); 
        output;
    end;

    keep delvars;
    rename delvars = __delvars__;
run;


%if %length(&delvars) > 0 %then %let delvars = %sysfunc(strip(&delvars)); ** remove trailing blanks;
%mend getDelVars;


%local chglbl;
%local nchglbl;
%macro getChgLBL(data);
%let  chglbl = ;
%let nchglbl = 0;

proc sql;
    create table _chglbl0 as
    select a.name, a.label as labelnew, b.label as labelold
    from _vcolumn as a,
          _vcolumnold as b
    where a.memname = "&data"
    and b.memname = "&data"
    and b.name = a.name
    and a.label ^= b.label;
quit;


data _chglbl;
    set _chglbl0 end = _eof_;
    where name  ^=: '__';

    nvar+1;
    length chglbl $4096;
    retain chglbl;
    labelold = prxchange('s/["]/""/', -1, labelold);
    labelnew = prxchange('s/["]/""/', -1, labelnew);
    chglbl = ifc(chglbl = ' ', strip(name)||':'||"&escapeChar.S={flyover='"||strip(labelold)||"'}"||labelnew,
            strip(chglbl)||&dlmcompare||strip(name)||':'||"&escapeChar.S={flyover='"||strip(labelold)||"'}"||labelnew);
    if _eof_ then do;
        call symput('nchglbl', strip(put(nvar, best.))); 
        call symput('chglbl', strip(chglbl)); 
        output;
    end;

    keep chglbl;
    rename chglbl = __chglbl__;
run;

%if %length(&chglbl) > 0 %then %let chglbl = %sysfunc(strip(&chglbl)); ** remove trailing blanks;
%mend getChgLBL;


** get dataset label;
%local label;
%macro getDsetLabel(data);
%local dsid;
%local rc;

%let label =;

%let  dsid = %sysfunc(open(&data));
%let label = %bquote(%sysfunc(attrc(&dsid, label)));
%let    rc = %sysfunc(close(&dsid));

%put &label;
%mend getDsetLabel;



** determine if dataset is subject-level;
%local isSubjectLevel;
%macro isSubjectLevel(data);
%local dsid;
%local varnum;
%local rc;

%let isSubjectLevel = 0;

%let   dsid = %sysfunc(open(&data));
%let varnum = %bquote(%sysfunc(varnum(&dsid, &subjectvar)));
%let     rc = %sysfunc(close(&dsid));

%if &varnum > 0 %then %let isSubjectLevel = 1;
%mend isSubjectLevel;

** output datasets - table of contents;
data _toc(compress=yes);
    length dsetname $33 memlabel $255 nobs 8 nobsold 8 newdsetfl $1 nnew 8 ndel 8 nmodify 8 keyvars $32767 compvars $32767 
           chgvars $1024 duplicate $1;
    label
         dsetname = 'Dataset'
         memlabel = 'Label'
             nobs = '# of Records in NEW'
          nobsold = '# of Records in OLD'
        newdsetfl = 'No Old Counterpart'
             nnew = 'New Records'
             ndel = "Deleted Record"
          nmodify = 'Modified Record'
          keyvars = 'Key Variable'
         compvars = 'Compared Variable'
          chgvars = 'Added(+)/Deleted(-) Variable'
        duplicate = "Flag of duplication"
    ;
    call missing(dsetname, memlabel, nobs, nobsold, newdsetfl, nnew, ndel, nmodify, keyvars, compvars, chgvars, duplicate);
    if 0;
run;


** output datasets - by subject;
data _subj0(compress=yes);
    length subject $255 dsetname $33 memlabel $255 nnew 8 ndel 8 nmodify 8;
    label
          subject = "Subject"
         dsetname = 'Dataset'
         memlabel = 'Label'
             nnew = 'New Record'
             ndel = 'Deleted Record'
          nmodify = 'Modified Record'
    ;
    call missing(subject, dsetname, memlabel, nnew, ndel, nmodify);
    if 0;
run;

data __del;
    length ndel 8  subject $255  dsetname $33;
    label 
            ndel = 'Deleted Record'
         subject = "Subject"
        dsetname = 'Dataset'
    ;
    if 0;
    call missing(subject, dsetname, ndel);
run;


%local nobsnew;  ** # of records in NEW;
%local nobsold;  ** # of records in OLD;

%do i = 1 %to &ndset;

    %getNOBS(__new.&&dset&i);
    %let nobsnew = &nobs;

    %getNOBS(__old.&&dset&i);
    %let nobsold = &nobs;

    %getKey(&&dset&i);
    %getComp(&&dset&i);

    %getAddedVars(&&dset&i);
    %getDelVars(&&dset&i);
    %getChgLBL(&&dset&i);

    %getDsetLabel(__new.&&dset&i);
    %let label = %bquote(%sysfunc(prxchange(s/[""]/""/, -1, %bquote(&label))));

    %isSubjectLevel(__new.&&dset&i);

    ***********************************************;
    * insert observation #, key variables, compare
    * variables.
    * other information will be updated later
    ***********************************************;
    proc sql;
        insert into _toc(dsetname, memlabel, nobs, nobsold, keyvars, compvars, chgvars)
        values("&&dset&i", "&label", &nobsnew, &nobsold, "&keyvars", "&compvars", "&addedvars &delvars");
    quit;


    ** dataset only exists in NEW directory;
    %if %sysfunc(exist(__old.&&dset&i)) = 0 %then %do;
        data __new.&&dset&i(compress=yes label="%bquote(&dsetlbl)");
            set __new.&&dset&i;
            length ____msg___ $2048;
            ____msg___ = "NEW DATASET";
        run;

        proc sql;
            update _toc
            set newdsetfl = 'Y'
            where dsetname = "&&dset&i";
        quit;


        proc sql;
            insert into _subj0(subject, dsetname, memlabel, nnew, nmodify)
            select  &subjectvar
                   ,"&&dset&i" 
                   ,"&label" 
                   ,count(*)
                   ,0
            from __new.&&dset&i
            group by &subjectvar;
        quit;

    %end;
    %else %do;
        ************************************************************************************;
        * CASE 1: Both key variables and compare variables are specified - Nothing needs
        * to be handled.
        *
        * CASE 2: Only key variables specified. - Use all variables as compare variables.
        *
        * CASE 3: Only compare variales specified. - Use all variables other than compare
        * variables as key variales.
        *
        * CASE 4: Both key variables and compare variables are not specified. - Use all
        * variables as both key variables and compare variables.
        ************************************************************************************;
        %getAllvars(&&dset&i);

        %if &nkey > 0 and &ncomp = 0 %then %do;
            %let compvars = &allvars;
            %let    ncomp = &nvar;
        %end;
        %else %if &nkey = 0 and &ncomp > 0 %then %do;
            %do j = 1 %to &nvar;
                %let var = %upcase(%scan(&allvar, &j, " "));
                %if %sysfunc(indexw("&compvars", "var", " ")) = 0 %then %do;
                    %let    nkey = %eval(&nkey + 1);
                    %let keyvars = &keyvars &var;
                %end;
            %end;

            %if %length(&keyvars) > 0 %then %let keyvars = %sysfunc(strip(&keyvars));
            %else %do;
                %put WARN&blank.ING: It seems that all variables specified as compare variables while no variables assigned as key variable;
                %put WARN&blank.ING In this case key variables will be automatically assigned as all variables;
                %let    nkey = &nvar;
                %let keyvars = &allvars;
            %end;
        %end;
        %else %if &nkey = 0 and &ncomp = 0 %then %do;
            %let compvars = &allvars;
            %let    ncomp = &nvar;
            %let  keyvars = &allvars;
            %let     nkey = &nvar;
        %end;


        ************************************************;
        * rename all compare variables so that NEW and 
        * OLD dataset can be merged together.
        ************************************************;

        %let renamecompvarsnew = ;
        %let renamecompvarsold = ;
        %do j = 1 %to &ncomp;
            %let var = %scan(&compvars, &j, " ");
            %let renamecompvarsnew = &renamecompvarsnew &var=___NEWVAR&j;
            %let renamecompvarsold = &renamecompvarsold &var=___OLDVAR&j;
        %end;



        /* Ken Cao on 2015/03/13: 
         * In some cases, key varaibles may start with double score. 
         * Those varaibles are excluded in macro %getAllvars.
         */

        %let allvars = &keyvars &compvars &allvars;

        ****************************************************************;
        * Use SAS function MD5() to generate hash value for both key 
        * variables and compare variables so that record between OLD and
        * NEW datasets can be compared by simple equality test.
        ****************************************************************;
        data _new(compress=yes index=(___keyhash) rename=(&renamecompvarsnew));
            set __new.&&dset&i;
            length ___rechash ___valhash ___keyhash ___hash $32;

            %GenHash(&allvars);
            ___rechash = ___hash;

            %GenHash(&compvars);
            ___valhash = ___hash;

            %GenHash(&keyvars);
            ___keyhash = ___hash;

            ___n___ = _n_;  ** to keep original order;

            keep ___keyhash ___valhash ___rechash &compvars ___n___;
        run;

        data _old(compress=yes index=(___keyhash) rename=(&renamecompvarsold  ___valhash=___valhash2));
            set __old.&&dset&i;
            length ___rechash ___valhash ___keyhash ___hash $32;

            %GenHash(&allvars);
            ___rechash = ___hash;

            %GenHash(&compvars);
            ___valhash = ___hash;

            %GenHash(&keyvars);
            ___keyhash = ___hash;

            ___n___ = _n_;  ** to keep original order;


            keep ___keyhash ___valhash ___rechash &compvars ___n___;
        run;


        ****************************************************************;
        * duplicate check
        * first check if dataset itself contains duplicate records.
        * then check if user specified key variables makes duplicate
        ****************************************************************;
        %let dup    = 0;
        %let dupkey = 0;

        proc sql noprint;
            select count(*) as n
            into: dup
            from _new
            group by ___rechash
            having n > 1;
        quit;

        %if &dup > 0 %then %do;
            %put WARN&blank.ING: Dataset &&dset&i contains duplicate records;
        %end;
        %else %do;
            proc sql noprint;
                select count(*) as n
                into: dupkey
                from _new
                group by ___keyhash
                having n > 1;
            quit;
            
            %if &dupkey > 0 %then %do;
                %put WARN&blank.ING: Under current settings, dataset &&dset&i contains duplicate records (KEY: &keyvars);
            %end;
        %end;

        %if &dup > 0 or &dupkey > 0 %then %do;
            %put WARN&blank.ING: When duplicate exists, compare result may be not accurate and even mis-leading.;
            proc sql;
                update _toc
                set 
                    duplicate = 'Y'
                where dsetname = "&&dset&i";
            quit;
        %end;


        data _compRslt(compress=yes);
            merge _new (in = _new)
                  _old (in = _old drop=___n___)
            ;

            by ___keyhash;

            if _new;
            
            length __type__ $1; ** record type (M=Modified, N=New.);
            length __diff__ $2048; ** tracking differences;
     
            if not _old then __type__ = 'N';
            else if ___valhash ^= ___valhash2 then __type__ = 'M';
  
            
            length __msg $256 __mdfnum__ 8;

            __mdfnum__ = 0; ** # of modifications;
            if __type__ ^= 'M' then return;

            %do j = 1 %to &ncomp;
                %let var = %upcase(%scan(&compvars, &j, " "));
                if ___newvar&j ^= ___oldvar&j then
                    do;
                        __mdfnum__ = __mdfnum__ + 1;
                         __msg  = "&var:"|| strip(vvalue(___oldvar&j));
                         __diff__ = ifc(__diff__ > ' ', strip(__diff__)||&dlmcompare||__msg, __msg);
                    end;
            %end;

            if __diff__ = ' ' then do;
                put 'ERR' "OR: Dataset: &&dset&i __type__ is set to M, but no report variables found different." @@;
                put ' Record ID: ' ___valhash;
            end;

            keep ___valhash ___keyhash __type__ __diff__  ___n___ __mdfnum__;
        run;

        proc sql;
            alter table _compRslt
            add __vars__ char length=2100,
                __chglbl__ char length=4100
            ;

            update _compRslt
            set __vars__ = (select strip(__addedvars__)||&dlmcompare||strip(__delvars__) from _addedvars, _delvars),
                __chglbl__ = (select __chglbl__ from _chglbl);

            
        quit;

        proc sort data = _compRslt; by ___n___; run;
        proc sort data = _old FORCE; by ___n___; run;


        ** Ken Cao on 2015/02/25: Keep dataset label;
        %getDsetLabel(__new.&&dset&i);
        %let dsetlbl = %bquote(%sysfunc(prxchange(s/[""]/""/,-1, &label)));

        data __new.&&dset&i;
            set __new.&&dset&i;
            call missing(___valhash, ___keyhash, __type__, __diff__,  ___n___, __mdfnum__, __vars__, __chglbl__);
            drop ___valhash ___keyhash __type__ __diff__  ___n___ __mdfnum__ __vars__ __chglbl__;
        run;

        data __new.&&dset&i(compress=yes label="%bquote(&dsetlbl)");
            set __new.&&dset&i;
            set _compRslt(drop=___n___);
        run;


        data __old.&&dset&i(compress=yes label="%bquote(&dsetlbl)");
            set __old.&&dset&i;
            set _old(drop=___n___ ___oldvar: rename=(___VALHASH2=___VALHASH));
        run;

        proc sql;
            update _toc
            set
                nnew    = (select count(*) from _compRslt where __type__ = 'N'),
                nmodify = (select count(*) from _compRslt where __type__ = 'M'),
                ndel    = (select count(*) from _old where ___keyhash not in (select distinct ___keyhash from _new))
            where dsetname = "&&dset&i";
            ;
        quit;
    %end;
    ** summary of compare result by subject;
    %if &isSubjectLevel = 1 %then %do;
        proc sql;
            insert into _subj0(subject, dsetname, nnew, nmodify)
            select  &subjectvar
                   ,"&&dset&i" 
                   ,count(ifn(__type__='N',1,.))
                   ,count(ifn(__type__='M',1,.))
            from __new.&&dset&i
            group by &subjectvar;

            insert into __del(ndel, subject, dsetname)
            select distinct count(*) as ndel, &subjectvar, "&&dset&i" 
            from __old.&&dset&i
            where ___keyhash not in 
                (select distinct ___keyhash from __new.&&dset&i)
            group by &subjectvar;
        quit;
    %end;
%end;

proc sort data = _subj0; by subject dsetname; run;
proc sort data = __del; by subject dsetname; run;

data _subj1;
    merge _subj0  __del(rename=(ndel=__ndel));
        by subject dsetname;
    ndel = __ndel;
    drop __ndel;
run;


proc sql;
    create table _subjdset as
    select distinct
        a.subject
       ,b.dsetname
       ,b.memlabel
    from _subj1 as a
    full join _toc as b
    on 1 = 1
    order by subject, dsetname;
quit;


data _subj2;
    merge _subj1 _subjdset;
        by subject dsetname;
    
    if nnew = . then nnew = 0;
    if ndel = . then ndel = 0;
    if nmodify = . then nmodify = 0;

run;





*** Flag new subjects ;
data _newsubj;
    set _subj2;
    where dsetname = "%upcase(%scan(&demodset, 1, ()))" and nnew > 0;
    keep subject;
run;

data _subj3;
    length subject $255 newsubjfl $1;
    if _n_ = 1 then do;
        declare hash h (dataset:'_newsubj');
        rc = h.defineKey('subject');
        rc = h.defineDone();
        call missing(subject);
    end;
    set _subj2;
    rc = h.find();
    if rc = 0 then do;
        subject = strip(subject)||'(New Subject)';
        newsubjfl = 'Y';
    end;
    drop rc;
run;


** use variable attribute of dataset _subj0;
data _subj;
    set _subj0(where=(0))
        _subj3 ;
run;


** insert table only existed in OLD directory;
proc sql;
    insert into _toc(dsetname)
    select distinct memname 
    from _vtableOLD
    where memname not in 
    (select distinct memname from _vtable);
quit;

proc sort data=_subj; by subject dsetname; run;

data _subjtoc;
    set _subj;
        by subject dsetname;
    if nnew = . then  nnew = 0;
    if nmodify = . then nmodify = 0;
    if ndel = . then ndel = 0;
    keep subject nnew nmodify ndel newsubjfl;
    retain _nmodify_ _nnew_ _ndel_;
    if first.subject then do;
        _nmodify_ = nmodify;
        _nnew_ = nnew;
        _ndel_ = ndel;
    end;
    else do;
        _nmodify_ = _nmodify_ + nmodify;
        _nnew_ = _nnew_ + nnew;
        _ndel_ = _ndel_ + ndel;
    end;
    if last.subject then do;
        nmodify = _nmodify_;
        nnew = _nnew_;
        ndel = _ndel_;
        output;
    end;
run;

************************************************;
** generate summary report
************************************************;
%if &genReport = N %then %goto EXIT;
%local ndup;
%let ndup = 0;


** put a aesterisk after dataset name to remind user of duplication;
data _toc;
    modify _toc;
    if duplicate = 'Y' then dsetname = strip(dsetname)||'*'; 
run;


proc sql noprint;
    select count(*) 
    into: ndup
    from _toc
    where index(dsetname, '*') > 0;
quit;


proc template;
    define style saswebc;
    parent = styles.sasweb;

    class table /
        fontsize=8pt
        width = 100%
    ;
    
    class header /
        background=cx4FADA1
        fontsize=8pt
    ;

    class data /
        fontsize=8pt
    ;

    class TitlesAndFooters /
        foreground = cx808080
    ;

    end;
run;

option orientation=landscape nonumber missing=" " nobyline;
ods _all_ close;
%if &ndup > 0 %then %do;
    footnote7 j=l height=7pt "*: Duplicate records detected";
%end;
footnote9 j=l height=7pt "New: &newtransferID";
footnote10 j=l height=7pt "Benchmark: &oldtransferID";
ods rtf file = "&outdir\__compare_summary_report.rtf" style=saswebc;
ods pdf file = "&outdir\__compare_summary_report.pdf" style=saswebc;

ods proclabel = "Table of Contents - Dataset";
title1 "Compare Result Summary Report - Dataset Summary";

proc report data = _toc nowd 
;
    column dsetname memlabel nobs nobsold newdsetfl nnew nmodify ndel keyvars compvars chgvars flag1 flag2;
    define dsetname / order;
    define newdsetfl / noprint;
    define flag1 / computed noprint;
    define flag2 / computed noprint;
    define nnew / display;
    define nmodify / display;
    define ndel / display;
    define nobs / display;
    define compvars / noprint;

    ** dataset only existed in NEW;
    compute newdsetfl;
        if newdsetfl = 'Y' then do;
            call define ('dsetname', 'style', 'style=[foreground=red fontweight=bold]');
            *call define('dsetname', 'style', 'style=[flyover="Only Existed in &newdir"]'); 
        end;
    endcomp;
    
    ** no any change;
    compute flag1 / character length=1;
        if nnew = 0 and nmodify = 0 and ndel =0 then flag1 = 'Y';
        if flag1 = 'Y' then do;
            call define(_row_, 'style', 'style=[background=#C5E0B3]'); 
            *call define('dsetname', 'style', 'style=[flyover="No Change"]'); 
        end;
    endcomp;

    ** dataset existed in OLD but not in NEW;
    compute flag2 / character length=1;
        if nobs = . then flag2 = 'Y';
        if flag2 = 'Y' then do;
            call define(_row_, 'style', 'style=[textdecoration=line_through fontstyle=italic background=#FFFF99]'); 
            *call define('dsetname', 'style', 'style=[flyover="Not Existed in &newdir"]'); 
        end;
    endcomp;

    compute ndel;
        if ndel > 0 then call define('ndel', 'style', 'style=[foreground=red]');
    endcomp;
run;


ods pdf columns = 2;
ods rtf columns = 2;
ods proclabel = "Table of Contents - Subject";
title1 "Compare Result Summary Report - Subject Summary";
proc report data=_subjtoc nowd;
    column subject  nnew nmodify ndel flag1 newsubjfl;
    define nnew / display;
    define nmodify / display;
    define ndel / display;
    define flag1 / noprint computed;
    define newsubjfl / noprint;

    compute flag1 / character length=1;
        if nnew = 0 and nmodify = 0 and ndel =0 then flag1 = 'Y';
        if flag1 = 'Y' then do;
            call define(_row_, 'style', 'style=[background=#C5E0B3]'); 
        end;
    endcomp;

    compute newsubjfl;
        if newsubjfl = 'Y' then call define('subject', 'style', 'style=[foreground=red]');
    endcomp;

    compute ndel;
        if ndel > 0 then call define('ndel', 'style', 'style=[foreground=red]');
    endcomp;
run;


ods pdf columns = 1;
ods rtf columns = 1;
ods proclabel = "By Subject";
title "#byval1";
proc report data=_subj nowd;
    by subject;
    column subject dsetname memlabel  nnew nmodify ndel flag1;

    define dsetname / order;
    define nnew / display;
    define nmodify / display;
    define ndel / display;
    define flag1 / noprint computed;

    compute flag1 / character length=1;
        if nnew = 0 and nmodify = 0 and ndel = 0 then flag1 = 'Y';
        if flag1 = 'Y' then do;
            call define(_row_, 'style', 'style=[background=#C5E0B3]'); 
        end;
    endcomp;
    compute ndel;
        if ndel > 0 then call define('ndel', 'style', 'style=[foreground=red]');
    endcomp;
run;

ods rtf close;
ods pdf close;

%EXIT:
%mend sasDsetCompare;
