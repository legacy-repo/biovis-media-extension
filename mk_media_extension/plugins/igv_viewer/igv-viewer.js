function IgvViewer(divId, configs, dataUrl, genome, locus) {

    const igvDiv = document.getElementById(divId);

    while (igvDiv.firstChild) {
        igvDiv.removeChild(igvDiv.firstChild);
    }

    const options =
    {
        showNavigation: true,
        showRuler: true,
        genome: genome ? genome : 'hg19',
        locus: locus ? locus : 'chr1',
        tracks: [
            {
                url: dataUrl,
                indexed: false,
                isLog: true,
                name: 'Segmented CN'
            }
        ]
    };

    igv.createBrowser(igvDiv, options)
}