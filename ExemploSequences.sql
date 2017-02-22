--Cursor explicito
--OBS: Cursor deve ser declarado!
--A expressão '*' pode ser usada. 
--Não é preciso utilizar a expressão 'into' no select
DECLARE 
linha  number;
tabela varchar2(38);
CURSOR r1(row number) is select rownum, table_name from user_tables where rownum<=row;
c1 r1%rowtype;
BEGIN
	--Consumindo cursor r1
	dbms_output.put_line(' Cursor R1 ');
	open r1(20);
	loop 
		fetch r1
		into linha, tabela; 
		exit when r1%notfound;
		dbms_output.put_line(linha||' - '||tabela);
	end loop;
	close r1;	
	
	--consumindo cursor c1
	dbms_output.put_line(' Cursor C1 ');
	open r1(20);
	loop 
		fetch r1
		into c1; 
		exit when r1%notfound;
		dbms_output.put_line(c1.rownum||' - '||c1.table_name);
	end loop;
	close r1;	
END;
/


--definição interna
BEGIN 
	for r1 in (select rownum, table_name from user_tables where rownum<11) loop 
	dbms_output.put_line(r1.rownum||' - '||r1.table_name);
	end loop;
END;
/

