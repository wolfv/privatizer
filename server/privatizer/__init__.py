from pyramid.config import Configurator
from sqlalchemy import engine_from_config

from pyramid.authentication import AuthTktAuthenticationPolicy
from pyramid.authorization import ACLAuthorizationPolicy
from .security import groupfinder

from pyramid.session import UnencryptedCookieSessionFactoryConfig


from .models import DBSession

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    engine = engine_from_config(settings, 'sqlalchemy.')
    DBSession.configure(bind=engine)

    # Authentication

    authn_policy = AuthTktAuthenticationPolicy(secret='wolfdergeilehengstbamdam',
                                               callback=groupfinder)
    authz_policy = ACLAuthorizationPolicy()

    # Session

    session_factory = UnencryptedCookieSessionFactoryConfig('itsaseekreet')

    config = Configurator(settings=settings,
                          session_factory=session_factory)
    config.add_static_view('static', 'static', cache_max_age=3600)
    
    config.add_route('home', '/')

    config.add_route('key.add', 'keys/add', factory='privatizer.models.KeyFactory')
    config.add_route('key.list', 'keys', factory='privatizer.models.KeyFactory')

    config.add_route('key.changepermission', 'keys/key/changepermission/{id}', factory='privatizer.models.KeyFactory', traverse='/{id}')
    config.add_route('key.delete', 'keys/key/delete/{id}', factory='privatizer.models.KeyFactory', traverse='/{id}')
    config.add_route('key.deletepermission', 'keys/permission/delete/{id}:{for}', factory='privatizer.models.KeyFactory', traverse='/{id}')

    config.add_route('keys.api.list', 'api/keys/list', factory='privatizer.models.KeyFactory')
    config.add_route('key.api.by_id', 'api/key/{id}', factory='privatizer.models.KeyFactory')
    config.add_route('key.api.new', 'api/key/add', factory='privatizer.models.KeyFactory')

    config.add_route('user.api.autofill', 'api/user/find')
    config.add_route('api.login', 'api/login')

    config.add_route('user_view', 'user/{name}', factory='privatizer.models.User')
 
    config.add_route('signup', 'signup')
    config.add_route('login', 'login')
    config.add_route('logout', 'logout')
    

    config.set_authentication_policy(authn_policy)
    config.set_authorization_policy(authz_policy)

    config.scan('privatizer.views')
    return config.make_wsgi_app()

