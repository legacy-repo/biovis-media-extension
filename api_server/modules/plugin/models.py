# -*- coding: utf-8 -*-
"""
    api_server.modules.plugin.models
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Plugin database models.

    :copyright: © 2019 by the Choppy team.
    :license: AGPL, see LICENSE.md for more details.
"""

from api_server.extensions import db


class Plugin(db.Model):  # noqa
    """
    Plugin database model.
    """
    __tablename__ = 'plugin'
    id = db.Column(db.Integer, autoincrement=True, primary_key=True)
    name = db.Column(db.String(length=250), nullable=False)
    command = db.Column(db.String(length=255), nullable=False)
    command_md5 = db.Column(db.String(length=64), nullable=False, unique=True, index=True)
    is_server = db.Column(db.Boolean, nullable=False)
    container_id = db.Column(db.String(length=64), nullable=True)
    process_id = db.Column(db.String(length=8), nullable=True)
    access_url = db.Column(db.String(length=255), nullable=False)
    proxy_url = db.Column(db.String(length=255), nullable=True)
    workdir = db.Column(db.String(length=255), nullable=True)
    active = db.Column(db.Boolean, default=False)
    message = db.Column(db.ARRAY(db.TEXT))
