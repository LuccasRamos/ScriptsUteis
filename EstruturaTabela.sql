SELECT DISTINCT t1.column_name "Column Name", 
                t1.column_id "ID",
                NVL2 ((SELECT c1.column_name
                         FROM user_cons_columns c1, user_constraints a1
                        WHERE a1.table_name = c1.table_name
                          AND a1.constraint_name = c1.constraint_name
                          AND a1.constraint_type = 'P'
                          AND a1.table_name = t1.table_name
                          AND t1.column_name = c1.column_name),
                      1,
                      ''
                     ) AS "PK",
                      t1.nullable "Null?",
                DECODE (t1.data_type,
                        'VARCHAR2', 'VARCHAR2 (' || char_length || ' Byte)',
                        'CHAR', 'CHAR (' || char_length || ' Byte)',
                        'NUMBER', 'NUMBER (' || data_precision || ',' --Implementar quando o valor não for especificado
                         || data_scale || ')',
                        data_type
                       ) "DATA TYPE",
                       NULL AS "Obrigatório",
                       NULL AS "Comments",
                DECODE (t1.density, NULL, 'No', 'Yes') "Histogram"
           FROM user_tab_columns t1, user_cons_columns t2,
                user_constraints t3
          WHERE t1.column_name = t2.column_name(+)
                AND t1.table_name = 'ORCAMENTO_ORC' --Substituir pelo nome da tabela a ser usada
       ORDER BY "ID"
