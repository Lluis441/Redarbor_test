--CREATE VIEW [dbo].[data_redarbor_test_source] as


WITH times_min_max AS (
    SELECT 
        MIN(time) AS min_time,
        MAX(time) AS max_time
    FROM 
		dbo.Data
)
,top10_sources as(
	SELECT
		top (11) source
		,count(*) as qty

	FROM
		dbo.Data

	GROUP BY 
		source
	ORDER BY
		count(*) desc
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
	,COUNT(CASE WHEN d.quality = 'bad' THEN 1 END) AS bad
	,COUNT(CASE WHEN d.quality = 'good' THEN 1 END) AS good
	,CASE
		WHEN COUNT(CASE WHEN d.quality = 'good' THEN 1 END) = 0 THEN NULL
		ELSE CAST(COUNT(CASE WHEN d.quality = 'bad' THEN 1 END) AS DECIMAL(10,2)) /
			 CAST(COUNT(CASE WHEN d.quality = 'good' THEN 1 END) AS DECIMAL(10,2))
		END AS [bad_good_ratio]
	,d.source as source

FROM
	fechas f
	LEFT JOIN dbo.Data d ON d.time>= DATEADD(hour, -1, f.time) AND d.time < f.time --Desde la �ltima hora hasta la fecha.
	JOIN top10_sources t ON t.source=d.source

--where d.source=0

GROUP BY
	f.time
	,d.source



ORDER BY
	f.time