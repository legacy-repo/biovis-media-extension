# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from mk_media_extension.plugin import BasePlugin


class BoxplotRPlugin(BasePlugin):
    """
    Boxplot R plugin for mk_media_extension.

    :Example:
    @boxplot-r()
    """
    plugin_name = 'boxplot-r'
    plugin_dir = os.path.dirname(os.path.abspath(__file__))
    is_server = True

    def __init__(self, *args, **kwargs):
        super(BoxplotRPlugin, self).__init__(*args, **kwargs)

    def check_plugin_args(self, **kwargs):
        pass
