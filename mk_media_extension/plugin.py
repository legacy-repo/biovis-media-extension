# -*- coding:utf-8 -*-
from __future__ import unicode_literals
import os
import re
import uuid
import shutil
import requests
import logging
import pkg_resources
from mk_media_extension.utils import (check_dir, copy_and_overwrite,
                                      BashColors, get_candidate_name)
from mk_media_extension.file_mgmt import run_copy_files, get_oss_fsize


class BasePlugin:
    """
    Plugin class is initialized by plugin args from markdown.
    Plugin args: @plugin_name(arg1=value, arg2=value, arg3=value)
    """
    def __init__(self, context, net_dir=None, sync_oss=True, sync_http=True, sync_ftp=True, target_fsize=10):
        """
        Initialize BasePlugin class.

        :param: context: a dict that contains all plugin arguments.
        :param: net_dir: plugin used it to get relative network path for all files that are needed by html. if net_dir is None, plugin will upload all files to qiniu and get a qiniu url.
        :param: sync_oss: whether sync oss.
        :param: sync_http: whether sync http.
        :param: sync_ftp: whether sync ftp.
        :param: file_size: file size(MB).
        """
        if net_dir:
            temp_dir = os.path.join(net_dir, '.choppy-media-extension')
        else:
            temp_dir = os.path.join('/tmp', 'choppy-media-extension')
            # Clean up the temp directory
            # TODO: rmtree will cause other choppy process failed, how to solve it?
            shutil.rmtree(temp_dir, ignore_errors=True)
        self.logger = logging.getLogger(__name__)
        self.net_dir = net_dir
        self.sync_oss = sync_oss
        self.sync_http = sync_http
        self.sync_ftp = sync_ftp
        self.target_fsize = target_fsize
        self.tmp_plugin_dir = os.path.join(temp_dir, str(uuid.uuid1()))
        self.plugin_data_dir = os.path.join(self.tmp_plugin_dir, 'plugin')

        self.ftype2dir = {
            'css': os.path.join(self.plugin_data_dir, 'css'),
            'javascript': os.path.join(self.plugin_data_dir, 'js'),
            'js': os.path.join(self.plugin_data_dir, 'js'),
            'data': os.path.join(self.plugin_data_dir, 'data'),
            'context': os.path.join(self.plugin_data_dir, 'context'),
            'html': os.path.join(self.plugin_data_dir, 'html'),
        }

        for dir in self.ftype2dir.values():
            check_dir(dir, skip=True, force=True)

        # Parse args from markdown new syntax. e.g.
        # @scatter_plot(a=1, b=2, c=3)
        # kwargs = {'a': 1, 'b': 2, 'c': 3}
        self._context = context

        # The target_id will help to index html component position.
        self.target_id = str(uuid.uuid1())

        # The index db for saving key:real_path pairs.
        self._index_db = [{
            'type': 'directory',
            'key': key,
            'value': value
        } for key, value in self.ftype2dir.items()]

        # All plugin args need to check before next step.
        self._wrapper_check_args()

        # rendered js code
        self._rendered_js = []

    @property
    def plugin_name(self):
        raise NotImplementedError('BasePlugin Subclass must override plugin_name attribute.')

    def get_file_size(self, path, protocol='http'):
        # TODO: handle error
        if protocol == 'http' or protocol == 'https':
            content_length = requests.get(path, stream=True).headers['Content-length']
        elif protocol == 'oss':
            content_length = get_oss_fsize(path)  # MB
        elif protocol == 'file':
            content_length = os.path.getsize(path)
        elif protocol == 'ftp':
            # TODO: support to get file size(ftp).
            content_length = 0

        self.logger.debug('File Size(%s Bytes): %s' % (path, content_length))
        file_size = int(content_length) / (1024 * 1024)  # MB
        return file_size

    def _fsize_is_ok(self, path, target_value, protocol='http'):
        file_size = self.get_file_size(path, protocol=protocol)
        if file_size < target_value:
            return True
        else:
            return False

    def add_file_type(self, ftype):
        dest_dir = os.path.join(self.plugin_data_dir, ftype)
        check_dir(dest_dir, skip=True, force=True)
        self.ftype2dir.update({
            ftype: dest_dir
        })

    def _wrapper_check_args(self):
        """
        Unpack context into keyword arguments of check_plugin_args method.
        """
        self.check_plugin_args(**self._context)

    def check_plugin_args(self, **kwargs):
        """
        All plugin args is holded by self._context. you need to check all plugin args when inherit Plugin class.
        """
        raise NotImplementedError('You need to reimplement check_plugin_args method.')

    def filter_ctx_files(self):
        """
        Filter context for getting all files.
        """
        files = []
        file_pattern = r'^(/)?([^/\0]+(/)?)+$'
        ftp_pattern = r'^ftp://.*$'
        http_pattern = r'^(http|https)://.*$'
        oss_pattern = r'^oss://.*$'

        for key, value in self._context.items():
            if isinstance(value, str):
                if re.match(file_pattern, str(value))\
                   and self._fsize_is_ok(value, self.target_fsize, 'file'):
                    files.append({
                        'value': value,
                        'key': key,
                        'type': 'context'
                    })

                if self.sync_ftp and re.match(ftp_pattern, str(value))\
                   and self._fsize_is_ok(value, self.target_fsize, 'ftp'):
                    files.append({
                        'value': value,
                        'key': key,
                        'type': 'context'
                    })

                if self.sync_http and re.match(http_pattern, str(value))\
                   and self._fsize_is_ok(value, self.target_fsize, 'http'):
                    files.append({
                        'value': value,
                        'key': key,
                        'type': 'context'
                    })

                if self.sync_oss and re.match(oss_pattern, str(value))\
                   and self._fsize_is_ok(value, self.target_fsize, 'oss'):
                    files.append({
                        'value': value,
                        'key': key,
                        'type': 'context'
                    })

        return files

    @property
    def context(self):
        return self._context

    @property
    def index_db(self):
        """
        Return index db's records.
        """
        return self._index_db

    def get_index(self, key):
        """
        Get record index from index db.
        """
        for idx, dic in enumerate(self._index_db):
            if dic['key'] == key:
                return idx
        return -1

    def get_value_by_idx(self, idx):
        """
        Get value by using record index from index db.
        """
        if idx >= 0:
            return self._index_db[idx].get('value')

    def set_value_by_idx(self, idx, value):
        if idx >= 0 and idx < len(self._index_db):
            self._index_db[idx].update({
                'value': value
            })

    def search(self, key):
        """
        Search index db by using key.
        """
        # Bug: next func just return one value,
        # so you need to make sure that the key in self._index_db is unique.
        return next((item for item in self._index_db if item["key"] == key), None)

    def _get_dest_dir(self, ftype):
        """
        Get the plugin data directory.
        """
        dest_dir = self.ftype2dir.get(ftype.lower())
        return dest_dir

    def set_index(self, key, path, ftype='css'):
        """
        Add a record into index db. All files from plugin arguments will be autosaved and indexed. Other files must be saved and indexed manually by plugin developer.

        :param key: index key, plugin developer can get the real path or network url of the file by using the key.
        :param path: the path of a file that is needed to cache and index.
        :param ftype: file type, it will determin where the file will be saved.
        """
        if self.search(key):
            color_msg = BashColors.get_color_msg('WARNING', 'The key (%s) is inside of index db. '
                                                 'The value will be updated by new value.' % key)
            self.logger.warning(color_msg)
            idx = next((index for (index, d) in enumerate(self._index_db) if d["key"] == key), None)
            self._index_db[idx] = {
                'type': ftype,
                'key': key,
                'value': path
            }
        else:
            pattern = r'^%s.*' % self.plugin_data_dir
            matched = re.match(pattern, path)
            # Save file when the file is not in plugin_data_dir.
            if not matched:
                self.logger.debug('set_index: %s, %s, %s, %s' % (key, path, ftype, pattern))
                self._save_file(key, path, ftype=ftype)
            else:
                self._index_db.append({
                    'type': ftype,
                    'key': key,
                    'value': path
                })

    def _save_file(self, key, path, ftype='css'):
        """
        Copy the file to plugin data directory.
        """
        dest_dir = self._get_dest_dir(ftype)
        # TODO: how to distinguish file path from string? We can not simply raise NotImplementedError when can not get dest_dir by using ftype.
        if not dest_dir:
            raise NotImplementedError("Can't support the file type: %s" % ftype)

        if os.path.isfile(path):
            is_file = True
            net_path = 'file://' + os.path.abspath(path)
        elif os.path.isdir(path):
            is_file = False
            net_path = 'file://' + os.path.abspath(path)
        else:
            net_path = path

        self.logger.debug('_save_file net_path: %s' % net_path)
        matched = re.match(r'^(https|http|file|ftp|oss)://.*$', net_path)
        if matched:
            protocol = matched.groups()[0]
            filename, file_extension = os.path.splitext(os.path.basename(path))
            dest_filepath = os.path.join(dest_dir, '%s_%s%s' % (get_candidate_name(), filename, file_extension))

            self.set_index(key, dest_filepath, ftype=ftype)
            if protocol == 'file':
                copy_and_overwrite(path, dest_filepath, is_file=is_file)
            elif protocol == 'oss':
                run_copy_files(path, dest_filepath, recursive=False, silent=True)
            elif protocol == 'http' or protocol == 'https':
                r = requests.get(net_path)
                if r.status_code == 200:
                    with open(dest_filepath, "wb") as f:
                        f.write(r.content)
                else:
                    self.logger.warning('No such file: %s' % path)
            elif protocol == 'ftp':
                # TODO: support to save ftp file.
                pass
        else:
            self.logger.warning('No such file: %s' % path)

    def external_data(self):
        """
        Adding external data files.

        :return: file dict, such as {'idx_key': 'filepath'}
        """
        pass

    def external_css(self):
        """
        Adding external css files.

        :return: file list, such as [{'idx_key': 'filepath'}]
        """
        pass

    def external_javascript(self):
        """
        Adding external javascript files.

        :return: file list, such as [{'idx_key': 'filepath'}]
        """
        pass

    def inject(self, net_path, ftype='css'):
        """
        Inject js and css into document.
        """
        if ftype not in ('css', 'js', 'javascript'):
            self.logger.warning('inject %s error, %s is not supported.' % (net_path, ftype))
        else:
            if ftype == 'css':
                script = "<script>window.webInject.css(window.location.origin + '/' + '%s', function(){console.log('%s injected.')})</script>" % (net_path, net_path)
                self._rendered_js.append(script)
            elif ftype == 'js' or ftype == 'javascript':
                script = "<script>window.webInject.js(window.location.origin + '/' + '%s', function(){console.log('%s injected.')})</script>" % (net_path, net_path)
                self._rendered_js.append(script)

    def _get_index_lst(self, external_files, ftype):
        try:
            idx_dict = []
            if isinstance(external_files, dict):
                for key, value in external_files.items():
                    idx_dict.append({
                        'key': key,
                        'value': value,
                        'type': ftype
                    })
            elif isinstance(external_files, list):
                for idx, value in enumerate(external_files):
                    idx_dict.append({
                        'key': list(value.keys())[0],
                        'value': list(value.values())[0],
                        'type': ftype
                    })
            return idx_dict
        except Exception as err:
            self.logger.warning(str(err))
            raise Exception('External file must be a dict that contains'
                            ' key: value or a list that contains {key: value}.')

    def _prepare_js(self):
        javascript = self._get_index_lst(self.external_javascript(), 'js')
        # TODO: async加速?
        for item in javascript:
            self.set_index(item.get('key'), item.get('value'), item.get('type'))
            self.logger.debug('index_db: %s, context: %s' % (self._index_db, self.context))
            self.inject(self.get_net_path(item.get('key')), ftype='js')

    def set_default_static(self):
        default_css = os.path.join(os.path.dirname(__file__), 'static', 'default.css')
        css_lst = [{
            'default_css': default_css
        }]
        css = self._get_index_lst(css_lst, 'css')
        # TODO: async加速?
        for item in css:
            self.set_index(item.get('key'), item.get('value'), item.get('type'))
            self.inject(self.get_net_path(item.get('key')), ftype='css')

    def _prepare_css(self):
        css = self._get_index_lst(self.external_css(), 'css')

        # TODO: async加速?
        for item in css:
            self.set_index(item.get('key'), item.get('value'), item.get('type'))
            self.inject(self.get_net_path(item.get('key')), ftype='css')

        self.logger.debug('index_db: %s, context: %s, css: %s' % (self._index_db, self.context, css))

    def prepare(self):
        """
        One of stages: copy all dependencies to plugin data directory.
        """
        self.set_default_static()
        self._prepare_css()
        self._prepare_js()

        data = self._get_index_lst(self.external_data(), 'data')
        context_files = self.filter_ctx_files()

        files = data + context_files

        # TODO: async加速?
        for item in files:
            self.set_index(item.get('key'), item.get('value'), item.get('type'))

    def multiqc(self, analysis_dir):
        import sys
        from subprocess import CalledProcessError, PIPE, Popen

        output_dir = os.path.join(self._get_dest_dir('html'), get_candidate_name())
        check_dir(output_dir, skip=True, force=True)
        multiqc_cmd = ['multiqc', analysis_dir, '-o', output_dir]
        try:
            process = Popen(multiqc_cmd, stdout=PIPE)
            while process.poll() is None:
                output = process.stdout.readline()
                if output == '' and process.poll() is not None:
                    break
                self.logger.info(output.strip())
                sys.stdout.flush()
                process.poll()
            return output_dir
        except CalledProcessError as e:
            self.logger.critical(e)
            return None

    def bokeh(self):
        pass

    def plotly(self):
        pass

    def index_js_lst(self, js_lst):
        javascript = self._get_index_lst(js_lst, 'js')
        net_path_lst = []
        # TODO: async加速?
        for item in javascript:
            self.set_index(item.get('key'), item.get('value'), item.get('type'))
            self.logger.debug('index_db: %s, context: %s' % (self._index_db, self.context))
            net_path_lst.append(self.get_net_path(item.get('key')))
        return net_path_lst

    def autogen_js(self, required_js_lst, func_name, *args, div_id=None, configs=None, html_components=None):
        """
        Auto generate javascript code by function arguments.
        """
        import json

        if div_id is None:
            div_id = 'plugin_' + get_candidate_name()

        if html_components:
            div_component = '%s<div id="%s" class="%s choppy-plot-container">Loading...</div>'\
                            % (html_components, div_id, self.plugin_name)
        else:
            div_component = '<div id="%s" class="%s choppy-plot-container">Loading...</div>'\
                            % (div_id, self.plugin_name)

        # Get network path
        net_path_lst = self.index_js_lst(required_js_lst)

        # Javascript function specification: the first two of js function must be div_id and configs.
        args = list(args)
        if args:
            args.insert(0, div_id)
            args.insert(1, configs)
            func_args = json.dumps(args)
        else:
            func_args = json.dumps([div_id, configs, ])
        js_code = '<script>var loader = new Loader(); loader.require(%s,  function () { window.addEventListener("load", function() { var args = JSON.parse(\'%s\'); %s.apply(this, args);})});</script>' % (net_path_lst, func_args, func_name)
        codes = [div_component, ] + [js_code, ]
        self.logger.debug("Rendered js code(%s): %s" % (self.plugin_name, codes))
        self.logger.info("Js fucntion's arguments(%s): %s" % (func_name, func_args))
        return codes

    def _transform(self, bokeh_plot=None, plotly_plot=None):
        """
        The second stage: It's necessary for some plugins to transform data or render plugin template before generating javascript code. May be you want to reimplement transform method when you have a new plugin that is not a plotly or bokeh plugin. If the plugin is a plotly or bokeh plugin, you need to reimplement plotly method or bokeh method, not transform method. (transform, save and index transformed data file.)

        :return: the path of transformed file.
        """
        def index_files(filename_lst):
            file_lst = [os.path.join(os.path.dirname(__file__), 'static', 'bokeh', filename)
                        for filename in filename_lst]
            js = self._get_index_lst(file_lst, 'js')
            # TODO: async加速?
            js_lst = []
            for item in js:
                self.set_index(item.get('key'), item.get('value'), item.get('type'))
                js_lst.append(self.get_net_path(item.get('key')))
            return js_lst

        # Only support bokeh in the current version.
        from bokeh.plotting.figure import Figure as bokehFigure
        from plotly.graph_objs import Figure as plotlyFigure
        if isinstance(bokeh_plot, bokehFigure):
            from bokeh.resources import CDN
            from bokeh.embed import autoload_static

            # Temporary directory
            dest_dir = self._get_dest_dir('js')
            plot_js_path = os.path.join(dest_dir, 'bokeh_%s.js' % get_candidate_name())

            # TODO: How to cache bokeh js?
            # js_files = ['bokeh-1.0.4.min.js', 'bokeh-gl-1.0.4.min.js', 'bokeh-tables-1.0.4.min.js',
            #             'bokeh-widgets-1.0.4.min.js']
            # js_resources = index_files(js_files)

            # URL
            virtual_path = self._get_virtual_path(plot_js_path)
            plot_js, js_tag = autoload_static(bokeh_plot, CDN, virtual_path)

            self.logger.debug('Bokeh js tag: %s' % js_tag)
            with open(plot_js_path, 'w') as f:
                f.write(plot_js)
                self.set_index('bokeh_js', plot_js_path, ftype='js')
                net_path = self.get_net_path('bokeh_js')

                self.logger.debug('index_db: %s, net_path: %s, virtual_path: %s' %
                                  (self._index_db, net_path, virtual_path))
                if net_path == virtual_path:
                    return [js_tag, ]
                else:
                    raise Exception('virtual_path(%s) and net_path(%s) are wrong.' % (virtual_path, net_path))
        elif isinstance(plotly_plot, plotlyFigure):
            from plotly.offline import plot, get_plotlyjs
            # Temporary directory
            dest_dir = self._get_dest_dir('js')
            plot_js_path = os.path.join(dest_dir, 'bokeh_%s.js' % get_candidate_name())
            plotly_js = get_plotlyjs()

            with open(plot_js_path, 'w') as f:
                f.write(plotly_js)
                self.set_index('plotly_js', plot_js_path, ftype='js')
                net_path = self.get_net_path('plotly_js')
                js_code = '<script type="text/javascript" src="%s"></script>' % net_path

                self.logger.debug('Plotlyjs: %s' % js_code)
                plot_div = plot(plotly_plot, output_type='div', include_plotlyjs=False)
                self.logger.debug('Plotly Object Js Code: %s' % js_code)
                return [js_code, plot_div, ]

    def render(self, **kwargs):
        """
        The third stage: rendering javascript snippet. The js code will inject into markdown file, and then build as html file.

        :param kwargs: all plugin args.
        :return: a list that contains js code.
        """
        pass

    def _wrapper_render(self):
        """
        Unpack context into keyword arguments of render method.
        """
        bokeh_plot = self.bokeh()
        plotly_plot = self.plotly()  # noqa
        if bokeh_plot or plotly_plot:
            rendered_lst = self._transform(bokeh_plot=bokeh_plot, plotly_plot=plotly_plot)
            if not isinstance(rendered_lst, list):
                raise NotImplementedError('Plugin does not yet support plotly framework.')
        else:
            rendered_lst = self.render(**self._context)
            if not isinstance(rendered_lst, list):
                raise NotImplementedError('You need to implement render method.')

        self._rendered_js.extend(rendered_lst)
        self.logger.debug('Plugin %s inject js code: %s' % (self.plugin_name, self._rendered_js))
        return self._rendered_js

    def run(self):
        """
        Run three stages step by step.
        """
        self.prepare()
        return self._wrapper_render()

    def _get_virtual_path(self, path):
        virtual_path = path.replace(self.tmp_plugin_dir, '')
        # To avoid invalid replace.
        if virtual_path != path:
            virtual_path = virtual_path.strip('/')

        return virtual_path

    def get_net_path(self, key):
        """
        Get virtual network path for mkdocs server.
        """
        record_idx = self.get_index(key)
        if record_idx >= 0:
            file_path = self.get_value_by_idx(record_idx)
            virtual_path = self._get_virtual_path(file_path)
            if self.net_dir:
                # Fix bug: virtual_path will break os.path.join when it start with '/'
                self.logger.debug("virtual_path: %s" % virtual_path)
                dest_path = os.path.join(self.net_dir, virtual_path)
                self.logger.debug("dest_path: %s" % dest_path)
                check_dir(os.path.dirname(dest_path), skip=True, force=True)
                copy_and_overwrite(file_path, dest_path, is_file=True)
                self.set_value_by_idx(record_idx, dest_path)
                return virtual_path
            else:
                # TODO: upload to qiniu and return a url.
                return virtual_path
        else:
            self.logger.warning('No such key in index db: %s' % key)

    def get_real_path(self, key):
        """
        Get real path in local file system.
        """
        record_idx = self.get_index(key)
        if record_idx > -1:
            real_file_path = self.get_value_by_idx(record_idx)
            return real_file_path
        else:
            return ''


def get_internal_plugins():
    from mk_media_extension.plugins import internal_plugins
    return internal_plugins


def get_plugins():
    """
    Return a dict of all installed Plugins by name.
    """
    plugins = pkg_resources.iter_entry_points(group='choppy.plugins')

    return dict((plugin.name, plugin) for plugin in plugins)
