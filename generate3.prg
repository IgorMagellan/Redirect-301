#INCLUDE [..\INCLUDE\TPDSL.H]
#define LF                 chr(10)

PRIVATE pnTip, pnFrmGenOptOK
pnTip=2
pnFrmGenOptOK=.F.

DO FORM GenOpt.scx 

IF !pnFrmGenOptOK  && Cancel pressed
    RETURN
ENDIF

*
************************

SET ENGINEBEHAVIOR 70

LOCAL lcPathFiles, lcGenFname, lnFhOut, nCntInGrp, lcSaveFilter, lcCurFname, lcGenOrder

lcPathFiles=ADDBS(JUSTPATH(DBF('rules')))

lcGenFname=lcPathFiles+SUBSTR(TTOC(DATETIME(),1),3,10)

DO CASE
   CASE pnTip=1 && IDgrp
        lcGenFname=lcGenFname+"IDGRP.htaccess"
        lcCurFname=lcPathFiles+'GenIDGRP'
        lcGenOrder='rules.idgrp'
        
   CASE pnTip=2 &&
        lcGenFname=lcGenFname+"FGRP.htaccess"
        lcCurFname=lcPathFiles+'GenFGRP'
        lcGenOrder='rules.fgrp'
        
   CASE pnTip=3 &&
        lcGenFname=lcGenFname+"XX.htaccess"   
        lcCurFname=lcPathFiles+'GenXX'
        lcGenOrder='CntRul'
        
   OTHERWISE
        MESSAGEBOX("�� �������������� ����� = "+STR(pnTip),MB_OK+MB_ICONINFORMATION,"��������!")
        RETURN
ENDCASE

glWasError=.F.
   SELECT Rules.*,;
          COUNT(Pins.idgrp) AS cntRul;
          FROM rules LEFT JOIN pins ;
          ON Pins.idgrp = Rules.idgrp;
          GROUP BY rules.idgrp ;
          ORDER BY &lcGenOrder ;
          INTO TABLE (lcCurFname) READWRITE
          
          
* ORDER BY rules.fgrp;   
*              WHERE rules.idgrp>-1 ;
*!*	   SELECT Rules.*, ;
*!*	          COUNT(Pins.idgrp) AS cntRul;
*!*	          FROM pins LEFT JOIN rules ;
*!*	          ON Pins.idgrp = Rules.idgrp;
*!*	          GROUP BY rules.idgrp ;
*!*	          INTO TABLE curTmp READWRITE
*!*	* ORDER BY rules.fgrp;   

IF glWasError

   MESSAGEBOX("������ ������������ �������� ����� "+lcCurFname+CHR(13)+lcGenFname,MB_OK+MB_ICONINFORMATION,"��������!")
   RETURN 
ENDIF   

lnFhOut=FCREATE(lcGenFname)
IF lnFhout < 0
   MESSAGEBOX("������ ��������� ����� "+CHR(13)+lcGenFname,MB_OK+MB_ICONEXCLAMATION,"������")
ELSE

   *  ������ ���������
  =FWRITE(lnFhOut,"php_value register_globals 0"+LF)
  =FWRITE(lnFhOut,""+LF)
  =FWRITE(lnFhOut,"Options +FollowSymLinks"+LF)
  =FWRITE(lnFhOut,""+LF)
  =FWRITE(lnFhOut,"RewriteEngine On"+LF)
  =FWRITE(lnFhOut,""+LF)

   * ������ ������
   SELECT pins
   lcSaveFilter=FILTER('pins')
   SET FILTER TO IN pins
      
   SELECT rules 
   REPLACE ALL rules.cntRules WITH 0
   GO TOP
   
   SET ORDER TO idgrp

   SCAN FOR rules.idgrp>0 .AND. rules.lInOut
        SELECT pins
        COUNT FOR pins.idgrp=rules.idgrp TO nCntInGrp &&������� ����������
        SELECT rules

       =FWRITE(lnFhOut,"# ID:"+TRANSFORM(rules.idgrp,"@L 99999")+" N-"+ALLTRIM(STR(nCntInGrp))+" "+ALLTRIM(rules.commentar)+LF)
       =FWRITE(lnFhOut,"RewriteCond "+ALLTRIM(rules.rCond)+LF)  
       =FWRITE(lnFhOut,"RewriteRule ^index.php$ "+ALLTRIM(rules.rRule)+" [R=301,L]"+LF)
       =FWRITE(lnFhOut,""+LF)           
   ENDSCAN

* ������ ������
  =FWRITE(lnFhOut,""+LF)
  =FWRITE(lnFhOut,"#  =============== ���� ������ ��� ===================="+LF) 
  =FWRITE(lnFhOut,"RewriteCond %{HTTP_HOST} ^shop.pkf-karo.ru"+LF)
  =FWRITE(lnFhOut,"RewriteRule (.*) http://www.shop.pkf-karo.ru/$1 [R=301,L]"+LF)
      
  =FCLOSE(lnFhout)
   IF !EMPTY(lcSaveFilter)
       SET FILTER TO &lcSaveFilter IN pins
   ENDIF
   
   * ������ ����������
   SELECT (lcCurFname)
   GO TOP
   SCAN
      SCATTER MEMVAR
      SELECT rules
      REPLACE rules.cntRules WITH m.cntRul ALL FOR rules.idGrp==m.idGrp
      SELECT (lcCurFname)      
   ENDSCAN
*           REPLACE rules.cntRules WITH nCntInGrp 
   MESSAGEBOX("������������ ���� "+CHR(13)+lcGenFname,MB_OK+MB_ICONINFORMATION,"�������")
ENDIF && FCREATE
=CleanAlias(lcCurFname)
RETURN
