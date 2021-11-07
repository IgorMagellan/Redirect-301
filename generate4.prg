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

LOCAL lcPathFiles, lcGenFname, lnFhOut, nCntInGrp, lcSaveFilter, lcCurFname, lcGenOrder, lcGenAlias

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
        lcGenOrder='rules.fgrp, CntRul DESC, rules.idgrp'
        
   CASE pnTip=3 &&
        lcGenFname=lcGenFname+"XX.htaccess"   
        lcCurFname=lcPathFiles+'GenXX'
        lcGenOrder='CntRul'
        
   OTHERWISE
        MESSAGEBOX("Не обрабатываемый выбор = "+STR(pnTip),MB_OK+MB_ICONINFORMATION,"Внимание!")
        RETURN
ENDCASE


glWasError=.F.
   SELECT Rules.*, ;
          COUNT(Pins.idgrp) AS cntRul;
          FROM rules LEFT JOIN pins ;
          ON Pins.idgrp = Rules.idgrp;
          GROUP BY rules.idgrp ;
          ORDER BY &lcGenOrder ;
          INTO TABLE (lcCurFname) 


*!*	   SELECT * ;
*!*	          FROM curTmp ;
*!*	          ORDER BY &lcGenOrder ;
*!*	          INTO TABLE (lcCurFname) READWRITE
*!*	           

IF glWasError

   MESSAGEBOX("Ошибка формирования рабочего файла "+lcCurFname+CHR(13)+lcGenFname,MB_OK+MB_ICONINFORMATION,"Внимание!")
   RETURN 
ENDIF   

lcGenAlias=JUSTSTEM(lcCurFname)

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
   REPLACE ALL rules.cntRules WITH 0
   GO TOP
   
   SELECT (lcGenAlias)
   GO TOP
*  SET ORDER TO idgrp

   SCAN FOR idgrp>0 .AND. lInOut
        SCATTER MEMVAR
        SELECT pins
        COUNT FOR pins.idgrp=m.idgrp TO nCntInGrp &&считаем количество
        SELECT (lcGenAlias)

       =FWRITE(lnFhOut,"# ID:"+TRANSFORM(m.idgrp,"@L 99999")+" N-"+ALLTRIM(STR(nCntInGrp))+" "+ALLTRIM(m.commentar)+LF)
       =FWRITE(lnFhOut,"RewriteCond "+ALLTRIM(m.rCond)+LF)  
       =FWRITE(lnFhOut,"RewriteRule ^index.php$ "+ALLTRIM(m.rRule)+" [R=301,L]"+LF)
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
   
   * Запись количества
   SELECT (lcGenAlias)
   GO TOP
   SCAN
      SCATTER MEMVAR
      SELECT rules
      REPLACE rules.cntRules WITH m.cntRul ALL FOR rules.idGrp==m.idGrp
      SELECT (lcCurFname)      
   ENDSCAN
*           REPLACE rules.cntRules WITH nCntInGrp 
   MESSAGEBOX("Сгенерирован файл "+CHR(13)+lcGenFname,MB_OK+MB_ICONINFORMATION,"Успешно")
ENDIF && FCREATE
=CleanAlias(lcCurFname)
RETURN
