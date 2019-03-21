# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from mk_media_extension.plugin import BasePlugin


class UpsetRPlugin(BasePlugin):
    """
    Upset plugin for mk_media_extension.

    :Example:
    @upset-r()
    """
    plugin_name = 'upset-r'
    plugin_dir = os.path.dirname(os.path.abspath(__file__))
    is_server = True

    def check_plugin_args(self, **kwargs):
        pass
