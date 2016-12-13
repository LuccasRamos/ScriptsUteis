 SELECT
	C.OWNER as "Owner",
	C.TABLESPACE_NAME "Tablespace padrao",
	CASE 
		WHEN C.BYTES < 1 THEN ROUND(C.BYTES*1024,2) || ' KB '  
		WHEN C.BYTES <1024 THEN ROUND(C.BYTES,2) || ' MB '  
		ELSE ROUND(C.BYTES/1024,2) ||  ' GB '
	END as "Tamanho"
FROM (SELECT OWNER AS OWNER,
	TABLESPACE_NAME  AS TABLESPACE_NAME,                                  
	SUM(BYTES/1024/1024) AS BYTES                                         
FROM DBA_SEGMENTS                                                         
--WHERE TABLESPACE_NAME<>'SYS' AND TABLESPACE_NAME<>'SYSAUX' AND TABLESPACE_NAME<>'USERS' AND TABLESPACE_NAME<>'SYSTEM' AND TABLESPACE_NAME<>'UNDOTBS1'                                              
GROUP BY OWNER,TABLESPACE_NAME                                            
ORDER BY OWNER DESC)C; 
