select
	'bad' as quality
	,source
	,userid
	,time

into Redarbor_test.dbo.Data
from Redarbor_test.dbo.bad

UNION ALL --junto todas las l�neas porque se que no habr� duplicados. Si lo quisiera sin duplicados, usar�a union.

select
	'good' as quality
	,source
	,userid
	,time

from Redarbor_test.dbo.good