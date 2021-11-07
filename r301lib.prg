#INCLUDE [..\INCLUDE\TPDSL.H]
PROCEDURE REGDLL_PROFILEAPP

*-- DECLARE DLL statements for reading/writing to private INI files
DECLARE INTEGER GetPrivateProfileString IN Win32API  AS GetPrivStr ;
  String cSection, String cKey, String cDefault, String @cBuffer, ;
  Integer nBufferSize, String cINIFile

DECLARE INTEGER WritePrivateProfileString IN Win32API AS WritePrivStr ;
  String cSection, String cKey, String cValue, String cINIFile
  
* --Для перевода клавиатуры на русский язык
DECLARE INTEGER GetKeyboardLayoutName IN user32 STRING @pwszKLID 
DECLARE INTEGER ActivateKeyboardLayout IN user32 INTEGER hkl, INTEGER Flags 

DECLARE INTEGER ShellExecute IN SHELL32.dll ;  
  		INTEGER nWinHandle, ;  
  		STRING cOperation, ;  
  		STRING cFileName, ;  
  		STRING cParameters, ;  
  		STRING cDirectory, ;  
  		INTEGER nShowWindow  
ENDPROC

FUNCTION LoadPrivStr
LPARAMETERS pcSection, pcStr, pcDefValue, pcINIfile
* Читает строку из INI файла
LOCAL lcBuffer, lcRetStr
lcBuffer = SPACE(60) + CHR(0)
IF GetPrivStr(pcSection, pcStr, pcDefValue, @lcBuffer,;
              LEN(lcBuffer),pcINIfile)>0
   lcRetStr=LEFT(lcBuffer,AT(CHR(0),lcBuffer,1)-1)
ELSE
   lcRetStr=pcDefValue
ENDIF
RETURN lcRetStr
ENDFUNC

FUNCTION LoadPrivNum
LPARAMETERS pcSection, pcStr, pcDefValue, pcINIfile
LOCAL lnRetNum,lcBuffer,lcOldError,llError,lnTmp 
lnRetNum = pcDefValue
lcBuffer = SPACE(10) + CHR(0)
lcOldError = ON('ERROR')
llError = .F.
ON ERROR llError = .T.
IF GetPrivStr(pcSection, pcStr, ALLTRIM(STR(pcDefValue)), @lcBuffer, 11, pcINIfile) > 0
   lnTmp=VAL(lcBuffer)
   IF !llError
       lnRetNum = lnTmp
   ENDIF  
ENDIF
ON ERROR &lcOldError
RETURN lnRetNum
ENDFUNC

FUNCTION CleanAlias
LPARAMETER cpAlias
IF USED(cpAlias)
   USE IN (cpAlias)
ENDIF
RETURN .T.
ENDFUNC
  
FUNCTION FileExist
LPARAMETER cpFn
IF !FILE(cpFn)
  #IFNDEF XMODEM
   =MESSAGEBOX("Не найден файл:"+CHR(13)+UPPER(cpFn),MB_OK+MB_ICONSTOP,_screen.Caption)
  #ELSE   
*!*	  && Пропускаем messagebox2   !!! НЕ РАБОТАЕТ!
  #ENDIF
    RETURN .F.
ENDIF
RETURN .T.
ENDFUNC
