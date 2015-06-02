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
%let rootdir                  =       %str(Q:\Files\CDM\Patient Profile);
%let rawdatadir               =       %str(Q:\Files\C107\ARQ-087\ARQ087-101\cdisc\dev\data\raw);
%let studyid                  =       %str(ARQ 087-101);
%let demodset                 =       %str(pdata.dm);
%let subjectvar               =       %str(subid);
%let subset                   =       %str(053-0002 053-0003 053-0027);
/*%let subset                   =       %str();*/
%let dlm4subj                 =       %str( );
%let newtransferID            =       %str(18DEC2013);
%let escapechar               =       %str(^);
%let SkipRawDataProcessing    =       %str(N);
%let debugMode                =       %str(Y);




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
%let sectionheadercolor       =       %str(#1F497D);
%let sectionheaderfsize       =       %str(10pt);
%let appendixheadercolor      =       %str(green);
%let appendixheaderfsize      =       %str(14pt);
%let tableheaderbgcolor       =       %str(cxF5F7F1); 
%let tablebordercolor         =       %str(cxC1C1C1);
%let nblanklinesbetweentable  =       %str(3);
%let usrdefinedheadfootfsize  =       %str(7pt);


%include "&rootdir\src\preparation\setupSASEnvir.sas";
*setup SAS Environment;
%setupSASEnvir;



/*User Defined Part Below*/
%let abovecolor    = red;   /*value above upper limit*/
%let belowcolor    = blue;  /*value below lower limit*/
%let norangecolor  = green; /*value without a normal range*/

%include "&plugindir/formats.sas";
%include "&plugindir/_userMacros.sas";
