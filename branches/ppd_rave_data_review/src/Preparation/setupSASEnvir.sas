/*
    Setup SAS Enviornment for patient profile
    

    Revision History:
    Ken Cao on 2015/02/07: Add TEMPDIR and DBUGDIR for temporary and debug files.
*/

%macro GlbMvars();
    %local glbmvarlist1;
    %local glbmvarlist2;
    %local nglbmvar;
    %local i;

    ** configurable macro variable **;
    %let glbmvarlist1 = %str
    (
        rootdir                 /* root directory of patinet profile application. It is the direcotry where L_patient_profile.sas locates */  
        rawdatadir              /* raw datasets directory */
        pdatadir                /* directory for processed datasets */
        pdatabkdir              /* directory for backuped processed datasets */
        outputdir               /* directory for patient profiles */
        graphdir                /* directory for graphics */
        plugindir               /* directory for project directory (legacy name) */
        projectdir              /* directory for project directory */
        tempdir                 /* directory for temporary files */
        debugdir                /* directory for debug information */


        /**************************************************************************
        In case of real study ID contains invalid characters for a folder name,
        user will assgin a proper name for the project folder and assign it to 
        STUDYID and then assign real study ID to STUDYID2. In all other cases,
        STUDYID2 could be left out.
        **************************************************************************/
        studyid                 /* STUDY ID. It must be exactly same as the folder name for the project. */
        studyid2                /* STYDY ID. */


        subset                  /* a list of subjects to be ran against */
        dlm4subj                /* separators for the list of subjects in subset. Default value: blank */
        escapechar              /* ODS ESCAPECHAR character */
        splitchar               /* SPLIT= in PROC REPORT */
        debugMode               /* Y/N. If Y then write debug information in SAS log and directory TEMPDIR. Default is Y. */
        skipRawDataProcessing   /* Y/N. Whether to refresh processed datasets */
        skipCompare             /* Y/N. Default is N. Whether to skip compare process */
        subjectvar              /* varaible name of SUBJECT ID */
        demodset                /* datasets to be used as demographics datasets */


        rerun                   /* Y/N. Whether to backup current datasets to backup folder */
        compare                 /* Y/N. Whether to compare processed datasets with backup processed datasets */
        newtransferID           /* current data transfer ID */
        oldtransferID           /* old data transfer ID */

        newcolor                /* background color for new record */
        mdfcolor                /* background color for modified record */
        mdfvarcolor             /* background color for modified value */
        delcolor                /* background color for deleted record */

        tableheadercolor        /* font color for table header */
        tableheadersize         /* font color for table size */

        logo                    /* logo to be displayed */
        slogon                  /* slogon to be displayed */
        logourl                 /* URL embedded with logo */



        pdfstyle                /* customized style name used for PDF output */
        rtfstyle                /* customized style name used for RTF output  */
        genPDF                  /* Y/N. Whether to generate PDF output */
        genRTF                  /* Y/N. Whether to generate RTF output */
        pdfFormat               /* PDF/PS. If PDF, then native pdf file will be generated. If PS, then .PS file will be generated instead */
        suppressSysTitle        /* Y/N. whether to suppress system generated titles (logo and "patient profile" line */
        suppressSysFooter       /* Y/N. whether to suppress system generated footers */

        returncode              /**/

        showDeletedRecord       /* Y/N. Wheter to display deleted record */
        dlmcompare              /* Delemeter for temporary variables in COMPARE */

        showCoverPage           /* Y/N. Whether to add a cover page. */
        displayQ2InCoverPage    /* Y/N. Whether to display Q2 indentifier in cover page. */

    );


    ** static macro variable **;
    %let glbmvarlist2 = %str
        (
            PDATALIBRF PDATABKLIBRF DSETCFG DATE TIME
        );


    %let glbmvarlist = &glbmvarlist1 &glbmvarlist2; ** combine two list **;

    %let glbmvarlist = %sysfunc(prxchange(s/\s+/ /, -1, &glbmvarlist));
    %let glbmvarlist = %sysfunc(prxchange(s/^\s//, -1, &glbmvarlist));
    %let nglbmvar    = %sysfunc(countc(&glbmvarlist, " "));
    %let nglbmvar    = %eval(&nglbmvar + 1);

    %do i = 1 %to &nglbmvar;
        %local glbvar;
        %let glbvar = %scan(&glbmvarlist, &i, " ");

        %if %symexist(&glbvar) = 0 %then  %do;
            %global &glbvar;
        %end;
    %end;



    ** static macro variable **;

    %let PDATALIBRF      = pdata;
    %let PDATABKLIBRF    = pdatabk;
    %let DSETCFG         = _config0;
%mend GlbMvars;



%macro setupSASEnvir(restrict);

    /*
        Ken on 2013/12/03: With macro GlbMvars, it will be unnecessary to declare a global macro variable used 
        as input paramter in _setup.sas. This will tremendously improve comptability of patient profile package.
    */
    %GlbMvars;
    
    *system will ignore user specification of outputdir/pdatadir/pdatadirbk if in restricted mode (1);
    %if %length(&restrict)=0 %then %let restrict=1;
    
    %local filrf;
    %let filrf = src;

    %local rc;
    %let rc  =  %sysfunc(filename(filrf));

    %if &rc = 0 %then %do;
    filename src
    (
        "&rootdir\src\preparation"
        "&rootdir\src\compare"
        "&rootdir\src\report"
        "&rootdir\src\public"
    );
    %end;
    %else %do;
        %let isErr = 1;
        %return;
    %end;

    option validvarname=upcase nofmterr fmtsearch=(source work) mautosource sasautos=(sasautos src) COMPRESS=YES missing=" "; 
    option leftmargin = 0.25in rightmargin=0.25in topmargin=0.25in bottommargin=0.25in;
    option pdfpagelayout = continuous;
    option PS=max LS=max;
    option orientation = landscape;
    ods path work.templat(update) sashelp.tmplmst(read) ;



    *library for source datasets;
    libname source "&rawdatadir";

    *ods escape character;
    ods escapechar = "&EscapeChar";



    *##################################################################*;
    *Set default value for all global macro variables (input parameter)*;
    *##################################################################*;

    ** Ken Cao on 2015/02/07: Default color for data change;
    %if %length(&mdfcolor) = 0 %then %let mdfcolor = cxFFF2CC;
    %if %length(&newcolor) = 0 %then %let newcolor = cxFFCCFF;
    %if %length(&mdfvarcolor) = 0 %then %let mdfvarcolor = cxC1C1C1;
    %if %length(&delcolor) = 0 %then %let delcolor = cxF8CBAD;


    * setup default value for data label font size and font color;
    %if %length(&tableheadercolor ) = 0 %then %let tableheadercolor = %str(cx1F497D);
    %if %length(&tableheadersize) = 0 %then %let tableheadersize = %str(10pt);




    * default style for PDF and RTF otputs;
    %if %length(&pdfstyle) = 0 %then %let pdfstyle = styles.pdfstyle;
    %if %length(&rtfstyle) = 0 %then %let rtfstyle = styles.rtfstyle;

    * generate PDF report by default;
    %let genRTF = %upcase(&genRTF);
    %let genPDF = %upcase(&genPDF);

    %if %length(&genRTF) = 0 %then %let genRTF = N;
    %if %length(&genPDF) = 0 %then %let genPDF = Y;


    %let pdfFormat = %upcase(&pdfFormat);
    %if %length(&pdfFormat) = 0 %then %let pdfFormat = PS;


    * supress system generated title (logo and patient profile);
    %let suppressSysTitle = %upcase(&suppressSysTitle);
    %if %length(&suppressSysTitle) = 0 %then %let suppressSysTitle = N;

    * supress system generated footer (timestamp and raw data transfer date );
    %let suppressSysFooter = %upcase(&suppressSysFooter);
    %if %length(&suppressSysFooter) = 0 %then %let suppressSysFooter = N;


    %let showDeletedRecord = %upcase(&showDeletedRecord);
    %if %length(&showDeletedRecord) = 0 %then %let showDeletedRecord = Y;

    %let skipRawDataProcessing = %upcase(&skipRawDataProcessing);
    %if %length(&skipRawDataProcessing) = 0 %then %let skipRawDataProcessing = N;

    %let skipCompare = %upcase(&skipCompare);
    %if %length(&skipCompare) = 0 %then %let skipCompare = N;

    %let showCoverPage = %upcase(&showCoverPage);
    %if %length(&showCoverPage) = 0 %then %let showCoverPage = Y;

    %let displayQ2InCoverPage = %upcase(&displayQ2InCoverPage);
    %if %length(&displayQ2InCoverPage) = 0 %then %let displayQ2InCoverPage = Y;




    ** Check if input parameter is Y/N only;
    %chkYN(rerun, &rerun, N);
    %chkYN(compare, &compare, N);
    %chkYN(genRTF, &genRTF, N);
    %chkYN(genPDF, &genPDF, Y);
    %chkYN(suppressSysTitle, &suppressSysTitle, N);
    %chkYN(suppressSysFooter, &suppressSysFooter, N);
    %chkYN(showDeletedRecord, &showDeletedRecord, Y);
    %chkYN(skipRawDataProcessing, &skipRawDataProcessing, N);
    %chkYN(skipCompare, &skipCompare, N);
    %chkYN(showCoverPage, &showCoverPage, Y);
    %chkYN(displayQ2InCoverPage, &displayQ2InCoverPage, Y);


    %if %length(&dlmcompare) = 0 %then %let dlmcompare = '01'x;


    %if %length(&splitchar) = 0 %then %let splitchar = #;
    %if %length(&studyid2) = 0 %then %let studyid2  = %str(&studyid);

    %if %length(&logo) = 0 %then %do;
        %let logo = %str(&rootdir\icon\nologo.png);
    %end;


    %if %length(&outputdir)  = 0  %then  %let outputdir   = %str(&rootdir\output\&studyid);
    %if %length(&pdatadir)   = 0  %then  %let pdatadir    = %str(&rootdir\output\&studyid\processed data);
    %if %length(&pdatabkdir) = 0  %then  %let pdatabkdir  = %str(&rootdir\output\&studyid\processed data\backup);
    %if %length(&graphdir)   = 0  %then  %let graphdir    = %str(&rootdir\output\Graphics);
    %if %length(&plugindir)  = 0  %then  %let plugindir   = %str(&rootdir\projects\&studyid);
    %if %length(&tempdir)    = 0  %then  %let tempdir     = %str(&rootdir\temp\&studyid);
    %if %length(&debugdir)   = 0  %then  %let debugdir    = %str(&rootdir\temp\&studyid\debug);


    %if &restrict=1 %then
    %do;
        %let outputdir    =  %str(&rootdir\output\&studyid);
        %let pdatadir     =  %str(&rootdir\output\&studyid\processed data);
        %let pdatabkdir   =  %str(&rootdir\output\&studyid\processed data\backup);
        %let graphdir     =  %str(&rootdir\output\Graphics);
        %let plugindir    =  %str(&rootdir\projects\&studyid);
        %let tempdir      = %str(&rootdir\temp\&studyid);
        %let debugdir     = %str(&rootdir\temp\&studyid\debug);
    %end;


    ** DEAL WITH LEGACY NAMES AND CONVENTIONS;
    %let projectdir = &plugindir; ** PROJECTDIR will be used instead of plugindir;

    ** DEMODSET is specified without a library name and it must be located in PDATA library;
    %if %sysfunc(prxmatch(/^\w+\.\w+/, &demodset)) %then %do;
        %let demodset = %sysfunc(prxchange(s/^(\w+)\.(.*)/$2/, -1, &demodset));
    %end;


    %if %sysfunc(fileexist(&outputdir))=0 %then 
    %do;
        %setupFolder(foldername=&studyid, parentdir=&rootdir\output);
    %end;
    %if %sysfunc(fileexist(&pdatadir))=0 %then 
    %do;
        %setupFolder(foldername=processed data, parentdir=&rootdir\output\&studyid);
    %end;
    %if %sysfunc(fileexist(&pdatabkdir))=0 %then 
    %do;
        %setupFolder(foldername=backup, parentdir=&rootdir\output\&studyid\processed data);
    %end;
    %if %sysfunc(fileexist(&graphdir))=0 %then 
    %do;
        %setupFolder(foldername=Graphics, parentdir=&rootdir\output\&studyid);
    %end;
    %if %sysfunc(fileexist(&tempdir))=0 %then 
    %do;
        %setupFolder(foldername=&studyid, parentdir=&rootdir\temp);
    %end;
    %if %sysfunc(fileexist(&debugdir))=0 %then 
    %do;
        %setupFolder(foldername=debug, parentdir=&rootdir\temp\&studyid);
    %end;
    
    libname out "&pdatadir";
    libname pdata "&pdatadir";
    libname pdatabk "&pdatabkdir";
    libname debug "&debugdir";

    proc datasets lib=work kill nolist nowarn memtype=data; quit;

    %let ReturnCode=0;


%mend setupSASEnvir;

