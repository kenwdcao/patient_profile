

/*------------------------------------------------------------
  Setup below parameters before first running   
  ----------------------------------------------------------*/

%let    rootdir  = %str(C:\Users\Yong\Documents\SVN\working copy\patient profile\trunk);
%let    studyid  = %str(ORAX-01-13-US-DM);
%let    studyid2 = %str(ORAX-01-13-US);
%let   demodset  = %str(pdata.dm);
%let subjectvar  = %str(subjid);
%let       logo  = %str(icon\Kinex2.png);
%let escapechar  = %str(~);




/*------------------------------------------------------------
  Setup proper value for below parameters before each running
  ----------------------------------------------------------*/

%let    rawdatadir = %str(C:\Users\Yong\Documents\Nutstore\Janus\Projects\Patient Profile\orax\sasdset\Oraxol Data 25Feb2015);
%let newtransferID = %str(25Feb2015);
%*let oldtransferID = %str(05Dec2014);
%let        genRTF = %str(N);
%let        genPDF = %str(Y);
%let        subset = %str(02-01);
%let      dlm4subj = %str( );
%let         rerun = %str(N);
%let       compare = %str(N);
%let     debugMode = %str(Y);
%let  SkipRawDataProcessing = %str(Y);


/*------------------------------------------------------------
  Modify below parameters to change appearance
  ----------------------------------------------------------*/
%let                pdfstyle = %str(styles.pdfstyle2);
%let                rtfstyle = %str(styles.rtfstyle2);
%let                printTOC = %str(N);
%*let        suppressSysTitle = %str(Y);
%*let                newcolor = %str(#DDDDDD);
%*let                mdfcolor = %str(BLUE);
%*let             mdfvarcolor = %str(white);
%*let      sectionheadercolor = %str(cx1F497D);
%*let      sectionheaderfsize = %str(10pt);



/*------------------------------------------------------------
  Deprecated parameters
  ----------------------------------------------------------*/
/*
%let  SkipRawDataProcessing = %str(N);
%let      tableheaderbgcolor = %str(cxFFFFF1);
%let        tablebordercolor = %str(cxC1C1C1);
%let nblanklinesbetweentable = %str(3);
%let usrdefinedheadfootfsize = %str(7pt);
*/




/*!!!!-- DO NOT EDIT OR MOVE BELOW TWO LINES --!!!!*/
%include "&rootdir\src\preparation\setupSASEnvir.sas";
%setupSASEnvir;





/*------------------------------------------------------------
  project specific .
  User can create customized macro variables and include 
  customized programs.
  ----------------------------------------------------------*/

%include "&plugindir\_formats.sas";
%include "&plugindir\_publicMacros.sas";

