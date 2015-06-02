

/*------------------------------------------------------------
  Setup below parameters before first running   
  ----------------------------------------------------------*/

%let    rootdir = %str(C:\Users\Yong\Documents\SVN\working copy\patient profile\trunk);
%let    studyid = %str(Q2-Demo);
%let   demodset = %str(pdata.dm);
%let subjectvar = %str(subject);
%let       logo = %str(icon\janus.jpg);
%*let     slogon = %str(^{style [fontweight=bold foreground=blue fontstyle=italic fontsize=10pt]Quality Work for Quality World});
%let escapechar = %str(^);
%let splitchar  = %str(~);




/*------------------------------------------------------------
  Setup proper value for below parameters before each running
  ----------------------------------------------------------*/

%let    rawdatadir = %str(C:\Users\Yong\Documents\Nutstore\Janus\Projects\Patient Profile\pcyc-1121\Raw Datasets\17Feb2015);
%let newtransferID = %str(17Feb2015);
%let oldtransferID = %str(05Dec2014);
%let        genRTF = %str(Y);
%let        genPDF = %str(Y);
%let     pdfFormat = %str(PDF);
%let        subset = %str(047-004);
%let      dlm4subj = %str( );
%let         rerun = %str(Y);
%let       compare = %str(Y);
%let     debugMode = %str(Y);


%let     showDeletedRecord = %str(Y);
%let SkipRawDataProcessing = %str(Y);
%let           skipCompare = %str(Y);


/*------------------------------------------------------------
  Change below parameters to change appearance
  ----------------------------------------------------------*/
%*let                pdfstyle = %str(styles.pdfstyle2);
%*let                rtfstyle = %str(styles.rtfstyle2);
%*let        suppressSysTitle = %str(Y);
%*let                newcolor = %str( );
%*let                mdfcolor = %str( );
%*let             mdfvarcolor = %str( );
%*let             delcolor    = %str( );



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
