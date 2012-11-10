import logging

from sqlalchemy import and_
from pyramid.response import Response
from pyramid.view import view_config

from pyramid.httpexceptions import *

from pyramid.security import authenticated_userid

from ..models import *

from ..resources.tools import flashtype

log = logging.getLogger(__name__)


@view_config(route_name='key.add', renderer='key/add.mako', permission='auth')
def add(request):
	error = False
	if 'form.submitted' in request.params:
		log.debug(request.POST)
		if not len(request.POST['name']):
			request.session.flash({'message': 'You need to set a name for your Key!', 'type': flashtype['error']})
			error = True
		if not len(request.POST['keytext']):
			request.session.flash({'message': 'You need to set a keytext for your Key!', 'type': flashtype['error']})
			error = True
		if error:
			return {}
		else:
			user = User.by_id(authenticated_userid(request))
			key = Key(
				request.POST['name'],
				user.id,
				request.POST['keytext'],
				request.POST['description']
				)
			DBSession.add(key)
			request.session.flash({'message': 'Your Key was added', 'type': flashtype['success']})
	else:
		log.debug(request.params)
	return {}


@view_config(route_name='key.changepermission', context='privatizer.models.Key', permission='own')
def changepermission(context, request):
	if 'form.adduserpermission' in request.params:
		key = context
		url = request.route_url('key.list')
		user = User.by_name_or_email(request.POST['name_or_email'])
		try:
			user_id = user.id
			key_id = int(request.POST['key_id'])
		except:
			return HTTPBadRequest()

		res = DBSession.query(KeyPermission).filter(KeyPermission.user_id == user_id, KeyPermission.key_id == key.id).first()

		if res:
			res.permission = request.POST['key_permission']
			DBSession.add(res)
			return HTTPFound(location=url)
		else:
			permission = KeyPermission()
			permission.user_id = user_id
			permission.key_id = key_id
			permission.permission = request.POST['key_permission']
			DBSession.add(permission)
			return HTTPFound(location=url)
	return Response('Something wrong here.')


@view_config(route_name='key.deletepermission', context='privatizer.models.Key', permission='own', renderer='json')
def deletepermission(context, request):
	log.debug('delete key permission')
	key = context
	log.debug(key)

	if key.owner_id != authenticated_userid(request):
		return HTTPForbidden()

	user_id = int(request.matchdict['for'])
	try:
		p = KeyPermission.by_user_and_key(user_id, key.id)
		DBSession.delete(p)
		return {'key': key.id, 'shared_with': [{'name': permission.user.user_name, 'id': permission.user_id} for permission in key.permissions]}
	#	return HTTPFound(location=url)

	except:
		return Response('Sorry, something wrong.', 403)


@view_config(route_name='key.list', renderer='key/list.mako', permission='auth')
def list(request):
	userid = authenticated_userid(request)
	if userid != None:
		user = User.by_id(userid)
		return {'keys': user.keys, 'perms': user.permissions}
	else:
		return Response('Forbidden', 403)
