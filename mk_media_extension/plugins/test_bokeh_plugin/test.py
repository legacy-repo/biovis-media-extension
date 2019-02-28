# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from mk_media_extension.plugin import BasePlugin


class TestBokehPlugin(BasePlugin):
    """
    Test mk_media_extension plugin.

    :Example:
    @test-bokeh-plugin(oss='', )
    """
    plugin_name = 'test-bokeh-plugin'
    is_server = False

    def external_css(self):
        test_css = os.path.join(os.path.dirname(__file__), 'test.css')
        return [{'bokeh_plugin_css': test_css}]

    def check_plugin_args(self, **kwargs):
        number = kwargs.get('number')
        kwargs_str = ', '.join('%s=%r' % x for x in kwargs.items())
        self.logger.info('Running @%s(%s)' % (self.plugin_name, kwargs_str))
        if not number:
            raise Exception('%s must have a number argument' % self.plugin_name)

    def bokeh(self):
        import numpy as np
        from bokeh.plotting import figure

        number = self.context.get('number')
        # prepare some data
        N = number
        x = np.random.random(size=N) * 100
        y = np.random.random(size=N) * 100
        radii = np.random.random(size=N) * 1.5
        colors = [
            "#%02x%02x%02x" % (int(r), int(g), 150) for r, g in zip(50 + 2 * x, 30 + 2 * y)
        ]

        TOOLS = "crosshair,pan,wheel_zoom,box_zoom,reset,box_select,lasso_select"

        # create a new plot with the tools above, and explicit ranges
        plot = figure(tools=TOOLS, x_range=(0, 100), y_range=(0, 100))

        # add a circle renderer with vectorized colors and sizes
        plot.circle(x, y, radius=radii, fill_color=colors, fill_alpha=0.6, line_color=None)  # noqa
        return plot
