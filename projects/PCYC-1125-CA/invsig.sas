/*********************************************************************
 Program Nmae: INVSIG.sas
  @Author: Zhuoran Li
  @Initial Date: 2015/03/16
 
__________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

%include '_setup.sas';


** read from source datasets;

data invsig;
	set source.invsig;
	%subject;
	__id=id;
	keep __id subject APP;
run;

data pdata.invsig(label="Investigator");
	retain __id subject APP;
	set invsig;
	keep __id subject APP;
run;
