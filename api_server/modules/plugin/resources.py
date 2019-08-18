# -*- coding: utf-8 -*-
"""
    mk_media_extension.api_server.modules.plugin.resources
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    RESTful API Plugin resources.

    :copyright: © 2019 by the Choppy team.
    :license: AGPL, see LICENSE.md for more details.
"""

from flask_restplus import Namespace, Resource
from .parameters import plugin_get_args
from mk_media_extension.plugin import get_plugins, get_internal_plugins

api = Namespace('plugins', description='Choppy report related operations')


@api.route('/')
class Plugin(Resource):
    @api.doc(responses={
        201: "Success.",
        400: "Bad request.",
    })
    @api.doc(params={'active': 'Plugin instances'})
    @api.expect(plugin_get_args, validate=True)
    def get(self):
        """Get a set of plugins, filterd by something.
        """
        args = plugin_get_args.parse_args()
        active = args.active
        if not active:
            installed_plugins = get_plugins()
            internal_plugins = get_internal_plugins()
            plugins = list(installed_plugins.keys()) + list(internal_plugins.keys())
            resp = {
                "message": "Success",
                "data": plugins
            }
            return resp, 200
        else:
            # TODO: Get plugin instances from database
            pass

    def post(self):
        """Launch a plugin.
        """
        pass

    def put(self):
        """Pause/Restart a set of plugins
        """
        pass

    def delete(self):
        """Stop a set of plugins.
        """
        pass
