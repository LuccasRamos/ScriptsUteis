ORDER BY 
- Default nulls last
- somente campos presente no select
- combinação de números(posição) e campos
- Aceita "campo" ou campo. quando usando "", o campo é case-sensitive
- resultado considera case sensitive
- resultado considera casas decimais
- quando é definido um alias, o mesmo deve ser usado(do mesmo jeito que foi criado) e o campo original não é reconhecido
- quando usado com set operator, é considerado os campos da primeira consulta. 

NVL()
NVL2()
COALESCE()
NULLIF()

TO_CHAR('','formato')
TO_NUMBER('')
TO_DATE('','formato')

--caracter
SELECT CONCAT(CLI_CODIGO||' ',CLI_NOME) FROM CLIENTE_CLI
SELECT SUBSTR(CLI_NOME,1,5) FROM CLIENTE_CLI
SELECT LOWER(CLI_NOME) FROM CLIENTE_CLI 
SELECT UPPER(CLI_NOME) FROM CLIENTE_CLI
SELECT INITCAP(CLI_NOME) FROM CLIENTE_CLI
SELECT LENGTH(CLI_NOME) FROM CLIENTE_CLI
SELECT INSTR(CLI_NOME||CLI_CODIGO,'C',1) FROM CLIENTE_CLI
SELECT RPAD(CLI_CODIGO,10,'*') FROM CLIENTE_CLI
SELECT LPAD(CLI_CODIGO,10,'*') FROM CLIENTE_CLI
SELECT REPLACE(CLI_CODIGO,'0','A') FROM CLIENTE_CLI
SELECT TRIM(CLI_CODIGO FROM 'CF') FROM CLIENTE_CLI

--Numeros
SELECT ROUND(10.3879,2) FROM DUAL
SELECT TRUNC(10.3879,2) FROM DUAL
SELECT MOD(6,2) FROM DUAL

--data
1 de janeiro 4712 A.C a 31 de dezembro 9999D.C 
default(MM/DD/YYYY)
date
select sysdate-sysdate from dual

SELECT MONTHS_BETWEEN(TO_DATE('20/09','DD/MM'),TO_DATE('20/02','DD/MM')) FROM DUAL
SELECT ADD_MONTHS(SYSDATE,2) FROM DUAL 
SELECT NEXT_DAY(SYSDATE,'SÁBADO') FROM DUAL
SELECT LAST_DAY(SYSDATE) FROM DUAL
SELECT ROUND(SYSDATE) FROM DUAL
SELECT TRUNC(SYSDATE) FROM DUAL
/* Formatted on 2017/09/12 15:07 (Formatter Plus v4.8.8) */
SELECT ROUND(MONTHS_BETWEEN (TO_DATE ('28/12/2017 17:10:46', 'DD/MM/YYYYHh24:mi:ss'),
                       TO_DATE ('20/09/2017 12:10:10', 'DD/MM/YYYYHh24:mi:ss'))) AS "MESES"
FROM DUAL

SELECT NEXT_DAY(SYSDATE,3) FROM DUAL

9-NUMERO
0-qualquer numero ou zero
$ dolar
L moeda local
. casa decimal
, milhar

SELECT TO_CHAR('1987103','L999G999G999D00') FROM DUAL

NVL()
NVL2()
NULLIF(A,B) se a=b então nulo senão retorna a.
COALESCE()

