#INCLUDE [..\INCLUDE\TPDSL.H]
#define LF                 chr(10)

LPARAMETERS plSQL

LOCAL lcGenFname,lnFhOut,nCntInGrp, lcSaveFilter
lcGenFname=ADDBS(JUSTPATH(DBF('rules')))+SUBSTR(TTOC(DATETIME(),1),3,10)+".htaccess"

IF plSQL
   SELECT * FROM rules INTO TABLE curTmp
ELSE
   IF !USED('rules')
       MESSAGEBOX("Не открыт фал правил rules.dbf",MB_OK+MB_ICONSTOP,"Ошибка")
       RETURN
   ENDIF
ENDIF
*MESSAGEBOX("рабочий файл "+CHR(13)+lcGenFname,MB_OK+MB_ICONINFORMATION,"Внимание!")

lnFhOut=FCREATE(lcGenFname)
IF lnFhout < 0
   MESSAGEBOX("Ошибка генерации файла "+CHR(13)+lcGenFname,MB_OK+MB_ICONEXCLAMATION,"Ошибка")
ELSE

   *  запись заголовка
  =FWRITE(lnFhOut,"php_value register_globals 0"+LF)
  =FWRITE(lnFhOut,""+LF)
  =FWRITE(lnFhOut,"Options +FollowSymLinks"+LF)
  =FWRITE(lnFhOut,""+LF)
  =FWRITE(lnFhOut,"RewriteEngine On"+LF)
  =FWRITE(lnFhOut,""+LF)

   * запись правил
   SELECT pins
   lcSaveFilter=FILTER('pins')
   SET FILTER TO IN pins
      
   SELECT rules 
   SET ORDER TO idgrp

   SCAN FOR rules.idgrp>0 .AND. rules.lInOut
        SELECT pins
        COUNT FOR pins.idgrp=rules.idgrp TO nCntInGrp &&считаем количество
        SELECT rules
       =FWRITE(lnFhOut,"# ID:"+TRANSFORM(rules.idgrp,"@L 99999")+" N-"+ALLTRIM(STR(nCntInGrp))+" "+ALLTRIM(rules.commentar)+LF)
       =FWRITE(lnFhOut,"RewriteCond "+ALLTRIM(rules.rCond)+LF)  
       =FWRITE(lnFhOut,"RewriteRule ^index.php$ "+ALLTRIM(rules.rRule)+" [R=301,L]"+LF)
       =FWRITE(lnFhOut,""+LF)           
   ENDSCAN

* Запись хвоста
  =FWRITE(lnFhOut,""+LF)
  =FWRITE(lnFhOut,"#  =============== БЫЛО ТОЛЬКО ЭТО ===================="+LF) 
  =FWRITE(lnFhOut,"RewriteCond %{HTTP_HOST} ^shop.pkf-karo.ru"+LF)
  =FWRITE(lnFhOut,"RewriteRule (.*) http://www.shop.pkf-karo.ru/$1 [R=301,L]"+LF)
      
  =FCLOSE(lnFhout)
   IF !EMPTY(lcSaveFilter)
       SET FILTER TO &lcSaveFilter IN pins
   ENDIF
   MESSAGEBOX("Сгенерирован файл "+CHR(13)+lcGenFname,MB_OK+MB_ICONINFORMATION,"Успешно")
ENDIF && FCREATE

RETURN



*!*	    *  запись заголовка
*!*	  =FPUTS(lnFhOut,"php_value register_globals 0")
*!*	  =FPUTS(lnFhOut,"")
*!*	  =FPUTS(lnFhOut,"Options +FollowSymLinks")
*!*	  =FPUTS(lnFhOut,"")
*!*	  =FPUTS(lnFhOut,"RewriteEngine On")
*!*	  =FPUTS(lnFhOut,"")

*!*	   * запись правил

*!*	   SELECT rules 
*!*	   SET ORDER TO idgrp
*!*	   SCAN FOR rules.idgrp>0 .AND. rules.lInOut
*!*	        SELECT pins
*!*	        COUNT FOR pins.idgrp=rules.idgrp TO nCntInGrp &&считаем количество
*!*	        SELECT rules
*!*	       =FPUTS(lnFhOut,"# ID:"+TRANSFORM(rules.idgrp,"@L 99999")+" N-"+ALLTRIM(STR(nCntInGrp))+" "+ALLTRIM(rules.commentar))
*!*	       =FPUTS(lnFhOut,"RewriteCond %{QUERY_STRING} ^"+ALLTRIM(rules.rCond))  
*!*	       =FPUTS(lnFhOut,"RewriteRule ^index.php$ "+ALLTRIM(rules.rRule)+" [R=301,L]")
*!*	       =FPUTS(lnFhOut,"")           
*!*	   ENDSCAN

*!*	* Запись хвоста
*!*	  =FPUTS(lnFhOut,"")
*!*	  =FPUTS(lnFhOut,"#  =============== БЫЛО ТОЛЬКО ЭТО ====================") 
*!*	  =FPUTS(lnFhOut,"RewriteCond %{HTTP_HOST} ^shop.pkf-karo.ru")
*!*	  =FPUTS(lnFhOut,"RewriteRule (.*) http://www.shop.pkf-karo.ru/$1 [R=301,L]")