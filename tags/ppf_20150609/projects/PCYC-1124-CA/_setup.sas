

/*------------------------------------------------------------
  Setup below parameters before first running   
  ----------------------------------------------------------*/

%let    rootdir = %str(C:\Users\Yong\Documents\SVN\working copy\patient profile\trunk);
%let    studyid = %str(PCYC-1124-CA);
%let   demodset = %str(dm);
%let subjectvar = %str(subject);
%let       logo = %str(icon\pcyc.jpg);
%let escapechar = %str(~);




/*------------------------------------------------------------
  Setup proper value for below parameters before each running
  ----------------------------------------------------------*/

%let    rawdatadir = %str(C:\Users\Yong\Documents\Nutstore\Janus\Projects\Patient Profile\pcyc-1124\Source Datasets\20150506);
%let newtransferID = %str(06May2015);
%let oldtransferID = %str(15Apr2015);
%let        genRTF = %str(N);
%let        genPDF = %str(Y);
%*let        subset = %str(205-112);
%let      dlm4subj = %str( );
%let         rerun = %str(Y);
%let       compare = %str(Y);
%let     debugMode = %str(Y);


%let   SkipRawDataProcessing = %str(N);
%let       showDeletedRecord = %str(Y);
%let           showCoverPage = %str(Y);


/*------------------------------------------------------------
  Modify below parameters to change appearance
  ----------------------------------------------------------*/
%*let                pdfstyle = %str(styles.pdfstyle2);
%*let                rtfstyle = %str(styles.rtfstyle2);
%*let        suppressSysTitle = %str(Y);
%*let                newcolor = %str(#DDDDDD);
%*let                mdfcolor = %str(BLUE);
%*let             mdfvarcolor = %str(white);



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

