# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import logging
from mk_media_extension.plugin import get_plugins, get_internal_plugins
from mk_media_extension.exceptions import ValidationError
from mk_media_extension.plugin import BasePlugin


class PluginInstance:
    """
    Parse plugin call code and execute it.
    """

    def __init__(self, plugin_name, plugin_kwargs, config):
        """
        Initialize plugin instance.

        :param: plugin_name: plugin name.
        :param: plugin_kwargs: such as @plugin_name(arg1=value, arg2=value, arg3=value).
        :param: config: flask config object
        """
        self.logger = logging.getLogger(__name__)
        self.installed_plugins = get_plugins()
        self.internal_plugins = get_internal_plugins()

        self.plugin_name = plugin_name
        self.plugin_kwargs = plugin_kwargs
        self.net_dir = config.get("STATIC_ROOT")
        self.config = config

    def load_plugin(self, name, context):
        InternalPlugin = self.internal_plugins.get(name)
        if InternalPlugin:
            plugin = InternalPlugin(context, self.net_dir, self.config)
        else:
            if name not in self.installed_plugins:
                raise ValidationError('The "{0}" plugin is not installed'.format(name))

            Plugin = self.installed_plugins[name].load()

            if not issubclass(Plugin, BasePlugin):
                raise ValidationError('{0}.{1} must be a subclass of {2}.{3}'.format(
                                      Plugin.__module__, Plugin.__name__, BasePlugin.__module__,
                                      BasePlugin.__name__))

            plugin = Plugin(context, self.net_dir, self.config)
        return plugin

    def generate(self):
        # e.g. ["<script id='plot' src=''>", "</script>"]
        try:
            plugin = self.load_plugin(self.plugin_name, self.plugin_kwargs)
            code_lst = plugin.run()
            success = True
        except Exception as err:
            import traceback
            kwargs_str = ', '.join('%s=%r' % x for x in self.plugin_kwargs.items())
            code = """\
<div class='alert {class_name}' role='alert'>
<pre><code>
Error: for more information, please check logs as follows.

{err}

Plugin:
{plugin_name}

Arguments:
{plugin_kwargs}
</code></pre>
</div>""".format(class_name='alert-danger', err=str(err),
                 plugin_name=self.plugin_name, plugin_kwargs=kwargs_str)
            self.logger.debug("Generate code for %s error: %s" % (self.plugin_name, str(err)))
            self.logger.debug(traceback.format_exc())
            self.logger.warning("Generate code for %s error: %s" % (self.plugin_name, str(err)))
            code_lst = [code, ]
            success = False

        plugin.metadata.update({
            "message": code_lst
        })

        resp = {
            "message": code_lst,
            "success": success,
            "metadata": plugin.metadata
        }
        return resp
