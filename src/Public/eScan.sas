
*-->enhanced scan. devide string into two;
%macro eScan(InStr=,count=,side=,delimters=); 
	%local i j len char charnext dlmnum pos;

	%let InStr=%sysfunc(strip(&InStr));
	%if %eval(%scan(&InStr,&count,&delimters) eq) and %eval(%scan(&InStr,%eval(&count-1),&delimters) eq) %then %do;
		%put ERROR: Second parameter COUNT exceeds validity.;
		%goto EXIT;
	%end;
	%else %do;
		%if %eval(&count gt 0) %then  %do;
			%let dlmnum=0;
			%let i=1;
			%let len=%length(&InStr);
			%do %until(&dlmnum eq &count);
				%if %eval(&i gt &len) %then %do;
					%let IsError=1;
					%put ERROR: Value of parameter COUNT is out of range;
					%goto EXIT;
				%end;
				%let char=%substr(&InStr,&i,1);
				%let charnext=%substr(&InStr,%eval(&i+1),1);
				%if %index(&delimters,&char) and not %index(&delimters,&charnext) %then %do;
					%let dlmnum=%eval(&dlmnum+1);
				%end;

				%let i=%eval(&i+1);
				%let char=%substr(&InStr,&i,1);;
			%end;

			%if &i le &len %then %let i=%eval(&i-1);
			%else %let i=&len;
		%end;
		%else %if %eval(&count lt 0) %then %do;
			%let dlmnum=0;
			%let len=%length(&InStr);
			%let i=&len;
			%do %until(&dlmnum eq &count);
				%if %eval(&i lt 1) %then %do;
					%let IsError=1;
					%put ERROR: Value of parameter COUNT is out of range;
					%goto EXIT;
				%end;
				%let char=%substr(&InStr,&i,1);
				%let charnext=%substr(&InStr,%eval(&i-1),1);
				%if %index(&delimters,&char) and not %index(&delimters,&charnext) %then %do;
					%let dlmnum=%eval(&dlmnum-1);
				%end;

				%let i=%eval(&i-1);
				%let char=%substr(&InStr,&i,1);;
			%end;

			%if &i ge 1 %then %let i=%eval(&i+1);
			%else %let i=1;
		%end;
		%put &i;

		%if %upcase(&side) eq L %then %do;
			%let char=%substr(&InStr,&i,1);
			%do %until(not %index(&delimters,&char));
				%let i=%eval(&i-1);
				%let char=%substr(&InStr,&i,1);
			%end;
		%end;
		%else %if %upcase(&side) eq R %then %do;
			%let char=%substr(&InStr,&i,1);
			%do %until(not %index(&delimters,&char));
				%let i=%eval(&i+1);
				%let char=%substr(&InStr,&i,1);
			%end;
		%end;
		%put &i;

		%let pos=&i;

		%if %eval(%upcase(&side) eq L) %then %let outstr=%substr(&InStr,1,&pos);
		%else %if %eval(%upcase(&side) eq R) %then %let outstr=%substr(&InStr,&pos);
		%else %let outstr=;
	%end;
%EXIT: %mend eScan;

