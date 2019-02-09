# -*- coding:utf-8 -*-
from __future__ import unicode_literals
import os
import shutil
from datetime import datetime


class BashColors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    SUCCESS = '\033[92m'  # Green
    WARNING = '\033[93m'  # Yellow
    DANGER = '\033[91m'   # Red
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
    INFO = '\033[30m'     # Black

    @classmethod
    def _get_color(cls, color_name):
        color_dict = {
            'SUCCESS': BashColors.SUCCESS,
            'INFO': BashColors.INFO,
            'WARNING': BashColors.WARNING,
            'DANGER': BashColors.DANGER,
            'UNDERLINE': BashColors.UNDERLINE,
            'BOLD': BashColors.BOLD,
            'BLUE': BashColors.OKBLUE
        }
        return color_dict.get(color_name.upper(), BashColors.INFO)

    @classmethod
    def get_color_msg(cls, color_name, msg):
        return cls._get_color(color_name) + msg + BashColors.ENDC

    @classmethod
    def print_color(cls, color_name, msg):
        print(cls._get_color(color_name) + msg + BashColors.ENDC)


def copy_and_overwrite(from_path, to_path, is_file=False):
    if os.path.isfile(to_path):
        os.remove(to_path)

    if os.path.isdir(to_path):
        shutil.rmtree(to_path)

    if is_file and os.path.isfile(from_path):
        shutil.copy2(from_path, to_path)
    elif os.path.isdir(from_path):
        shutil.copytree(from_path, to_path)


def print_obj(str):
    try:  # For Python2.7
        print(unicode(str).encode('utf8'))
    except NameError:  # For Python3
        print(str)


def check_dir(path, skip=False, force=True):
    """
    Check whether path exists.

    :param path: directory path.
    :param skip: Boolean, Raise exception when skip is False and directory exists.
    :param force: Boolean, Force to make directory when directory doesn't exist?
    :return:
    """
    if not os.path.isdir(path):
        if force:
            os.makedirs(path)
        else:
            raise Exception("%s doesn't exist." % path)
    elif not skip:
        raise Exception("%s exists" % path)
