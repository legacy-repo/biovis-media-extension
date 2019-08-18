#!/usr/bin/env python
# PYTHON_ARGCOMPLETE_OK
"""
    api_server.server
    ~~~~~~~~~~~~~~~~~

    Launch a api server for mk_media_extension.

    :copyright: © 2019 by the Choppy team.
    :license: AGPL, see LICENSE.md for more details.
"""

import sys
import click
import logging
import verboselogs

logging.setLoggerClass(verboselogs.VerboseLogger)
logger = logging.getLogger(__name__)


@click.command()
@click.option('-d', '--debug', default=False, help='Debug mode.')
@click.option('-H', '--host', default="localhost", help='Domain or IP Address')
@click.option('-p', '--port', default=8080, help='Port Number')
@click.option('-f', '--framework', default='flask', type=click.Choice(['bjoern', 'gevent', 'flask']),
              help='Run server with framework.')
@click.option('-s', '--swagger', default=True, help='Enable swagger documentation.')
def run_server(debug, host, port, framework, swagger):
    """Launch an api server."""
    from api_server import create_app
    flask_app = create_app(flask_config_name='production')

    if swagger:
        from api_server.helper import register_helper
        register_helper(flask_app)

    #
    # TODO: this starts the built-in server, which isn't the most
    # efficient.  We should use something better.
    #
    if framework == "gevent":
        from gevent.pywsgi import WSGIServer
        logger.success("Starting gevent based server")
        logger.success('Running Server: %s:%s' % (host, port))
        svc = WSGIServer((host, port), flask_app)
        svc.serve_forever()
    elif framework == "bjoern":
        import bjoern
        logger.success("Starting bjoern based server")
        logger.success('Running Server: %s:%s' % (host, port))
        bjoern.run(flask_app, host, port, reuse_port=True)
    else:
        flask_app.run(debug=True)


if __name__ == "__main__":
    sys.exit(run_server())
