(SELECT                                                                   
	CASE                                                                  
		WHEN OBJECT_TYPE = 'PROCEDURE' THEN 'PROCEDURE ' || OBJECT_NAME 
		WHEN OBJECT_TYPE = 'VIEW'      THEN 'VIEW '      || OBJECT_NAME 
		WHEN OBJECT_TYPE = 'TABLE'     THEN 'TABLE '     || OBJECT_NAME 
		WHEN OBJECT_TYPE = 'TRIGER'    THEN 'TRIGGER '   || OBJECT_NAME
		WHEN OBJECT_TYPE = 'FUNCTION'  THEN 'FUNCTION '  || OBJECT_NAME 
		WHEN OBJECT_TYPE = 'SEQUENCE'  THEN 'SEQUENCE '  || OBJECT_NAME 		
	END AS "Objeto"
		FROM DBA_OBJECTS WHERE OBJECT_TYPE IN ('PROCEDURE','VIEW','TABLE','TRIGGER','FUNCTION','SEQUENCE') AND OWNER='MANAGER')
MINUS 
(
SELECT 
	CASE 
		WHEN OBJECT_TYPE = 'PROCEDURE' THEN 'PROCEDURE ' || OBJECT_NAME 
		WHEN OBJECT_TYPE = 'VIEW'      THEN 'VIEW '      || OBJECT_NAME 
		WHEN OBJECT_TYPE = 'TABLE'     THEN 'TABLE '     || OBJECT_NAME 
		WHEN OBJECT_TYPE = 'TRIGER'    THEN 'TRIGGER '   || OBJECT_NAME 
		WHEN OBJECT_TYPE = 'FUNCTION'  THEN 'FUNCTION '  || OBJECT_NAME 
		WHEN OBJECT_TYPE = 'SEQUENCE'  THEN 'SEQUENCE '  || OBJECT_NAME 
	END AS "Objeto"
		FROM DBA_OBJECTS WHERE OBJECT_TYPE IN ('PROCEDURE','VIEW','TABLE','TRIGGER','FUNCTION','SEQUENCE') AND OWNER='WEBMANAGER');
