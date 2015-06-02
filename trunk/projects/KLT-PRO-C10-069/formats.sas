proc format;
	value $VISIT
	'MONTH 0' = 'Month 0'
	'MONTH 1' = 'Month 1'
	'MONTH 2' = 'Month 2'
	'MONTH 12 / EARLY TERM' = 'Month 12 / Early Term'
	'Month 14 or 26 / Follow Up' = 'Month 14 or 26 / Follow Up'
	'MONTH 15' = 'Month 15'
	'MONTH 18' = 'Month 18'
	'MONTH 3' = 'Month 3'
	'MONTH 4' = 'Month 4'
	'MONTH 5' = 'Month 5'
	'MONTH 6' = 'Month 6'
	'MONTH 7' = 'Month 7'
	'MONTH 8' = 'Month 8'
	'MONTH 9' = 'Month 9'
	'MONTH 10' = 'Month 10'
	'MONTH 11' = 'Month 11'
	'SCREENING' = 'Screening'
	'UNSCHEDULED' = 'Unscheduled'
	'Month 12' = 'Month 12 / Early Term'
	'Month 14' = 'Month 14 or 26 / Follow Up'
	'Month 15' = 'Month 15'
	'Month 18' = 'Month 18'
	'Month 3' = 'Month 3'
	'Month 6' = 'Month 6'
	'Month 9' = 'Month 9'
	'Screening' = 'Screening'
	'Unscheduled' = 'Unscheduled'
	'Early Term' = 'Month 12 / Early Term'
	'Month 0' = 'Month 0'
	;

	value $VNUM
	'MONTH 0' = 'v_01'
	'MONTH 1' = 'v_10'
	'MONTH 2' = 'v_20'
	'MONTH 12 / EARLY TERM' = 'v_120'
	'Month 14 or 26 / Follow Up' = 'v_260'
	'MONTH 15' = 'v_150'
	'MONTH 18' = 'v_180'
	'MONTH 3' = 'v_30'
	'MONTH 4' = 'v_40'
	'MONTH 5' = 'v_50'
	'MONTH 6' = 'v_60'
	'MONTH 7' = 'v_70'
	'MONTH 8' = 'v_80'
	'MONTH 9' = 'v_90'
	'MONTH 10' = 'v_100'
	'MONTH 11' = 'v_110'
	'SCREENING' = 'v_00'
	'UNSCHEDULED' = 'v_990'
	'Month 12' = 'v_120'
	'Month 14' = 'v_260'
	'Month 15' = 'v_150'
	'Month 18' = 'v_180'
	'Month 3' = 'v_30'
	'Month 6' = 'v_60'
	'Month 9' = 'v_90'
	'Screening' = 'v_00'
	'Unscheduled' = 'v_990'
	'Early Term' = 'v_120'
	'Month 0' = 'v_01'
	;
	value $VIST
	'MONTH 0' = 'M0'
	'MONTH 1' = 'M1'
	'MONTH 2' = 'M2'
	'MONTH 12 / EARLY TERM' = 'M12 / ET'
	'Month 14 or 26 / Follow Up' = 'M14 or 26 / FU'
	'MONTH 15' = 'M15'
	'MONTH 18' = 'M18'
	'MONTH 3' = 'M3'
	'MONTH 4' = 'M4'
	'MONTH 5' = 'M5'
	'MONTH 6' = 'M6'
	'MONTH 7' = 'M7'
	'MONTH 8' = 'M8'
	'MONTH 9' = 'M9'
	'MONTH 10' = 'M10'
	'MONTH 11' = 'M11'
	'SCREENING' = 'Screening'
	'UNSCHEDULED' = 'UNS'
	'Month 12' = 'M12 / ET'
	'Month 14' = 'M14 or 26 / FU'
	'Month 15' = 'M15'
	'Month 18' = 'M18'
	'Month 3' = 'M3'
	'Month 6' = 'M6'
	'Month 9' = 'M9'
	'Screening' = 'Screening'
	'Unscheduled' = 'UNS'
	'Early Term' = 'M12 / ET'
	'Month 0' = 'M0'
	;

	value $race
	'WHITE'='White'
	'BLACK OR AFRICAN AMERICAN'='Black or African American'
   'OTHER'='Other'
	 ;

	value aetoxgr
	.=' '
	1='Grade 1: Mild'
	2='Grade 2: Moderate'
	3='Grade 3: Severe'
	4='Grade 4: Life-threatening or disabling'
	5='Grade 5: Death related to AE'
	;

	invalue VNUM
	'Month 0' = 1
	'Month 1' = 10
	'Month 2' = 20
	'Month 12 / Early Term' = 120
	'Month 14 or 26 / Follow Up' = 260
	'Month 15' = 150
	'Month 18' = 180
	'Month 3' = 30
	'Month 4' = 40
	'Month 5' = 50
	'Month 6' = 60
	'Month 7' = 70
	'Month 8' = 80
	'Month 9' = 90
	'Month 10' = 100
	'Month 11' = 110
	'Screening' = 0
	'Unscheduled' = 990
	'Label'=0
	;

	value VNUM
	1 = 'M0'
	10 = 'M1' 
	20 = 'M2'
	120 = 'M12 / ET'
	260 = 'M14 or 26 / FU'
	150 = 'M15'
	180 = 'M18'
	30 = 'M3'
	40 = 'M4'  
	50 = 'M5'  
	60 = 'M6'  
	70 = 'M7'  
	80 = 'M8'  
	90 = 'M9'  
	100 = 'M10'  
	110 = 'M11'  
	0 = 'Baseline'  
	990 = 'UNS' 
	;

	value $yn
		'N' = 'No'
		'Y' = 'Yes'
		'n' = 'No'
		'y' = 'Yes'
	;

	value $lbchem
	'Triglycerides' = 'Triglycerides'
	'Total Protein' = 'Total Protein'
	'Total Bili' = 'Total Bilirubin'
	'Sodium' = 'Sodium'
	'Potassium' = 'Potassium'
	'LDL Direct' = 'LDL'
	'HDL' = 'HDL'
	'Glucose, Serum' = 'Glucose'
	'Creatinine' = 'Creatinine'
	'Cholesterol' = 'Total Cholesterol'
	'Chloride' = 'Chloride'
	'Calcium' = 'Calcium'
	'Blood Urea Nitrogen' = 'BUN'
	'Bicarbonate' = 'Bicarbonate'
	'AST (SGOT)' = 'SGOT/AST'
	'ALT (SGPT)' = 'SGPT/ALT'
	'Alkaline Phosphatase' = 'Alkaline Phosphatase'
	'Albumin' = 'Albumin'
	;

	value $VSTEST
	'Systolic Blood Pressure' = 'Systolic Blood Pressure'
	'Diastolic Blood Pressure' = 'Diastolic Blood Pressure'
	'Pulse' = 'Heart Rate'
	'Respiratory Rate' = 'Respiration Rate'
	'Temperature' = 'Oral Body Temperature'
	'Weight' = 'Weight'
	'Height' = 'Height'
	;

	value $RDTEST
	'CT - CHEST / ABDOMEN / PELVIS' = 'CT - Chest / Abdomen / Pelvis'
	'WHOLE BODY' = 'Whole Body'
	;

	value $RDSITE
	'01' = 'Adrenal'
	'02' = 'Bladder'
	'03' = 'Bone'
	'04' = 'Chest Wall'
	'05' = 'Distant Lymph Nodes'
	'06' = 'Intestine'
	'07' = 'Kidney'
	'08' = 'Liver'
	'09' = 'Lung'
	'10' = 'Mediastinum'
	'11' = 'Pelvis (Bone Disease)'
	'12' = 'Pelvis (Soft Tissue)'
	'13' = 'Pericardium'
	'14' = 'Peritoneum'
	'15' = 'Prostate'
	'16' = 'Regional Lymph Nodes'
	'17' = 'Skin'
	'18' = 'Soft Tissue'
	'19' = 'Subcutaneous'
	'93' = 'Other'
	;

	value $qsorres
	'0' = '0 = Fully active, able to carry on all pre-disease performance without restriction'
	'1' = '1 = Restricted in physically strenuous activity but ambulatory and able to carry out work of a light or sedentary nature, e.g., light house work, office work'
	'2' = '2 = Ambulatory and capable of all selfcare but unable to carry out any work activities. Up and about more than 50% of waking hours'
	'3' = '3 = Capable of only limited selfcare, confined to bed or chair more than 50% of waking hours'
	'4' = '4 = Completely disabled. Cannot carry on any selfcare. Totally confined to bed or chair'
	'5' = '5 = Dead'
	;

	value $pe
	'NORMAL'='No'	
	'ABNORMAL'='Yes'
	;

	value $petest
	'MUSCULOS' = 'Musculoskeletal/Extremities'
	'SKIN' = 'Skin'
	'ABDOMEN' = 'Abdomen'
	'HEENT' = 'HEENT'
	'OTHER' = 'Other'
	'CARDIOVA' = 'Cardiovascular'
	'NEUROLOG' = 'Neurological'
	'GENERAL' = 'General Appearance'
	;

run;
