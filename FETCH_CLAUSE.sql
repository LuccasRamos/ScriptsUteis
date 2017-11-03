--#REVISAR
SELECT employee_id, first_name
from employees 
order by employee_id 

SELECT employee_id, first_name
from employees 
order by employee_id 
fetch first 5 rows only -- pega as primeiras 5 linhas

SELECT employee_id, first_name
from employees 
order by employee_id 
fetch first 50 percent with TIES -- pega 50% dos funcionarios

SELECT employee_id, first_name
from employees 
order by employee_id 
offset 8 rows fetch next 50 percent rows only --pega 50% dos funcionarios e pula os 8 primeiros

SELECT employee_id, first_name
from employees 
order by employee_id 
fetch first 2 row only -- pega as duas primeiras linhas

SELECT employee_id, first_name
from employees 
order by employee_id 
fetch first 2 rows with TIES -- pega as duas primeiras linhas classificando 
--valores que teoricamente ocupam a mesma posição retornndo mais que as linhas especificadas

**Questão importante
	- a clausula rownum é executada antes do order by. 
	  logo, primeiro é restringido e depois ordenado e 
	  o correto seria order todas as linhas e depois restringir com rownum. 
	  
--Jeito errado	  
select last_name, commission_pct 
    from employees where rownum<=5
    order by commission_pct desc nulls last
    
--jeito correto    
    SELECT * 
    FROM(
        SELECT last_name, commission_pct 
                from employees 
                order by commission_pct desc nulls last
         ) where rownum <=5
