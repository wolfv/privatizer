def groupfinder(userid, request):
	return 'view'
	if userid in USERS:
		return GROUPS.get(userid, [])