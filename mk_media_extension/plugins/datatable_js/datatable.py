# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from mk_media_extension.plugin import BasePlugin
from mk_media_extension.utils import get_candidate_name


class DataTableJSPlugin(BasePlugin):
    """
    DataTableJS allows you to create interactive tables in seconds from any HTML Table, JavaScript Array, AJAX data source or JSON formatted data. Plugin name: data-table-js.

    :Example:
    @data-table-js(dataUrl='', )
    Arguments:
    1. dataUrl
    """
    plugin_name = 'data-table-js'
    plugin_dir = os.path.dirname(os.path.abspath(__file__))
    is_server = False
    lib_dir = os.path.join(os.path.dirname(__file__), 'lib')

    def __init__(self, *args, **kwargs):
        super(DataTableJSPlugin, self).__init__(*args, **kwargs)

    def external_css(self):
        datatable_css = os.path.join(self.lib_dir, 'datatables.min.css')
        datatable_custom_css = os.path.join(self.lib_dir, 'datatable-custom.css')
        return [
            {'datatable_css': datatable_css},
            {'datatable_custom_css': datatable_custom_css}
        ]

    def check_plugin_args(self, **kwargs):
        pass

    def render(self, **kwargs):
        """
        Rendering and auto-generating js code.

        :param kwargs: plugin's keyword arguments.
        :return: rendered js code.
        """
        temp_div_id = 'datatable-' + get_candidate_name()
        csv_js = os.path.join(self.lib_dir, 'papaparse.min.js')
        datatable_js = os.path.join(self.lib_dir, 'datatables.min.js')
        datatable_wrapper_js = os.path.join(self.lib_dir, 'datatable-wrapper.js')
        js_lst = [
            {
                'csv_js': csv_js
            }, {
                'datatable_js': datatable_js
            }, {
                'datatable_wrapper_js': datatable_wrapper_js
            }
        ]

        # The arguments of function 'DataTableViewer' are position paraments, all paraments are defined in datatable-wrapper.js.
        # DataTableViewer(div_id, configs)
        table_id = 'datatable-' + get_candidate_name()
        configs = {
            "tableId": table_id,
            "dataUrl": self.get_net_path('dataUrl'),
            "columnsType": kwargs.get('columnsType'),
            "enableItemSearch": kwargs.get('enableItemSearch')
        }
        codes = self.autogen_js(js_lst, 'DataTableViewer', configs=configs,
                                div_id=temp_div_id)

        return codes
