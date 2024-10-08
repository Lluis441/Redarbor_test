--alter view dbo.Statistical_Summary as
 select
	'all' as source
	,avg(bad_good_ratio) as Mean_Ratio
	,stdev(bad_good_ratio) as Standard_Deviation_Ratio
	  ,var(bad_good_ratio) as Variance_Ratio
	  ,min(bad_good_ratio) as Min_Ratio
	  ,max(bad_good_ratio) as Max_Ratio
	  ,count(bad_good_ratio) as Puntos
	  ,0 as Puntos_sin_good
	  ,0 as Puntos_sin_users
	  ,sum(bad)/sum(good) as Ratio_total
	  ,sum(bad) + sum (good) as Users
	  ,sum(bad) as bad
	  ,sum(good) as good
FROM [Redarbor_test].[dbo].[data_redarbor_test]

UNION ALL

 SELECT top (2000000)
  source
  ,avg(bad_good_ratio) as Mean_Ratio
  ,stdev(bad_good_ratio) as Standard_Deviation_Ratio
  ,var(bad_good_ratio) as Variance_Ratio
  ,min(bad_good_ratio) as Min_Ratio
  ,max(bad_good_ratio) as Max_Ratio
  ,count(bad_good_ratio) as Puntos
  ,count(case when good = 0 then 1 end)as Puntos_sin_good
  ,count(case when bad + good = 0 then 1 end)as Puntos_sin_users
  ,sum(bad)/sum(good) as Ratio_total
  ,sum(bad) + sum (good) as Users
  ,sum(bad) as bad
  ,sum(good) as good
  FROM [Redarbor_test].[dbo].[data_redarbor_test_source]

  group by source

  order by Users desc,Ratio_total

