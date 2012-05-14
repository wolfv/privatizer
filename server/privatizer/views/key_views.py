import logging

from sqlalchemy import and_
from pyramid.response import Response
from pyramid.view import view_config

from pyramid.httpexceptions import *

from pyramid.security import authenticated_userid

from ..models import *

log = logging.getLogger(__name__)

@view_config(route_name='key.add', renderer='addkey.mako', permission='auth')
def add(request):
    flashtype = {'attention':
        {'cssclass': 'attention',
         'name': 'Attention'}, 
    'error': 
        {'cssclass': 'error',
         'name': 'Error'}, 
    'success': 
        {'cssclass': 'success',
        'name': 'Success'}
    }
    error = False
    if 'form.submitted' in request.params:
        log.debug(request.POST)
        if not len(request.POST['name']):
            request.session.flash({'message': 'You need to set a name for your Key!', 'type': flashtype['error']})
            error = True
        if  not len(request.POST['keytext']):
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
            permission.key_id = request.POST['key_id']
            permission.permission = request.POST['key_permission']
            DBSession.add(permission)
            return HTTPFound(location=url)
    return Response('Something wrong here.')

@view_config(route_name='key.deletepermission', context='privatizer.models.Key', permission='own')
def deletepermission(context, request):
    key = context
    url = request.route_url('key.list')

    if key.owner_id != authenticated_userid(request):
        return HTTPForbidden()
    user = User.by_id(request.matchdict['for'])
    try:
        p = KeyPermission.by_user_and_key(user.id, key.id)
        DBSession.delete(p)
        return HTTPFound(location=url)
    except:
        return Response('Sorry, something wrong.', 403)

@ view_config(route_name = 'key.list', renderer='key/list.mako', permission='auth')
def list(request):   
    userid = authenticated_userid(request)
    if userid != None:
        user = User.by_id(userid)
        return {'keys': user.keys, 'perms': user.permissions}
    else:
        return Response('Forbidden', 403)

@ view_config(route_name = 'keys.api.list', renderer='json', permission='auth')
def api_list(request):
    userid = authenticated_userid(request)
    if userid != None:
        user = User.by_id(userid)
        keys = user.keys
        return [{'hash': key.hash(), 'name': key.name, 'description': key.description} for key in keys]
    else:
        return Response('Forbidden', 403)

@view_config(route_name='key.api.by_id', renderer='json')
def key_api_by_id(request):
    log.debug( request.client_addr)
    request.response.headerlist.extend([
        ('Access-Control-Allow-Origin', "*" ),
        ('Access-Control-Allow-Credentials', "true")
    ])   
    log.debug(request.cookies)
    log.debug(authenticated_userid(request))
    key_id = request.matchdict['id']
    if key_id:
        key = Key.by_hash(key_id)
    if key:
        auth_user= authenticated_userid(request)
        if key.owner_id == auth_user:
            return {
                'name': key.name, 
                'key': key.keytext
            }
        else:
            perm = KeyPermission.by_user_and_key(authenticated_userid(request), key_id)
            if perm and perm.permission == 'view':
                return {
                    'name': key.name, 
                    'key': key.keytext
                }
            else:   
                response = request.response.status_int = 403
                return [('No Access')]

@view_config(route_name='user.api.autofill', renderer='json')
def user_api_autofill(request):
    text = request.GET['q']
    log.debug(u'' + text + '%')
    if text:
        query = DBSession.query(User).filter(User.user_name.like(text + '%')).order_by(User.user_name)[0:10]
        res = dict()
        res['success'] = 'true'
        res['users'] = []
        for user in query:
            res['users'].append(user.user_name)
        return res
    else:
        return {}

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

        return {'success' : True}
    else:
        log.debug(request.params)
    return {}
