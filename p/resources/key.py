class Key(Object):
	__acl__ = [
		(Allow, Authenticated, 'new'),
		(Allow, 'key:permission', 'view')
	]