/*********************************************************************
 Program Nmae: PEABN.sas
  @Author: ZSS
  @Initial Date: 2015/03/13
 


 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc sort data=source.spe out=s_spe nodupkey; by _all_; run;
proc sort data=source.spe1 out=s_spe1 nodupkey; by _all_; run;

**** physical exam ***;
data spe;
      set s_spe;

	  %subject;

	  rename id=__id;
	  if pend^=1;
run;

proc sort data=spe; by __id subject event_no event_id  pedtc;
proc transpose data=spe out=spe_1(rename=(_label_=__test));
      by __id subject event_no event_id pedtc;
	  var petest1 petest2 petest3 petest4 petest5 petest6 petest7 petest9;
run;

proc transpose data=spe out=spe_2;
      by __id subject event_no event_id pedtc;
	  var pecom1 pecom2 pecom3 pecom4 pecom5 pecom6 pecom7 pecom9;
run;

proc sql;
     create table pe_0 as 
	 select a.*, b.col1 as abndes length=200 from spe_1 as a left join spe_2 as b
	 on a.__id=b.__id and a.subject=b.subject and substr(a._name_,7)=substr(b._name_,6);
quit;

**** additional physical exam ****;
data spe1;
     length __test1 $200;
     set s_spe1(rename=(id=__id petest=in_result));

	 %subject;

	 if petst=1 then __test1="Musculoskeletal";
	     else if petst=2 then __test1="Nervous";
		    else if petst=99 and petstsp^='' then __test1="Other: "||strip(petstsp);
			else if petst=99 then __test1="Other";
run;

proc sql;
    create table spe1_0 as 
    select a.*, b.pedtc from spe1 as a left join
	(select distinct subject, event_no, pedtc from pe_0) as b on a.subject=b.subject and a.event_no=b.event_no;
quit;

*** pe all ***;
data peall;
    length test result $200;
    set pe_0(in=in0) spe1_0(in=in1);
	if in0 then do test=strip(__test); result=strip(put(col1, genapp.)); end;
	if in1 then do test=strip(__test1); result=strip(put(in_result, petest.)); abndes=strip(pecom); end;
run;

data peabn;
    length rfstdtc $10;
    set peall(rename=(pedtc=__pedtc));
    if _n_ = 1 then do;
        declare hash h (dataset:'pdata.rfstdtc');
        rc = h.defineKey('subject');
        rc = h.defineData('rfstdtc');
        rc = h.defineDone();
        call missing(subject, rfstdtc);
    end;
    rc = h.find();
    length pedtc $20;   
    pedtc = __pedtc;
    %concatDY(pedtc);

	**** filter out ****;
    if result='Abnormal';
run;

proc sort data=peabn; by subject pedtc event_no test; run;

data pdata.peabn(label="Physical Exam (Abnormal Finding)");
     retain __id subject __event_no event_id pedtc test result abndes;
     set peabn(rename=(event_no=__event_no));
	 attrib
     event_id          label = "Visit"
     pedtc              label = "Assessment Date"
     test                label = "Test"
     result             label = "Result"
     abndes          label = "Abnormal Description"
	 ;
	 keep __id subject __event_no event_id pedtc test result abndes;
run;




