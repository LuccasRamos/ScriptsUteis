SET LINES 1000  DEFINE OFF  COLSEP '|'  UNDERLINE '=' PAGES 100
SPOOL LEVANTAMENTO_LOG.LOG
PROMPT *******************************************************************
PROMPT *       LEVANTAMENTO DE INFORMAÇÕES DO SERVIDOR DE BD             *
PROMPT *                            [V1.1]                               *
PROMPT *******************************************************************
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/RRRR HH24:MI:SS';
COLUMN "INFORMAÇÕES DE CONEXÃO"   FORMAT A100
SELECT 	'USUÁRIO_ORACLE| ' ||SYS_CONTEXT('USERENV','SESSION_USER') ||CHR(10)||
		'INSTANCIA.....| ' ||SYS_CONTEXT('USERENV','INSTANCE_NAME')||CHR(10)|| 
		'USUARIO S.O...| ' ||SYS_CONTEXT('USERENV','OS_USER')      ||CHR(10)||
		'SERVIDOR......| ' ||SYS_CONTEXT('USERENV','HOST')         ||CHR(10)||
		'DATA/HORA.....| ' ||TO_CHAR(TO_DATE(SYSDATE),'DD/MM/YYYY HH24:MI:SS')||CHR(10)||
		'CHARSET.......| ' ||SYS_CONTEXT('USERENV','LANGUAGE')  AS "INFORMAÇÕES DE CONEXÃO"
		FROM DUAL; 
		
		
PROMPT ****************************************************************
PROMPT *                 VERSÃO ORACLE                                *		
PROMPT **************************************************************** 
COLUMN "VERSÃO ORACLE" 		FORMAT A100
SELECT BANNER AS "PRODUTO" FROM v$version;		
		

PROMPT *******************************************************************
PROMPT *                      TAMANHO FISICO TABLESPACES                 *
PROMPT ******************************************************************* 
COLUMN "TABLESPACE_NAME"  		FORMAT A14
COLUMN "STATUS"					FORMAT A14
COLUMN "USED_SPACE(MB)"  		FORMAT A14
COLUMN "MAX_SIZE(MB)" 			FORMAT A14
COLUMN "SPACE_FREE(MB)"			FORMAT A14
COLUMN "PCT_USED(%)" 			FORMAT A14
COLUMN "PCT_FREE(%)" 			FORMAT A14
SELECT 	DTU.TABLESPACE_NAME, DT.STATUS,
		TO_CHAR(ROUND((TABLESPACE_SIZE*8192/1048576),2),'FM999G999G9999G990D00') AS "MAX_SIZE(MB)",
		TO_CHAR(ROUND((USED_SPACE*8192 / 1048576),2),'FM999G999G9999G990D00') AS "USED_SPACE(MB)", 
		TO_CHAR(ROUND((TABLESPACE_SIZE*8192/1048576),2) - ROUND((USED_SPACE*8192/1048576),2),'FM999G999G9999G990D00') AS "SPACE_FREE(MB)",
		TO_CHAR(ROUND((USED_SPACE*8192/1048576)/(TABLESPACE_SIZE*8192/1048576)*100,2),'FM999G999G9999G990D00') AS "PCT_USED(%)*", 
		TO_CHAR(ROUND((ROUND((TABLESPACE_SIZE*8192/1048576),2) - ROUND((USED_SPACE*8192/1048576),2))/(TABLESPACE_SIZE*8192/1048576)*100,2),'FM999G999G9999G990D00') AS "PCT_FREE(%)*"
FROM DBA_TABLESPACE_USAGE_METRICS DTU
INNER JOIN DBA_TABLESPACES DT 
ON DTU.TABLESPACE_NAME = DT.TABLESPACE_NAME
ORDER BY 1;

PROMPT *******************************************************************
PROMPT *                      INFO. DATAFILES                            *
PROMPT ******************************************************************* 
COLUMN "TABLESPACE_NAME"  	FORMAT A20
COLUMN "FILE_NAME"  		FORMAT A50
COLUMN "STATUS"  			FORMAT A15
COLUMN "AUTO_EXT"  			FORMAT A9
COLUMN "INCREMENT_BY(MB)"  	FORMAT A20
COLUMN "TAM(MB)"  			FORMAT A20
COLUMN "ALOCADO(MB)"  		FORMAT A20 
COLUMN "USER_BYTES(MB)"  	FORMAT A20 
COLUMN "PCT_USED(%)"  		FORMAT A20 

SELECT      F.TABLESPACE_NAME AS "TABLESPACE_NAME",
            F.FILE_NAME AS "FILE_NAME",            
            F.STATUS AS "STATUS",            
            F.AUTOEXTENSIBLE AS "AUTO_EXT",
            TO_CHAR(DECODE(F.AUTOEXTENSIBLE, 'NO', 0,
              ROUND((F.INCREMENT_BY * (F.BYTES/F.BLOCKS))/1048576,2)),'FM999G999G9999G990D00') AS "INCREMENT_BY(MB)",
            TO_CHAR(ROUND((F.BYTES/1048576),2),'FM999G999G9999G990D00')  AS "TAM(MB)",
            TO_CHAR(ROUND((F.BYTES-NVL(S.LIVRES,0))/1048576,2),'FM999G999G9999G990D00') AS "ALOCADO(MB)",
            TO_CHAR(ROUND(F.USER_BYTES/1048576,2),'FM999G999G9999G990D00') AS "USER_BYTES(MB)",            
            TO_CHAR(ROUND(DECODE((F.BYTES-NVL(S.LIVRES,0))/1048576,0,0,                          
                ((((F.BYTES-NVL(S.LIVRES,0))/1048576)/(F.BYTES/1048576))*100)),2),'FM999G999G9999G990D00') AS "PCT_USED(%)",
            TO_CHAR(ROUND(F.MAXBYTES/1048576,2),'FM999G999G9999G990D00') AS "MAX(MB)"
FROM        DBA_DATA_FILES F
LEFT JOIN  (  SELECT    FILE_ID, SUM(BYTES) LIVRES 
              FROM      DBA_FREE_SPACE S 
              GROUP BY  FILE_ID ) S
    ON      F.FILE_ID = S.FILE_ID
ORDER BY    F.TABLESPACE_NAME, F.FILE_NAME;



PROMPT *******************************************************************
PROMPT *		  INFO. TAMANHO OWNER  POR TABLESPACE                    * 
PROMPT *******************************************************************
COLUMN "OWNER" 				FORMAT A20
COLUMN "TABLESPACE_PADRAO"	FORMAT A30 
COLUMN "TAMANHO"		 	FORMAT A20 

SELECT 	NVL(C.OWNER,'[TOTAL]') AS "OWNER",
		NVL(C.TABLESPACE_NAME,'[TOTAL]') AS "TABLESPACE_PADRAO",
       CASE
          WHEN C.BYTES < 1 	  THEN ROUND (C.BYTES * 1024, 2) || ' KB '
          WHEN C.BYTES < 1024 THEN ROUND (C.BYTES, 2) 		 || ' MB '
          ELSE ROUND (C.BYTES / 1024, 2) 	|| ' GB '
       END AS "TAMANHO"
  FROM (SELECT   OWNER AS OWNER, TABLESPACE_NAME AS TABLESPACE_NAME,
                 SUM (BYTES / 1024 / 1024) AS BYTES
            FROM DBA_SEGMENTS
        GROUP BY OWNER, TABLESPACE_NAME
        ORDER BY OWNER, TABLESPACE_NAME ASC) C;

PROMPT *******************************************************************
PROMPT *		        OBJETOS INVÁLIDOS POR OWNER                      * 
PROMPT *******************************************************************
COLUMN "OWNER" 				FORMAT A20
COLUMN "QTD_OBJETOS"	    FORMAT A30 
COLUMN "AMBIENTE"	        FORMAT A30 

SELECT 	DBO.OWNER, 
		TO_CHAR(COUNT(DBO.OBJECT_NAME)) AS QTD_OBJETOS
	FROM DBA_OBJECTS DBO 
	WHERE STATUS <> 'VALID' 
GROUP BY DBO.OWNER;


PROMPT *******************************************************************
PROMPT *		        OWNER COM OBJETOS DO MANAGER                      * 
PROMPT *******************************************************************
SELECT DISTINCT OWNER 
FROM ALL_TABLES 
WHERE TABLE_NAME IN ('LANCCTB_LCT', 'TITCP_TCP', 'CLIENTE_CLI');


PROMPT *******************************************************************
PROMPT *		            GRANTS DOS USUARIOS                          * 
PROMPT *******************************************************************
SET UNDERLINE '='
SET COLSEP '|'
SET LINES 1000
COLUMN "GRANTEE"  FORMAT A20 
COLUMN "GRANTS" FORMAT A120
SELECT 	GRANTEE,	
		LISTAGG(PRIVILEGE||';',CHR(10)) WITHIN GROUP (ORDER BY PRIVILEGE)  AS "GRANTS"
FROM DBA_SYS_PRIVS 
WHERE COMMON <> 'YES' 
GROUP BY GRANTEE;

PROMPT *******************************************************************
PROMPT *		              ROLE DOS USUARIOS                          * 
PROMPT *******************************************************************
SET UNDERLINE '='
SET COLSEP '|'
SET LINES 1000
COLUMN "OWNER"  FORMAT A20 
COLUMN "LIST_ROLE"   FORMAT A120
SELECT GRANTEE AS "OWNER", 
       LISTAGG(GRANTED_ROLE,'; ') WITHIN GROUP(ORDER BY GRANTED_ROLE) AS "LIST_ROLE"
FROM DBA_ROLE_PRIVS WHERE COMMON <> 'YES'
GROUP BY GRANTEE;
		
PROMPT *******************************************************************
PROMPT *                      USUARIOS BD                                *
PROMPT ******************************************************************* 
COLUMN "USERNAME" 	FORMAT A40 
COLUMN "USER_ID" 	FORMAT A30 
COLUMN "CREATED" 	FORMAT A40
SELECT 	USERNAME, 
		TO_CHAR(USER_ID) AS "USER_ID",
		CREATED
		FROM ALL_USERS 
		ORDER BY USERNAME,COMMON;

PROMPT *******************************************************************
PROMPT *                         INFO GERAIS PFILE                       *
PROMPT ******************************************************************* 
COLUMN "PARAMETRO"          FORMAT A40
COLUMN "VALOR"              FORMAT A100
COLUMN "DESCRICAO"          FORMAT A45
SELECT 
	PARAMETRO.NOME "PARAMETRO", 
	NVL(VALOR.DISPLAY_VALUE,'<<N Parametrizado>>') "VALOR", 
	PARAMETRO.DESCRICAO "DESCRICAO"
	FROM (SELECT 1 ORDEM,  'OPEN_CURSORS'        		NOME,'Cursors and Library Cache'  DESCRICAO FROM DUAL UNION 
		  SELECT 2 ORDEM,  'DB_BLOCK_SIZE'         		NOME,'Cache and I/O'  DESCRICAO FROM DUAL UNION 
		  SELECT 3 ORDEM,  'PGA_AGGREGATE_TARGET'  		NOME,'Sort, Hash Joins, Bitmap Indexes'  DESCRICAO FROM DUAL UNION
		  SELECT 4 ORDEM,  'DB_CREATE_FILE_DEST'   		NOME,'File Configuration'  DESCRICAO FROM DUAL UNION 
		  SELECT 5 ORDEM,  'DB_RECOVERY_FILE_DEST' 		NOME,'File Configuration'  DESCRICAO FROM DUAL UNION
		  SELECT 6 ORDEM,  'DB_RECOVERY_FILE_DEST_SIZE' NOME,'File Configuration'  DESCRICAO FROM DUAL UNION  
		  SELECT 7 ORDEM,  'COMPATIBLE' 				NOME,'Miscellaneous'  DESCRICAO FROM DUAL UNION 
		  SELECT 8 ORDEM,  'DIAGNOSTIC_DEST' 			NOME,'Miscellaneous'  DESCRICAO FROM DUAL UNION
		  SELECT 9 ORDEM,  'DB_DOMAIN' 					NOME,'Database Identification'  DESCRICAO FROM DUAL UNION 
		  SELECT 10 ORDEM, 'DB_NAME' 					NOME,'Database Identification'  DESCRICAO FROM DUAL UNION  
		  SELECT 11 ORDEM, 'SGA_TARGET' 				NOME,'SGA Memory'  DESCRICAO FROM DUAL UNION 
		  SELECT 12 ORDEM, 'PROCESSES' 					NOME,'Processes and Sessions'  DESCRICAO FROM DUAL UNION 
		  SELECT 13 ORDEM, 'SESSIONS' 					NOME,'Processes and Sessions'  DESCRICAO FROM DUAL UNION 
		  SELECT 14 ORDEM, 'UNDO_TABLESPACE' 			NOME,'System Managed Undo and Rollback Segments'  DESCRICAO FROM DUAL UNION 
		  SELECT 15 ORDEM, 'AUDIT_FILE_DEST' 			NOME,'Security and Auditing'  DESCRICAO FROM DUAL UNION 
		  SELECT 16 ORDEM, 'AUDIT_TRAIL' 				NOME,'Security and Auditing'  DESCRICAO FROM DUAL UNION 
		  SELECT 17 ORDEM, 'REMOTE_LOGIN_PASSWORDFILE' 	NOME,'Security and Auditing'  DESCRICAO FROM DUAL UNION 
		  SELECT 18 ORDEM, 'DISPATCHERS' 				NOME,'Shared Server'  DESCRICAO FROM DUAL UNION 
		  SELECT 19 ORDEM, 'CONTROL_FILES' 				NOME,'Shared Server'  DESCRICAO FROM DUAL  
		  ) PARAMETRO
		  LEFT JOIN
		  (SELECT 'OPEN_CURSORS' NAME, DISPLAY_VALUE 
		  FROM (SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='open_cursors')
		  UNION
		  SELECT 'DB_BLOCK_SIZE' NAME, DISPLAY_VALUE
		  FROM (SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='db_block_size')
		  UNION 
		  SELECT 'PGA_AGGREGATE_TARGET' NAME, DISPLAY_VALUE 
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='pga_aggregate_target')
		  UNION 
		  SELECT 'DB_CREATE_FILE_DEST' NAME, DISPLAY_VALUE 
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='db_create_file_dest')
		  UNION 
		  SELECT 'DB_RECOVERY_FILE_DEST' NAME,DISPLAY_VALUE 
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='db_recovery_file_dest')
		  UNION 
		  SELECT 'DB_RECOVERY_FILE_DEST_SIZE' NAME, DISPLAY_VALUE
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='db_recovery_file_dest_size')
		  UNION 
		  SELECT 'COMPATIBLE' NAME, DISPLAY_VALUE 
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='compatible')
		  UNION 
		  SELECT 'DIAGNOSTIC_DEST' NAME, DISPLAY_VALUE
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='diagnostic_dest')
		  UNION 
		  SELECT 'DB_DOMAIN' NAME, DISPLAY_VALUE 
		  FROM (SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME ='db_domain')
		  UNION 
		  SELECT 'DB_NAME' NAME, DISPLAY_VALUE 
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='db_name')
		  UNION 
		  SELECT 'SGA_TARGET' NAME, DISPLAY_VALUE 
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='sga_target')
		  UNION 
		  SELECT 'PROCESSES' NAME, DISPLAY_VALUE
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='processes')
		  UNION
		  SELECT 'SESSIONS' NAME, DISPLAY_VALUE
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='sessions')
		  UNION 
		  SELECT 'UNDO_TABLESPACE' NAME, DISPLAY_VALUE
		  FROM(SELECT  DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='undo_tablespace')
		  UNION 
		  SELECT 'AUDIT_FILE_DEST' NAME, DISPLAY_VALUE
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='audit_file_dest')
		  UNION
		  SELECT 'AUDIT_TRAIL' NAME, DISPLAY_VALUE
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='audit_trail')
		  UNION 
		  SELECT 'REMOTE_LOGIN_PASSWORDFILE' NAME, DISPLAY_VALUE
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='remote_login_passwordfile')
		  UNION 
		  SELECT 'DISPATCHERS' NAME, DISPLAY_VALUE 
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME ='dispatchers')
		  UNION
		  SELECT 'CONTROL_FILES' NAME, DISPLAY_VALUE 
		  FROM(SELECT DISPLAY_VALUE FROM V$PARAMETER WHERE NAME='control_files')
		  )VALOR ON PARAMETRO.NOME = VALOR.NAME 
		  ORDER BY PARAMETRO.ORDEM; 
   
PROMPT *******************************************************************
PROMPT *                      PARAMETROS INSTANCIA                       *
PROMPT *******************************************************************  
SET LINES 1000
COLUMN "NOME"  		 FORMAT A30
COLUMN "VALOR"  	 FORMAT A30
COLUMN "COMENTARIO"  FORMAT A100 

SELECT 	PARAMETRO.NOME, 
		VALOR.VALOR,
		VALOR.COMENTARIO			
	FROM(
		SELECT 1 ORDEM,  'INSTANCE_NUMBER' 	NOME FROM DUAL UNION ALL  
		SELECT 2 ORDEM,  'INSTANCE_NAME'   	NOME FROM DUAL UNION ALL
		SELECT 3 ORDEM,  'HOST_NAME' 	    NOME FROM DUAL UNION ALL 
		SELECT 4 ORDEM,  'VERSION' 			NOME FROM DUAL UNION ALL
		SELECT 5 ORDEM,  'STARTUP_TIME' 	NOME FROM DUAL UNION ALL
		SELECT 6 ORDEM,  'STATUS' 			NOME FROM DUAL UNION ALL
		SELECT 7 ORDEM,  'PARALLEL' 		NOME FROM DUAL UNION ALL
		SELECT 8 ORDEM,  'THREAD#' 			NOME FROM DUAL UNION ALL
		SELECT 9 ORDEM,  'ARCHIVER' 		NOME FROM DUAL UNION ALL
		SELECT 10 ORDEM, 'LOG_SWITCH_WAIT' 	NOME FROM DUAL UNION ALL
		SELECT 11 ORDEM, 'LOGINS' 			NOME FROM DUAL UNION ALL
		SELECT 12 ORDEM, 'SHUTDOWN_PENDING' NOME FROM DUAL UNION ALL
		SELECT 13 ORDEM, 'DATABASE_STATUS' 	NOME FROM DUAL UNION ALL
		SELECT 14 ORDEM, 'INSTANCE_ROLE' 	NOME FROM DUAL UNION ALL
		SELECT 15 ORDEM, 'ACTIVE_STATE' 	NOME FROM DUAL UNION ALL
		SELECT 16 ORDEM, 'BLOCKED' 			NOME FROM DUAL UNION ALL
		SELECT 17 ORDEM, 'CON_ID' 			NOME FROM DUAL UNION ALL
		SELECT 18 ORDEM, 'INSTANCE_MODE' 	NOME FROM DUAL UNION ALL
		SELECT 19 ORDEM, 'EDITION' 			NOME FROM DUAL UNION ALL
		SELECT 20 ORDEM, 'FAMILY' 			NOME FROM DUAL 
	) PARAMETRO LEFT JOIN (
		SELECT 'INSTANCE_NUMBER' NAME, VALOR, 'Número para registro de instância' COMENTARIO FROM(
			SELECT TO_CHAR(INSTANCE_NUMBER) VALOR FROM V$INSTANCE
		)UNION 
		SELECT 'INSTANCE_NAME' NAME, VALOR, 'Nome da instância' FROM(
			SELECT TO_CHAR(INSTANCE_NAME) VALOR FROM V$INSTANCE
		)UNION 
		SELECT 'HOST_NAME' NAME, VALOR, 'Nome da máquina host' FROM(
			SELECT TO_CHAR(HOST_NAME) VALOR FROM V$INSTANCE
		)UNION
		SELECT 'VERSION' NAME, VALOR, 'Versão do banco de dados' FROM(
			SELECT TO_CHAR(VERSION) VALOR FROM V$INSTANCE
		)UNION 
		SELECT 'STARTUP_TIME' NAME, VALOR, 'Hora em que a instância foi iniciada' FROM(
			SELECT TO_CHAR(STARTUP_TIME) VALOR FROM V$INSTANCE
		)UNION 
		SELECT 'STATUS' NAME, VALOR, 'Status da instância' FROM(
			SELECT TO_CHAR(STATUS) VALOR FROM V$INSTANCE
		)UNION 
		SELECT 'PARALLEL' NAME, VALOR, 'Cluster(?) (YES/NO)' FROM(
			SELECT TO_CHAR(PARALLEL) VALOR FROM V$INSTANCE
		)UNION 
		SELECT 'THREAD#' NAME, VALOR, '' FROM(
			SELECT TO_CHAR(THREAD#) VALOR FROM V$INSTANCE
		)UNION 
		SELECT 'ARCHIVER' NAME, VALOR, 'Status de arquivamento automático' FROM(
			SELECT TO_CHAR(ARCHIVER) VALOR FROM V$INSTANCE
		)UNION 
		SELECT 'LOG_SWITCH_WAIT' NAME, VALOR, 'Status da troca de log' FROM(
			SELECT TO_CHAR(LOG_SWITCH_WAIT) VALOR FROM V$INSTANCE
		)UNION 
		SELECT 'LOGINS' NAME, VALOR, 'Restrição' FROM(
			SELECT TO_CHAR(LOGINS) VALOR FROM V$INSTANCE
		)UNION 
		SELECT 'SHUTDOWN_PENDING' NAME, VALOR, 'Desligamentos pendentes(YES/NO)' FROM(
			SELECT TO_CHAR(SHUTDOWN_PENDING) VALOR FROM V$INSTANCE 
		)UNION 
		SELECT 'DATABASE_STATUS' NAME, VALOR, 'Status do banco de dados' FROM(
			SELECT TO_CHAR(DATABASE_STATUS) VALOR FROM V$INSTANCE
		)UNION 
		SELECT 'INSTANCE_ROLE' NAME, VALOR, 'Indica se a instância é uma instância ativa/secundaria/UNKNOWN' FROM(
			SELECT TO_CHAR(INSTANCE_ROLE) VALOR FROM V$INSTANCE
		)UNION 
		SELECT 'ACTIVE_STATE' NAME, VALOR, 'Estado de Quiesce da instância' FROM(
			SELECT TO_CHAR(ACTIVE_STATE) VALOR FROM V$INSTANCE 
		)UNION 
		SELECT 'BLOCKED' NAME, VALOR, 'Indica se todos os serviços estão bloqueados(YES/NO)' FROM (
			SELECT TO_CHAR(BLOCKED) VALOR FROM V$INSTANCE
		)UNION
		SELECT 'CON_ID' NAME, VALOR, 'O ID do recipiente ao qual os dados pertencem' FROM(
			SELECT TO_CHAR(CON_ID) VALOR FROM V$INSTANCE
		)UNION 
		SELECT 'INSTANCE_MODE'  NAME, VALOR, 'Modo Oracle RAC(REGULAR/READ MOSTLY)' FROM(
			SELECT TO_CHAR(INSTANCE_MODE) VALOR FROM V$INSTANCE
		)UNION 
		SELECT 'EDITION' NAME, VALOR, 'Edição do banco de dados' FROM(
			SELECT TO_CHAR(EDITION) VALOR FROM V$INSTANCE
		)UNION
		SELECT 'FAMILY' NAME, VALOR, 'Uso interno*' FROM(
			SELECT TO_CHAR(EDITION) VALOR FROM V$INSTANCE
		)	
	)VALOR ON PARAMETRO.NOME = VALOR.NAME
	ORDER BY PARAMETRO.ORDEM;
   
PROMPT *******************************************************************
PROMPT *                PARAMETROS BANCO DE DADOS                        *
PROMPT *******************************************************************  
SET LINES 120 
SET PAGES 100  
SELECT PARAMETRO.PARAMETRO AS "PARAMETRO",
	   NVL(VALOR.VALOR,'<<N Parametrizado>>') AS "VALOR" 
	FROM(
			SELECT 1 ORDEM,'DBID' 						PARAMETRO FROM DUAL UNION ALL
			SELECT 2 ORDEM,'NAME' 						PARAMETRO FROM DUAL UNION ALL
			SELECT 3 ORDEM,'CREATED' 					PARAMETRO FROM DUAL UNION ALL
			SELECT 4 ORDEM,'RESETLOGS_CHANGE#' 			PARAMETRO FROM DUAL UNION ALL
			SELECT 5 ORDEM,'RESETLOGS_TIME' 			PARAMETRO FROM DUAL UNION ALL
			SELECT 6 ORDEM,'PRIOR_RESETLOGS_CHANGE#'	PARAMETRO FROM DUAL UNION ALL
			SELECT 7 ORDEM,'PRIOR_RESETLOGS_TIME' 		PARAMETRO FROM DUAL UNION ALL
			SELECT 8 ORDEM,'LOG_MODE' 					PARAMETRO FROM DUAL UNION ALL
			SELECT 9 ORDEM,'CHECKPOINT_CHANGE#' 		PARAMETRO FROM DUAL UNION ALL
			SELECT 10 ORDEM,'CONTROLFILE_TYPE,' 		PARAMETRO FROM DUAL UNION ALL
			SELECT 11 ORDEM,'CONTROLFILE_CREATED' 		PARAMETRO FROM DUAL UNION ALL
			SELECT 12 ORDEM,'CONTROLFILE_SEQUENCE#' 	PARAMETRO FROM DUAL UNION ALL
			SELECT 13 ORDEM,'CONTROLFILE_CHANGE#' 		PARAMETRO FROM DUAL UNION ALL
			SELECT 14 ORDEM,'CONTROLFILE_TIME' 			PARAMETRO FROM DUAL UNION ALL
			SELECT 15 ORDEM,'OPEN_RESETLOGS' 			PARAMETRO FROM DUAL UNION ALL
			SELECT 16 ORDEM,'VERSION_TIME' 				PARAMETRO FROM DUAL UNION ALL
			SELECT 17 ORDEM,'OPEN_MODE' 				PARAMETRO FROM DUAL UNION ALL
			SELECT 18 ORDEM,'PROTECTION_MODE' 			PARAMETRO FROM DUAL UNION ALL
			SELECT 19 ORDEM,'PROTECTION_LEVEL' 			PARAMETRO FROM DUAL UNION ALL
			SELECT 20 ORDEM,'REMOTE_ARCHIVE' 			PARAMETRO FROM DUAL UNION ALL
			SELECT 21 ORDEM,'ACTIVATION#' 				PARAMETRO FROM DUAL UNION ALL
			SELECT 22 ORDEM,'SWITCHOVER#' 				PARAMETRO FROM DUAL UNION ALL
			SELECT 23 ORDEM,'DATABASE_ROLE' 			PARAMETRO FROM DUAL UNION ALL
			SELECT 24 ORDEM,'ARCHIVELOG_CHANGE#' 		PARAMETRO FROM DUAL UNION ALL
			SELECT 25 ORDEM,'ARCHIVELOG_COMPRESSION' 	PARAMETRO FROM DUAL UNION ALL
			SELECT 26 ORDEM,'SWITCHOVER_STATUS' 		PARAMETRO FROM DUAL UNION ALL
			SELECT 27 ORDEM,'DATAGUARD_BROKER' 			PARAMETRO FROM DUAL UNION ALL
			SELECT 28 ORDEM,'GUARD_STATUS' 				PARAMETRO FROM DUAL UNION ALL
			SELECT 29 ORDEM,'SUPPLEMENTAL_LOG_DATA_MIN' PARAMETRO FROM DUAL UNION ALL
			SELECT 30 ORDEM,'SUPPLEMENTAL_LOG_DATA_PK' 	PARAMETRO FROM DUAL UNION ALL
			SELECT 31 ORDEM,'SUPPLEMENTAL_LOG_DATA_UI' 	PARAMETRO FROM DUAL UNION ALL
			SELECT 32 ORDEM,'FORCE_LOGGING' 			PARAMETRO FROM DUAL UNION ALL
			SELECT 33 ORDEM,'PLATFORM_ID' 				PARAMETRO FROM DUAL UNION ALL
			SELECT 34 ORDEM,'PLATFORM_NAME' 			PARAMETRO FROM DUAL UNION ALL
			SELECT 35 ORDEM,'RECOVERY_TARGET_INCARNATION#' PARAMETRO FROM DUAL UNION ALL
			SELECT 36 ORDEM,'LAST_OPEN_INCARNATION#' 	PARAMETRO FROM DUAL UNION ALL
			SELECT 37 ORDEM,'CURRENT_SCN' 				PARAMETRO FROM DUAL UNION ALL
			SELECT 38 ORDEM,'FLASHBACK_ON' 				PARAMETRO FROM DUAL UNION ALL
			SELECT 39 ORDEM,'SUPPLEMENTAL_LOG_DATA_FK' 	PARAMETRO FROM DUAL UNION ALL
			SELECT 40 ORDEM,'SUPPLEMENTAL_LOG_DATA_ALL' PARAMETRO FROM DUAL UNION ALL
			SELECT 41 ORDEM,'DB_UNIQUE_NAME' 			PARAMETRO FROM DUAL UNION ALL
			SELECT 42 ORDEM,'STANDBY_BECAME_PRIMARY_SCN'PARAMETRO FROM DUAL UNION ALL 
			SELECT 43 ORDEM,'FS_FAILOVER_STATUS' 		PARAMETRO FROM DUAL UNION ALL
			SELECT 44 ORDEM,'FS_FAILOVER_CURRENT_TARGET' PARAMETRO FROM DUAL UNION ALL
			SELECT 45 ORDEM,'FS_FAILOVER_THRESHOLD' 	PARAMETRO FROM DUAL UNION ALL
			SELECT 46 ORDEM,'FS_FAILOVER_OBSERVER_PRESENT' PARAMETRO FROM DUAL UNION ALL
			SELECT 47 ORDEM,'CONTROLFILE_CONVERTED' 	PARAMETRO FROM DUAL UNION ALL
			SELECT 48 ORDEM,'PRIMARY_DB_UNIQUE_NAME' 	PARAMETRO FROM DUAL UNION ALL
			SELECT 49 ORDEM,'SUPPLEMENTAL_LOG_DATA_PL' 	PARAMETRO FROM DUAL UNION ALL
			SELECT 50 ORDEM,'MIN_REQUIRED_CAPTURE_CHANGE#' PARAMETRO FROM DUAL UNION ALL
			SELECT 51 ORDEM,'CDB' 						PARAMETRO FROM DUAL UNION ALL
			SELECT 52 ORDEM,'CON_ID' 					PARAMETRO FROM DUAL UNION ALL
			SELECT 53 ORDEM,'PENDING_ROLE_CHANGE_TASKS' PARAMETRO FROM DUAL UNION ALL
			SELECT 54 ORDEM,'CON_DBID' 					PARAMETRO FROM DUAL UNION ALL
			SELECT 55 ORDEM,'FORCE_FULL_DB_CACHING'		PARAMETRO FROM DUAL
		) PARAMETRO LEFT JOIN 
		(
			SELECT 'DBID' NAME, VALOR FROM
				(SELECT TO_CHAR(DBID) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'NAME' NAME, VALOR FROM
				(SELECT NAME VALOR FROM V$DATABASE) 
			UNION 
			SELECT 'CREATED' NAME, VALOR FROM
				(SELECT TO_CHAR(CREATED) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'RESETLOGS_CHANGE#' NAME, VALOR FROM
				(SELECT TO_CHAR(RESETLOGS_CHANGE#) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'RESETLOGS_TIME' NAME, VALOR FROM
				(SELECT TO_CHAR(RESETLOGS_TIME) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'PRIOR_RESETLOGS_CHANGE#' NAME, VALOR FROM
				(SELECT TO_CHAR(PRIOR_RESETLOGS_CHANGE#) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'PRIOR_RESETLOGS_TIME' NAME, VALOR FROM
				(SELECT TO_CHAR(PRIOR_RESETLOGS_TIME) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'LOG_MODE' NAME, VALOR FROM
				(SELECT TO_CHAR(LOG_MODE) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'CHECKPOINT_CHANGE#' NAME, VALOR FROM
				(SELECT TO_CHAR(CHECKPOINT_CHANGE#) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'CONTROLFILE_TYPE' NAME, VALOR FROM
				(SELECT TO_CHAR(CONTROLFILE_TYPE) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'CONTROLFILE_CREATED' NAME, VALOR FROM
				(SELECT TO_CHAR(CONTROLFILE_CREATED) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'CONTROLFILE_SEQUENCE#' NAME, VALOR FROM
				(SELECT TO_CHAR(CONTROLFILE_SEQUENCE#) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'CONTROLFILE_CHANGE#' NAME, VALOR FROM
				(SELECT TO_CHAR(CONTROLFILE_CHANGE#) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'CONTROLFILE_TIME' NAME, VALOR FROM
				(SELECT TO_CHAR(CONTROLFILE_TIME) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'OPEN_RESETLOGS' NAME, VALOR FROM
				(SELECT TO_CHAR(OPEN_RESETLOGS) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'VERSION_TIME' NAME, VALOR FROM
				(SELECT TO_CHAR(VERSION_TIME) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'OPEN_MODE' NAME, VALOR FROM
				(SELECT TO_CHAR(OPEN_MODE) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'PROTECTION_MODE' NAME, VALOR FROM
				(SELECT TO_CHAR(PROTECTION_MODE) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'PROTECTION_LEVEL' NAME, VALOR FROM
				(SELECT TO_CHAR(PROTECTION_LEVEL) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'REMOTE_ARCHIVE' NAME, VALOR FROM
				(SELECT TO_CHAR(REMOTE_ARCHIVE) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'ACTIVATION#' NAME, VALOR FROM
				(SELECT TO_CHAR(ACTIVATION#) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'SWITCHOVER#' NAME, VALOR FROM
				(SELECT TO_CHAR(SWITCHOVER#) VALOR FROM V$DATABASE)
				UNION 
			SELECT 'DATABASE_ROLE' NAME, VALOR FROM
				(SELECT TO_CHAR(DATABASE_ROLE) VALOR FROM V$DATABASE) 
				UNION 
			SELECT 'ARCHIVELOG_CHANGE#' NAME, VALOR FROM
				(SELECT TO_CHAR(ARCHIVELOG_CHANGE#) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'ARCHIVELOG_COMPRESSION' NAME, VALOR FROM
				(SELECT TO_CHAR(ARCHIVELOG_COMPRESSION) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'SWITCHOVER_STATUS' NAME, VALOR FROM
				(SELECT TO_CHAR(SWITCHOVER_STATUS) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'DATAGUARD_BROKER' NAME, VALOR FROM
				(SELECT TO_CHAR(DATAGUARD_BROKER) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'GUARD_STATUS' NAME, VALOR FROM
				(SELECT TO_CHAR(GUARD_STATUS) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'SUPPLEMENTAL_LOG_DATA_MIN' NAME, VALOR FROM
				(SELECT TO_CHAR(SUPPLEMENTAL_LOG_DATA_MIN) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'SUPPLEMENTAL_LOG_DATA_PK' NAME, VALOR FROM
				(SELECT TO_CHAR(SUPPLEMENTAL_LOG_DATA_PK) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'SUPPLEMENTAL_LOG_DATA_UI' NAME, VALOR FROM
				(SELECT TO_CHAR(SUPPLEMENTAL_LOG_DATA_UI) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'FORCE_LOGGING' NAME, VALOR FROM
				(SELECT TO_CHAR(FORCE_LOGGING) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'PLATFORM_ID' NAME, VALOR FROM
				(SELECT TO_CHAR(PLATFORM_ID) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'PLATFORM_NAME' NAME, VALOR FROM
				(SELECT TO_CHAR(PLATFORM_NAME) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'RECOVERY_TARGET_INCARNATION#' NAME, VALOR FROM
				(SELECT TO_CHAR(RECOVERY_TARGET_INCARNATION#) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'LAST_OPEN_INCARNATION#' NAME, VALOR FROM
				(SELECT TO_CHAR(LAST_OPEN_INCARNATION#) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'CURRENT_SCN' NAME, VALOR FROM
				(SELECT TO_CHAR(CURRENT_SCN) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'FLASHBACK_ON' NAME, VALOR FROM
				(SELECT TO_CHAR(FLASHBACK_ON) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'SUPPLEMENTAL_LOG_DATA_FK' NAME, VALOR FROM
				(SELECT TO_CHAR(SUPPLEMENTAL_LOG_DATA_FK) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'SUPPLEMENTAL_LOG_DATA_ALL' NAME, VALOR FROM
				(SELECT TO_CHAR(SUPPLEMENTAL_LOG_DATA_ALL) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'DB_UNIQUE_NAME' NAME, VALOR FROM
				(SELECT TO_CHAR(DB_UNIQUE_NAME) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'STANDBY_BECAME_PRIMARY_SCN' NAME, VALOR FROM
				(SELECT TO_CHAR(STANDBY_BECAME_PRIMARY_SCN) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'FS_FAILOVER_STATUS' NAME, VALOR FROM
				(SELECT TO_CHAR(FS_FAILOVER_STATUS) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'FS_FAILOVER_CURRENT_TARGET' NAME, VALOR FROM
				(SELECT TO_CHAR(FS_FAILOVER_CURRENT_TARGET) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'FS_FAILOVER_THRESHOLD' NAME, VALOR FROM
				(SELECT TO_CHAR(FS_FAILOVER_THRESHOLD) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'FS_FAILOVER_OBSERVER_PRESENT' NAME, VALOR FROM
				(SELECT TO_CHAR(FS_FAILOVER_OBSERVER_PRESENT) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'CONTROLFILE_CONVERTED' NAME, VALOR FROM
				(SELECT TO_CHAR(CONTROLFILE_CONVERTED) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'PRIMARY_DB_UNIQUE_NAME' NAME, VALOR FROM
				(SELECT TO_CHAR(PRIMARY_DB_UNIQUE_NAME) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'SUPPLEMENTAL_LOG_DATA_PL' NAME, VALOR FROM
				(SELECT TO_CHAR(SUPPLEMENTAL_LOG_DATA_PL) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'MIN_REQUIRED_CAPTURE_CHANGE#' NAME, VALOR FROM
				(SELECT TO_CHAR(MIN_REQUIRED_CAPTURE_CHANGE#) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'CDB' NAME, VALOR FROM
				(SELECT TO_CHAR(CDB) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'CON_ID' NAME, VALOR FROM
				(SELECT TO_CHAR(CON_ID) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'PENDING_ROLE_CHANGE_TASKS' NAME, VALOR FROM
				(SELECT TO_CHAR(PENDING_ROLE_CHANGE_TASKS) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'CON_DBID' NAME, VALOR FROM
				(SELECT TO_CHAR(CON_DBID) VALOR FROM V$DATABASE) 
				UNION
			SELECT 'FORCE_FULL_DB_CACHING' NAME, VALOR FROM
				(SELECT TO_CHAR(FORCE_FULL_DB_CACHING) VALOR FROM V$DATABASE) 
		)VALOR ON PARAMETRO.PARAMETRO = VALOR.NAME 
		ORDER BY PARAMETRO.ORDEM;

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/RRRR'; 
SPOOL OFF
