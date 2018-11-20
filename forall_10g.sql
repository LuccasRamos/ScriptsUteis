DECLARE  
  TYPE F_ID_FATURA IS TABLE OF VARCHAR2(100);
  TYPE F_DATA_COMPRA IS TABLE OF globo.faturas.data_compra%TYPE;
  
  V_ID_FATURA F_ID_FATURA := F_ID_FATURA();
  V_DATA_COMPRA F_DATA_COMPRA := F_DATA_COMPRA();
  
  idx int := 1;
BEGIN 
  FOR x in (SELECT f.rowid as id,
               f.id_fatura, 
               f.data_compra old_data_compra,
               to_char(c.dia_pagamento,'00')||'/'||to_char(f.data_compra,'mm/rr') as new_data_compra,
               c.dia_pagamento
				FROM
  				globo.faturas f,
  				globo.cliente_servicos cs,
  				globo.clientes c
				WHERE
				  f.id_cli_serv   = cs.id_cli_serv
				AND cs.id_cliente = c.id_cliente 
        and dia_pagamento <28
        AND ROWNUM <=500000)
  LOOP
    V_ID_FATURA.extend;
    V_DATA_COMPRA.extend;
    
    V_ID_FATURA(V_ID_FATURA.last) := x.id;
    V_DATA_COMPRA(V_DATA_COMPRA.last) := x.new_data_compra;
  
    idx := idx + 1;
  
    if (mod(idx,30000)=0)then 
      FORALL i in V_ID_FATURA.FIRST .. V_ID_FATURA.LAST 
      	UPDATE globo.faturas SET data_teste = V_DATA_COMPRA(i) WHERE ROWID = V_ID_FATURA(i);
          V_ID_FATURA.delete;
          V_DATA_COMPRA.delete;
        commit;
        idx:=1;
    end if;   
  END LOOP;
END;
/
