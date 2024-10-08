SELECT  [time]
	  ,'all' as source
      ,[bad]
      ,[good]
      ,[bad_good_ratio]
	  , bad + good as total_users
      

 FROM [Redarbor_test].[dbo].[data_redarbor_test]


  UNION ALL

  SELECT top (2000000)
		[time]
		,[source]
      ,[bad]
      ,[good]
      ,[bad_good_ratio]
	  ,total_users

	FROM [Redarbor_test].[dbo].[data_redarbor_test_top_source_each_time]
      
	order by
		time, total_users