# -*- coding:utf-8 -*-
from __future__ import unicode_literals
import os
import re
import uuid
import json
import requests
import logging
import pkg_resources
from bokeh.embed import json_item
from mk_media_extension.utils import check_dir, copy_and_overwrite, BashColors
from mk_media_extension.file_mgmt import run_copy_files


class BasePlugin:
    """
    Plugin class is initialized by plugin args from markdown. Plugin args: @plugin_name(arg1=value, arg2=value, arg3=value)
    """
    def __init__(self, context, net_dir=None):
        """
        Initialize BasePlugin class.

        :param: context: a dict that contains all plugin arguments.
        :param: net_dir: plugin used it to get relative network path for all files that are needed by html. if net_dir is None, plugin will upload all files to qiniu and get a qiniu url.
        """
        self.logger = logging.getLogger(__name__)
        self.net_dir = net_dir
        self.tmp_plugin_dir = os.path.join('/tmp', 'choppy-media-extension', str(uuid.uuid1()))
        self.plugin_data_dir = os.path.join(self.tmp_plugin_dir, 'plugin')

        self.ftype2dir = {
            'css': os.path.join(self.plugin_data_dir, 'css'),
            'javascript': os.path.join(self.plugin_data_dir, 'js'),
            'js': os.path.join(self.plugin_data_dir, 'js'),
            'data': os.path.join(self.plugin_data_dir, 'data'),
            'context': os.path.join(self.plugin_data_dir, 'context')
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
        pattern = r'^(/)?([^/\0]+(/)?)+$'
        for key, value in self._context.items():
            if isinstance(value, str) and re.match(pattern, str(value)):
                files.append(value)
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

    def set_index(self, path, ftype='css'):
        """
        Add a record into index db.
        """
        key = os.path.basename(path)

        if self.search(key):
            color_msg = BashColors.get_color_msg('The key (%s) is inside of index db. '
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
                self._save_file(path, ftype=ftype)
            else:
                self._index_db.append({
                    'type': ftype,
                    'key': key,
                    'value': path
                })

    def _get_dest_dir(self, ftype):
        """
        Get the plugin data directory.
        """
        dest_dir = self.ftype2dir.get(ftype.lower())
        return dest_dir

    def _save_file(self, path, ftype='css'):
        """
        Copy the file to plugin data directory.
        """
        dest_dir = self._get_dest_dir(ftype)
        # TODO: how to distinguish file path from string? We can not simply raise NotImplementedError when can not get dest_dir by using ftype.
        if not dest_dir:
            raise NotImplementedError("Can't support the file type: %s" % ftype)

        if os.path.isfile(path):
            net_path = 'file://' + os.path.abspath(path)
        else:
            net_path = path

        matched = re.match(r'(https|http|file|ftp|oss)://.*', net_path)
        if matched:
            protocol = matched.groups()[0]
            filename = os.path.basename(path)
            dest_filepath = os.path.join(dest_dir, filename)
            # Set index database record.
            self.set_index(dest_filepath, ftype=ftype)
            if protocol == 'file':
                copy_and_overwrite(path, dest_filepath, is_file=True)
            elif protocol == 'oss':
                run_copy_files(path, dest_filepath, recursive=False, silent=True)
            else:
                r = requests.get(net_path)
                if r.status_code == 200:
                    with open(dest_filepath, "wb") as f:
                        f.write(r.content)
                else:
                    self.logger.warning('No such file: %s' % path)

    def external_data(self):
        """
        Adding external data files.

        :return: file list.
        """
        pass

    def external_css(self):
        """
        Adding external css files.

        :return: file list:
        """
        pass

    def external_javascript(self):
        """
        Adding external javascript files.

        :return: file list:
        """
        pass

    def _get_list(self, value):
        if value:
            return value
        else:
            return list()

    def prepare(self):
        """
        One of stages: copy all dependencies to plugin data directory.
        """
        css = self._get_list(self.external_css())
        javascript = self._get_list(self.external_javascript())
        data = self._get_list(self.external_data())
        context_files = self.filter_ctx_files()

        filetype = ['css'] * len(css) + ['js'] * len(javascript) + \
                   ['data'] * len(data) + ['context'] * len(context_files)
        filelist = css + javascript + data + context_files

        # TODO: async加速?
        for ftype, file in zip(filetype, filelist):
            self._save_file(file, ftype=ftype)

    def bokeh(self):
        pass

    def plotly(self):
        pass

    def transform(self):
        """
        The second stage: It's necessary for some plugins to transform data or render plugin template before generating javascript code. May be you want to reimplement transform method when you have a new plugin that is not a plotly or bokeh plugin. If the plugin is a plotly or bokeh plugin, you need to reimplement plotly method or bokeh method, not transform method. (transform, save and index transformed data file.)

        :return:
        """
        bokeh_plot = self.bokeh()
        plotly_plot = self.plotly()  # noqa
        # Only support bokeh in the current version.
        if bokeh_plot:
            dest_dir = self._get_dest_dir(ftype)
            plot_json = json.dumps(json_item(bokeh_plot, self.target_id))
            plot_json_path = os.path.join(dest_dir, 'plot.json')
            with open(plot_json_path) as f:
                f.write(plot_json)
                self.set_index(plot_json_path, ftype='json')
        else:
            pass

    def render(self, **kwargs):
        """
        The third stage: rendering javascript snippet. The js code will inject into markdown file, and then build as html file.

        :param kwargs: all plugin args.
        """
        raise NotImplementedError('You need to implement render method.')

    def _wrapper_render(self):
        """
        Unpack context into keyword arguments of render method.
        """
        return self.render(**self._context)

    def run(self):
        """
        Run three stages step by step.
        """
        self.prepare()
        self.transform()
        render_lst = self._wrapper_render()
        return render_lst

    def get_net_path(self, filename):
        """
        Get virtual network path for mkdocs server.
        """
        record_idx = self.get_index(filename)
        if record_idx >= 0:
            file_path = self.get_value_by_idx(record_idx)
            virtual_path = file_path.replace(self.tmp_plugin_dir, '')
            if self.net_dir:
                # Fix bug: virtual_path will break os.path.join when it start with '/'
                virtual_path = virtual_path.strip('/')
                dest_path = os.path.join(self.net_dir, virtual_path)
                check_dir(os.path.dirname(dest_path), skip=True, force=True)
                copy_and_overwrite(file_path, dest_path, is_file=True)
                self.set_value_by_idx(record_idx, dest_path)
                return virtual_path
            else:
                # TODO: upload to qiniu and return a url.
                pass
        else:
            return ''

    def get_real_path(self, filename):
        """
        Get real path in local file system.
        """
        record = self.search(filename)
        if record:
            real_file_path = record.get('value')
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
