select
	'bad' as quality
	,source
	,userid
	,time

into Redarbor_test.dbo.Analysis_test
from Redarbor_test.dbo.bad

UNION ALL --junto todas las líneas porque se que no habrá duplicados. Si lo quisiera sin duplicados, usaría union.

select
	'good' as quality
	,source
	,userid
	,time

from Redarbor_test.dbo.good