# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from mk_media_extension.plugin import BasePlugin


class HeatmapD3Plugin(BasePlugin):
    """
    Heatmap plugin for mk_media_extension.

    :Example:
    @heatmap-d3()
    """
    plugin_name = 'heatmap-d3'
    plugin_dir = os.path.dirname(os.path.abspath(__file__))
    is_server = True

    def check_plugin_args(self, **kwargs):
        pass
