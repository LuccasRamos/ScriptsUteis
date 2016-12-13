--Consultar Owner, tablespace padrão e o tamanho que o owner está ocupando dentro da tablespace, contendo o subtotal dos produtos
--Executar script conectado com SYS/SYSTEM ou usuarios com grants equivalentes.  

SELECT DECODE (c.owner, NULL, 'TOTAL', c.owner) AS "Owner",
       DECODE (c.tablespace_name,
               NULL, '- SubTotal -',
               c.tablespace_name
              ) AS "Tablespace Padrão",
       CASE
          WHEN c.BYTES < 1
             THEN ROUND (c.BYTES * 1024, 2) || ' KB '
          WHEN c.BYTES < 1024
             THEN ROUND (c.BYTES, 2) || ' MB '
          ELSE ROUND (c.BYTES / 1024, 2) || ' GB '
       END AS "Tamanho"
  FROM (SELECT   owner AS owner, tablespace_name AS tablespace_name,
                 SUM (BYTES / 1024 / 1024) AS BYTES
            FROM dba_segments
         --  WHERE tablespace_name <> 'SYS'
         --    AND tablespace_name <> 'SYSAUX'
         --    AND tablespace_name <> 'USERS'
         --    AND tablespace_name <> 'SYSTEM'
         --    AND tablespace_name <> 'UNDOTBS1'
         -- WHERE tablespace_name not in('SYS','SYSAUX','USERS','SYSTEM','UNDOTBS1') 
        GROUP BY CUBE (owner, tablespace_name)
        ORDER BY owner, tablespace_name ASC) c;
