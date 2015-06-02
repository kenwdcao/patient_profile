/*********************************************************************
 Program Nmae: FL.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/03/13
 
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 

*********************************************************************/

%include '_setup.sas';

data fl;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;

    length fldxdtc tobstdtc tobendtc alcstdtc alcendtc $20;
    set source.fl(rename=(fldxdtc=fldxdtc_ tobstdtc=tobstdtc_ tobendtc=tobendtc_ alcstdtc=alcstdtc_ alcendtc=alcendtc_));
    %subject;
    fldxdtc=fldxdtc_;
    tobstdtc=tobstdtc_;
    tobendtc=tobendtc_;
    alcstdtc=alcstdtc_;
    alcendtc=alcendtc_;
    rc = h.find();
    %*concatDY(tobstdtc);
    %*concatDY(tobendtc);
    %*concatDY(alcstdtc);
    %*concatDY(alcendtc);
    __id=id;
    keep __id subject fldxdtc flgrd flstg tobsu tobstdtc tobendtc tobongo tobcig tobpipe tobsmkls alcsu alcstdtc alcendtc alcongo
        alctxt alcfreq;
run;

proc sort data=fl;by subject fldxdtc;run;

data pdata.fl1(label="Follicular Lymphoma/Tobacco/Alcohol Hx");
    retain __id subject fldxdtc flgrd flstg tobsu tobstdtc tobendtc tobongo tobcig tobpipe tobsmkls;
    attrib
    fldxdtc         label="Date of Initial FL Diagnosis"
    tobsu           label="Does the subject have a history of tobacco use?"
    tobstdtc        label="If Yes, Date First Started"
    tobendtc        label="Date Last Quit"
    tobongo         label="Ongoing"
    tobcig         label="Cigarette smokers: how many packs per day?"
    tobpipe         label="Pipe and cigar smokers: how many times per day?"
    tobsmkls         label="Smokeless tobacco users: how many times per day?"
    ;
    set fl;
    keep __id subject fldxdtc flgrd flstg tobsu tobstdtc tobendtc tobongo tobcig tobpipe tobsmkls;
run;

data pdata.fl2(label="Follicular Lymphoma/Tobacco/Alcohol Hx (Continued)");
    retain __id subject alcsu alcstdtc alcendtc alcongo alctxt alcfreq;
    attrib
    alcsu         label="Does the subject have a history of alcohol use?"
    alcstdtc        label="If Yes, Date First Started"
    alcendtc        label="Date Last Quit"
    alcongo         label="Ongoing"
    alctxt         label="Drinks Subject Consume"
    alcfreq         label="Drinks Frequency"
    ;
    set fl;
    keep __id subject alcsu alcstdtc alcendtc alcongo alctxt alcfreq;
run;
