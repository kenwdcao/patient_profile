/*********************************************************************
 Program Nmae: _formats.sas
  @Author: Ken Cao
  @Initial Date: 2015/01/29
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

proc format;
    value $checked
        'Checked' = 'Yes'
    ;

    value $checkeds
        'Checked' = 'Y'
    ;
run;


proc format;
    value $month
    'JAN' = '01'
    'FEB' = '02'
    'MAR' = '03'
    'APR' = '04'
    'MAY' = '05'
    'JUN' = '06'
    'JUL' = '07'
    'AUG' = '08'
    'SEP' = '09'
    'OCT' = '10'
    'NOV' = '11'
    'DEC' = '12'
    'UNK' = ' '
    ;
run;


proc format;
    value d2b /* format to convert numeric missing value (period) to blank */
    . = ' '
    ;
run;
