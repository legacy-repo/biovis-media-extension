.. Biovis Media Extension documentation master file, created by
   sphinx-quickstart on Tue Jul  2 15:55:57 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to Biovis Media Extension's documentation!
==================================================

Summary
~~~~~~~
Biovis-media-extension is an extension for Python-Markdown.
It can launch dynamic plot or preprocess multimedia.

Dependencies
~~~~~~~~~~~~
Biovis requires Python 3+ and Python-Markdown to be loaded
in your environment in order for full functionality to work.

Syntax
~~~~~~
::

  # Such as @plugin-name(arg1=value, arg2=value)
  @boxplot-r(dataFile='boxplot-r.rds', dataType='rds', title='',
             xAxis='DoubleBlind_0to24', xTitle='DoubleBlind_0to24',
             xAngle=90, yAxis='HbA1c_DF24to0', yTitle='HbA1c_DF24to0',
             colorAttr='DoubleBlind_0to24', subtitle='', text='')


Installation
~~~~~~~~~~~~
::

  pip install biovis-media-extension


Plugins
~~~~~~~
1. `boxplot-r: Interactive boxplot visualization from a Shiny app(r version). <http://docs.3steps.cn/docs/plugins/boxplot-r.html>`_
2. `corrplot-r: Interactive correlation plot visualization from a Shiny app(r version). <http://docs.3steps.cn/docs/plugins/corrplot-r.html>`_
3. `data-table-js: Another interactive data table. It is based on datatables js library. <http://docs.3steps.cn/docs/plugins/data-table-js.html>`_
4. `density-plot: Interactive density plot visualization from a Shiny app(r version). <http://docs.3steps.cn/docs/plugins/density-plot.html>`_
5. `group-boxplot: Interactive group-boxplot visualization from a Shiny app(r version). <http://docs.3steps.cn/docs/plugins/group-boxplot.html>`_
6. `pivot-table-js: Interactive pivot-table and pivot-chart. It is based on webdatarocks and highcharts. <http://docs.3steps.cn/docs/plugins/pivot-table-js.html>`_
7. `rocket-plot-r: Interactive rocket plot visualization from a Shiny app(r version). <http://docs.3steps.cn/docs/plugins/rocket-plot-r.html>`_
8. `stack-barplot-r: Interactive stack barplot visualization from a Shiny app(r version). <http://docs.3steps.cn/docs/plugins/stack-barplot-r.html>`_
9. `upset-r: Interactive upset plot visualization from a Shiny app(r version). <http://docs.3steps.cn/docs/plugins/upset-r.html>`_
10. `violin-plot-r: Interactive violin plot visualization from a Shiny app(r version). <http://docs.3steps.cn/docs/plugins/violin-plot-r.html>`_

.. toctree::
   :maxdepth: 2
   :caption: Contents:



Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
