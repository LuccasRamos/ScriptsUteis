CREATE OR REPLACE PROCEDURE prc_tabelabkp (nometabela IN VARCHAR2)
AS
   count_table   INT;
   tabela        VARCHAR2 (50);
   criado_em     VARCHAR2 (25);

   CURSOR listatabela
   IS
      SELECT   table_name,
               TO_CHAR (created, 'DD/MM/YY HH24:MI:SS') AS "CRIADO"
          FROM user_tables ut, user_objects uo
         WHERE table_name LIKE '%' || nometabela || '%'
           AND table_name LIKE '%BKP%'
           AND ut.table_name = uo.object_name
      ORDER BY table_name ASC;
BEGIN
   DBMS_OUTPUT.put_line (   'COMANDO: CREATE TABLE '
                         || nometabela
                         || '_BKP_'
                         || TO_CHAR (SYSDATE, 'DDMMYY')
                         || ' AS SELECT * FROM '
                         || nometabela
                         || ';'
                        );

   EXECUTE IMMEDIATE    'CREATE TABLE '
                     || nometabela
                     || '_BKP_'
                     || TO_CHAR (SYSDATE, 'DDMMYY')
                     || ' AS SELECT * FROM '
                     || nometabela;

   IF SUBSTR (UPPER (SQLERRM (SQLCODE)), 0, 8) = 'ORA-0000'
   THEN
      DBMS_OUTPUT.put_line ('TABELA DE BACKUP -> ' || nometabela);
      DBMS_OUTPUT.put_line ('STATUS           -> CRIADA!');
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      IF SUBSTR (UPPER (SQLERRM (SQLCODE)), 0, 9) = 'ORA-00972'
      THEN
         DBMS_OUTPUT.put_line
                             ('ERRO: NOME DA TABELA ULTRAPASSA 30 CARACTERES');
      ELSIF SUBSTR (UPPER (SQLERRM (SQLCODE)), 0, 9) = 'ORA-00955'
      THEN
         DBMS_OUTPUT.put_line
                        (   SUBSTR (UPPER (SQLERRM (SQLCODE)), 0, 10)
                         || ' -> JÁ EXISTE UMA TABELA DE BACKUP PARA O DIA: '
                         || TO_CHAR (SYSDATE, 'DD/MM/YY')
                        );

         SELECT COUNT (table_name)
           INTO count_table
           FROM user_tables
          WHERE table_name LIKE '%' || nometabela || '%'
            AND table_name LIKE '%BKP%';

         EXECUTE IMMEDIATE    'CREATE TABLE '
                           || nometabela
                           || '_BKP_'
                           || TO_CHAR (SYSDATE, 'DDMMYY')
                           || '_'
                           || (count_table + 1)
                           || ' AS SELECT * FROM '
                           || nometabela;

         OPEN listatabela;

         DBMS_OUTPUT.put_line
            ('************************************************************************');
         DBMS_OUTPUT.put_line
            ('*                          TABELAS EXISTES                             *');
         DBMS_OUTPUT.put_line
            ('************************************************************************');

         LOOP
            FETCH listatabela
             INTO tabela, criado_em;

            EXIT WHEN listatabela%NOTFOUND;
            DBMS_OUTPUT.put_line (   'TABELA -> '
                                  || tabela
                                  || '   '
                                  || 'CRIADO EM -> '
                                  || criado_em
                                 );
         END LOOP;
      END IF;
END;
/
