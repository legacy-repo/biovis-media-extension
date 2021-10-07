# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from biovis_media_extension.plugin import BasePlugin
from biovis_media_extension.utils import get_candidate_name


class PivotTableJSPlugin(BasePlugin):
    """
    PivotTableJSPlugin allows you to create pivot table viewer which is a web reporting tool for data analysis and visualization. Plugin name: pivot-table-js.

    :Example:
    @pivot-table-js(dataUrl='', )
    Arguments:
    1. dataUrl
    """
    plugin_name = 'pivot-table-js'
    plugin_dir = os.path.dirname(os.path.abspath(__file__))
    is_server = False
    lib_dir = os.path.join(os.path.dirname(__file__), 'lib')

    def __init__(self, *args, **kwargs):
        super(PivotTableJSPlugin, self).__init__(*args, **kwargs)

    def external_css(self):
        pivottable_theme = os.path.join(self.lib_dir, 'theme')
        pivottable_css = os.path.join(self.lib_dir, 'webdatarocks.min.css')
        pivottable_custom_css = os.path.join(self.lib_dir, 'pivottable-custom.css')
        return [
            {'pivottable_theme': pivottable_theme},
            {'pivottable_css': pivottable_css},
            {'pivottable_custom_css': pivottable_custom_css}
        ]

    def check_plugin_args(self, **kwargs):
        pass

    def render(self, **kwargs):
        """
        Rendering and auto-generating js code.

        :param kwargs: plugin's keyword arguments.
        :return: rendered js code.
        """
        temp_div_id = 'pivottable-' + get_candidate_name()
        pivottable_storage = os.path.join(self.lib_dir, 'brownies.js')
        pivottable_js = os.path.join(self.lib_dir, 'webdatarocks.js')
        pivottable_wrapper_js = os.path.join(self.lib_dir, 'pivottable-wrapper.js')
        pivottable_toolbar_js = os.path.join(self.lib_dir, 'webdatarocks.toolbar.js')
        highcharts = os.path.join(self.lib_dir, 'highcharts.js')
        highcharts_more = os.path.join(self.lib_dir, 'highcharts-more.js')
        pivottable_highcharts = os.path.join(self.lib_dir, 'webdatarocks.highcharts.js')
        js_lst = [
            {
                'pivottable_storage': pivottable_storage
            }, {
                'pivottable_js': pivottable_js
            }, {
                'pivottable_wrapper_js': pivottable_wrapper_js
            }, {
                'pivottable_toolbar_js': pivottable_toolbar_js
            }, {
                'highcharts': highcharts
            }, {
                'highcharts_more': highcharts_more
            }, {
                'pivottable_highcharts': pivottable_highcharts
            }
        ]

        # The arguments of function 'PivotTableViewer' are position paraments, all paraments are defined in pivottable-wrapper.js.
        # PivotTableViewer(div_id, configs)
        table_id = 'pivot-chart-' + get_candidate_name()
        html_components = '<div id="%s"></div>' % table_id
        configs = {
            "dataUrl": self.get_net_path('dataUrl'),
            "enableLocal": kwargs.get('enableLocal'),
            "chartId": table_id
        }
        codes = self.autogen_js(js_lst, 'PivotTableViewer', configs=configs,
                                div_id=temp_div_id, html_components=html_components,
                                position='next')

        return codes
