# -*- coding:utf-8 -*-
from __future__ import unicode_literals
import os
import sys
import logging
import configparser
from mk_media_extension.utils import check_dir

logger = logging.getLogger(__name__)
CONFIG_FILES = ['~/.choppy/choppy.conf', '/etc/choppy.conf']


def getconf(config_files):
    for f in config_files:
        try:
            loc = os.path.expanduser(f)
        except KeyError:
            # os.path.expanduser can fail when $HOME is undefined and
            # getpwuid fails. See http://bugs.python.org/issue20164 &
            # https://github.com/kennethreitz/requests/issues/1846
            return

        if os.path.exists(loc):
            return loc


config = configparser.ConfigParser()

config_files = CONFIG_FILES
conf_path = getconf(config_files)


def check_oss_config():
    if access_key and access_secret and endpoint:
        return True
    else:
        raise Exception("You need to config oss section in choppy.conf")


if conf_path:
    config.read(conf_path, encoding="utf-8")

    # oss access_key and access_secret
    access_key = config.get('oss', 'access_key')
    access_secret = config.get('oss', 'access_secret')
    endpoint = config.get('oss', 'endpoint')
    if config.has_section('plugin'):
        plugin_cache_dir = os.path.expanduser(config.get('plugin', 'cache_dir'))
        plugin_db = os.path.expanduser(config.get('plugin', 'plugin_db'))
        clean_cache = config.getboolean('plugin', 'clean_cache')
        protocol = config.get('plugin', 'protocol')
        domain = config.get('plugin', 'domain')
        enable_iframe = config.getboolean('plugin', 'enable_iframe')
        wait_server_seconds = config.getint('wait_server_seconds', 5)
    else:
        logger.warn('No plugin section in config file.')
        plugin_cache_dir = os.path.join('/tmp', 'choppy-media-extension')
        plugin_db = os.path.join('/tmp/choppy-media-extension', 'plugin.db')
        clean_cache = True
        protocol = 'http'
        domain = '127.0.0.1'
        enable_iframe = True
        wait_server_seconds = 5

    logger.info('Create plugin_cache_dir: %s' % plugin_cache_dir)
    check_dir(plugin_cache_dir, skip=True)
    check_oss_config()


def get_oss_bin():
    if sys.platform == 'darwin':
        oss_bin = os.path.join(os.path.dirname(
            __file__), "lib", 'ossutilmac64')
    else:
        oss_bin = os.path.join(os.path.dirname(__file__), "lib", 'ossutil64')
    return oss_bin
