LPARAMETER nError,cMethod,nLine
LOCAL lnRowsArr
LOCAL lcErrorMsg,lcCodeLineMsg,lcErrorTitle
WAIT CLEAR
glWasError=.T.
lcErrorTitle=""
DO CASE
   CASE nError=1705
        lcErrorMsg="Попытка повторно открыть данные"+CHR(13)+;
        "Возможно, вы пытаетесь запустить программу второй раз."
        lcErrorTitle=SYS(2018)
   CASE nError=1753
        lcErrorMsg="Ошибка при попытке загрузить 32-bit DLL."
        lcErrorTitle=SYS(2018)+".DLL"
   CASE nError=109
        lcErrorMsg="Эта запись уже изменяется другим пользователем."
        lcErrorTitle="Совместный доступ"
        
   OTHERWISE && Все остальные ошибки
     lcErrorMsg=ALLTRIM(STR(nError))+"."+MESSAGE()+CHR(13)+CHR(13)
     lcErrorMsg=lcErrorMsg+"Метод:    "+cMethod
     lcCodeLineMsg=MESSAGE(1)
     IF BETWEEN(nLine,1,10000) AND NOT lcCodeLineMsg="..."
    	lcErrorMsg=lcErrorMsg+CHR(13)+"Строка:         "+ALLTRIM(STR(nLine))
        IF NOT EMPTY(lcCodeLineMsg)
		   lcErrorMsg=lcErrorMsg+CHR(13)+CHR(13)+lcCodeLineMsg
		ENDIF
     ENDIF   
ENDCASE
IF MESSAGEBOX(lcErrorMsg,16+IIF(VERSION(2)=0,0,1),IIF(EMPTY(lcErrorTitle),_screen.Caption,lcErrorTitle))#1
   ON ERROR
   RETURN .F.
ENDIF
RETURN



