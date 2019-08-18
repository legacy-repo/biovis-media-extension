# -*- coding: utf-8 -*-
"""
    api_server.modules.plugin.parameters
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Input arguments (Parameters) for Workflow resources RESTful API.

    :copyright: © 2019 by the Choppy team.
    :license: AGPL, see LICENSE.md for more details.
"""

from flask_restplus import reqparse
from flask_restplus import inputs


# Plugin
plugin_args = reqparse.RequestParser()
plugin_args.add_argument('command', required=True, help='Plugin command.')


plugin_get_args = reqparse.RequestParser()
plugin_get_args.add_argument('active', type=inputs.boolean, default=False,
                             help='Show plugin instances.')
