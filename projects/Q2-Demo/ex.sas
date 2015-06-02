/*********************************************************************
 Program Nmae: EX.sas
  @Author: Huihui Zhang
  @Initial Date: 2015/01/29
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

 Ken Cao on 2015/02/05: Adjust variable order of final dataset.
                        Change variable label for variable exdisc.
 Ken Cao on 2015/02/24: Add EDC_EntryDate to output dataset.
 Ken Cao on 2015/02/25: Drop EXCAT from EX.
 Ken Cao on 2015/03/05: Concatenate --DY to EXSTDTC and EXENDTC.

*********************************************************************/
%include '_setup.sas';

proc sort data=source.ex out=s_ex nodupkey; by _all_; run;

data ex01;
    length subject $13 rfstdtc $10;
    if _n_ = 1 then do;
    	declare hash h (dataset:'pdata.rfstdtc');
    	rc = h.defineKey('subject');
    	rc = h.defineData('rfstdtc');
    	rc = h.defineDone();
    	call missing(subject, rfstdtc);
    end;

    length exstdtc exendtc $19 aenum $20 exadose exreasad $200 aenum1-aenum3 $20; 
    set s_ex(rename=(exadose=in_exadose exreasad=in_exreasad EDC_EntryDate = __EDC_EntryDate));
     %subject;
    if exdisc^='' then exdisc=put(exdisc,$checked.);
    exadose=catx(": ",in_exadose,exadoseo);  
    exreasad=catx(": ",in_exreasad,exreasao);  
    array aen(*) aenum01-aenum03;
    array aec(*) aenum1-aenum3;
    do i=1 to dim(aen);
        if aen(i)^=. then aec(i)=put(aen(i),best.); else aec(i)='';
    end;
    aenum=catx(", ",aenum1,aenum2,aenum3);
    %ndt2cdt(ndt=exstdt, cdt=exstdtc);
    %ndt2cdt(ndt=exendt, cdt=exendtc);

    rc = h.find();
    %concatDY(exstdtc);
    %concatDY(exendtc);
    drop rc;

    __edc_treenodeid=edc_treenodeid;
    drop edc_: in_: aenum1-aenum3 i;
run;

proc sort data=ex01; by subject exstdtc; run;


/* Ken Cao on 2015/02/05:
    Adjust variable order of final dataset.
    Change variable label for variable exdisc.
*/

data pdata.ex(label="Dose Administration");
    retain __edc_treenodeid __EDC_EntryDate subject  exstdtc exendtc exdisc exadose exreasad aenum;
    keep __edc_treenodeid __EDC_EntryDate subject  exstdtc exendtc exdisc exadose exreasad aenum;
    set ex01;
    label 
        exadose = 'Dose per Administration'
        exreasad = 'Reason for Missed/Modified Dose'
        exstdtc = 'Start Date'
        exendtc = 'End Date'
        aenum = 'AE Number'
        exdisc = 'Ibrutinib Dosing Discontinued Permanently'
    ;
run;
