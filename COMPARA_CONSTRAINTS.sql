===================================================================================
# MAPEIO DE CONSTRAINTS ENTRE DOIS SCHEMAS
===================================================================================
CREATE OR REPLACE DATABASE LINK DBLINK
CONNECT TO WM912 IDENTIFIED BY ADMDADOSPWD 
USING 'MXMMOD';  

MXM\MRJ01B-NTB007
@DBLINK

SET LINES 1000
SET SERVEROUTPUT ON 
SPOOL GERA_CONSTRAINTS.sql
DECLARE 
  V_COMANDO VARCHAR2(4000); 
  V_COUNT_P  INT := 0; 
  V_COUNT_R  INT := 0;
  V_COUNT_U  INT := 0;                                                                                                                                                                                                                                                                                           
  V_COUNT_C  INT := 0;
BEGIN 
  FOR CTS IN(
	SELECT  C1.TABLE_NAME, 
               CONSTRAINT_NAME, 
               CONSTRAINT_TYPE, 
               LISTAGG(C1.COLUMN_NAME,',')WITHIN GROUP ( ORDER BY C1.COLUMN_NAME) AS "COLUMNS_NAME", 
               R_CONSTRAINT_NAME,
               R_TABLE_NAME,
               R_COLUMNS_NAME,
			   SEARCH_CONDITION_VC
           FROM ( SELECT     T1.CONSTRAINT_NAME, 
                             T2.COLUMN_NAME, 
                             T1.CONSTRAINT_TYPE, 
                             T1.TABLE_NAME,
                             T1.R_CONSTRAINT_NAME,
                             (SELECT DISTINCT TABLE_NAME  
									FROM ALL_CONS_COLUMNS@DBLINK L1
										WHERE OWNER='WM912' 
										AND CONSTRAINT_NAME = T1.R_CONSTRAINT_NAME) AS "R_TABLE_NAME",
                             (SELECT LISTAGG(L2.COLUMN_NAME,',')WITHIN GROUP ( ORDER BY COLUMN_NAME) AS "R_COLUMNS_NAME" 
									FROM ALL_CONS_COLUMNS L2
										WHERE OWNER='WM912' 
										AND CONSTRAINT_NAME = T1.R_CONSTRAINT_NAME) AS "R_COLUMNS_NAME",
						     T1.SEARCH_CONDITION_VC
                  FROM       ALL_CONSTRAINTS T1 
                  INNER JOIN ALL_CONS_COLUMNS T2 
                  ON         T1.CONSTRAINT_NAME = T2.CONSTRAINT_NAME 
                  WHERE      T1.OWNER = 'WM912'
                  MINUS 
                  SELECT     T1.CONSTRAINT_NAME, 
                             T2.COLUMN_NAME, 
                             T1.CONSTRAINT_TYPE, 
                             T1.TABLE_NAME,                             
                             T1.R_CONSTRAINT_NAME,
                             (SELECT DISTINCT TABLE_NAME 
									 FROM ALL_CONS_COLUMNS  L1
										WHERE OWNER='SENAC_MS' 
										AND CONSTRAINT_NAME = T1.R_CONSTRAINT_NAME) AS "R_TABLE_NAME",
                             (SELECT LISTAGG(L2.COLUMN_NAME,',')WITHIN GROUP ( ORDER BY COLUMN_NAME) AS "R_COLUMNS_NAME" 
									FROM ALL_CONS_COLUMNS L2
										WHERE OWNER='WM912' 
										AND CONSTRAINT_NAME = T1.R_CONSTRAINT_NAME) AS "R_COLUMNS_NAME",
							 T1.SEARCH_CONDITION_VC
                  FROM       ALL_CONSTRAINTS T1 
                  INNER JOIN ALL_CONS_COLUMNS T2 
                  ON         T1.CONSTRAINT_NAME = T2.CONSTRAINT_NAME 
                  WHERE      T1.OWNER = 'SENAC_MS'
				) C1 		
    WHERE CONSTRAINT_TYPE IN ('P','R','U','C') 
    GROUP BY C1.TABLE_NAME, 
             CONSTRAINT_NAME, 
             CONSTRAINT_TYPE, 
             R_CONSTRAINT_NAME,
             R_TABLE_NAME,
             R_COLUMNS_NAME,
			 SEARCH_CONDITION_VC
	ORDER BY CONSTRAINT_TYPE
  ) LOOP 
		--PK
		IF(CTS.CONSTRAINT_TYPE = 'P') THEN 
			V_COMANDO:='ALTER TABLE '|| CTS.TABLE_NAME||CHR(10)||' ADD CONSTRAINT '||CTS.CONSTRAINT_NAME ||' PRIMARY KEY('||CTS.COLUMNS_NAME||')'||CHR(10)||'/'||CHR(10);
			DBMS_OUTPUT.PUT_LINE(V_COMANDO);
			V_COUNT_P:=V_COUNT_P + 1;
		END IF;	
		--FK
		IF(CTS.CONSTRAINT_TYPE = 'R') THEN 
			V_COMANDO:='ALTER TABLE '||CTS.TABLE_NAME||CHR(10)||' ADD CONSTRAINT '||CTS.CONSTRAINT_NAME||' FOREIGN KEY('||CTS.COLUMNS_NAME||')'||CHR(10)||'REFERENCES '|| CTS.R_TABLE_NAME||'('||CTS.R_COLUMNS_NAME||')'||CHR(10)||'/'||CHR(10);
			DBMS_OUTPUT.PUT_LINE(V_COMANDO);
			V_COUNT_R:=V_COUNT_R + 1;
		END IF;
		--UNIQUE
		IF(CTS.CONSTRAINT_TYPE = 'U') THEN 
			V_COMANDO:='ALTER TABLE '||CTS.TABLE_NAME||CHR(10)||
			' ADD CONSTRAINT '||CTS.CONSTRAINT_NAME||' UNIQUE('||CTS.COLUMNS_NAME||')'||CHR(10)||
			'/'||CHR(10);
			DBMS_OUTPUT.PUT_LINE(V_COMANDO);
			V_COUNT_U:=V_COUNT_U + 1;
		END IF;
		--CHECK
		IF(CTS.CONSTRAINT_TYPE = 'C') THEN		
			IF(CTS.SEARCH_CONDITION_VC LIKE '%IS NOT NULL%')THEN
				NULL;
			ELSE
				V_COMANDO:='ALTER TABLE '||CTS.TABLE_NAME||CHR(10)||
				' ADD (CONSTRAINT '||CTS.CONSTRAINT_NAME||CHR(10)||
				' CHECK('||CTS.SEARCH_CONDITION_VC||'))'||CHR(10)||
				'/'||CHR(10);
				DBMS_OUTPUT.PUT_LINE(V_COMANDO);
				V_COUNT_C:=V_COUNT_C + 1;
			END IF;
		END IF;
  END LOOP; 
  DBMS_OUTPUT.PUT_LINE('###############################');
  DBMS_OUTPUT.PUT_LINE('#RESUMO.....: ');
  DBMS_OUTPUT.PUT_LINE('#Primary Key: '||V_COUNT_P);
  DBMS_OUTPUT.PUT_LINE('#Foreign Key: '||V_COUNT_R);
  DBMS_OUTPUT.PUT_LINE('#Unique  Key: '||V_COUNT_U);
  DBMS_OUTPUT.PUT_LINE('#Check......: '||V_COUNT_C);
  DBMS_OUTPUT.PUT_LINE('#TOTAL......: '||TO_NUMBER(V_COUNT_P+V_COUNT_R+V_COUNT_U+V_COUNT_C));
  DBMS_OUTPUT.PUT_LINE('###############################');
END; 
/
SPOOL OFF
===================================================================================
