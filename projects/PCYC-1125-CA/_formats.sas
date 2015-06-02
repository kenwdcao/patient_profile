/*********************************************************************
 Program Nmae: _formats.sas
  @Author: Ken Cao
  @Initial Date: 2015/01/29
 
 __________________________________________________________________
 Modification History:
 xxx on yyyy/mm/dd: 


*********************************************************************/

proc format;
    value checked
    low - 0 = ' '
    1 - high = 'Yes'
    ;
run;
