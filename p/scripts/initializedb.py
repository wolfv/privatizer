import os
import sys
import transaction

from sqlalchemy import engine_from_config

from pyramid.paster import (
    get_appsettings,
    setup_logging,
    )

from ..models import *

def usage(argv):
    cmd = os.path.basename(argv[0])
    print('usage: %s <config_uri>\n'
          '(example: "%s development.ini")' % (cmd, cmd)) 
    sys.exit(1)

def main(argv=sys.argv):
    if len(argv) != 2:
        usage(argv)
    config_uri = argv[1]
    setup_logging(config_uri)
    settings = get_appsettings(config_uri)
    engine = engine_from_config(settings, 'sqlalchemy.')
    DBSession.configure(bind=engine)


    Base.metadata.create_all(engine)

    user = User()
    user.set_password('wolfvo8491')
    user.user_name = 'wolfv'
    user.email = 'w.vollprecht@gmail.com'
    user.status = 1 # Not verified yet

    DBSession.add(user)

    with transaction.manager:
        user = User()
        user.user_name = 'wolf'
        user.email = 'w.vollprecht@gmail.com'
        user.set_password('wolf')
        user.status = 1
        DBSession.add(user)

        user = User()
        user.user_name = 'peter'
        user.email = 'p@p.de'
        user.set_password('p')
        user.status = 1
        DBSession.add(user)

