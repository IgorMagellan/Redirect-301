CLOSE TABLES ALL

**** для проверки однократного запуска программы
#Define ERROR_ALREDY_EXIST 183
#Define MUTEX_NAME "{P13388SF-5FEC-4f9f-8B47-5B5MAGE13VF5}"

Declare integer CreateMutex in kernel32 integer lpMutexAttributes, ;
integer bInitialOwner, string lpName
Declare integer CloseHandle in kernel32 integer hObject
Declare integer GetLastError in kernel32 
* Открываем объект ядра (в данном случае мьютекс)
hMutex = CreateMutex(0, 0, MUTEX_NAME)
* Проверяем существует ли объект с этим именем
if GetLastError() = ERROR_ALREDY_EXIST
* если существует закрываем экземпляр приложения
  =MESSAGEBOX("Программа Redirect301 уже запущена.", 4112, 'Попытка запустить второй экземпляр программы', 9000)
  =CloseHandle(hMutex)
   CLEAR DLLS
   CANCEL
ENDIF

PUBLIC glWasError, gcPinsFileName, gcRulesFileName, gnUIDgrp, gcFindString
PRIVATE pcOldCurDir 
pcOldCurDir = SET("DIRECTORY")

*!*	PRIVATE gnTipRecalc, gnSelMinMax, gnHminVal, gnHminStep, gnHmaxVal, gnHmaxStep, gnHshift, gnShiftAll, ;
*!*	        gnHmdlVal, gnHmdlStep, gnRecNo
*!*	gnTipRecalc=1
*!*	gnSelMinMax=1
*!*	gnHminVal=0
*!*	gnHminStep=20
*!*	gnHmaxVal=1000
*!*	gnHmaxStep=20
*!*	gnHshift=0    &&-1
*!*	gnShiftAll=0
*!*	gnHmdlVal=300
*!*	gnHmdlStep=20
*!*	gnRecNo=1

glWasError=.F.
SET PROCEDURE TO R301LIB.PRG 
DO REGDLL_PROFILEAPP

ON ERROR DO ErrHandT.prg WITH ERROR(),PROGRAM(),LINENO()

SET DATABASE TO 
SET EXCLUSIVE ON
SET DELETED OFF
SET TALK OFF

gcPinsFileName= JustPath(SYS(16,0))+"\Files\PINS.DBF"
gcRulesFileName= JustPath(SYS(16,0))+"\Files\RULES.DBF"
gcFindString=""

IF FileExist(gcPinsFileName).AND.FileExist(gcRulesFileName)
   USE (gcPinsFileName) ALIAS pins
   SET ORDER TO arg 
   USE (gcRulesFileName) ALIAS rules IN 0
   SET ORDER TO IDGRP IN rules  && IDGRP
   IF glWasError.OR.!USED('rules').OR.!USED('pins')
WAIT WINDOW "ERROR OPEN"
   ELSE  
      * Берем макс UIDgrp
      SELECT rules
      CALCULATE MAX(idGrp) TO gnUIDgrp
      GO TOP
      
      DO FORM r301frm.scx 
      ACTIVATE WINDOW frmMain

     READ EVENTS    
   
   ENDIF 
ENDIF 

CD (pcOldCurDir) && Восст.текущую папку
CLOSE TABLES
=CloseHandle(hMutex)
*=MESSAGEBOX("clearing")
ON ERROR
SET PROCEDURE TO 
CLEAR DLLS
RELEASE ALL
CLEAR ALL
CLEAR PROGRAM
CLEAR MEMORY
CLEAR WINDOWS
*CLEAR RESOURCES pulsar.gif
CLEAR RESOURCES
CANCEL
