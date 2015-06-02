/*********************************************************************
 Program Nmae: su.sas
  @Author: Meiping Wu
  @Initial Date: 2015/04/27
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

*********************************************************************/

%include "_setup.sas";

data su0;
    set source.su;
    %subject;
    keep EDC_TreeNodeID SUBJECT VISIT SUYN SUTSTDY SUTSTMO SUTSTYR SUTENDY SUTENMO SUTENYR SUTONGO 
         SUTRT1 SUDSTXT1 SUDOSU1 SUDOSFR1 SUDUR1 SUONGYN1 SUTRT2 SUDSTXT2 SUDOSU2 SUDOSFR2 SUDUR2   
         SUONGYN2 SUTRT3 SUDSTXT3 SUDOSU3 SUDOSFR3 SUDUR3 SUONGYN3 SUTRT4 SUDSTXT4 SUDOSU4 SUDOSFR4 
         SUDUR4 SUONGYN4 SUTRT5 SUDSTXT5 SUDOSUO SUDOSFR5 SUDUR5 SUONGYN5 SUALCHYN SUASTDY SUASTMO  
         SUASTYR SUAENDY SUAENMO SUAENYR SUAONGO SUADSTXT SUADOSFR EDC_EntryDate;
run;


data su01(keep=edc_treenodeid subject visit suyn sutstdtc sutendtc sutongo _sutrt1 sudstxt1 sudosu1 sudosfr1 sudur1 suongyn1 edc_entrydate)
     su02(keep=edc_treenodeid subject visit suyn sutstdtc sutendtc sutongo _sutrt2 sudstxt2 sudosu2 sudosfr2 sudur2 suongyn2 edc_entrydate) 
     su03(keep=edc_treenodeid subject visit suyn sutstdtc sutendtc sutongo _sutrt3 sudstxt3 sudosu3 sudosfr3 sudur3 suongyn3 edc_entrydate)
     su04(keep=edc_treenodeid subject visit suyn sutstdtc sutendtc sutongo _sutrt4 sudstxt4 sudosu4 sudosfr4 sudur4 suongyn4 edc_entrydate) 
     su05(keep=edc_treenodeid subject visit suyn sutstdtc sutendtc sutongo _sutrt5 sudstxt5 sudosuo sudosfr5 sudur5 suongyn5 edc_entrydate)
     su06(keep=edc_treenodeid subject visit sualchyn suastdtc suaendtc suaongo _sutrt6 suadstxt suadosfr edc_entrydate);
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    set su0;

    length sutstdtc sutendtc suastdtc suaendtc _sutrt1 - _sutrt6 $20;
    %concatdate(year=sutstyr, month=sutstmo, day=sutstdy, outdate=sutstdtc);
    %concatdate(year=sutenyr, month=sutenmo, day=sutendy, outdate=sutendtc);
    %concatdate(year=suastyr, month=suastmo, day=suastdy, outdate=suastdtc);
    %concatdate(year=suaenyr, month=suaenmo, day=suaendy, outdate=suaendtc);
    rc = h.find();
    drop rc rfstdtc;
    %concatDY(sutstdtc);
    %concatDY(sutendtc);
    %concatDY(suastdtc);
    %concatDY(suaendtc);
    if sutrt1 = 'Checked' then _sutrt1 = 'Cigarette';
    if sutrt2 = 'Checked' then _sutrt2 = 'Cigar';
    if sutrt3 = 'Checked' then _sutrt3 = 'Pipe';
    if sutrt4 = 'Checked' then _sutrt4 = 'Smokeless Tobacco (chewing)';
    if sutrt5 = 'Checked' then _sutrt5 = 'Smokeless Tobacco (other)';
    if sualchyn = 'Yes' then _sutrt6 = 'Alcohol';

    if suyn = 'No' or sutrt1 = 'Checked' then output su01;
    if sutrt2 = 'Checked' then output su02;
    if sutrt3 = 'Checked' then output su03;
    if sutrt4 = 'Checked' then output su04;
    if sutrt5 = 'Checked' then output su05;
    if sualchyn ^= '' then output su06;
    drop sutstyr sutstmo sutstdy sutenyr sutenmo sutendy suastyr suastmo suastdy suaenyr suaenmo suaendy;  
run;

data su1;
    set su01-su05 su06(in=_alcohol);

    length suoccur sustdtc suendtc suong $20 sutrt sutxt sudosu sudosfr $200 sudur suongyn $20 sucat $60;
    label sucat   = 'Subcateory for Substance Use'
          suoccur = 'Occurence'
          sustdtc = 'Date first started'
          suendtc = 'Date last quit'
            suong = 'Ongoing'
            sutrt = 'Name of Substance'
            sutxt = 'Quantity'
           sudosu = 'Unit'
          sudosfr = 'Frequency'
            sudur = 'Duration (Years)'
          suongyn = 'Ongoing';

    suoccur = coalescec(suyn, sualchyn);
    sustdtc = coalescec(sutstdtc, suastdtc);
    suendtc = coalescec(sutendtc, suaendtc);
      suong = ifc(coalescec(suaongo, sutongo)='Checked', 'Yes', '');
      sutrt = coalescec(_sutrt1, _sutrt2, _sutrt3, _sutrt4, _sutrt5, _sutrt6);
      sutxt = coalescec(sudstxt1, sudstxt2, sudstxt3, sudstxt4, sudstxt5, suadstxt);
     sudosu = coalescec(sudosu1, sudosu2, sudosu3, sudosu4, sudosuo);
    sudosfr = coalescec(sudosfr1, sudosfr2, sudosfr3, sudosfr4, sudosfr5, suadosfr);
      sudur = coalescec(sudur1, sudur2, sudur3, sudur4, sudur5);
    if suaongo = 'Checked' then suaongo = 'Yes';
    suongyn = coalescec(suongyn1, suongyn2, suongyn3, suongyn4, suongyn5, suaongo);
    if _alcohol then sucat = 'Alcohol';
       else sucat = 'Tobacco'; 
run;

proc sort data = su1; by subject sucat sustdtc suendtc sutrt; run;

data pdata.su(label="Tobacco and Alcohol History");

    retain EDC_TreeNodeID EDC_EntryDate subject visit sucat suoccur sustdtc suendtc suong sutrt sutxt sudosu sudosfr sudur suongyn;
      keep EDC_TreeNodeID EDC_EntryDate subject visit sucat suoccur sustdtc suendtc suong sutrt sutxt sudosu sudosfr sudur suongyn;

    set su1;

    rename EDC_TreeNodeID = __EDC_TreeNodeID;
    rename  EDC_EntryDate = __EDC_EntryDate;
    rename          visit = __visit;

    label suoccur = 'Does this subject have a history of tobacco/alcohol use?';
run;



