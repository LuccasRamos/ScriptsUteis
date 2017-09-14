-- O conceito deste exercicio era o não agrupamento de todos os campo... resolvido fazendo um self join
  SELECT T1.EMPLOYEE_ID,
         SUM (
            ROUND (MONTHS_BETWEEN (TO_DATE (END_DATE), TO_DATE (START_DATE))))
            AS "MESES",
            SUM(ROUND (MONTHS_BETWEEN (TO_DATE (END_DATE), TO_DATE (START_DATE))/12,1)) AS "ANOS E MESES",
            T2."QTD_JOBS"
    FROM    JOB_HISTORY T1
         INNER JOIN
            (  SELECT EMPLOYEE_ID, COUNT (JOB_ID) AS "QTD_JOBS"
                 FROM JOB_HISTORY
             GROUP BY EMPLOYEE_ID) T2
         ON (T1.EMPLOYEE_ID = T2.EMPLOYEE_ID)
GROUP BY T1.EMPLOYEE_ID, T2."QTD_JOBS"
  

--Pegar o nome do funcionario que é manager. conceito... self join e verificar os managers da tabela 1 que são funcionarios da tabela 2
SELECT FIRST_NAME || ' ' || LAST_NAME AS "EMPLOYEE_NAME", T2."MANAGER_NAME",T1.MANAGER_ID
  FROM    EMPLOYEES T1
       LEFT JOIN
          (SELECT FIRST_NAME || ' ' || LAST_NAME AS "MANAGER_NAME", EMPLOYEE_ID
             FROM EMPLOYEES
            WHERE EMPLOYEE_ID IN (SELECT MANAGER_ID FROM EMPLOYEES)) T2
       ON  T1.MANAGER_ID = T2.EMPLOYEE_ID 
       ORDER BY 1
