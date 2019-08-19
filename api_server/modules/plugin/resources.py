# -*- coding: utf-8 -*-
"""
    api_server.modules.plugin.resources
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    RESTful API Plugin resources.

    :copyright: © 2019 by the Choppy team.
    :license: AGPL, see LICENSE.md for more details.
"""

import logging
from flask_restplus import Resource
from flask import current_app
from .parameters import plugin_get_args, plugin_post_args
from .parameters import plugin_post_fields
from mk_media_extension.plugin import get_plugins, get_internal_plugins
from mk_media_extension.plugin_instance import PluginInstance
from . import api


logger = logging.getLogger(__file__)


@api.route('/')
class Plugin(Resource):
    @api.doc(responses={
        200: "Success.",
        400: "Bad request.",
    })
    @api.doc(params={'show_instance': 'Plugin instances'})
    @api.expect(plugin_get_args, validate=True)
    def get(self):
        """Get a set of plugins, filterd by something.
        """
        args = plugin_get_args.parse_args()
        show_instance = args.show_instance
        if not show_instance:
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

    @api.doc(responses={
        201: "Success.",
        400: "Bad request.",
    })
    @api.doc(body=plugin_post_fields)
    @api.expect(plugin_post_args, validate=True)
    def post(self):
        """Launch a plugin.
        """
        args = plugin_post_args.parse_args()
        plugin_name = args.plugin_name
        plugin_args = args.plugin_args
        plugin = PluginInstance(plugin_name, plugin_args, current_app.config)
        resp = plugin.generate()
        logger.info("Launch %s plugin: %s" % (plugin_name, resp))
        return resp, 201

    def put(self):
        """Pause/Restart a set of plugins
        """
        pass

    def delete(self):
        """Stop a set of plugins.
        """
        pass
