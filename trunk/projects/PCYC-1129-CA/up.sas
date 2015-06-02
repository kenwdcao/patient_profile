/*********************************************************************
 Program Nmae: up.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/27
*********************************************************************/
%include "_setup.sas";

data up_;
        length subject $13 __rfstdtc $10 usdtc $20  ;
		   if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
    set source.up(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate));
    %subject;
     %visit2;
	%ndt2cdt(ndt=UNSDT, cdt=usdtc);
    rc = h.find();
    %concatDY(usdtc);
	label usdtc="Visit Date";
    unsnun07="";
   label unsnun01="Physical Exam - Complete"
      unsnun02="Physical Exam - Limited"
	  unsnun03="Vitals Signs, Height and Weight"
      unsnun04="Karnofsky Performance Status (KPS)"
	  unsnun05="Electrocardiogram"
      unsnun06="Oxygen Saturation/PFT"
	  unsnun08="Hematology (Local Lab)"
      unsnun09="Serum Chemistry (Local Lab)"
	  unsnun10="Hepatitis (Local Lab)"
	  unsnun11="Pregnancy Test"
	  unsnun12="Coagulation (Local Lab)" 
      unsnun13="T/B/NK Cell Count (Local Lab)"
	  unsnun14="Biomarkers (Local Lab)"
	  unsnun15="Pharmacokinetics (PK)" 
      unsnun16="Pharmacodynamics (PD)"
	  unsnun17="Donor Chimerism Testing (Local Lab)"
	  unsnun18="Quantitative Serum Immunoglobulins (Local Lab)" 
      unsnun19="Immunosuppressant Levels (Local Lab)"
      unsnun20="Photographic Imaging Assessment"
      unsnun21="Chronic GVHD Assessment - Clinician"
	  unsnun22="Chronic GVHD Assessment - Patient Self Report"
	  unsnun23="Lee cGVHD Symptom Scale"
	  unsnun24="cGVHD Response Assessment" 
      unsnun25="Disease Progression (PD) by Investigator"
      unsnun26="Ophthalmologic Exam"
run;

proc sort data=up_; by subject __edc_treenodeid __edc_entrydate usdtc visit2; run;

proc transpose data=up_ out=up1_;
     var unsnun01-unsnun26;
     by subject __edc_treenodeid __edc_entrydate usdtc visit2;
run;

data up;
       length  label $150;
         set up1_(where=(col1^=""));
		 label=strip(_label_);
         label label = 'Unscheduled Forms Name';
run;

proc sort data=up;by subject usdtc;run;

data pdata.up (label="Unscheduled Visit");
    retain __edc_treenodeid __edc_entrydate subject visit2 usdtc label;
    set up;
    keep __edc_treenodeid __edc_entrydate subject visit2 usdtc label;
run;






