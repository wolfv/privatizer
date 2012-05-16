from cryptacular.bcrypt import BCRYPTPasswordManager
from cryptacular.core import DelegatingPasswordManager

import hashlib
import urllib
import random
import string
import logging

from .resources.tools import encode_base36, decode_base36

from pyramid.security import(
		Allow,
		Everyone,
		Authenticated,
		Deny
	)

import sqlalchemy as sa

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy.orm import (
	scoped_session,
	sessionmaker,
	)

from zope.sqlalchemy import ZopeTransactionExtension

log = logging.getLogger(__name__)

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
Base = declarative_base()

class KeyFactory(object):
	__acl__ = [
		(Allow, Everyone, 'test'),
		(Allow, Authenticated, 'auth'),
	]
	
	def __init__(self, request):
		pass

	def __getitem__(self, key):
		key = DBSession.query(Key).get(int(key))
		key.__parent__ = self
		key.__name__ = key
		return key

class User(Base):

	__tablename__ = 'user'

	def __init__(self):
		pass

	id = sa.Column(sa.Integer, primary_key=True)

	user_name = sa.Column(sa.Unicode(30), unique=True)

	user_password = sa.Column(sa.String(256))

	email = sa.Column(sa.Unicode(100), nullable=False, unique=True)

	status = sa.Column(sa.SmallInteger(), nullable=False)

	security_code = sa.Column(sa.String(256), default='default')

	keys = sa.orm.relationship("Key", backref="owner", cascade="all, delete, delete-orphan")

	permissions = sa.orm.relationship("KeyPermission", backref="user", cascade="all, delete, delete-orphan")

	passwordmanager = DelegatingPasswordManager(preferred=BCRYPTPasswordManager())

	last_login_date = sa.Column(sa.TIMESTAMP(timezone=False),
								default=sa.sql.func.now(),
								server_default=sa.func.now()
								)

	registered_date =  sa.Column(sa.TIMESTAMP(timezone=False),
								default=sa.sql.func.now(),
								server_default=sa.func.now()
								)

	def __repr__(self):
		return "<User %s>" % self.user_name

	def gravatar_url(self, default='mm'):
		""" returns user gravatar url """
		# construct the url
		hash = hashlib.md5(self.email.encode('utf8').lower()).hexdigest()
		gravatar_url = "https://secure.gravatar.com/avatar/%s?%s" % (
												hash,
												urllib.urlencode({'d':default})
																	  )
		return gravatar_url

	def set_password(self, raw_password):
		""" sets new password """
		self.user_password = self.passwordmanager.encode(raw_password)
		self.regenerate_security_code()

	def check_password(self, raw_password):
		""" checks string with users password hash"""
		return self.passwordmanager.check(self.user_password, raw_password,
										  setter=self.set_password)
	@classmethod
	def generate_random_pass(cls, chars=7):
		""" generates random string of fixed length"""
		return cls.generate_random_string(chars)
	
	def regenerate_security_code(self):
		""" generates new security code"""
		self.security_code = self.generate_random_string(32)
 
	@staticmethod
	def generate_random_string(chars=7):
		return u''.join(random.sample(string.ascii_letters + string.digits, chars))

	@staticmethod
	def by_email(email):
		res = DBSession.query(User).filter(User.email == email)
		return res.first()
	
	@staticmethod
	def by_id(id):
		res = DBSession.query(User).get(id)
		return res

	@classmethod
	def by_name_or_email(cls, value):
		query1 = DBSession.query(cls).filter(cls.email == value)
		query2 = DBSession.query(cls).filter(cls.user_name == value)
		return query1.union(query2).first()
	
	@staticmethod
	def authenticate(email, password):
		user = DBSession.query(User).one(User.email == email)
		if user.check_password(password):
			return user
		else:
			return False

class KeyPermission(Base):

	__tablename__ = 'key_permission'

	key_id = sa.Column('key_id', sa.BigInteger, sa.ForeignKey('key.id'), primary_key=True)
	
	user_id = sa.Column('user_id', sa.Integer, sa.ForeignKey('user.id'), primary_key=True)
	
	permission = sa.Column('permission', sa.String(30))

	@classmethod
	def by_user_and_key(cls, user_id, key_hash):
		key_id = decode_base36(key_hash)
		return DBSession.query(cls).filter(cls.user_id == user_id, cls.key_id == key_id).first()
	
class Key(Base):
	"""Key Table""" 
	@property 
	def __acl__(self):
		return [
			(Allow, self.owner_id, 'own')
		]


	__tablename__ = 'key'		

	def __init__(self, name, owner_id, keytext, description = None):
		self.name = name
		self.owner_id = owner_id
		self.keytext = keytext
		self.description = description

	id = sa.Column(sa.Integer, primary_key=True)

	owner_id = sa.Column(sa.Integer, sa.ForeignKey('user.id'))

	name = sa.Column(sa.Unicode(100), nullable=False)

	description = sa.Column(sa.Unicode(300))

	keytext = sa.Column(sa.Unicode(200), nullable=False)

	keyhash = sa.Column(sa.String(200), unique=True)

	permissions = sa.orm.relationship("KeyPermission", backref="key", cascade="all, delete, delete-orphan")

	def __repr__(self):
		return '<Key %s, %s>' % (self.name, self.description)

	@classmethod
	def by_id(cls, id_):
		query = DBSession.query(cls).filter(cls.id == id_)
		return query.first()

	@classmethod
	def by_hash(cls, hash):
		id_ = decode_base36(hash)
		query = DBSession.query(cls).filter(cls.id == id_)
		return query.first()

	def hash(self):
		return encode_base36(self.id)

class Group(Base):
	"""Groups with Group Permissions"""

	__tablename__ = 'group'

	id = sa.Column(sa.Integer, primary_key=True)

	name = sa.Column(sa.Unicode(50))

	description = sa.Column(sa.Unicode(300))

