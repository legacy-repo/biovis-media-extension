# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import re
import logging
from mk_media_extension import config
from markdown.preprocessors import Preprocessor
from markdown.extensions import Extension
from mk_media_extension.plugin import get_plugins, get_internal_plugins
from mk_media_extension.convertor import get_convertors
from mk_media_extension.utils import BashColors
from mk_media_extension.exceptions import PluginSyntaxError, ValidationError
from mk_media_extension.plugin import BasePlugin
from mk_media_extension.convertor import BaseConvertor


class Code:
    """
    Parse plugin call code and execute it.
    """
    def __init__(self, code, net_dir):
        """
        Initialize code instance.

        :param: code: code string, such as @plugin_name(arg1=value, arg2=value, arg3=value)
        :param: net_dir: a directory which is used as html directory. plugin and convertor maybe generate some files that are needed by html, so all these files should be copied to net directory.
        """
        self.logger = logging.getLogger(__name__)
        self._code = code
        self.installed_plugins = get_plugins()
        self.internal_plugins = get_internal_plugins()
        self.installed_convertors = get_convertors()
        self.net_dir = net_dir

    def load_convertor(self, name, context):
        if name not in self.installed_convertors:
            raise ValidationError('The "{0}" convertor is not installed'.format(name))

        Convertor = self.installed_convertors[name].load()

        if not issubclass(Convertor, BaseConvertor):
            raise ValidationError('{0}.{1} must be a subclass of {2}.{3}'.format(
                                  Convertor.__module__, Convertor.__name__, BaseConvertor.__module__,
                                  BaseConvertor.__name__))

        convertor = Convertor(context, self.net_dir)
        return convertor

    def load_plugin(self, name, context):
        InternalPlugin = self.internal_plugins.get(name)
        if InternalPlugin:
            plugin = InternalPlugin(context, self.net_dir)
        else:
            if name not in self.installed_plugins:
                raise ValidationError('The "{0}" plugin is not installed'.format(name))

            Plugin = self.installed_plugins[name].load()

            if not issubclass(Plugin, BasePlugin):
                raise ValidationError('{0}.{1} must be a subclass of {2}.{3}'.format(
                                      Plugin.__module__, Plugin.__name__, BasePlugin.__module__,
                                      BasePlugin.__name__))

            plugin = Plugin(context, self.net_dir, target_fsize=config.target_fsize)
        return plugin

    def _parse(self):
        """
        Parse plugin call for identify plugin name and keyword arguments.
        """
        from mk_media_extension.syntax_parser import plugin_kwarg
        from pyparsing import ParseException

        # Split func with args
        pattern = r'^@(?P<plugin_name>[-\w]+)(?P<args_str>.*)$'
        matched = re.match(pattern, self._code)
        if matched:
            plugin_name = matched.group('plugin_name')
            args_str = matched.group('args_str')
            color_msg = BashColors.get_color_msg('SUCCESS',
                                                 '\nParsed choppy plugin command: %s and %s' %
                                                 (plugin_name, args_str))
            self.logger.info(color_msg)

            try:
                # Bug: maybe error when the argument value is a string as file name.
                # filter_ctx_files function's pattern '^(/)?([^/\0]+(/)?)+$' may treat a string as a file but it's not true.
                items = plugin_kwarg.parseString(args_str).asList()
                plugin_kwargs = {i[0]: i[1] for i in items if len(i) == 2}
            except ParseException as err:
                color_msg = BashColors.get_color_msg('DANGER',
                                                     'Choppy plugin command[plugin_name: %s, args: %s]: syntax error - %s' % (plugin_name, args_str, str(err)))
                self.logger.error(color_msg)
                raise PluginSyntaxError('Can not parse choppy plugin command.')
            self.logger.info('Plugin name: %s, Plugin kwargs: %s' % (plugin_name, str(plugin_kwargs)))
            return plugin_name, plugin_kwargs
        else:
            color_msg = BashColors.get_color_msg('WARNING', 'Can not parse choppy plugin command.')
            self.logger.error(color_msg)
            raise PluginSyntaxError('Can not parse choppy plugin command.')

    def _recursive_call(self, filepath, convertor_key_lst):
        """
        Call convertor in the chain.
        """
        if len(convertor_key_lst) == 1:
            convertor = self.load_convertor(convertor_key_lst[0])
            return convertor.run(filepath)
        else:
            convertor = self.load_convertor(convertor_key_lst[0])
            return self._recursive_call(convertor.run(filepath), convertor_key_lst[1:])

    def _convert_context(self, plugin_kwargs):
        """
        Parse convertor from choppy plugin kwargs, and then call convertor in the chain. (Get real path of all files.)
        """
        context = {}
        for key, value in plugin_kwargs.items():
            if isinstance(value, str):
                convertor_str_lst = [i.strip() for i in value.split('|')]
                if len(convertor_str_lst) == 1:
                    filepath = convertor_str_lst[0]
                else:
                    filepath = convertor_str_lst[0]
                    convertor_key_lst = convertor_str_lst[1:]
                    filepath = self._recursive_call(filepath, convertor_key_lst)
                context.update({
                    key: filepath
                })
            else:
                context.update({
                    key: value
                })
        self.logger.debug('Context: %s' % context)
        return context

    def _extract_context(self, plugin_kwargs):
        context = {}
        for key, value in plugin_kwargs.items():
            convertor_str_lst = [i.strip() for i in value.split('|')]
            # For "filepath | convertor"
            context.update({
                key: convertor_str_lst[0]
            })
        return context

    def generate(self):
        # Get all plugin kwargs and plugin name.
        plugin_name, plugin_kwargs = self._parse()
        # Run convertor and get new plugin kwargs as context.
        context = self._convert_context(plugin_kwargs)
        # e.g. ["<script id='plot' src=''>", "</script>"]
        try:
            plugin = self.load_plugin(plugin_name, context)
            code_lst = plugin.run()
        except Exception as err:
            import traceback
            kwargs_str = ', '.join('%s=%r' % x for x in plugin_kwargs.items())
            code = """\
<div class='alert {class_name}' role='alert'>
<pre><code>
Error: for more information, please check logs as follows.

{err}

Plugin:
{plugin_name}

Arguments:
{plugin_kwargs}

Context:
{context}
</code></pre>
</div>""".format(class_name='alert-danger', err=str(err),
                 plugin_name=plugin_name, plugin_kwargs=kwargs_str,
                 context=str(context))
            code_lst = [code, ]
            self.logger.debug("Generate code for %s error: %s" % (plugin_name, str(err)))
            self.logger.debug(traceback.format_exc())
            self.logger.warning("Generate code for %s error: %s" % (plugin_name, str(err)))
        return code_lst


class ChoppyPluginPreprocessor(Preprocessor):
    """
    Dynamic Plot / Multimedia Preprocessor for Python-Markdown.
    """
    def __init__(self, md, config):
        super(ChoppyPluginPreprocessor, self).__init__(md)
        self.logger = logging.getLogger(__name__)

        self.net_dir = config.get('net_dir', None)

        if self.net_dir is None:
            color_msg = BashColors.get_color_msg('WARNING', "mk_media_extension's kwarg net_dir is not set, so it will be instead by qiniu url.")
            self.logger.warning(color_msg)

    def run(self, lines):
        new_lines = []
        block = []
        flag = False
        start_pattern = r'^@[-\w]+\(.*'
        end_pattern = r'.*\)$'
        for line in lines:
            striped_line = line.strip()
            start_matched = re.match(start_pattern, striped_line)
            end_matched = re.match(end_pattern, striped_line)
            # Single line
            if start_matched and end_matched:
                block.append(striped_line)
                code_str = re.sub(r'\s', '', ''.join(block))

                # Parse plugin call code, and then call plugin.
                code_instance = Code(code_str, self.net_dir)
                js_code_lines = code_instance.generate()
                new_lines.extend(js_code_lines)
                block = []
            # Multiple lines start point
            elif start_matched:
                flag = True
                block.append(striped_line)
            # Multiple lines
            elif flag:
                if end_matched:
                    block.append(striped_line)
                    code_str = re.sub(r'\s', '', ''.join(block))

                    # Parse plugin call code, and then call plugin.
                    code_instance = Code(code_str, self.net_dir)
                    js_code_lines = code_instance.generate()
                    new_lines.extend(js_code_lines)
                    block = []
                    flag = False
                else:
                    block.append(line)
            # Not matched
            else:
                new_lines.append(line)

        return new_lines


class ChoppyPluginExtension(Extension):
    def __init__(self, **kwargs):
        self.config = {
            'net_dir': [None, 'a directory which is used as html directory.'],
        }

        self.config.update({
            'net_dir': [kwargs.get('net_dir'), 'a directory which is used as html directory.'],
        })

    def extendMarkdown(self, md, md_globals):
        md.registerExtension(self)

        plugin_preprocessor = ChoppyPluginPreprocessor(md, self.getConfigs())
        md.preprocessors.add('plugin_preprocessor', plugin_preprocessor,
                             '<normalize_whitespace')


# http://pythonhosted.org/Markdown/extensions/api.html#makeextension
def makeExtension(*args, **kwargs):
    return ChoppyPluginExtension(*args, **kwargs)
