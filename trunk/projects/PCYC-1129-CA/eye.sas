/*********************************************************************
 Program Nmae: eye.sas
  @Author: Yuanmei Wang
  @Initial Date: 2015/04/27
*********************************************************************/
%include "_setup.sas";


proc format;
    value $eytestcd
"Dry Eye" = "DRYE"
"Watering Eyes/Abnormal Discharge" = "WEYE"
"Eye Pain (Left)" = "EYEPL"
"Eye Pain (Right)" = "EYEPR"
"Blurred Vision/Double Vision" = "BLUV"
"Decreased Visual Acuity (Left)" = "DVAL"
"Decreased Visual Acuity (Right)" = "DVAR"
"Photophobia/Sensitivity to Light" = "PHOTO"
"Floaters" = "FLOAT"
"Flashing Lights" = "FLASH"
"Eye Irritation" = "EYEI"
"Other Ocular Problem" = "OOCUP"
   ;
run;


data eye_;
         length subject $13 __rfstdtc $10 eyedtc eytestcd $20 EYORRES_ $200 ;
		   if _n_ = 1 then do;
        declare hash h (dataset:'pdata.dm');
        rc = h.defineKey('subject');
        rc = h.defineData('__rfstdtc');
        rc = h.defineDone();
        call missing(subject, __rfstdtc);
    end;
         set source.eye(rename=(edc_treenodeid=__edc_treenodeid edc_entrydate=__edc_entrydate));
        %subject;
		  %ndt2cdt(ndt=EYTESTDT, cdt=eyedtc);
    rc = h.find();
    %concatDY(eyedtc);
   eytestcd=put(eytest, $eytestcd.);
	if EYTEST="Other Ocular Problem" and EYORRES^="" and EYORRESO^="" then EYORRES_=strip(EYORRES)|| ": " ||strip(EYORRESO);
	else EYORRES_=EYORRES;
	label eyedtc="Assessment Date";
run;


proc sort data=eye_; by subject __edc_treenodeid __edc_entrydate eyedtc visit eyoccur; run;

proc transpose data=eye_ out=eye;
  id eytestcd;
  idlabel eytest;
     var eyorres_;
     by subject __edc_treenodeid __edc_entrydate eyedtc visit eyoccur;
run;


proc sort data=eye;by subject eyedtc;run;

data pdata.eye1(label="Eye-Related Symptoms (Screening)");
    retain __edc_treenodeid __edc_entrydate subject visit eyedtc drye weye eyepl eyepr bluv dval dvar ;
    set eye;
    keep __edc_treenodeid __edc_entrydate subject visit eyedtc drye weye eyepl eyepr bluv dval dvar ;
run;

data pdata.eye2(label="Eye-Related Symptoms (Screening) (Continued)");
    retain __edc_treenodeid __edc_entrydate subject visit eyedtc photo float flash eyei oocup eyoccur;
    set eye;
    keep __edc_treenodeid __edc_entrydate subject visit eyedtc photo float flash eyei oocup eyoccur;
	label  oocup="Other Ocular Problem, specify"
	       visit="Visit"
           eyoccur="Has the subject been evaluated by an Ophthalmologist for these symptoms?";
run;






