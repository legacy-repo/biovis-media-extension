# -*- coding:utf-8 -*-
from __future__ import unicode_literals
from .test_bokeh_plugin.test import TestBokehPlugin
from .test_plotly_plugin.test import TestPlotlyPlugin
from .igv_viewer.igv_viewer import IgvViewer
from .circos_scatter.circos_scatter import CircosScatterViewer
from .tabulator.tabulator import Tabulator
from .multiqc.multiqc import MultiqcPlugin
from .boxplot.boxplot import BoxplotPlugin
from .pca.pca import PCAPlugin
from .scatter_plot.scatter_plot import ScatterPlotPlugin
from .bubble_plot.bubble_plot import BubblePlotPlugin
from .heatmap.heatmap import HeatmapPlugin


class PluginRegistry:
    def __init__(self):
        self._internal_plugins = {}

    def register(self, plugin_class):
        self._internal_plugins.update({
            plugin_class.plugin_name: plugin_class
        })
        return self

    @property
    def internal_plugins(self):
        return self._internal_plugins


plugin_registry = PluginRegistry()
plugin_registry.register(TestBokehPlugin)
plugin_registry.register(TestPlotlyPlugin)
plugin_registry.register(IgvViewer)
plugin_registry.register(CircosScatterViewer)
plugin_registry.register(Tabulator)
plugin_registry.register(MultiqcPlugin)
plugin_registry.register(BoxplotPlugin)
plugin_registry.register(PCAPlugin)
plugin_registry.register(ScatterPlotPlugin)
plugin_registry.register(BubblePlotPlugin)
plugin_registry.register(HeatmapPlugin)

internal_plugins = plugin_registry.internal_plugins
