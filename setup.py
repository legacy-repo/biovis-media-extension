from distutils.core import setup
from version import get_version

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
    keywords='markdown, dynamic plot, multimedia',
    install_requires=['markdown'],
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Environment :: Web Environment',
        'Intended Audience :: Developers',
        'License :: Other/Proprietary License',
        'Operating System :: OS Independent',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 3',
    ],
)
