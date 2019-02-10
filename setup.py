import os
from setuptools import setup
from mk_media_extension.version import get_version


def get_packages(package):
    """Return root package and all sub-packages."""
    return [dirpath
            for dirpath, dirnames, filenames in os.walk(package)
            if os.path.exists(os.path.join(dirpath, '__init__.py'))]


setup(
    name='mk-media-extension',
    version=get_version(),
    description='Display dynamic plot or more multimedia content in markdown.',
    long_description=open('README.md').read(),
    author='Jingcheng Yang',
    author_email='yjcyxky@163.com',
    url='http://choppy.3steps.cn/go-choppy/mk-media-extension',
    zip_safe=False,
    platforms='any',
    include_package_data=True,
    packages=get_packages("mk_media_extension"),
    keywords='markdown, dynamic plot, multimedia',
    install_requires=[
        'bokeh==1.0.4',
        'certifi==2018.11.29',
        'chardet==3.0.4',
        'idna==2.8',
        'Jinja2==2.10',
        'Markdown==3.0.1',
        'MarkupSafe==1.1.0',
        'numpy==1.16.1',
        'packaging==19.0',
        'Pillow==5.4.1',
        'pyparsing==2.3.1',
        'python-dateutil==2.8.0',
        'PyYAML==3.13',
        'requests==2.21.0',
        'six==1.12.0',
        'tornado==5.1.1',
        'urllib3==1.24.1'
    ],
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Environment :: Web Environment',
        'Intended Audience :: Developers',
        'License :: Other/Proprietary License',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 3',
    ],
    entry_points={
        'markdown.extensions': ['mk_media_extension = mk_media_extension.extension:ChoppyPluginExtension']
    }
)
