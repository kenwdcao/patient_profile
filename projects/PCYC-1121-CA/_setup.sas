

/*------------------------------------------------------------
  Setup below parameters before first running   
  ----------------------------------------------------------*/

%let    rootdir = %str(C:\Users\Yong\Documents\SVN\working copy\patient profile\trunk);
%let    studyid = %str(PCYC-1121-CA);
%let   demodset = %str(dm);
%let subjectvar = %str(subject);
%let       logo = %str(icon\pcyc.jpg);
%let escapechar = %str(^);




/*------------------------------------------------------------
  Setup proper value for below parameters before each running
  ----------------------------------------------------------*/

%let    rawdatadir = %str(C:\Users\Yong\Documents\Nutstore\Janus\Projects\Patient Profile\pcyc-1121\Raw Datasets\01Jun2015);
%let newtransferID = %str(01Jun2015);
%let oldtransferID = %str(20Apr2015);
%let        genRTF = %str(N);
%let        genPDF = %str(Y);
%*let     pdfFormat = %str(PDF);
%*let        subset = %str(407-008);
%let      dlm4subj = %str( );
%let         rerun = %str(Y);
%let       compare = %str(Y);
%let     debugMode = %str(Y);

%let SkipRawDataProcessing = %str(Y);
%let           SkipCompare = %str(Y);
%let     showDeletedRecord = %str(Y);





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

