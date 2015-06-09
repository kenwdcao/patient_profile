******************************************************************************;
* Purpose: Patient Profile                                                   *;
* Module: Main Program                                                       *;
* Type: Sas Program                                                          *;
* Program Name: L_pp.sas                                                     *;
* Function: Integrate each module to generate patient profile                *;
* Author: Ken Cao (yong.cao@q2bi.com)                                        *;
* Intial Date: 16Feb2013                                                     *;
******************************************************************************;


/*
    2013/04/02 Ken: Test Version 0.1. Test integraty.
    2013/04/08 Ken: Add a macro %setupFolder to automatically setup folders for a new study in output directory.
    2013/04/09 Ken: Fix the MPRINT / MLOGIC issue. In case of user defined hehavior of MPRINT / MLOGIC RawDataProcessing.sas,
                     the two options will be redefined again after call program RawDataProcessing.sas.
    2013/04/17 Ken: Add support of where statment (subset) for macro variable DEMODSET.
    2013/04/28 Ken: Add some interactive interface with user to enable user choose which setup program in setup folder to use.
    2013/05/01 Ken: Use window statement in data step to replace %window statement. Use of stop statement can exit input/information
                     window. Change wording of some window.
    2013/05/02 Ken: Change the way headers and footers printed. This reduces time consuming by at least 50%.
    2013/05/08 Ken: Add attribute "startpage" in configuration file. STARTPAGE=Y means a dataset needs to be printed in new page.
    2013/05/08 Ken: Add a interface in proc report, to enable user cutomize compute block.
    2013/05/16 Ken: Add new feature in configuration file, user could customize table border width and output table scale.
    2013/05/16 Ken: Use inline formatting to embed graphics in patient profile.
    2013/05/21 Ken: Minor change in compare module. Fix a conflict.
    2013/05/22 Ken: Add user-defined anchor while keeping original programming-determined anchors.
    2013/05/23 Ken: Add support for page orientation customization. This can optimize figure/image support.
    2013/05/23 Ken: Modulize macro ppf_prt.
    2013/05/29 Ken: Add validation on some key parameters: skipRawDataProcessing, Compare;
    2013/06/02 Ken: Fix a bug of pdf likage.
    2013/06/03 Ken: Enable user to customize page orientation of TOC page(s).
    2013/06/04 Ken: Enable user to change logo in the patient profile.
    2013/07/17 Ken: Change some wording in start window.
    2013/10/18 Ken: Major update. Merge two setup programs. Remove setup folder under root directory
    2013/12/04 Ken: Add a macro GlbMvars in macro setupSASEnvir. Now new paramters can be added to setup without losing compatability.
*/


*** Ken Cao on 2014/11/06: Line Size on V52b is 64 by default which is too small ***;
option ls = 95; *** this is a temporary solution ***;
option mprint mlogic;

%macro main(project);
    
    %local isErr;
    %local blank; /*separators*/
    %local whichProject; /*project name of user input */


    %let blank = ;

    %include 'src\Preparation\selectProject.sas';


    %if %length(&project) = 0 %then %do;
        * SAS Windowing Environment to let user enter project name;
        %selectProject;
    %end;
    %else %do;
        %let whichProject = &project;
        %let rc = %sysfunc(fileexist(projects/&whichProject/_setup.sas));
        %if &rc = 0 %then %do;
            %let isErr = 1;
            %put ERR&blank.OR: In&blank.valid project name: &whichproject;
        %end;
    %end;

    %if &isErr = 1 %then %goto EXIT;



    **********************************************************************;
    *Load user-sepcified setup*;
    **********************************************************************;
    %include "projects/&whichProject/_setup.sas";

    %if &isErr = 1 %then %goto EXIT;


    *Only include the following three program if detected.;
    %if %sysfunc(fileexist(&projectdir/data_exception.sas)) %then %do;
        %include "&projectdir/data_exception.sas";
    %end;
    %if %sysfunc(fileexist(&projectdir/prt_exception.sas)) %then %do;
        %include "&projectdir/prt_exception.sas";
    %end;
    %if %sysfunc(fileexist(&projectdir/prt_compute_exception.sas)) %then %do;
        %include "&projectdir/prt_compute_exception.sas";
    %end;

    %let config=&projectdir/config.txt;

    *Whether to use mprint and mlogic option(complie and call);
    %debug;
    *Define report styles(based on whether compare would be performed);
    %style;
    

    **********************************************************************;
    *Setup Folder System*;
    **********************************************************************;
    *get study folder name, same as the folder name under projects directory;
    %local studyoutputfoldername;
    %let studyoutputfoldername=%scan(&projectdir,-1,/\); 



    *check integrity of setup --> TBD;
    %chkSetup;
    %if &ReturnCode=1 %then %return;    


    
    *Ken on 2013/05/18: Add option definition of linesize and pagesize;
    option validvarname=upcase orientation=landscape nobyline nodate nonumber noquotelenmax ls=95 ps=80;
    ods escapechar="&escapechar";
    ods _all_ close;
    title;footnote;


    *User could determine which step will be skiped, this is rather useful in test/debug mode;
    %if %upcase(&skipRawDataProcessing)=Y  %then %goto READCONFIG;

    *Raw Data Processing;
    %RAWDATAPROCESS:

        **deletion/backup;
        ***Ken on 2013/03/17: Some exception needs to be taken care of, e.g., data is opened and could not be moved/deleted(TBD);
        %start(worklibref=pdata,bklibref=pdatabk);

        option noxwait xsync;
        *save current directory and goto plugin directory;
        x cd "&projectdir";
        %include "RawDataProcessing.sas";
        *back to previous directory;
        /*
         Ken on 2013/04/28: Go back to previous location using macro variable &currentloc.
        */
        x "cd &rootdir";
    
    *Ken on 2013/04/15: In case of user defined behavior of MPRINT/MLOGIC in the program of RawDataProcessing.sas;
    %debug;

    *clean up;
    proc datasets lib=work memtype=data kill nowarn nolist; quit;

    *duplicate sas options definition;
    option validvarname=upcase orientation=landscape nobyline nodate nonumber noquotelenmax ps=max ls=max;

    
    *import Configuration file into SAS;
    *<!-- Must not be skiped -->;
    %READCONFIG:
        %readConfig(&config);
        %if &ReturnCode = 1 %then %return;

    %COMPARE:
    %if &skipCompare = N %then %do;
    %compare(_config0);
    %end;


    ** Ken Cao on 2014/11/25: load user customied PDF style template definition;
    %if %sysfunc(fileexist(&projectdir/style.sas)) %then %do;
        %include "&projectdir/style.sas";
    %end;

    %REPORT:
    %ppf_prt
    (
          demodset = &demodset,
           subsets = &subset,
          dlm4subj = &dlm4subj,
        subjectvar = &subjectvar,
        dsetconfig = _config0,
    headfootconfig = _config1,
          pdfstyle = &pdfstyle,
          rtfstyle = &rtfstyle
    );

    ** Ken Cao on 2015/02/07: Move temporary datasets into debug folder;
    proc datasets lib = debug kill nolist nowarn; quit;
    proc copy in = work out = debug; run;
%mend main;


*the statment below is useful when program is stopped in the middle of running. It will force SAS to close file being written;
ods pdf close;

%main(&sysparm);


