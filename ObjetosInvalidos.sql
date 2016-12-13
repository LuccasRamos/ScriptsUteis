SELECT      'ALTER '
         || DECODE (object_type, ' PACKAGE BODY ', ' PACKAGE ', object_type)
         || ' '
         || object_name
         || DECODE (object_type,
                    ' PACKAGE BODY ', ' COMPILE BODY; ',
                    ' COMPILE; '
                   )
         || CHR (10)
    FROM user_objects
   WHERE status = 'INVALID'
ORDER BY object_name;
