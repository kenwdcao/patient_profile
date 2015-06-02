

/*------------------------------------------------------------
  Setup below parameters before first running   
  ----------------------------------------------------------*/

%let    rootdir = %str(C:\Users\Yong\Documents\SVN\working copy\patient profile\trunk);
%let    studyid = %str(PCYC-1125-CA);
%let   demodset = %str(pdata.dm);
%let subjectvar = %str(subject);
%let       logo = %str(icon\pcyc.jpg);
%let escapechar = %str(~);




/*------------------------------------------------------------
  Setup proper value for below parameters before each running
  ----------------------------------------------------------*/

%let    rawdatadir = %str(C:\Users\Yong\Documents\Nutstore\Janus\Projects\Patient Profile\pcyc-1125\Source Datasets\26Jan2015);
%let newtransferID = %str(26Jan2015);
%let oldtransferID = %str();
%let        genRTF = %str(N);
%let        genPDF = %str(Y);
%let        subset = %str(032-101);
%let      dlm4subj = %str( );
%let         rerun = %str(N);
%let       compare = %str(N);
%let     debugMode = %str(Y);



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
%let   SkipRawDataProcessing = %str(N);
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
%let   abovecolor = red;   ** value above upper limit **;
%let   belowcolor = blue;  ** value below lower limit **;
%let norangecolor = cxA1A1A1; ** value without a normal range **;

%include "&plugindir\_formats.sas";
%include "&plugindir\_publicMacros.sas";
%include "&rawdatadir\formats.sas";