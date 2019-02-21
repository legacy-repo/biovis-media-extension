# -*- coding:utf-8 -*-
from __future__ import unicode_literals

import os
from mk_media_extension.plugin import BasePlugin


class PCAPlugin(BasePlugin):
    """
    PCA plugin.

    :Example:
    @pca(csvFile='')
    """
    plugin_name = 'pca'

    def external_css(self):
        pca_css = os.path.join(os.path.dirname(__file__), 'pca.css')
        return [{'pca_css': pca_css}]

    def check_plugin_args(self, **kwargs):
        pass

    def plotly(self):
        import plotly.graph_objs as go
        from plotly import tools
        import numpy as np
        import pandas as pd

        from sklearn.datasets import load_iris
        from sklearn.decomposition import PCA, IncrementalPCA
        iris = load_iris()
        csvFile = self.context.get('csvFile')
        rt = pd.read_csv(csvFile)

        X = np.array(rt)
        y = np.array([0, 0, 0, 0, 1, 1, 1, 1, 1])
        iris.target_names = np.array(['A', 'B'])

        n_components = 2
        ipca = IncrementalPCA(n_components=n_components, batch_size=10)
        X_ipca = ipca.fit_transform(X)

        pca = PCA(n_components=n_components)
        X_pca = pca.fit_transform(X)

        colors = ['navy', 'turquoise', 'darkorange']

        for X_transformed, title in [(X_ipca, "Incremental PCA"), (X_pca, "PCA")]:
            if "Incremental" in title:
                err = np.abs(np.abs(X_pca) - np.abs(X_ipca)).mean()

        fig = tools.make_subplots(rows=1, cols=2,
                                  subplot_titles=("Incremental PCA of sample A/B dataset<br>"
                                                  "Mean absolute unsigned error %.6f" % err,
                                                  "PCA of sample A/B dataset"))
        col = 1
        legend = True

        for X_transformed, title in [(X_ipca, "Incremental PCA"), (X_pca, "PCA")]:

            for color, i, target_name in zip(colors, [0, 1, 2], iris.target_names):
                if(col == 2):
                    legend = False

                pca = go.Scatter(x=X_transformed[y == i, 0],
                                 y=X_transformed[y == i, 1],
                                 showlegend=legend,
                                 mode='markers',
                                 marker=dict(size=10, color=color),
                                 name=target_name)
                fig.append_trace(pca, 1, col)
            col += 1

        for i in map(str, range(1, 3)):
            x = 'xaxis' + i
            y = 'yaxis' + i

            fig['layout'][x].update(zeroline=False, showgrid=False)
            fig['layout'][y].update(zeroline=False, showgrid=False)

        return fig
