# -*- coding:utf-8 -*-
from __future__ import unicode_literals
from .test_bokeh_plugin.test import TestBokehPlugin
from .test_plotly_plugin.test import TestPlotlyPlugin
from .igv_viewer.igv_viewer import IgvViewer
from .circos_scatter.circos_scatter import CircosScatterViewer


class PluginRegistry:
    def __init__(self):
        self._internal_plugins = {}

    def register(self, plugin_name, plugin_class):
        self._internal_plugins.update({
            plugin_name: plugin_class
        })
        return self

    @property
    def internal_plugins(self):
        return self._internal_plugins


plugin_registry = PluginRegistry()
plugin_registry.register(IgvViewer.plugin_name, IgvViewer)
plugin_registry.register(CircosScatterViewer.plugin_name, CircosScatterViewer)
plugin_registry.register(TestBokehPlugin.plugin_name, TestBokehPlugin)
plugin_registry.register(TestPlotlyPlugin.plugin_name, TestPlotlyPlugin)

internal_plugins = plugin_registry.internal_plugins
