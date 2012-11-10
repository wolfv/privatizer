"""
	API Module for all API Views
	Provides interfaces for all actions called
	from the JS-Plugin
"""

# Setup Logger
import logging
log = logging.getLogger(__name__)

from pyramid.response import Response
from pyramid.view import view_config

from pyramid.httpexceptions import *

from pyramid.security import authenticated_userid

from ..models import *

from ..resources.tools import flashtype


# List Keys for selection in plugin
@view_config(route_name='keys.api.list', renderer='json', permission='auth')
def api(request):
	userid = authenticated_userid(request)
	if userid:
		if request.method == 'GET':
			# Return a list with all keys
			user = User.by_id(userid)
			keys = user.keys

			return [{
				'id': key.id,
				'hash': key.hash(),
				'name': key.name,
				'description': key.description,
				'shared_with': [
					{
						'name': permission.user.user_name,
						'id': permission.user_id
					} for permission in key.permissions
				]}
				for key in keys]
		elif request.method == 'POST':
			# Create a new key
			if not request.json_body['keytext']:
				keytext = generate_random_string(30)
			else:
				keytext = request.json_body['keytext']

			key = Key(
				request.json_body['name'],
				userid,
				keytext,
				request.json_body['description']
				)
			DBSession.add(key)

#			if request.POST['permissions']:
#				for permission in request.POST['permissions']:
#					perm            = KeyPermission()
#					perm.user_id    = permission.user_id
#					perm.key_id     = key.id
#					perm.permission = 'view'

			return {'success': True}

	else:
		return Response('Forbidden', 403)


# Modify Key Permissions
@view_config(route_name='keys.api.modify', renderer='json', permission='own')
def key_api_modify(context, request):
	key = context
	if request.method == 'PUT':
		key.name = request.json_body['name']
		key.description = request.json_body['description']
		return {}
	elif request.method == 'DELETE':
		DBSession.delete(key)
	else:
		return Response('Forbidden', 403)


# Get Key by ID
@view_config(route_name='key.api.by_hash', renderer='json', permission='auth')
def key_api_by_id(request):

# 	Should work without
#	request.response.headerlist.extend([
#		('Access-Control-Allow-Origin', "%s" % request.referer ),
#		('Access-Control-Allow-Credentials', "true")
#	])

	key_hash = request.matchdict['hash']
	if key_hash:
		key = Key.by_hash(key_hash)
	if key:
		auth_user = authenticated_userid(request)
		if key.owner_id == auth_user:
			permissions = [
				{
					'name': permission.user.user_name,
					'id': permission.user_id
				} for permission in key.permissions
			]
			return {
				'name': key.name,
				'key': key.keytext,
				'shared_with': permissions
			}
		else:
			perm = KeyPermission.by_user_and_key(auth_user, key_id)
			if perm and perm.permission == 'view':
				return {
					'name': key.name,
					'key': key.keytext
				}
			else:
				response = request.response.status_int = 403
				return [('No Access')]


@view_config(route_name='key.api.new', renderer='json', permission='add')
def key_api_new(request):
	if request.POST['name']:

		user = User.by_id(authenticated_userid(request))

		if not request.POST['keytext']:
			keytext = generate_random_string(30)
		else:
			keytext = request.POST['keytext']

		key = Key(
			request.POST['name'],
			user.id,
			request.POST['description'],
			keytext
			)
		DBSession.add(key)

		if request.POST['permissions']:
			for permission in request.POST['permissions']:
				perm = KeyPermission()
				perm.user_id = permission.user_id
				perm.key_id = key.id
				perm.permission = 'view'

		return {'success': True}
	else:
		log.debug(request.params)
	return {}


@view_config(route_name='key.api.modify_permissions', renderer='json',
	context='privatizer.models.Key', permission='own')
def key_api_permission(context, request):
	log.debug(context)
	key = context
	if request.method == 'POST':
		if request.json_body['name']:
			user = User.by_name_or_email(request.json_body['name'])
			if user:
				user_id = user.id
				res = DBSession.query(KeyPermission).filter(KeyPermission.user_id == user_id,
							KeyPermission.key_id == key.id).first()
				if res:
					# Do you need to commit?
					res.permission = request.json_body['key_permission']
				else:
					permission = KeyPermission()
					permission.user_id = user_id
					permission.key_id = key.id
					#permission.permission = request.json_body['key_permission']
					DBSession.add(permission)
				return ['success']
			elif '@' in request.POST['name_or_email']:
				external_id_type = 'email'
				external_identifier = request.POST['name_or_email']

		if request.POST['external_id_type']:
			external_identifier = request.POST['external_id']
			external_id_type = request.POST['external_id_type']

		if external_identifier and external_id_type:
			external_id = ExternalIdentification.find(external_id_type,
														external_identifier)
			future_permission = FuturePermission(key.id, 'view')
			if external_id:
				external_id.future_permissions.add(future_permission)
			else:
				external_id = ExternalIdentification(external_id_type, external_identifier)
				external_id.future_permissions.add(future_permission)
			return {'success': 'true'}
		return HTTPBadRequest()


@view_config(route_name='key.api.delete_permission', renderer='json',
			context='privatizer.models.Key', permission='own')
def key_api_delete(context, request):
	if request.method == 'DELETE':
		if not request.json_body['future_permission']:
			user_id = int(request.json_body['user'])
			KeyPermission.by_user_and_key(user_id, context.id)
			DBSession.delete(context)
		else:
			pass


###############################################################################
# User API 																	  #
###############################################################################


@view_config(route_name='user.api.autofill', renderer='json')
def user_api_autofill(request):

	"""Find users that start with ... for autofill"""
	text = request.GET['q']
	log.debug(u'' + text + '%')
	if text:
		query = DBSession.query(User).filter(User.user_name.like(text + '%')).order_by(User.user_name)[0:10]
		res = dict()
		res['success'] = 1
		res['users'] = ({'name': user.user_name} for user in query)
		return res
	else:
		return {}
