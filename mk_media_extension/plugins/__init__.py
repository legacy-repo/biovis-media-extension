# -*- coding:utf-8 -*-
from __future__ import unicode_literals
from .test_bokeh_plugin.test import TestBokehPlugin
from .test_plotly_plugin.test import TestPlotlyPlugin
from .igv_viewer.igv_viewer import IgvViewer
from .circos_scatter.circos_scatter import CircosScatterViewer

from .boxplot_py.boxplot import BoxplotPyPlugin
from .boxplot_r.boxplot import BoxplotRPlugin
from .bubble_plot.bubble_plot import BubblePlotPlugin
from .datatable_js.datatable import DataTableJSPlugin
from .density_plot.density_plot import DensityPlotPlugin
from .group_boxplot.group_boxplot import GroupBoxPlotPlugin
from .heatmap_d3.heatmap import HeatmapD3Plugin
from .heatmap_r.heatmap import HeatmapRPlugin
from .multiqc.multiqc import MultiqcPlugin
from .muts_needle_r.muts_needle import MutsNeedleRPlugin
from .pca.pca import PCAPlugin
from .pivot_table_js.pivot_table import PivotTableJSPlugin
from .rocket_plot_r.rocket_plot import RocketPlotRPlugin
from .scatter_plot.scatter_plot import ScatterPlotPlugin
from .stack_barplot_r.stack_barplot import StackBarPlotPlugin
from .tabulator.tabulator import Tabulator
from .upset_r.upset import UpsetRPlugin
from .violin_plot_r.violin_plot import ViolinPlotRPlugin


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
# For test
plugin_registry.register(TestBokehPlugin)
plugin_registry.register(TestPlotlyPlugin)
plugin_registry.register(IgvViewer)
plugin_registry.register(CircosScatterViewer)

# For production
plugin_registry.register(BoxplotPyPlugin)
plugin_registry.register(BoxplotRPlugin)
plugin_registry.register(BubblePlotPlugin)
plugin_registry.register(DataTableJSPlugin)
plugin_registry.register(DensityPlotPlugin)
plugin_registry.register(GroupBoxPlotPlugin)
plugin_registry.register(HeatmapD3Plugin)
plugin_registry.register(HeatmapRPlugin)
plugin_registry.register(MultiqcPlugin)
plugin_registry.register(MutsNeedleRPlugin)
plugin_registry.register(PCAPlugin)
plugin_registry.register(PivotTableJSPlugin)
plugin_registry.register(RocketPlotRPlugin)
plugin_registry.register(ScatterPlotPlugin)
plugin_registry.register(StackBarPlotPlugin)
plugin_registry.register(Tabulator)
plugin_registry.register(UpsetRPlugin)
plugin_registry.register(ViolinPlotRPlugin)

internal_plugins = plugin_registry.internal_plugins
