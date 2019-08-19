# -*- coding:utf-8 -*-
import os
import sys

PROJECT_ROOT = os.path.abspath(os.path.dirname(__file__))


def get_oss_bin():
    oss_bin = ''
    if sys.platform == 'darwin':
        oss_bin = os.path.join(os.path.dirname(__file__), "mk_media_extension", "lib", 'ossutilmac64')
    else:
        oss_bin = os.path.join(os.path.dirname(__file__), "mk_media_extension", "lib", 'ossutil64')
    return oss_bin


class BaseConfig(object):
    SECRET_KEY = 'this-really-needs-to-be-changed'

    # SQLITE
    SQLALCHEMY_DATABASE_URI = 'sqlite://'

    DEBUG = False
    ERROR_404_HELP = False

    REVERSE_PROXY_SETUP = os.getenv('EXAMPLE_API_REVERSE_PROXY_SETUP', False)

    AUTHORIZATIONS = {
        'oauth2_password': {
            'type': 'oauth2',
            'flow': 'password',
            'scopes': {},
            'tokenUrl': '/auth/oauth2/token',
        },

        # TODO: implement other grant types for third-party apps
        # 'oauth2_implicit': {
        #    'type': 'oauth2',
        #    'flow': 'implicit',
        #    'scopes': {},
        #    'authorizationUrl': '/auth/oauth2/authorize',
        # },
    }

    ENABLED_MODULES = (
        'pm2',
        'kong',
        'plugin',
        'api',
    )

    SWAGGER_UI_JSONEDITOR = True
    SWAGGER_UI_OAUTH_CLIENT_ID = 'documentation'
    SWAGGER_UI_OAUTH_REALM = "Authentication for Flask-RESTplus Example server documentation"
    SWAGGER_UI_OAUTH_APP_NAME = "Flask-RESTplus Example server documentation"

    # TODO: consider if these are relevant for this project
    SQLALCHEMY_TRACK_MODIFICATIONS = True
    CSRF_ENABLED = True

    # Enable cache
    CACHE_TYPE = 'simple'

    # OSS
    ACCESS_KEY = 'OSS_ACCESS_KEY'
    ACCESS_SECRET = 'OSS_ACCESS_SECRET'
    ENDPOINT = 'OSS_ENDPOINT'
    OSS_BIN = get_oss_bin()

    # Proxy
    PROXY_ADMIN_URL = 'http://localhost:8001'
    REVERSE_PROXY_URL = 'http://localhost:8000'

    # Plugin Engine
    SYNC_OSS = True
    SYNC_HTTP = True
    SYNC_FTP = True
    TARGET_FSIZE = 10
    PROTOCOL = 'http'
    DOMAIN = 'localhost'
    ENABLE_IFRAME = True
    WAIT_SERVER_SECONDS = 5
    BACKOFF_FACTOR = 3

    STATIC_ROOT = os.path.join(PROJECT_ROOT, 'static')
    STATIC_URL = 'http://localhost:5000'


class ProductionConfig(BaseConfig):
    ENV = 'production'
    SECRET_KEY = os.getenv('EXAMPLE_API_SERVER_SECRET_KEY')
    # POSTGRESQL
    DB_USER = 'user'
    DB_PASSWORD = 'password'
    DB_NAME = 'restplusdb'
    DB_HOST = 'localhost'
    DB_PORT = 5432
    SQLALCHEMY_DATABASE_URI = 'postgresql://{user}:{password}@{host}:{port}/{name}'.format(
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT,
        name=DB_NAME,
    )


class DevelopmentConfig(BaseConfig):
    ENV = 'development'
    DEBUG = True
    DOMAIN = '192.168.199.227'
    SQLALCHEMY_DATABASE_URI = 'sqlite:///%s' % (os.path.join(PROJECT_ROOT, "example.db"))


class TestingConfig(BaseConfig):
    ENV = 'testing'
    TESTING = True

    # Use in-memory SQLite database for testing
    SQLALCHEMY_DATABASE_URI = 'sqlite://'
