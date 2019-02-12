# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from mk_media_extension.plugin import BasePlugin
from mk_media_extension.utils import get_candidate_name


class IgvViewer(BasePlugin):
    """
    Embeddable genomic visualization component based on the Integrative Genomics Viewer. Plugin name: igv-viewer.

    :Example:
    @igv-viewer(data_url='https://data.broadinstitute.org/igvdata/test/igv-web/segmented_data_080520.seg.gz')
    Arguments:
    1. dataUrl:
    2. genome:
    3. locus:
    """
    plugin_name = 'igv-viewer'

    def external_css(self):
        igv_viewer_css = os.path.join(os.path.dirname(__file__), 'igv-viewer.css')
        return [{'igv_css': igv_viewer_css}]

    def check_plugin_args(self, **kwargs):
        pass

    def render(self, **kwargs):
        """
        Rendering and auto-generating js code.

        :param kwargs: plugin's keyword arguments.
        :return: rendered js code.
        """
        temp_div_id = 'igv-viewer-' + get_candidate_name()
        igv_js = os.path.join(os.path.dirname(__file__), 'igv.min.js')
        igv_viewer_js = os.path.join(os.path.dirname(__file__), 'igv-viewer.js')
        js_lst = [
            {
                'igv_js': igv_js
            },
            {
                'igv_viewer_js': igv_viewer_js
            }
        ]
        # The arguments of function 'IgvViewer' are position paraments, all paraments are defined in igv-viewer.js.
        # IgvViewer(div_id, dataUrl, genome, locus)
        codes = self.autogen_js(js_lst, 'IgvViewer', kwargs.get('data_url'), kwargs.get('genome'),
                                kwargs.get('locus'), div_id=temp_div_id)
        return codes
