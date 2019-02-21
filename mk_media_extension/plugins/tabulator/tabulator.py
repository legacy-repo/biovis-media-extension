# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from mk_media_extension.plugin import BasePlugin
from mk_media_extension.utils import get_candidate_name


class Tabulator(BasePlugin):
    """
    Tabulator allows you to create interactive tables in seconds from any HTML Table, JavaScript Array, AJAX data source or JSON formatted data. Plugin name: tabulator.

    :Example:
    @tabulator(dataUrl='', )
    Arguments:
    1. dataUrl
    """
    plugin_name = 'tabulator'

    def external_css(self):
        tabulator_css = os.path.join(os.path.dirname(__file__), 'tabulator.min.css')
        tabulator_theme_css = os.path.join(os.path.dirname(__file__), 'tabulator_bootstrap4.min.css')
        tabulator_custom_css = os.path.join(os.path.dirname(__file__), 'tabulator-custom.css')
        return [
            {'tabulator_css': tabulator_css},
            {'tabulator_theme_css': tabulator_theme_css},
            {'tabulator_custom_css': tabulator_custom_css}
        ]

    def check_plugin_args(self, **kwargs):
        pass

    def render(self, **kwargs):
        """
        Rendering and auto-generating js code.

        :param kwargs: plugin's keyword arguments.
        :return: rendered js code.
        """
        temp_div_id = 'tabulator-' + get_candidate_name()
        csv_js = os.path.join(os.path.dirname(__file__), 'papaparse.min.js')
        tabulator_js = os.path.join(os.path.dirname(__file__), 'tabulator.min.js')
        tabulator_wrapper_js = os.path.join(os.path.dirname(__file__), 'tabulator-wrapper.js')
        js_lst = [
            {
                'csv_js': csv_js
            }, {
                'tabulator_js': tabulator_js
            }, {
                'tabulator_wrapper_js': tabulator_wrapper_js
            }
        ]

        style = 'border-radius: 50px; cursor: pointer;'
        html_components = '<div style="position: relative; float: right; margin-bottom: 5px;">\
                           <button class ="table-button" id ="download-csv"\
                           style="%s">Download CSV</button></div>' % style
        # The arguments of function 'Tabulator' are position paraments, all paraments are defined in tabulator-wrapper.js.
        # Tabulator(div_id, configs, dataUrl)
        codes = self.autogen_js(js_lst, 'TabulatorViewer', self.get_net_path('dataUrl'), kwargs.get('columnsType'),
                                div_id=temp_div_id, html_components=html_components)
        return codes
