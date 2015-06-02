
/*********************************************************************
 Program Nmae: PEABN.sas
  @Author: ZSS
  @Initial Date: 2015/03/18
 


 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';

proc sort data=source.inc out=s_inc nodupkey; by _all_; run;
proc sort data=source.exc out=s_exc nodupkey; by _all_; run;


**** Inclusion criteria ***;
data inc;
      set s_inc(rename=(id=__id));
	  %subject;
run;

proc transpose data=inc out=ie_inc_;
       by subject __id event_no event_id;
	   var inc:;
run;

data ie_inc;
       set ie_inc_;
	   __incnum=input(substr(_name_,4), best.);
	  if col1=0;
run;

proc sort; by subject __incnum; run;

data ie1;
      length inc $200;
      set ie_inc;
	  by subject __incnum;
	  retain inc;
	  if first.subject then inc=strip(_name_);
	    else inc=strip(inc)||', '||strip(_name_);
	  if last.subject;
	  keep __id subject event_no event_id inc;
run;

**** Exclusion criteria ***;
data exc;
      set s_exc(rename=(id=__id));
	  %subject;
run;

proc transpose data=exc out=ie_exc_;
       by subject __id event_no event_id;
	   var exc:;
run;

data ie_exc;
       set ie_exc_;
	   __excnum=input(substr(_name_,4), best.);
	  if col1=1;
run;

proc sort; by subject __excnum; run;

data ie2;
      length exc $200;
      set ie_exc;
	  by subject __excnum;
	  retain exc;
	  if first.subject then exc=strip(_name_);
	    else exc=strip(exc)||', '||strip(_name_);
	  if last.subject;
	  keep __id subject event_no event_id exc;
run;

data ie;
      merge ie1(in=a) ie2(in=b);
	  by subject;
	  if a or b;
run;

proc sort data=ie; by subject; run;

data pdata.ie(label="Inclusion/Exclusion Criteria");
     retain __id subject inc exc;
     set ie;
	 attrib
/*     event_id    label = "Visit"*/
     inc            label = "Inclusion Criteria not Meet"
     exc           label = "Exclusion Criteria Meet"
	 ;
	 keep __id subject inc exc;
run;




