
--CREATE VIEW [dbo].[data_redarbor_test] as

WITH times_min_max AS (
    SELECT 
        MIN(time) AS min_time,
        MAX(time) AS max_time
    FROM 
		dbo.Data
)
,fechas AS (
	SELECT
		min_time as time	
	FROM
		times_min_max fmm

	UNION ALL
	
	SELECT
		dateadd(minute, 5 * N, fmm.min_time) as time
	FROM 
		dbo.Numbers
		,times_min_max fmm

	WHERE
		dateadd(minute, 5 * N, fmm.min_time) < fmm.max_time
)


SELECT TOP (2000000)
	f.time
	,COUNT(CASE WHEN a.quality = 'bad' THEN 1 END) AS bad
	,COUNT(CASE WHEN a.quality = 'good' THEN 1 END) AS good
	,CASE
		WHEN COUNT(CASE WHEN a.quality = 'good' THEN 1 END) = 0 THEN NULL
		ELSE CAST(COUNT(CASE WHEN a.quality = 'bad' THEN 1 END) AS DECIMAL(10,2)) /
			 CAST(COUNT(CASE WHEN a.quality = 'good' THEN 1 END) AS DECIMAL(10,2))
		END AS [bad_good_ratio]

FROM
	fechas f
	LEFT JOIN dbo.Data a ON a.time>= DATEADD(hour, -1, f.time) AND a.time < f.time --Desde la �ltima hora hasta la fecha.

GROUP BY
	f.time

ORDER BY
	f.time
GO


