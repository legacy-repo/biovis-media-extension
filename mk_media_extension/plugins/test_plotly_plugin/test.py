# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from mk_media_extension.plugin import BasePlugin


class TestPlotlyPlugin(BasePlugin):
    """
    Test mk_media_extension plugin.

    :Example:
    @test-plotly-plugin()
    """
    plugin_name = 'test-plotly-plugin'

    def external_css(self):
        test_css = os.path.join(os.path.dirname(__file__), 'test.css')
        return [{'test_plotly_css': test_css}]

    def check_plugin_args(self, **kwargs):
        pass

    def plotly(self):
        import plotly.graph_objs as go

        data = [go.Scatter(x=[1, 2, 3, 4], y=[4, 3, 2, 1])]
        layout = go.Layout(title="hello world")
        plot = go.Figure(data=data, layout=layout)
        return plot
