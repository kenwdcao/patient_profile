
%include "_setup.sas";

proc sort data=source.med_histhistory out=s_med_histhistory nodupkey; by _all_; run;

data mh;
     set s_med_histhistory;
     attrib
     diag   label='Diagnosis or Abnormality'
     diagdtc      length=$19       label='Date of Diagnosis'
     continue    length=$3         label='Continuing?'
     resdtc        length=$19       label='Date of Resolution'
     ;

     subjid=strip(ssid);
     if diagdt_min^='' and diagdt_max^='' then do;
         if diagdt_min=diagdt_max then diagdtc=diagdt_min;
         else if substr(diagdt_min,1,7)=substr(diagdt_max,1,7) then diagdtc=substr(diagdt_min,1,7);
         else if substr(diagdt_min,1,4)=substr(diagdt_max,1,4) then diagdtc=substr(diagdt_min,1,4);
     end;
     continue=strip(continuing_label);
     if resdt_min^='' and resdt_max^='' then do;
         if resdt_min=resdt_max then resdtc=resdt_min;
         else if substr(resdt_min,1,7)=substr(resdt_max,1,7) then resdtc=substr(resdt_min,1,7);
         else if substr(resdt_min,1,4)=substr(resdt_max,1,4) then resdtc=substr(resdt_min,1,4);
     end;
     keep subjid diag diagdtc continue resdtc;
run;

proc sort; by subjid diagdtc diag resdtc continue; run;

data pdata.mh(label='Medical History');
     retain subjid diag diagdtc continue resdtc;
     set mh;
     keep subjid diag diagdtc continue resdtc;
run;
