===================================================================================
# EXCLUI REGISTROS DUPLICADOS UTILIZANDO ROWID
===================================================================================
SPOOL C:\LOGS\EXCLUI_REGISTROS_DUP.sql
DELETE FROM bkp_orcamento_orc_14082017                                      --verificar tabela 
      WHERE ROWID NOT IN (
               SELECT ROWID
                 FROM bkp_orcamento_orc_14082017 t1                         --Verificar tabela
                WHERE ROWID =
                         (SELECT MIN (ROWID)
                            FROM bkp_orcamento_orc_14082017 t2
                           WHERE t1.orc_cdorcam = t2.orc_cdorcam            -------------------------------------------------
                             AND t1.orc_cdrevis = t2.orc_cdrevis            -- Campos que não podem ter valores duplicados --   
                             AND t1.orc_cdempresa = t2.orc_cdempresa))      -------------------------------------------------
						  

SPOOL OFF
===================================================================================
# FIM SCRIPT
===================================================================================
