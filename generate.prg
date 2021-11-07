#INCLUDE [..\INCLUDE\TPDSL.H]
#define LF                 chr(10)

LPARAMETERS plSQL

LOCAL lcGenFname,lnFhOut,nCntInGrp, lcSaveFilter
lcGenFname=ADDBS(JUSTPATH(DBF('rules')))+SUBSTR(TTOC(DATETIME(),1),3,10)+".htaccess"

IF plSQL
   SELECT * FROM rules INTO TABLE curTmp
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
   MESSAGEBOX("������������ ���� "+CHR(13)+lcGenFname,MB_OK+MB_ICONINFORMATION,"�������")
ENDIF && FCREATE

RETURN



*!*	    *  ������ ���������
*!*	  =FPUTS(lnFhOut,"php_value register_globals 0")
*!*	  =FPUTS(lnFhOut,"")
*!*	  =FPUTS(lnFhOut,"Options +FollowSymLinks")
*!*	  =FPUTS(lnFhOut,"")
*!*	  =FPUTS(lnFhOut,"RewriteEngine On")
*!*	  =FPUTS(lnFhOut,"")

*!*	   * ������ ������

*!*	   SELECT rules 
*!*	   SET ORDER TO idgrp
*!*	   SCAN FOR rules.idgrp>0 .AND. rules.lInOut
*!*	        SELECT pins
*!*	        COUNT FOR pins.idgrp=rules.idgrp TO nCntInGrp &&������� ����������
*!*	        SELECT rules
*!*	       =FPUTS(lnFhOut,"# ID:"+TRANSFORM(rules.idgrp,"@L 99999")+" N-"+ALLTRIM(STR(nCntInGrp))+" "+ALLTRIM(rules.commentar))
*!*	       =FPUTS(lnFhOut,"RewriteCond %{QUERY_STRING} ^"+ALLTRIM(rules.rCond))  
*!*	       =FPUTS(lnFhOut,"RewriteRule ^index.php$ "+ALLTRIM(rules.rRule)+" [R=301,L]")
*!*	       =FPUTS(lnFhOut,"")           
*!*	   ENDSCAN

*!*	* ������ ������
*!*	  =FPUTS(lnFhOut,"")
*!*	  =FPUTS(lnFhOut,"#  =============== ���� ������ ��� ====================") 
*!*	  =FPUTS(lnFhOut,"RewriteCond %{HTTP_HOST} ^shop.pkf-karo.ru")
*!*	  =FPUTS(lnFhOut,"RewriteRule (.*) http://www.shop.pkf-karo.ru/$1 [R=301,L]")