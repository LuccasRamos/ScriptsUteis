--WHENEVER SQLERROR EXIT
SET SERVEROUTPUT ON
DECLARE
	--adicionado em 29-12-16
	--CURSOR SQL_VERSAO IS SELECT LAST_VALUE(VER_VERSAO) OVER (ORDER BY VER_DATA ASC) FROM VERSAO_VER WHERE VER_VERSAO LIKE '9.%'; --recebe versão
	VERSAO VARCHAR2(15):='9.2.1.1'; --recebe do cursor a versão da base de dados
	OCCR01 INT; --primeira Ocorrencia
	OCCR02 INT; --segunda  Ocorrencia
	OCCR03 INT; --terceira Ocorrencia 
	VR1    INT; --primeira coluna
	VR2    INT; --segunda  coluna
	VR3    INT; --terceira coluna
	VR4    INT; --quarta   coluna
	VR5    INT; --concatena vr1,vr2,vr3,vr4 pra formar um inteiro unico
	VERSAOP VARCHAR2(15):='9.2.1.2'; --Aqui entra o WEBINI
	OCR01 INT; --primeira Ocorrencia
	OCR02 INT; --segunda  Ocorrencia
	OCR03 INT; --terceira Ocorrencia 
	V1    INT; --primeira coluna
	V2    INT; --segunda  coluna
	V3    INT; --terceira coluna
	V4    INT; --quarta   coluna
	V5    INT; --concatena vr1,vr2,vr3,vr4 pra formar um inteiro unico
	
	--fim edição
BEGIN 
	--inicio sub-bloco 001
	BEGIN
		/*OPEN SQL_VERSAO; 
		LOOP 
			FETCH SQL_VERSAO 
			INTO VERSAO; 
			EXIT WHEN SQL_VERSAO%NOTFOUND;
		END LOOP; 
		CLOSE SQL_VERSAO;*/
		--OCORRENCIAS VERSAO_VER
		SELECT INSTR(VERSAO,'.',1) INTO OCCR01 FROM DUAL;
		SELECT INSTR(VERSAO,'.',(OCCR01+1)) INTO OCCR02 FROM DUAL;
		SELECT INSTR(VERSAO,'.',(OCCR02+1)) INTO OCCR03 FROM DUAL;
		--SEPARAR VALORES VERSAO_VER
		SELECT SUBSTR(VERSAO,1,1) INTO VR1 FROM DUAL;
		SELECT SUBSTR(VERSAO,(OCCR02+1),1) INTO VR3 FROM DUAL;
		SELECT SUBSTR(VERSAO,(OCCR03+1),2) INTO VR4 FROM DUAL;
		SELECT SUBSTR(VERSAO,(OCCR01+1),2) INTO VR2 FROM DUAL;
		--CONCATENA
		VR5:=(VR1||VR2||VR3||VR4);
		DBMS_OUTPUT.PUT_LINE('versão base: '||VR5);
	
		EXCEPTION 
		WHEN VALUE_ERROR THEN 
			SELECT SUBSTR(VERSAO,(OCCR01+1),1) INTO VR2 FROM DUAL;
				VR5:=(VR1||VR2||VR3||VR4);
				DBMS_OUTPUT.PUT_LINE('versão base: '||VR5);
	
	END;
	--fim sub-bloco 001
	--inicio sub-bloco 002
	BEGIN
		--OCORRENCIAS VERSAO_pacote
		SELECT INSTR(VERSAOP,'.',1) INTO OCR01 FROM DUAL;
		SELECT INSTR(VERSAOP,'.',(OCR01+1)) INTO OCR02 FROM DUAL;
		SELECT INSTR(VERSAOP,'.',(OCR02+1)) INTO OCR03 FROM DUAL;
		--SEPARAR VALORES VERSAO_pacote
		SELECT SUBSTR(VERSAOP,1,1) INTO V1 FROM DUAL;
		SELECT SUBSTR(VERSAOP,(OCR02+1),1) INTO V3 FROM DUAL;
		SELECT SUBSTR(VERSAOP,(OCR03+1),2) INTO V4 FROM DUAL;
		SELECT SUBSTR(VERSAOP,(OCR01+1),2) INTO V2 FROM DUAL;
		--CONCATENA
		V5:=(V1||V2||V3||V4);
		DBMS_OUTPUT.PUT_LINE('Versão pacote: '||v5);
		
		EXCEPTION 
			WHEN VALUE_ERROR THEN 
				SELECT SUBSTR(VERSAOP,(OCR01+1),1) INTO V2 FROM DUAL;
					V5:=(V1||V2||V3||V4);
					DBMS_OUTPUT.PUT_LINE('versão pacote: '||V5);
	END;
	--fim sub-bloco 002
IF V5 - VR5 = 0 THEN
	RAISE_APPLICATION_ERROR(-20004,'ATENÇÃO! -> ESTE PACOTE JÁ FOI APLICADO!| abortado!');
END IF;--1º condicao
IF V4 - VR4  = 0 OR V4 - VR4 <> 1 THEN 
	DBMS_OUTPUT.PUT_LINE('#1incompativel');
END IF;--2º condicao
IF (((V3 > VR3) AND (VR3 = (V3-1))) OR V3 = VR3) AND V4 = 1 AND V3 - VR3 = 1 THEN 
	NULL;
ELSE 
	DBMS_OUTPUT.PUT_LINE('#2incompativel');
END IF;
IF V2 - VR2 <> 0 OR V2 - VR2 <> 1 THEN 
	NULL;
		IF V3 = VR3 AND V2 < VR2  THEN 
			DBMS_OUTPUT.PUT_LINE('#3INCOMPATIVEL');
		END IF;
ELSE 
	DBMS_OUTPUT.PUT_LINE('#3incompativel');
	END IF;
END; 
/