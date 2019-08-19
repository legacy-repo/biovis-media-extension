# -*- coding: utf-8 -*-
"""
    api_server.modules.pm2.resources
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    RESTful API Plugin resources.

    :copyright: © 2019 by the Choppy team.
    :license: AGPL, see LICENSE.md for more details.
"""

import logging
from flask_restplus import Resource
from . import api


logger = logging.getLogger(__file__)


@api.route('/')
class Process(Resource):
    def get(self):
        """Get a set of processes, filterd by something.
        """
        pass
