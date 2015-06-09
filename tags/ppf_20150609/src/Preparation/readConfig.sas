
/*

    Program Name: readConfig.sas
        @Author: Ken Cao (yong.cao@q2bi.com).
        @Intial Date: 2013/03/15
    
    **************************************************************;
    This program is a part of patient profile solution. It imports
    configuration file into SAS.
    **************************************************************; 

*/


/* Modification History:
    
    1. 2013/04/10 Ken: Add a attribute ISLABELSUBJECTLEVEL to indicate whether label of a
    dataset is subject-level.

    2. 2013/04/11 Ken: Add a attribute LABELLINKTO, dataset label now supports hyperlink.

    3. 2013/05/08 Ken: Add a attribute STARTPAGE. User could define which dataset to be printed in new page.
    
    4. 2013/05/23 Ken: Add a attribute ORIENTATION. User could define page orientation.
    
    5. 2013/06/02 Ken: Fix a e r r o r when configuration file contains a undefined sections. (Program will tolerate undefined section
    and throws an W A R N I N G message in log.
    
    6. 2014/06/16 Ken: Add a attribute NOPRINTWHENNODATA to suppress printing a blank table.

    7. 2014/11/12 Ken Cao: 
        1) Add a new section PROJECT in configuration to set some attributes for all dataset.
        2) Add a new attribute SHOWHDRWHENNODATA to decide whether to display column header when no observation.

    8. 2015/04/14 Ken Cao: Code cleaning. Some options that is not necessary are removed.

    9. 2015/05/20 Ken Cao: Add option GETLABEL to get variable label from first row of subset of each subject.
    
*/

%macro readConfig(config);
    %local rc;
    %local blank;
    %let blank=;

    *Assign 0 to debug macro varaible ReturnCode (initialization);
    %let ReturnCode=0;

    *Check if configuration file exists;
    %let rc=%sysfunc(fileexist(&config));   
    %if &rc=0 %then
    %do;
        %put ERR%str(&blank)OR: Configuration file does not exist.;
        %let ReturnCode=1;
        %return;
    %end;

    *Assign filref to configuration file;
    %let filrf=config;
    %let rc=%sysfunc(filename(filrf,&config));
    %if &rc>0 %then
    %do;
        %put ERR%str(&blank)OR: Unknow err%str(&blank)or. Save your session and restart SAS.;
        %let ReturnCode=1;
        %return;
    %end;

    data _config0(keep=ord dset keylist label islabelsubjectlevel nodatext subjectlevel startpage noprintwhennodata split getvarlbl);
        attrib
                ord                    length = 8        label = "Order Number"
                dset                   length = $32      label = "Dataset Name"
                keylist                length = $256     label = "Key variables"
                label                  length = $256     label = "Label in Main Body (Used as table header)"
                islabelsubjectlevel    length = $1       label = "Is Label Subject-level?"
                nodatext               length = $200     label = 'Text When No Data'
                subjectlevel           length = $1       label = "Subject level"
                startpage              length = $1       label = "Start New Page"
                noprintwhennodata      length = $1       label = "Supress printing a blank table"
                split                  length = $1       label = 'Split Character in PROC REPORT'
                getvarlbl              length = $1       label = 'Get Label from First Row of Subset of Each Subject'
        ;

        infile &filrf dlm=' ' lrecl=2048 truncover dsd;
        input @;
        input 
              @1
              @'LABEL='                   label                    : $256.    @1
              @'ISLABELSUBJECTLEVEL='     islabelsubjectlevel      : $1.      @1
              @'TEXTWHENNODATA='          nodatext                 : $200.    @1 
              @'SUBJECTLEVEL='            subjectlevel             : $1.      @1
              @'STARTPAGE='               startpage                : $1.      @1
              @'NOPRINTWHENNODATA='       noprintwhennodata        : $1.      @1
              @'SPLIT='                   split                    : $1.      @1
              @'GETVARLBL='               getvarlbl                : $1.      @1
        ;

        retain ord;
        if _n_ = 1 then ord = 0;

        line=strip(_infile_);

        *linenum records the line number of configuration file, and is used for debug;
        retain linenum;
        if _n_=1 then linenum=1;
        else linenum=linenum+1;


        *skip blank line, skip line with first character is "'";
        if line=' ' then return;
        else if substr(line,1,1)="'" then return;

        * use section to separate different contents ensure the program (as well as the configuration
        * file is extensible.
        ;
        *line beginning as "::" is the start of a section, and the line itself will not be dealt with;
        if substr(line,1,2)="::" then __sectionline=1;
        *Assign different value to different section;
        length __section $20;
        retain __section;
        length _warnmsg $200;
        if __sectionline=1 then
        do;
            __section='';
            __section=scan(line,1,": ");
        end;
        *different section will be lead to different section of program (labeled);

        if __section='DATASET' then goto DATASET;
        else do;
            _warnmsg="WARN"||"ING: Undefined section "||strip(__section)||" detected and yet not implemented. Statement will be ignored.";
            put _warnmsg;
            goto END;
        end;

    *DATASET PART;
    DATASET:
        *this statement should be added to the start each section.;
        *there seems to be a better way to make this statement global for all sections, to be developed(2013/03/15);
        if __sectionline=1 then return;

        if prxmatch('/^[_a-z]\w+:?/i', line) = 0 then do;
            put "ERR" "OR: Configuration err" "or. Invalid configuration line at line " linenum ": " line;
            goto RETURNERR;
        end;

        ord     = ord + 1;
        dset    = upcase(scan(line,1,": "));
        keylist = upcase(strip(scan(line,2,":|")));

        /*
            if NOPRINTWHENNODATA is set to Y then blank table (dataset with zero recrod) will not be printed.
        */;
        noprintwhennodata = upcase(noprintwhennodata);
        if noprintwhennodata = ' ' then noprintwhennodata = 'N';


        *if INCLUDEINTOC/TYPE/SUBJECTLEVEL is not specified in the configuration file, then use default value;
        subjectlevel = coalescec(coalescec(subjectlevel),'Y');
        nodatext     = coalescec(nodatext,'No Observation');;
        startpage    = coalescec(upcase(startpage),'N');


        *if LABEL/LABELINTOC is not specified in the configuration file, then use real lable of the dataset;
        if label = ' ' then do;
            length __label $256;
            dsid=open('pdata.'||strip(dset));
            if dsid=0 then do;
                put "ERR" "OR: DATA pdata." dset " could not be found.";
                goto RETURNERR;
            end;
            __label=strip(attrc(dsid,'label'));
            if __label = ' ' then do;
                put "ERR" "OR: Label of PDATA." dset " is not defined yet.";
                goto RETURNERR;
            end;
            label=__label;
            rc=close(dsid);
        end;


        getvarlbl = upcase(getvarlbl);
    
        output _config0;
        return;




    *Set ReturnCode to 1, indicating E R R O R.;
    RETURNERR:
        call symput('ReturnCode','1');
        return;

    END:
    run;

    *for compare module use;
    *Any variable end with a "*" will be treated as sort variable only;
    data _config0;
        **Ken on 2013/03/27: use drop statement to make the program more flexible to modify;
        *keep ord dset keylist droplist includeintoc labelintoc type subjectlevel;
        set _config0(rename=keylist=in_keylist);
        length keylist droplist $256;
        call missing(keylist,droplist);
        length i 8 _var $32;
        i=1;
        _var=strip(scan(in_keylist,i," "));
        do while(_var^='');
            if index(_var,'*')=0 then keylist=strip(keylist)||' '||_var;
            else droplist=strip(droplist)||' '||substr(_var,1,length(_var)-1);
            i=i+1;
            _var=strip(scan(in_keylist,i," "));
        end;
        drop in_keylist _var i; 
    run;

    %let rc=%sysfunc(filename(filrf));

    ****************************************************************************;
    ** Validate configuration dataset;
    ****************************************************************************;
    ***level 1: dataset exist ?;
    ***level 2: variable exists ?;
    data _null_;
        set _config0;
        length __dset $65 __allvars $1024 __var $32;
        __dset=upcase("&PDATALIBRF"||'.'||dset);
        dsid=open(__dset);
        if dsid=0 then
        do;
            call symput('ReturnCode','1');
            put "ERR" "OR: Dataset " __dset " not found ";
        end;
        else
        do;
            *If dataset exists, then verify variables in the keylist and droplist;
            __allvars=strip(strip(keylist)||' '||droplist);
            __allvars=compbl(__allvars);
            __nvars=ifn(strip(__allvars)='',-2,countc(strip(__allvars)," "))+1;
            do i=1 to __nvars;
                __var=scan(__allvars,i," ");
                __varnum=varnum(dsid,__var);
                if __varnum=0 then 
                do;
                    call symput('ReturnCode','1');
                    put "ERR" "OR: Variable " __var " not found in dataset " __dset;
                end;
            end;
            rc=close(dsid);
        end;
    run;

    ****************************************************************************;
    ** Check Dataset Variable;
    ****************************************************************************;
    proc contents data = &PDATALIBRF.._ALL_ out=_chkvarlbl(keep=memname memlabel name label) noprint;
    run;

    data _null_;
        length dset $32;
        if _n_ = 1 then do;
            declare hash h (dataset: '_config0');
            rc = h.defineKey('dset');
            rc = h.defineDone();
            call missing(dset);
        end;
        set _chkvarlbl;
        dset = upcase(memname);
        rc = h.find();
        if rc = 0 and name not =: '__' and upcase(name) ^= "%upcase(&subjectvar)" and label = ' ' then do;
            put "WARN" "ING: Variable " name "in dataset " memname "does not have a label.";
        end;
    run;



%mend readConfig;
