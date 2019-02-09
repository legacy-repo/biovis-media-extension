# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
import sys

from mk_media_extension.plugin import BasePlugin


class TestPlugin(BasePlugin):
    """
    Test mk_media_extension plugin.

    :Example:
    @test-plugin(oss='', )
    """
    plugin_name = 'test-plugin'

    def __init__(self, context, net_dir=None):
        super(TestPlugin, self).__init__(context, net_dir='/Users/FK/Downloads/test1234')

    def check_plugin_args(self, **kwargs):
        js_script = kwargs.get('js_script')
        if not js_script:
            raise Exception('%s must have a js_script argument' % self.plugin_name)

    def render(self, **kwargs):
        js_script = kwargs.get('js_script')
        return [
            "<script id='plot' src='%s'>" % self.get_net_path(os.path.basename(js_script)), 
            "</script>"
        ]
