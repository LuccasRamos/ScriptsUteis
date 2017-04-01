--Bloco criado para renomear constraints que são criadas com a nomeclatura padrão do oracle 

DECLARE
	contraint_name1 varchar2(40); 
	cursor c1 is SELECT t2.constraint_name, t1.table_name, t2.column_name
  FROM    USER_CONSTRAINTS T1
       JOIN
          USER_CONS_COLUMNS T2
       ON     T1.constraint_name = T2.CONSTRAINT_NAME
         -- AND t1.table_name = 'NOT_NULL'
          AND t2.constraint_name like 'SYS_%'; 
	r1 c1%rowtype;
BEGIN 
	open c1; 
	loop 
		fetch c1 into r1; 
		exit when c1%notfound;
		dbms_output.put_line('ALTER TABLE '||r1.table_name||' rename constraint '||r1.constraint_name||' TO '||r1.column_name||'_CK');
		execute immediate 'ALTER TABLE '||r1.table_name||' rename constraint '||r1.constraint_name||' TO '||r1.column_name||'_CK';
	end loop;
END;
/
