/*
	Program Name: QS
		@Author: Ken Cao (yong.cao@q2bi.com)
		@Initial Date: 2013/05/08 

	************************************************
	For ECOG data of KLT study.
	************************************************

*/

%include '_setup.sas';

proc format;
	invalue qsvsn
		SCREENING                      =  -1
		MONTH 0                        =  0
		MONTH 3                        =  3
		MONTH 6                        =  6
		MONTH 9                        =  7
		MONTH 12 / EARLY TERM          =  12
		Month 14 or 26 / Follow Up     =  14
		MONTH 15                       =  15
		MONTH 18                       =  18
		UNSCHEDULED                    =  99
	;
run;


data ecg0;
	set source.qs;
	where not (qsorres='' and qsstat='' and qsdtc='') and not (qsstat='NOT DONE' and upcase(visit)='UNSCHEDULED');
run;

data ecg1;
	keep subjid qstestcd qstest qsorres qsdtc visit visitnum;
	set ecg0(rename=(qsorres=qsorres_ visit=visit_ qsdtc=qsdtc_) drop=visitnum);
	length qsorres visit qsdtc $200;
	qsorres=qsorres_;
	visit=visit_;
	qsdtc=qsdtc_;
	if qsstat='NOT DONE' then qsorres='ND';
	visitnum=input(visit,qsvsn.);
	if visitnum=. and index(visit,'MONTH')=1 then visitnum=input(strip(scan(visit,2," ")),best.);
	if qsdy>. then qsdtc=strip(qsdtc)||' ('||strip(put(qsdy,10.0))||')';
run;

%getvisitnum(indata=ecg1,indtc=qsdtc,out=ecg2);

data ecg3;
	set ecg2;
	length visit2 $200;
	if upcase(visit)='SCREENING' then visit2='V__0';
	else visit2='V_'||strip(put(visitnum*10,3.0));
	if int(visitnum)^=visitnum then visit2=strip(visit2)||'_D';
run;

proc sort data=ecg3 nodupkey; by subjid visitnum qsorres;

%getinShape(indata=ecg3,indtc=qsdtc, testvar=qstest, resultvar=qsorres, out=ecg4);
%adjustVisitVarOrder(indata=ecg4,othvars=SUBJID QSTEST __ord);
data pdata.qs(label='ECOG PERFORMANCE STATUS');
	keep subjid qstest V_:;
	set ecg4;
	if __ord=2 then qstest='Date Performed (Study Day)';
	else if __ord=3 then qstest='Ecog Performance Status';
run;
