SELECT   utc.table_name, uc.column_name, uc.constraint_name,
         DECODE (ucc.constraint_type,
                 'P', 'Primary Key',
                 'R', 'FOREIGN KEY',
                 'U', 'UNIQUE KEY',
                 'C', 'CHECK',
                 'V','CHECK OPTION',
                 'O','READ ONLY',
                 'Undefinied'
                ) AS "CONSTRAINT_TYPE"
    FROM user_cons_columns uc, user_tab_columns utc, user_constraints ucc
   WHERE uc.column_name = utc.column_name
     AND uc.constraint_name = ucc.constraint_name
	 AND uc.table_name='MXS_FUNCAOSISTEMA_MXFS'
--   AND ucc.constraint_type = 'P'
--   AND utc.data_type = 'NUMBER'
--   AND uc.constraint_name NOT IN (select constraint_name from user_constraints where constraint_name like '%SYS%')
ORDER BY 3 ASC;
