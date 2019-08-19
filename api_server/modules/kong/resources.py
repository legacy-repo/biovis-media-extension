# -*- coding: utf-8 -*-
"""
    api_server.modules.kong.resources
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    RESTful API Plugin resources.

    :copyright: © 2019 by the Choppy team.
    :license: AGPL, see LICENSE.md for more details.
"""

import logging
from flask_restplus import Resource
from . import api


logger = logging.getLogger(__file__)


@api.route('/services')
class KongService(Resource):
    def get(self):
        """Get a set of kong services, filtered by something.
        """
        pass


@api.route('/routes')
class KongRoute(Resource):
    def get(self):
        """Get a set of kong routes, filtered by something.
        """
        pass
