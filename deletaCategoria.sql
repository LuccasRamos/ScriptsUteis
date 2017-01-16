CREATE OR REPLACE FUNCTION EXC_CATEGORIA_FCT(id_cat in NUMBER)
		RETURN VARCHAR2 
		IS MSG VARCHAR2(300);
		PRAGMA AUTONOMOUS_TRANSACTION;
		BEGIN 
			delete from TB_CATEGORIA where CAT_COD = id_cat;
			COMMIT;
			IF SUBSTR(UPPER(SQLERRM(SQLCODE)),0,8) = 'ORA-0000' THEN 
				MSG:='Categoria Excluida!';
				return MSG;
			END IF;
			EXCEPTION 
				WHEN OTHERS THEN 
					IF SUBSTR(UPPER(SQLERRM(SQLCODE)),0,9) = 'ORA-02292' THEN 
						SELECT DESCRICAO INTO MSG FROM ERRO_SISTEMA WHERE COD_ERRO='E_CAT001';
						RETURN MSG;
					ELSE
						MSG:=UPPER(SQLERRM(SQLCODE));
						RETURN MSG;
					END IF;
		END EXC_CATEGORIA_FCT;
	/