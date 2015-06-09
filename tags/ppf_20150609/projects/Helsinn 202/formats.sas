proc format;
	invalue visitnum
	"Adverse Events"								=	0
	"Screening Visit (V1A)"							=	0
	"Concomitant Medications"						=	0
	"Hospital Admission (V1B)"						=	0.2
	"Post Procedure (V1C)"							=	0.3
	"Study Completion/Discontinuation"				=	1
	"Study Drug Administration"						=	1
	"Post-Op Day 1 (V2)"							=	2
	"Post-Op Day 2 (V3)"							=	3
	"Post-Op Day 3 (V4)"							=	4
	"Post-Op Day 4 (V5)"							=	5
	"Post-Op Day 5 (V6)"							=	6
	"Post-Op Day 6 (V7)"							=	7
	"Post-Op Day 7 (V8)"							=	8
	"Post-Op Day 8 - Visit Optional A (VOA)"		=	9.1
	"Post-Op Day 9 - Visit Optional B (VOB)"		=	9.2
	"Post-Op Day 10 - Visit Optional C (VOC)"		=	9.3
	"Hospitalization Summary (V100)"				=	100
	"Outpatient/14 Day Follow-up (V101)"			=	101
	"Unscheduled"									=	999
	"Unscheduled 2"									=	999.2
	;
	value $visit
	'Adverse Events'								=	'Adverse Events'
	'Screening Visit (V1A)'							=	'Screening Visit (V1A)'
	'Post-Op Day 1 (V2)'							=	'Post-Op Day 1 (V2)'
	'Post-Op Day 2 (V3)'							=	'Post-Op Day 2 (V3)'
	'Post-Op Day 4 (V5)'							=	'Post-Op Day 4 (V5)'
	'Post-Op Day 5 (V6)'							=	'Post-Op Day 5 (V6)'
	'Post-Op Day 6 (V7)'							=	'Post-Op Day 6 (V7)'
	'Post-Op Day 7 (V8)'							=	'Post-Op Day 7 (V8)'
	'Post-Op Day 8 - Visit Optional A (VOA)'		=	'Post-Op Day 8 - VOA'
	'Outpatient/14 Day Follow-up (V101)'			=	'Outpatient/14 Day FU'
	'Unscheduled'									=	'Unscheduled'
	'Unscheduled 2'									=	'Unscheduled 2'
	'Concomitant Medications'						=	'Con. Medications'
	'Study Completion/Discontinuation'				=	'Study Comp. / Discont.'
	'Hospitalization Summary (V100)'				=	'Hosp. Summary'
	'Post Procedure (V1C)'							=	'Post Procedure (V1C)'
	'Post-Op Day 3 (V4)'							=	'Post-Op Day 3 (V4)'
	'Hospital Admission (V1B)'						=	'Hospital Admission'
	'Post-Op Day 9 - Visit Optional B (VOB)'		=	'Post-Op Day 9 - VOB'
	'Post-Op Day 10 - Visit Optional C (VOC)'		=	'Post-Op Day 10 - VOC'
	'Study Drug Administration'						=	'Study Drug Admin.'
	;

	value $crfstat
	'Monitored Reviewed'							=	'MR'
	'Monitored'										=	'M'
	'Complete Reviewed'								=	'CR'
	'Complete'										=	'C'
	'Incomplete'									=	'I'
	'Partial Monitored'								=	'PM'
	;

run;
