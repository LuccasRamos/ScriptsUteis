--Exemplo do uso do GROUP BY 

SELECT TO_CHAR(DATA,'MONTH'),COUNT(DATA) FROM TB_PUBLICACAO  GROUP BY TO_CHAR(DATA,'MONTH') ORDER BY 1;
