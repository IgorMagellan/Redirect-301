LPARAMETER nError,cMethod,nLine
LOCAL lnRowsArr
LOCAL lcErrorMsg,lcCodeLineMsg,lcErrorTitle
WAIT CLEAR
glWasError=.T.
lcErrorTitle=""
DO CASE
   CASE nError=1705
        lcErrorMsg="������� �������� ������� ������"+CHR(13)+;
        "��������, �� ��������� ��������� ��������� ������ ���."
        lcErrorTitle=SYS(2018)
   CASE nError=1753
        lcErrorMsg="������ ��� ������� ��������� 32-bit DLL."
        lcErrorTitle=SYS(2018)+".DLL"
   CASE nError=109
        lcErrorMsg="��� ������ ��� ���������� ������ �������������."
        lcErrorTitle="���������� ������"
        
   OTHERWISE && ��� ��������� ������
     lcErrorMsg=ALLTRIM(STR(nError))+"."+MESSAGE()+CHR(13)+CHR(13)
     lcErrorMsg=lcErrorMsg+"�����:    "+cMethod
     lcCodeLineMsg=MESSAGE(1)
     IF BETWEEN(nLine,1,10000) AND NOT lcCodeLineMsg="..."
    	lcErrorMsg=lcErrorMsg+CHR(13)+"������:         "+ALLTRIM(STR(nLine))
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



