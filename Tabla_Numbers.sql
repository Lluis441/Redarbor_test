-- Crear tabla de numeros
WITH NumbersCTE AS (

    SELECT 1 AS N

    UNION ALL

    SELECT N + 1
    FROM NumbersCTE
    WHERE N < 5000
)


SELECT N
INTO [Redarbor_test].[dbo].[Numbers]
FROM NumbersCTE
OPTION (MAXRECURSION 0);

