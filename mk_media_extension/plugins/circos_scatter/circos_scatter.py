# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from mk_media_extension.plugin import BasePlugin
from mk_media_extension.utils import get_candidate_name


class CircosScatterViewer(BasePlugin):
    """
    Circos is a javascript library to easily build interactive graphs in a circular layout. It's based on d3.js. It aims to be a javascript version of the Circos software. Plugin name: circos-scatter-viewer.

    :Example:
    @circos-scatter-viewer(grch37Json, cytobandsCsv, snpDensity250KbTxt, snpDensityTxt, snpDensity1MbTxt)
    Arguments:
    1. dataUrl:
    2. genome:
    3. locus:
    """
    plugin_name = 'circos-scatter-viewer'
    plugin_dir = os.path.dirname(os.path.abspath(__file__))
    is_server = False

    def external_css(self):
        circos_viewer_css = os.path.join(os.path.dirname(__file__), 'circos-scatter-viewer.css')
        return [{'circos_css': circos_viewer_css}]

    def check_plugin_args(self, **kwargs):
        pass

    def render(self, **kwargs):
        """
        Rendering and auto-generating js code.

        :param kwargs: plugin's keyword arguments.
        :return: rendered js code.
        """
        temp_div_id = 'circos-scatter-viewer-' + get_candidate_name()
        d3_v4_js = os.path.join(os.path.dirname(__file__), 'd3.v4.min.js')
        circos_js = os.path.join(os.path.dirname(__file__), 'circos-min.js')
        circos_viewer_js = os.path.join(os.path.dirname(__file__), 'circos-scatter-viewer.js')
        js_lst = [
            {
                'd3': d3_v4_js
            }, {
                'circos_js': circos_js
            }, {
                'circos_scatter_viewer_js': circos_viewer_js
            }
        ]
        # The arguments of function 'CircosScatterViewer' are position paraments, all paraments are defined in circos-scatter-viewer.js.
        # CircosScatterViewer(divId, configs, grch37Json, cytobandsCsv, snpDensity250KbTxt, snpDensityTxt, snpDensity1MbTxt)
        codes = self.autogen_js(js_lst, 'CircosScatterViewer', self.get_net_path('grch37Json'),
                                self.get_net_path('cytobandsCsv'), self.get_net_path('snpDensity250KbTxt'),
                                self.get_net_path('snpDensityTxt'), self.get_net_path('snpDensity1MbTxt'),
                                div_id=temp_div_id)
        return codes
