# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from biovis_media_extension.plugin import BasePlugin


class ScatterPlotPlugin(BasePlugin):
    """
    Scatter plot plugin for biovis_media_extension.

    :Example:
    @scatter-plot()
    """
    plugin_name = 'scatter-plot'
    plugin_dir = os.path.dirname(os.path.abspath(__file__))
    is_server = True

    def __init__(self, *args, **kwargs):
        super(ScatterPlotPlugin, self).__init__(*args, **kwargs)

    def check_plugin_args(self, **kwargs):
        pass
