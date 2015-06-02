@REM Created by Ken Cao on 2014/04/24
@echo off

for %%d in (.) do set currDirName='%%~nd'
start sas.exe -sysin ../../L_patient_profile.sas -SASINITIALFOLDER "..\..\" -SYSPARM %currDirName% -LS MAX