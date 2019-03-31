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
        'plotly>=3.6.1',
        'bokeh>=1.0.4',
        'Jinja2>=2.10',
        'Markdown>=3.0.1',
        'pyparsing>=2.3.1',
        'requests>=2.21.0',
        'multiqc>=1.7',
        'sqlalchemy>=1.2.18',
        'docker>=3.5.1',
        'psutil>=5.5.1'
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
        'markdown.extensions': [
            'mk_media_extension = mk_media_extension.extension:ChoppyPluginExtension'
        ]
    }
)
