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
%let rawdatadir               =       %str(C:\Users\Yong\Documents\Nutstore\Janus\Projects\Patient Profile\orax\sasdset\Kinex Oraxol Data Pull 08Dec2014);
%let studyid                  =       %str(ORAX-01-13-US);
%let demodset                 =       %str(pdata.dm);
%let subjectvar               =       %str(subjid);
%let subset                   =       %str();
/*%let subset                   =       %str();*/

%let dlm4subj                 =       %str( );
%let newtransferID            =       %str(08DEC2014);
%let escapechar               =       %str(^);
%let SkipRawDataProcessing    =       %str(N);
%let debugMode                =       %str(Y);

/*%let outputdir                =       %str(E:\ORAX_Patient Profile\Patient Profile\output\ORAX-01-13-US);*/
/*%let outputdir                =       %str(Q:\Files\CDM\Patient Profile\output\ORAX-01-13-US\temp);*/
/*%let pdatadir                =       %str(Q:\Files\CDM\Patient Profile\output\ORAX-01-13-US);*/




*--->macro variables you don't have to take care of;
/*Compare module is under development now.*/
%let rerun                    =       %str(N);
%let compare                  =       %str(N);
%let displayq2commet          =       %str(N);
%let newcolor                 =       %str(#DDDDDD);
%let mdfcolor                 =       %str(YELLOW);
%let oldtransferID            =       %str();


%let logo                     =       %str(icon\Kinex2.png);
%let logourl                  =       %str();


%let printTOC                 =       %str(N);
%let TOCOrientation           =       %str(Landscape);
%let sectionheadercolor       =       %str(#FFFFFF);
%let sectionheaderfsize       =       %str(10pt);
%let appendixheadercolor      =       %str(green);
%let appendixheaderfsize      =       %str(14pt);
%let tableheaderbgcolor       =       %str(cxDFDFDF); 
%let tablebordercolor         =       %str(cxC1C1C1);
%let fontsize                 =       %str(9pt);
%let nblanklinesbetweentable  =       %str(1);
%let usrdefinedheadfootfsize  =       %str(8pt);


** Ken Cao on 2014/12/09: generate RTF output;
%let genRTF   = N;
%let genPDF   = Y;
%let rtfstyle = %str(styles.rtfstyle2);

%include "&rootdir\src\preparation\setupSASEnvir.sas";
*setup SAS Environment;
%setupSASEnvir(0);



/*User Defined Part Below*/
%include "&plugindir\_publicMacros.sas";
%include "&plugindir\formats.sas";
