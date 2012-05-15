import logging

from pyramid.response import Response
from pyramid.view import view_config, forbidden_view_config

from sqlalchemy.exc import DBAPIError
from sqlalchemy.orm import sessionmaker

from pyramid.security import authenticated_userid
from pyramid.security import has_permission
from pyramid.security import remember
from pyramid.security import forget

from pyramid.httpexceptions import *

from ..models import *

log = logging.getLogger(__name__)

def authenticate(request):
    user = User.authenticate(
        request.params['email'], 
        request.params['password']
    )
    if user:
        return user
    else:
        return None


@view_config(route_name='home', renderer='start.mako')
def home(request):
    user = authenticated_userid(request)
    if user:
        user = User.by_id(user)
    try:
    	return {'user': user}
    except DBAPIError:
        return Response(conn_err_msg, content_type='text/plain', status_int=500)
    return {'project':'p'}

@view_config(route_name='login', renderer='login.mako')
def login(request):
    login_url = '/login'
    referrer = request.url
    if referrer == login_url:
        referrer = '/' # never use the login form itself as came_from
    came_from = request.params.get('came_from', referrer)
    log.debug(request.params)
    message = ''
    login = ''
    password = ''
    if 'form.submitted' in request.params:
        login = request.params['login']
        password = request.params['password']
        log.debug(login)
        user = User.by_email(login)
        log.debug(user)
        log.debug(user.check_password(password))
        if user is not None and user.check_password(password):
            headers = remember(request, user.id)
            return HTTPFound(location = '/',
                             headers = headers)
        message = 'Failed login'

    return dict(
        flash = message,
        url = request.application_url + '/login',
        came_from = came_from,
        login = login,
        password = password,
        )

@view_config(route_name='api.login', renderer='json')
def api_login(request):
    request.response.headerlist.extend([
        ('Access-Control-Allow-Origin', "%s" % request.referer ),
        ('Access-Control-Allow-Credentials', "true")
    ])   
    if 'username' in request.params:
        login = request.params['username']
        password = request.params['password']
        log.debug(login)
        user = User.by_email(login)
        if user is not None and user.check_password(password):
            headers = remember(request, user.id, tokens=['Hannover'])
            log.debug(headers)
            request.response.headerlist.extend(headers)
            log.debug('WE got the moterfucker')
            return [
                ('User', 'Found'),
                ('auth_token', '123')    
            ]
        else:
            return [('User', 'Not Found')]
    return [('Access Forbidden')]

@view_config(route_name='logout')
def logout(request):
    headers = forget(request)
    return HTTPFound(location = request.resource_url(request.context),
                     headers = headers)

@view_config(route_name='signup', renderer='user_new.mako')
def user_new(request):
	if 'form.submitted' in request.params:
		if request.POST['password'] != request.POST['password_retype']:
			return {'flash': 'ERROR: Retype password correctly.'}
		if request.POST['name'] == None:
			return {'flash': 'ERROR: Put in a name.'}
		if request.POST['csrf'] != request.session.get_csrf_token():
			return Response('Forbidden', 403)
		else:
			user = User()
			user.set_password(request.POST['password'])
			user.user_name = request.POST['name']
			user.email = request.POST['email']
			user.status = 0 # Not verified yet
			DBSession.add(user)
			return {'flash': 'Hinzugepackt!'}
		return {}
	return {}

conn_err_msg = """\
Pyramid is having a problem using your SQL database.  The problem
might be caused by one of the following things:

1.  You may need to run the "initialize_p_db" script
    to initialize your database tables.  Check your virtual 
    environment's "bin" directory for this script and try to run it.

2.  Your database server may not be running.  Check that the
    database server referred to by the "sqlalchemy.url" setting in
    your "development.ini" file is running.

After you fix the problem, please restart the Pyramid application to
try it again.
"""

