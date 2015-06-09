/*********************************************************************
 Program Nmae: _formats.sas
  @Author: Ken Cao
  @Initial Date: 2015/04/08
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

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
    'UNK' = 'UNK'
    ;

     value checked
     1='Yes';


    value checkyes
     1='Yes';

	 value TYPE
     1='Autologous'
     2='Allogeneic'
     3='Systemic'
     4='Radiation'
     5='Surgery'
     6='Stem Cell Transplant'
     7='Curative'
     8='Palliative'
     9='Other';
run;


