
--CREATE VIEW [dbo].[data_redarbor_test_top_source_each_time] as

WITH times_min_max AS (
    SELECT 
        MIN(time) AS min_time,
        MAX(time) AS max_time
    FROM 
		dbo.Data
)
,top10_sources as(
	SELECT
		top (10) source
		--,time
		,count(*) as qty

	FROM
		dbo.Data

	GROUP BY 
		source
		--,time

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

,data as(
SELECT 
	f.time
	,COUNT(CASE WHEN d.quality = 'bad' THEN 1 END) AS bad
	,COUNT(CASE WHEN d.quality = 'good' THEN 1 END) AS good
	,COUNT(CASE WHEN d.quality = 'bad' THEN 1 END) + 
    COUNT(CASE WHEN d.quality = 'good' THEN 1 END) AS total_users
	,CASE
		WHEN COUNT(CASE WHEN d.quality = 'good' THEN 1 END) = 0 THEN NULL
		ELSE CAST(COUNT(CASE WHEN d.quality = 'bad' THEN 1 END) AS DECIMAL(10,2)) /
			 CAST(COUNT(CASE WHEN d.quality = 'good' THEN 1 END) AS DECIMAL(10,2))
		END AS [bad_good_ratio]
	,d.source as source
	, ROW_NUMBER() OVER (PARTITION BY f.time ORDER BY 
            COUNT(CASE WHEN d.quality = 'bad' THEN 1 END) + 
            COUNT(CASE WHEN d.quality = 'good' THEN 1 END) DESC
        ) AS row_num
FROM
	fechas f
	LEFT JOIN dbo.Data d ON d.time>= DATEADD(hour, -1, f.time) AND d.time < f.time --Desde la �ltima hora hasta la fecha.
	--JOIN top10_sources t ON t.source=d.source --and t.time=f.time

--where d.source=0

GROUP BY
	f.time
	,d.source
)

SELECT top (20000000)
	time
	,source
	,bad
	,good
	,total_users
	,bad_good_ratio

from data

WHERE
	row_num <= 10

order by
	time
	,row_num
	
GO


