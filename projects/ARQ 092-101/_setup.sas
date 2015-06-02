/*#############################################################################################################################################*

rootdir                 : Root directory of patient profile application. It is the direcotry of L_pp.sas
rawdatadir              : Directory of raw datasets
pdatadir                : Directory of processed datasets (hidden by default, will be assigned by system automatically.)
pdatabkdir              : Directory of backup processed datasets (hidden by default, will be assigned by system automatically.)
outputdir               : Directory of patient profile output (hidden by default, will be assigned by system automatically.)
graphdir                : Directory of graphic output (hidden by default, will be assigned by system automatically.)
plugindir               : Directory of study folder, i.e directory of programs of processed data (hidden by default, will be assigned by 
                         system automatically.)
studyid                 :  Study ID. studyid MUST be same with folder name of study folder (in the plugin folder). In case that study ID 
                          contains invalid chracters ('"?|*\/:><) for a windows folder name, those characters should be replaced with 
                          underscore(_). Original study ID will be recorded in STUDYID2.
studyid2                : Original study ID in the case of it contains characters '"?|*\/:><.
subset                  : A list of subject # separated by delimiter
dlm4subj                : Delimiter used to separate subjects in SUBSET.
newtransferID           : Transfer ID of raw datasets
escapechar              : Escape character used in ODS.
SkipRawDataProcessing   : If Y, then processed datasets won't be generated again.
debugMode               : If Y, then program will write debug information to SAS log.
logo                    : Directory(with file name) of company logo. (hidden by default, will be assigned by system automatically.)


rerun                   : If Y, then processed datasets won't be backuped before generating new ones.
compare                 : If Y, then newly generated processed datasets will be compared to old(backup) ones.
displayq2commet         : If Y, details about modified records will be displayed in bubbles.
newcolor                : Background color of new records.
mdfcolor                : Background color of modified records.
oldtransferID           : Data tranfer ID of benchmark datasets

printTOC                : If Y, then print Table of Contents in the first page
TOCOrientation          : Page orientation of TOC
sectionheadercolor      : Font color of table caption
sectionheaderfsize      : Font size of table caption
appendixheadercolor     : Font color of appendix title
appendixheaderfsize     : Font size of appendix title
tableheaderbgcolor      : Background color of column header
tablebordercolor        : Boder color of tables
nblanklinesbetweentable : # of blank lines inserted between tables
usrdefinedheadfootfsize : Font size of user defined titles and footnotes

*#########################################################################################################################################*/




*--->macro variables you MUST take care of;
%let rootdir                  =       %str(C:\Users\Yong\Documents\SVN\working copy\patient profile\trunk);
%let rawdatadir               =       %str(C:\Users\Yong\Documents\Nutstore\Janus\Projects\ARQ 092-101\arql013_20141128T0032);
%let studyid                  =       %str(ARQ 092-101);
%let demodset                 =       %str(pdata.dm(where=(__cleanfl = 'Y')));
%let subjectvar               =       %str(subid);
*%let subset                   =       %str(019-0003);
%let dlm4subj                 =       %str( );
%let newtransferID            =       %str(28NOV2014);
%let escapechar               =       %str(^);
%let SkipRawDataProcessing    =       %str(N);
%let debugMode                =       %str(Y);

** as per client comment, remove logo **;
*%let logo                     =       %str(icon\nologo.png);


*--->macro variables you don't have to take care of;
/*Compare module is under development now.*/
%let rerun                    =       %str(N);
%let compare                  =       %str(N);
%let displayq2commet          =       %str(N);
%let newcolor                 =       %str(#DDDDDD);
%let mdfcolor                 =       %str(YELLOW);
%let oldtransferID            =       %str();


%let printTOC                 =       %str(Y);
%let TOCOrientation           =       %str(Landscape);
* %let sectionheadercolor       =       %str(#1F497D);

** Ken Cao on 2014/11/26: As per client comments, all letters should be black and white **;
%let sectionheadercolor       =       %str(cx1F497D);
%let sectionheaderfsize       =       %str(10pt);
%let appendixheadercolor      =       %str(green);
%let appendixheaderfsize      =       %str(14pt);
%let tableheaderbgcolor       =       %str(cxFFFFF1);   /*%str(FFFFF1); */
*%let tablebordercolor         =       %str(cxC1C1C1);
%let tablebordercolor         =       %str(cxC1C1C1);
%let nblanklinesbetweentable  =       %str(3);
%let usrdefinedheadfootfsize  =       %str(7pt);

/*
%let titlecolor               =       %str(cx6F6F6F);
%let footercolor              =       %str(cx6F6F6F);
*/
** Ken Cao on 2014/11/26: As per client comments, remove spaces between tables ;
%let nbbtwntbl                =       %str(0);


** Ken Cao on 2014/11/26: customize style template for PDF output ;
%let pdfstyle                 =       %str(styles.pdfstyle2);
** Ken Cao on 2014/11/26: customize style template for RTF output ;
%let rtfstyle                 =       %str(styles.rtfstyle2);

%include "&rootdir\src\preparation\setupSASEnvir.sas";
*setup SAS Environment;
%setupSASEnvir;



/*User Defined Part Below*/
%let abovecolor    = red;   ** value above upper limit **;
%let belowcolor    = blue;  ** value below lower limit **;
%let norangecolor  = green; ** value without a normal range **;

** Ken Cao on 2014/11/26: As per client comments, all letters should be black and white **;
%let abovecolor    = black; 
%let belowcolor    = black; 
%let norangecolor  = black; 


** Ken Cao on 2014/11/27: Generate RTF output only **;
%let genRTF = Y;
%let genPDF = Y;


** Ken Cao on 2014/11/27: suppress system titles to gain more space for content **;
%let suppressSysTitle = Y;


%include "&plugindir/formats.sas";
%include "&plugindir\user_macros.sas";
