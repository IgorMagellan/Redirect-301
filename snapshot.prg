#INCLUDE [..\INCLUDE\TPDSL.H]
LOCAL lcSaveSelect,lcSnapFname
lcSaveSelect=SELECT()

lcSnapFname=ADDBS(JUSTPATH(DBF('pins')))+"snap"+SUBSTR(TTOC(DATETIME(),1),3,10)+"_pins.dbf"

SELECT * FROM pins ORDER BY arg INTO TABLE (lcSnapFname)

=CleanAlias(JUSTSTEM(lcSnapFname))

lcSnapFname=ADDBS(JUSTPATH(DBF('rules')))+"snap"+SUBSTR(TTOC(DATETIME(),1),3,10)+"_rules.dbf"

SELECT * FROM rules ORDER BY idgrp  INTO TABLE (lcSnapFname)

=CleanAlias(JUSTSTEM(lcSnapFname))

*DISPLAY STATUS TO FILE ds.txt

SELECT (lcSaveSelect)
MESSAGEBOX("Сделан Snapshot файлов данных "+CHR(13)+FORCEEXT(lcSnapFname,""),MB_OK+MB_ICONINFORMATION,"Успешно")
RETURN
