DECLARE
   CURSOR search_sequence
   IS
      SELECT c.seq, c.sequencia, c.tab, c.num
        FROM (SELECT object_name AS seq, last_number AS sequencia,
                     ut.table_name AS tab,
                     (SELECT NUM_ROWS FROM USER_TABLES UT2 WHERE UT2.TABLE_NAME = UT.TABLE_NAME ) AS num
                FROM user_objects uo INNER JOIN user_sequences us
                     ON uo.object_name = us.sequence_name
                     INNER JOIN user_tables ut
                     ON ut.table_name = SUBSTR (uo.object_name, 6) 
					 OR ut.table_name = SUBSTR (uo.object_name, 5)
					 OR ut.table_name = SUBSTR (uo.object_name, 4)
					 ) c;

   nome_sequence    VARCHAR2(120);
   NOME_TABELA      VARCHAR2(120);
   ALT_SEQ          NUMERIC;
   VALOR_SEQUENCE   NUMERIC;
   CONT             NUMERIC;
   VAL              NUMERIC;
BEGIN

   DBMS_OUTPUT.ENABLE (700000);
   OPEN search_sequence;
   LOOP 
      FETCH search_sequence
       INTO nome_sequence, valor_sequence, nome_tabela, cont;
		
		IF valor_sequence >= cont THEN		
					DBMS_OUTPUT.PUT_LINE(nome_sequence||' |-> Ok ');		
		ELSE 
				IF CONT IS NULL THEN CONT := 0; END IF; 
				IF VALOR_SEQUENCE IS NULL THEN VALOR_SEQUENCE := 0; END IF; 
				

	
				EXECUTE IMMEDIATE 'ALTER SEQUENCE '||nome_sequence||' INCREMENT BY '||(cont-valor_sequence); 
				EXECUTE IMMEDIATE 'SELECT '||nome_sequence||'.nextval FROM DUAL' INTO VAL; 
				EXECUTE IMMEDIATE 'ALTER SEQUENCE '||nome_sequence||' INCREMENT BY '||1; 
				DBMS_OUTPUT.PUT_LINE(nome_sequence||' -> Sequence Alterada!');
		END IF;
      EXIT WHEN search_sequence%NOTFOUND;
   END LOOP;
END;
/
