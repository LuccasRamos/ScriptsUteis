SET SERVEROUTPUT ON
CREATE OR REPLACE FUNCTION ADMDADOS_MAPEIA_TABELA(TABLE_NAME2 VARCHAR2)
 RETURN VARCHAR2
IS 
	TABLE2         VARCHAR2(50);
	NM_TABELA      VARCHAR2(50); 
	V_CONSTRAINT_R VARCHAR2(50); 
	V_CONSTRAINT_P VARCHAR2(50);
	V_COUNT_AUX    INT;
	
BEGIN
	FOR CTS IN (SELECT 	UC.TABLE_NAME, 
						CONSTRAINT_NAME, 
						R_CONSTRAINT_NAME, 
						CONSTRAINT_TYPE, 
						LISTAGG(COLUMN_NAME,',') WITHIN GROUP(ORDER BY COLUMN_NAME) AS "COLUMNS"
					FROM USER_CONS_COLUMNS UCC 
					INNER JOIN USER_CONSTRAINTS UC USING(CONSTRAINT_NAME)				
					WHERE UC.CONSTRAINT_TYPE IN ('R')
					AND UCC.TABLE_NAME=TABLE_NAME2
				    GROUP BY UC.TABLE_NAME,CONSTRAINT_NAME, R_CONSTRAINT_NAME, CONSTRAINT_TYPE)
				LOOP 
					
					SELECT TABLE_NAME INTO NM_TABELA FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME=CTS.R_CONSTRAINT_NAME;
					SELECT COUNT(CONSTRAINT_NAME) INT V_COUNT_AUX FROM USER_CONS_COLUMNS WHERE TABLE_NAME
					
					DBMS_OUTPUT.PUT_LINE(NM_TABELA);
				END LOOP; 
		RETURN NULL;
END ADMDADOS_MAPEIA_TABELA; 
/