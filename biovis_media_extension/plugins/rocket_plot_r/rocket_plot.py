# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from biovis_media_extension.plugin import BasePlugin


class RocketPlotRPlugin(BasePlugin):
    """
    RocketPlotRPlugin for biovis_media_extension.

    :Example:
    @rocket-plot-r()
    """
    plugin_name = 'rocket-plot-r'
    plugin_dir = os.path.dirname(os.path.abspath(__file__))
    is_server = True

    def __init__(self, *args, **kwargs):
        super(RocketPlotRPlugin, self).__init__(*args, **kwargs)

    def check_plugin_args(self, **kwargs):
        pass
