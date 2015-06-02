/********************************************************************************
 Program Nmae: _formats.sas
  @Author: 
  @Initial Date: 2015/02/26
 
 Pulic (shared) format goes here.
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 

********************************************************************************/
proc format ;
  value $visit
  "SE_SCREENING_1609" = "Screening"
"SE_BASELINE_525" = "Baseline"
"SE_C1D1" = "Cycle 1 Day 1"
"SE_C1D2345" = "Cycle 1 Day 2,3,4,5"
"SE_C1D81522" = "Cycle 1 Day 8,15,22"
"SE_CYCLE2DAY1" = "Cycle 2+ Day 1"
"SE_CYCLE2DAY15" = "Cycle 2+ Day 15"
"SE_FINALVISIT_8523" = "Final Visit"
"SE_EARLYTERM_6964" = "Early Term"
;

value $avisit
"Screening" = "Screening"
"Baseline" = "Baseline"
"C1D1" = "Cycle 1 Day 1"
"C1D5" = "Cycle 1 Day 5"
"C1D8" = "Cycle 1 Day 8"
"C1D15" = "Cycle 1 Day 15"
"C1D22" = "Cycle 1 Day 22"
"C2D1" = "Cycle 2 Day 1"
"C2D8" = "Cycle 2 Day 8"
"C2D15" = "Cycle 2 Day 15"
"C3D1" = "Cycle 3 Day 1"
"C3D8" = "Cycle 3 Day 8"
"C3D15" = "Cycle 3 Day 15"
"C4D1" = "Cycle 4 Day 1"
"C4D8" = "Cycle 4 Day 8"
"C4D15" = "Cycle 4 Day 15"
"C5D1" = "Cycle 5 Day 1"
"C5D8" = "Cycle 5 Day 8"
"C5D15" = "Cycle 5 Day 15"
"C6D1" = "Cycle 6 Day 1"
"C6D8" = "Cycle 6 Day 8"
"C6D15" = "Cycle 6 Day 15"
"C7D1" = "Cycle 7 Day 1"
"C7D8" = "Cycle 7 Day 8"
"C7D15" = "Cycle 7 Day 15"
"C8D1" = "Cycle 8 Day 1"
"C8D8" = "Cycle 8 Day 8"
"C8D15" = "Cycle 8 Day 15"
"C9D1" = "Cycle 9 Day 1"
"C9D8" = "Cycle 9 Day 8"
"C9D15" = "Cycle 9 Day 15"
"C10D1" = "Cycle 10 Day 1"
"C10D8" = "Cycle 10 Day 8"
"C10D15" = "Cycle 10 Day 15"
"C11D1" = "Cycle 11 Day 1"
"C11D8" = "Cycle 11 Day 8"
"C11D15" = "Cycle 11 Day 15"
"C12D1" = "Cycle 12 Day 1"
"Final visit" = "Final visit"
"Early Term" = "Early Term"
"End of Study" = "End of Study"
;
value $visitnum
"Screening" = 1
"Baseline" =2
"Cycle 1 Day 1" =3
"Cycle 1 Day 2,3,4,5" =4
"Cycle 1 Day 8,15,22" =5
"Cycle 2+ Day 1" =6
"Cycle 2+ Day 15" =7
"Final Visit" =9
"Early Term" =8
;
value $avistn
"Screening" =1
"Baseline" =2
"C1D1" =3
"C1D5" =4
"C1D8" =5
"C1D15" =6
"C1D22" =7
"C2D1" =8
"C2D8" =9
"C2D15" =10
"C3D1" =11
"C3D8" =12
"C3D15" =13
"C4D1" =14
"C4D8" =15
"C4D15" =16
"C5D1" =17
"C5D8" =18
"C5D15" =19
"C6D1" =20
"C6D8" =21
"C6D15" =22
"C7D1" =23
"C7D8" =24
"C7D15" =25
"C8D1" =26
"C8D8" =27
"C8D15" =28
"C9D1" =29
"C9D8" =30
"C9D15" =31
"C10D1" =32
"C10D8" =33
"C10D15" =34
"C11D1" =35
"C11D8" =36
"C11D15" =37
"C12D1" =38
"Final visit" =70
"Early Term" =60
"End of Study" =80
;

value miss
. = ''
;
run;
