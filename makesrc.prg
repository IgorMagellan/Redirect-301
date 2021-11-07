#INCLUDE [..\INCLUDE\TPDSL.H]
LPARAMETERS lpFnameSrc
LOCAL lcAfn, lcDbfRes

IF MESSAGEBOX("������������ �������� ������� ���� ?",MB_YESNO+MB_ICONEXCLAMATION+MB_DEFBUTTON2,"��������!")=IDNO
   RETURN   
ENDIF

SET DEFAULT TO (JUSTPATH(lpFnameSrc))  && ����� � �� �� �����
        
IMPORT FROM (lpFnameSrc) TYPE XL8 SHEET "sheet1"

lcAfn=JUSTSTEM(lpFnameSrc)

*lcDbfRes=lcAfn+"-res"
lcDbfRes="pins"

SELECT A AS URL, B AS DIND, C AS TITLE, ;
	ALLTRIM(SUBSTR(a, AT('?', a)+1)) AS arg, ;
	11111 AS idGrp, ;
	0 AS nStatus, ;
	TTOC(DATETIME(),1) AS cDTStatus,;
	.F. AS lCurSel ;
	FROM (lcAfn) ;
	WHERE LEN(ALLTRIM(a))>28 ;
	ORDER BY arg ;
	INTO TABLE (lcDbfRes)

REPLACE ALL idGrp WITH 0,;
			cDTStatus WITH "" 
INDEX ON LEFT(arg,120) TAG arg  && ����������� ����� �����
INDEX ON title TAG title ADDITIVE	
INDEX ON idGrp TAG idGrp ADDITIVE	
INDEX ON lCurSel TAG lCurSel ADDITIVE

*	SPACE(5) AS csum ;
*REPLACE ALL csum WITH SYS(2007, arg, 1)

*!*	fGrp - numeric, 1-��������� �������� 2 - ��������� 
*!*	lInOut - �����. ������ �������� � �������� ����������� ����
*!*	idGrp numeirc(5)- ���������� ID ������ (�������������)  CALCULATE MAX(idgrp) to xxx ��� ������
*!*						idGrp=0 - ������� (��� ����������� ������)
*!*						idGrp>0 - ��������� ������ 

*!* nStatus numeirc(1): 0 - ������� �� ���������, idGrp=0 - ������� (��� ����������� ������)
*!*                     1 - ��������� ������ �������� �� ����������	 idGrp>0				
*!*						2 - �������� ��������  ��������� ��
*!*						3 - �������� ��������  ��������� ������
*!*						4 - 
*!*												
*!*
*!*	lCurSel - �����. .T. ��������� ������ ��� ��������� ��������


=CleanAlias(lcAfn) 
DELETE FILE (FORCEEXT(lpFnameSrc,"dbf"))

SELECT 0

CREATE TABLE rules ( ;
	idGrp  N(5,0),;
	commentar C(100),;
	rcond C(150),;
	rrule C(100),;
	dsc C(250),;
	fGrp N(1,0),;
	lInOut L ;
	 )
	
SELECT rules
REPLACE ALL idGrp WITH 0
INDEX ON idGrp TAG idGrp 

WAIT WINDOW "����� ������������: "+lcDbfRes+CHR(13)+"rules.DBF"
RETURN

