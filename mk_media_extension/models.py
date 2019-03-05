# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
import logging
from sqlalchemy.orm import sessionmaker
from sqlalchemy import Column, String, Boolean, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import create_engine
from mk_media_extension import config
from mk_media_extension.utils import (check_dir, BashColors)
from mk_media_extension.process_mgmt import Process

logger = logging.getLogger(__name__)
Base = declarative_base()


class Plugin(Base):
    __tablename__ = 'plugin'
    id = Column(Integer, autoincrement=True, primary_key=True)
    name = Column(String(250), nullable=False)
    command = Column(String(255), nullable=False)
    command_md5 = Column(String(64), nullable=False, unique=True, index=True)
    is_server = Column(Boolean, nullable=False)
    container_id = Column(String(64), nullable=True)
    process_id = Column(String(8), nullable=True)
    access_url = Column(String(255), nullable=False)
    workdir = Column(String(255), nullable=True)


def init_db():
    # Create an engine that stores data in the local directory's
    # sqlalchemy_example.db file.
    check_dir(os.path.dirname(config.plugin_db), skip=True)
    engine = create_engine('sqlite:///%s' % config.plugin_db)

    # Create all tables in the engine. This is equivalent to "Create Table"
    # statements in raw SQL.
    Base.metadata.create_all(engine)
    return engine


def add_plugin(name, command, command_md5, access_url, workdir=None,
               is_server=False, container_id=None, process_id=None):
    engine = init_db()
    DBSession = sessionmaker(bind=engine)
    session = DBSession()
    new_plugin = Plugin(name=name, command=command, command_md5=command_md5,
                        is_server=is_server, container_id=container_id,
                        process_id=process_id, access_url=access_url,
                        workdir=workdir)
    session.add(new_plugin)
    session.commit()
    session.close()


def get_plugin(command_md5):
    engine = init_db()
    DBSession = sessionmaker(bind=engine)
    session = DBSession()
    plugins = session.query(Plugin).filter(Plugin.command_md5 == command_md5).all()

    if len(plugins) == 1:
        return plugins[0]
    else:
        return False


def get_plugins():
    engine = init_db()
    DBSession = sessionmaker(bind=engine)
    session = DBSession()
    plugins = session.query(Plugin).all()
    return plugins


def delete_plugin(command_md5):
    engine = init_db()
    DBSession = sessionmaker(bind=engine)
    session = DBSession()
    plugins = session.query(Plugin).filter(Plugin.command_md5 == command_md5).all()

    if len(plugins) == 1:
        plugin = plugins[0]
        session.delete(plugin)
        return True


def clean_at_exit():
    import atexit
    import shutil
    plugins = get_plugins()

    def clean_cache_db():
        for plugin in plugins:
            msg = '\nClean cache and database record for plugin %s' % plugin.name
            color_msg = BashColors.get_color_msg('INFO', msg)
            print(color_msg)
            if config.clean_cache:
                workdir = plugin.workdir
                shutil.rmtree(workdir, ignore_errors=True)

            try:
                os.remove(config.plugin_db)
            except Exception:
                pass

            color_msg = BashColors.get_color_msg('SUCCESS', 'Clean successfully.')
            print(color_msg)

    process = Process()
    atexit.register(process.clean_processs)
    atexit.register(clean_cache_db)


# clean_at_exit may not work, so you need to clean all dirty directory before launching choppy.
clean_at_exit()
