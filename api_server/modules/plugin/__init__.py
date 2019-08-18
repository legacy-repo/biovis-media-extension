# -*- coding: utf-8 -*-
"""
    api_server.modules.plugin
    ~~~~~~~~~~~~~~~~~~~~~~~~~

    Plugin Module.

    :copyright: © 2019 by the Choppy team.
    :license: AGPL, see LICENSE.md for more details.
"""

from api_server.extensions.api import api_v1


def init_app(app, **kwargs):
    """Init workflow module.
    """

    # Touch underlying modules
    from . import resources

    api_v1.add_namespace(resources.api)
