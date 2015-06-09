/*********************************************************************
 Program Nmae: AE.sas
  @Author: Ken Cao
  @Initial Date: 2015/03/12
 


 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 
 Ken Cao on 2015/03/16: Combine some variables in AE2.

*********************************************************************/

%include '_setup.sas';


** read from source datasets;
data ae0;
    set source.ae;
    drop proj_id subinit state;
run;


*** programs begins here;
data ae1;
    length subject $255 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set ae0(rename = (aestdtc=__aestdtc aeenddtc=__aeenddtc id=__id));

    %subject;

    rc = h.find();
    length aestdtc aeendtc $20;
    label aestdtc = 'Start Date';
    label aeendtc = 'End Date';
    aestdtc = __aestdtc;
    aeendtc = __aeenddtc;
    %concatDY(aestdtc);
    %concatDY(aeendtc);
    drop __aestdtc __aeenddtc rc;



    length aeacni aeacnr $255;
    label aeacni = 'Action Taken with Ibrutinib';
    label aeacnr = 'Action Taken with Rituximab';
    
    array __ibrutinib{3} aeacn02 aeacn03 aeacn12;
    array __ibrutinib2{3} $40 _temporary_ ('Dose Reduced', 'Dose Delay', 'Permanently Discontinued');

    do i = 1 to 3;
        if __ibrutinib[i] = . then continue;
        aeacni = ifc(aeacni>' ', strip(aeacni)||', '||__ibrutinib2[i], __ibrutinib2[i]);
    end;

    array __rituximab{4} aeacn09 aeacn10 aeacn13 aeacn11;
    array __rituximab2{4} $40 _temporary_ ('Dose Reduced' 'Dose Delay' 'Permanently Discontinued' 'Dose Interruption');

    do i = 1 to 4;
        if __rituximab[i] = . then continue;
        aeacnr = ifc(aeacnr>' ', strip(aeacnr)||', '||__rituximab2[i], __rituximab2[i]);
    end;

    drop i;

run;

proc sort data=ae1; by subject aestdtc aeendtc aeterm; run;


data pdata.ae1(label='Adverse Event');
    retain __id subject aenum  aeterm duetopd sae styproc overdose aestdtc aeout aeendtc aesev aerel01 aerel02;
    keep __id subject aenum  aeterm duetopd sae styproc overdose aestdtc aeout aeendtc aesev aerel01 aerel02;
    set ae1;
    label overdose = 'Associated with Overdose';
run;



data pdata.ae2(label='Adverse Event (Action Taken)');
    retain __id subject aenum  aeterm aeacn01 aeacn02 aeacn03 aeacn12 aeacni aeacn09 aeacn10 aeacn13 aeacn11 aeacnr 
          aeacn04 aeacn05 aeacn06 aeacn07 aeacnos ;
    keep __id subject aenum  aeterm aeacn01 aeacn02 aeacn03 aeacn12 aeacni aeacn09 aeacn10 aeacn13 aeacn11 aeacnr 
          aeacn04 aeacn05 aeacn06 aeacn07 aeacnos ;

    set ae1;

    label AEACN01 = 'None';

    label AEACN02 = 'Dose Reduced';
    label AEACN03 = 'Dose Delay';
    label AEACN12 = 'Study Drug Permanently Discontinued';

    label AEACN09 = 'Dose Reduced';
    label AEACN10 = 'Dose Delay';
    label AEACN13 = 'Study Drug Permanently Discontinued';
    label AEACN11 = 'Dose Interruption';

    label AEACN04 = 'Permanently Withdrawn from Study';
    label AEACN05 = 'Medication';
    label AEACN06 = 'Non-drug therapy';
    label AEACN07 = 'Hospitalization/prolongation of Hospital';
    label AEACNOS = 'Other Action Taken(Specify)';

    format aeacn01 - aeacn13 checked.;
    rename aeacn09 =__aeacn09 aeacn10 = __aeacn10 aeacn13 = __aeacn13 aeacn11 = __aeacn11;
    rename aeacn02 = __aeacn02 aeacn03 = __aeacn03 aeacn12 = __aeacn12;

run;
