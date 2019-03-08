# -*- coding:utf-8 -*-
from __future__ import unicode_literals
from .test_bokeh_plugin.test import TestBokehPlugin
from .test_plotly_plugin.test import TestPlotlyPlugin
from .igv_viewer.igv_viewer import IgvViewer
from .circos_scatter.circos_scatter import CircosScatterViewer
from .tabulator.tabulator import Tabulator
from .multiqc.multiqc import MultiqcPlugin
from .boxplot_py.boxplot import BoxplotPyPlugin
from .boxplot_r.boxplot import BoxplotRPlugin
from .pca.pca import PCAPlugin
from .scatter_plot.scatter_plot import ScatterPlotPlugin
from .bubble_plot.bubble_plot import BubblePlotPlugin
from .heatmap_d3.heatmap import HeatmapD3Plugin
from .heatmap_ggplot.heatmap import HeatmapGgplotPlugin
from .group_boxplot.group_boxplot import GroupBoxPlotPlugin
from .density_plot.density_plot import DensityPlotPlugin
from .rocket_plot_ggplot_r.rocket_plot import RocketPlotPlugin


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
plugin_registry.register(BoxplotPyPlugin)
plugin_registry.register(BoxplotRPlugin)
plugin_registry.register(PCAPlugin)
plugin_registry.register(ScatterPlotPlugin)
plugin_registry.register(BubblePlotPlugin)
plugin_registry.register(HeatmapD3Plugin)
plugin_registry.register(HeatmapGgplotPlugin)
plugin_registry.register(GroupBoxPlotPlugin)
plugin_registry.register(DensityPlotPlugin)
plugin_registry.register(RocketPlotPlugin)

internal_plugins = plugin_registry.internal_plugins
