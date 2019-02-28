# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from sqlalchemy.orm import sessionmaker
from sqlalchemy import Column, String, Boolean, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import create_engine


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


def init_db(site_dir):
    # Create an engine that stores data in the local directory's
    # sqlalchemy_example.db file.
    if site_dir is None:
        site_dir = '/tmp'
    engine = create_engine('sqlite:///%s' % os.path.join(site_dir, 'plugin.db'))

    # Create all tables in the engine. This is equivalent to "Create Table"
    # statements in raw SQL.
    Base.metadata.create_all(engine)
    return engine


def add_plugin(site_dir, name, command, command_md5, access_url,
               is_server=False, container_id=None, process_id=None):
    engine = init_db(site_dir)
    DBSession = sessionmaker(bind=engine)
    session = DBSession()
    new_plugin = Plugin(name=name, command=command, command_md5=command_md5,
                        is_server=is_server, container_id=container_id,
                        process_id=process_id, access_url=access_url)
    session.add(new_plugin)
    session.commit()
    session.close()


def get_plugin(site_dir, command_md5):
    engine = init_db(site_dir)
    DBSession = sessionmaker(bind=engine)
    session = DBSession()
    plugins = session.query(Plugin).filter(Plugin.command_md5 == command_md5).all()

    if len(plugins) == 1:
        return plugins[0]
    else:
        return False


def delete_plugin(site_dir, command_md5):
    engine = init_db(site_dir)
    DBSession = sessionmaker(bind=engine)
    session = DBSession()
    plugins = session.query(Plugin).filter(Plugin.command_md5 == command_md5).all()

    if len(plugins) == 1:
        plugin = plugins[0]
        session.delete(plugin)
        return True
