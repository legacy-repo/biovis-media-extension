# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from mk_media_extension.plugin import BasePlugin


class BoxplotPyPlugin(BasePlugin):
    """
    Boxplot plugin.

    :Example:
    @boxplot(csvFile='')
    """
    plugin_name = 'boxplot-py'
    plugin_dir = os.path.dirname(os.path.abspath(__file__))
    is_server = False

    def external_css(self):
        boxplot_css = os.path.join(os.path.dirname(__file__), 'boxplot.css')
        return [{'boxplot_css': boxplot_css}]

    def check_plugin_args(self, **kwargs):
        pass

    def plotly(self):
        import plotly.graph_objs as go

        csvFile = self.context.get('csvFile')

        import pandas as pd
        rt = pd.read_csv(csvFile)
        A1 = go.Box(
            y=rt['A1'],
            name='A1'
        )
        A3 = go.Box(
            y=rt['A3'],
            name='A3'
        )
        A5 = go.Box(
            y=rt['A5'],
            name='A5'
        )
        A7 = go.Box(
            y=rt['A7'],
            name='A7'
        )
        B2 = go.Box(
            y=rt['B2'],
            name='B2'
        )
        B4 = go.Box(
            y=rt['B4'],
            name='B4'
        )
        B6 = go.Box(
            y=rt['B6'],
            name='B6'
        )
        B8 = go.Box(
            y=rt['B8'],
            name='B8'
        )
        B9 = go.Box(
            y=rt['B9'],
            name='B9'
        )
        data = [A1, A3, A5, A7, B2, B4, B6, B8, B9]

        layout = go.Layout(title="hello world")
        plot = go.Figure(data=data, layout=layout)
        return plot
