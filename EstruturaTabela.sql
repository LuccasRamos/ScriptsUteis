/* Formatted on 2017/12/22 15:33 (Formatter Plus v4.8.8) */
SELECT DISTINCT t1.column_name "Column_Name", t1.column_id "ID",
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
                DECODE
                   (t1.data_type,
                    'VARCHAR2', 'VARCHAR2 (' || char_length || ' Byte)',
                    'CHAR', 'CHAR (' || char_length || ' Byte)',
                    'NUMBER', 'NUMBER ('
                     || data_precision
                     || ','  --Implementar quando o valor não for especificado
                     || data_scale
                     || ')',
                    data_type
                   ) "DATA TYPE",
                 T3.COMMENTS AS "Comentário",
                DECODE (t1.density, NULL, 'No', 'Yes') "Histogram"
           FROM user_tab_columns t1, user_col_comments t3
          WHERE t1.column_name = t3.column_name(+)
            AND t1.table_name = 'MATBEMSERV_MBS' --substituir o nome da tabela desejada
       ORDER BY "ID"
