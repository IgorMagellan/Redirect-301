#INCLUDE [..\INCLUDE\TPDSL.H]
#define LF                 chr(10)

LPARAMETERS plSQL

SET ENGINEBEHAVIOR 70

LOCAL lcGenFname,lnFhOut,nCntInGrp, lcSaveFilter
lcGenFname=ADDBS(JUSTPATH(DBF('rules')))+SUBSTR(TTOC(DATETIME(),1),3,10)+".htaccess"

IF plSQL
   SELECT Rules.*, ;
          COUNT(Pins.idgrp) AS cntRul;
          FROM rules LEFT JOIN pins ;
          ON Pins.idgrp = Rules.idgrp;
          WHERE rules.idgrp>-1 ;
          GROUP BY rules.idgrp ;
          ORDER BY rules.idgrp;
          INTO TABLE curTmp READWRITE
* ORDER BY rules.fgrp;   

*!*	   SELECT Rules.*, ;
*!*	          COUNT(Pins.idgrp) AS cntRul;
*!*	          FROM pins LEFT JOIN rules ;
*!*	          ON Pins.idgrp = Rules.idgrp;
*!*	          GROUP BY rules.idgrp ;
*!*	          INTO TABLE curTmp READWRITE
*!*	* ORDER BY rules.fgrp;   
*!*	   

   
ELSE
   IF !USED('rules')
       MESSAGEBOX("�� ������ ��� ������ rules.dbf",MB_OK+MB_ICONSTOP,"������")
       RETURN
   ENDIF
ENDIF
*MESSAGEBOX("������� ���� "+CHR(13)+lcGenFname,MB_OK+MB_ICONINFORMATION,"��������!")

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
   SELECT curTmp
   GO TOP
   SCAN
      SELECT rules
      REPLACE rules.cntRules WITH curTmp.cntRul ALL FOR rules.idGrp==curTmp.idGrp
   SELECT curTmp      
   ENDSCAN
   
   MESSAGEBOX("������������ ���� "+CHR(13)+lcGenFname,MB_OK+MB_ICONINFORMATION,"�������")
ENDIF && FCREATE
=CleanAlias('curTmp')
RETURN
