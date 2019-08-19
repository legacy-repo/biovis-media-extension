# -*- coding: utf-8 -*-
"""
    api_server.modules.pm2
    ~~~~~~~~~~~~~~~~~~~~~~

    PM2 Module.

    :copyright: © 2019 by the Choppy team.
    :license: AGPL, see LICENSE.md for more details.
"""

from api_server.extensions.api import api_v1
from flask_restplus import Namespace


def init_app(app, **kwargs):
    """Init workflow module.
    """

    # Touch underlying modules
    from . import resources

    api_v1.add_namespace(resources.api)


api = Namespace('pm2', description='Production process manager(pm2) related operations')
