%include "_setup.sas";

data pdata.psadt(label='PSA Double Time');
	length graph $256;
	set pdata.dm;
	graph="Q:\WorkSpace\Public\Janus\D1--CY\R203\CY\Applications\Patient Profile\work\output\KLT-PRO-C10-069\Graphics\PSADT_";
	graph=strip(graph)||strip(subjid)||".png";
	graph="^{style [preimage='"||strip(graph)||"']}";
	keep subjid graph;
run;

