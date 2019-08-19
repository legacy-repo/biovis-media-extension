# -*- coding: utf-8 -*-
"""
    api_server.modules.plugin.parameters
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Input arguments (Parameters) for Workflow resources RESTful API.

    :copyright: © 2019 by the Choppy team.
    :license: AGPL, see LICENSE.md for more details.
"""

from flask_restplus import reqparse, inputs, fields
from . import api


# Plugin
plugin_get_args = reqparse.RequestParser()
plugin_get_args.add_argument('show_instance', type=inputs.boolean, default=False,
                             help='Show plugin instances.')


plugin_post_args = reqparse.RequestParser()
plugin_post_args.add_argument('plugin_name', type=str, required=True, help='Plugin name.')
plugin_post_args.add_argument('plugin_args', type=dict, required=True, help='Plugin keyword arguments.')


# Plugin body models
plugin_post_fields = api.model('Resource', {
    'plugin_name': fields.String,
    'plugin_args': fields.Raw
})
