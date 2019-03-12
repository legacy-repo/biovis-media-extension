# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from mk_media_extension.plugin import BasePlugin


class StackBarPlotPlugin(BasePlugin):
    """
    Stack barplot plugin for mk_media_extension.

    :Example:
    @stack-barplot-r()
    """
    plugin_name = 'stack-barplot-r'
    plugin_dir = os.path.dirname(os.path.abspath(__file__))
    is_server = True

    def check_plugin_args(self, **kwargs):
        pass
