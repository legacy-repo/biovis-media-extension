function PivotTableViewer(divId, configs) {
    var pivotInstance = document.querySelector('#wdr-pivot-view')

    if (pivotInstance) {
        $('#' + divId).html("<div class='alert alert-warning' role='alert' style='width: 100%;min-height: 300px; display: flex; justify-content: center; align-items: center;'><pre class='highlight'><code>Only one pivot-table-js plugin can be added into a choppy report.<br>If you have any questions, Please contact the plugin developer.</pre></code></div>");
        return
    }

    initSessionStorage()

    // Initialize pivot table
    var pivot = new WebDataRocks({
        container: "#" + divId,
        beforetoolbarcreated: customizeToolbar,
        toolbar: true,
        report: {
            dataSource: {
                filename: configs.dataUrl
            },
            localization: "http://kancloud.nordata.cn/2019-03-18-custom-en.json"
        }
    });

    // Monitor sessionStorage and then redraw table
    const { session, subscribe } = brownies;
    subscribe(session, 'pivot-current-chart', function(chartType) {
        console.log("Change chart type to " + chartType)
        var chart = $('#' + configs.chartId).highcharts()
        if (chart) {
            chart.destroy()
        }

        if (chartType == 'none') {
            $('#' + configs.chartId).append("<div class='alert alert-info' role='alert' style='width: 100%; display: flex; margin-bottom: 0px; justify-content: center; align-items: center;'><pre class='highlight'><code>No Chart, you can choose a chart from Chart Options.</pre></code></div>");
        } else if (chartType == 'barchart') {
            createBarChart();
        } else if (chartType == 'areaspline') {
            createChart('areaspline');
        } else if (chartType == 'arearange') {
            createChart('arearange');
        } else if (chartType == 'areasplinerange') {
            createChart('areasplinerange')
        } else if (chartType == 'area') {
            createChart('area')
        } else if (chartType == 'column') {
            createChart('column')
        } else if (chartType == 'bubble') {
            createChart('bubble')
        } else if (chartType == 'columnrange') {
            createChart('columnrange')
        } else if (chartType == 'errorbar') {
            createChart('errorbar')
        } else if (chartType == 'line') {
            createChart('line')
        } else if (chartType == 'funnel') {
            createChart('funnel')
        } else if (chartType == 'pie') {
            createChart('pie')
        } else if (chartType == 'polygon') {
            createChart('polygon')
        } else if (chartType == 'pyramid') {
            createChart('pyramid')
        } else if (chartType == 'scatter') {
            createChart('scatter')
        } else if (chartType == 'spline') {
            createChart('spline')
        } else if (chartType == 'waterfall') {
            createChart('waterfall')
        }
    });


    function initSessionStorage() {
        var storage = window.sessionStorage;
        storage.setItem("pivot-current-chart", "none");
    }

    function addSwitchBtn() {
        // Readd button when change the pivot-chart.
        $('#' + configs.chartId).off('click', '#pivot-chart-btn')

        $('#' + configs.chartId).append('<div id="pivot-chart-btn" class="suspend-btn"><span class="fa" aria-hidden="true"></span></div>');

        if($('#' + configs.chartId).hasClass("pivot-chart-suspend")) {
            $('#pivot-chart-btn span').addClass('fa-close');
        } else {
            $('#pivot-chart-btn span').addClass('fa-caret-right');
        }

        $('#' + configs.chartId).addClass('pivot-chart-origin');

        $('#' + configs.chartId).on('click', '#pivot-chart-btn', function(e){
            $('#' + configs.chartId).toggleClass('pivot-chart-suspend');
            $('#pivot-chart-btn span').toggleClass('fa-close fa-caret-right');
            var width = $('#' + configs.chartId).width();
            var height = $('#' + configs.chartId).height();
            console.log('height', height, 'width', width)
            var charts = $('#' + configs.chartId).highcharts()
            if (charts) {
                charts.setSize(width, height, doAnimation = true);
            }
        });
    }

    function createChart(chartType) {
        pivot.highcharts.getData({
            // 'areaspline', 'arearange', 'areasplinerange', 'area',
            // 'column', 'bubble', 'columnrange', 'errorbar', 'line',
            // 'pie', 'funnel', 'polygon', 'pyramid', 'scatter', 'spline'
            // 'waterfall'
            type: chartType
        }, createAndUpdateChart, createAndUpdateChart);
    }

    function createAndUpdateChart(data, rawData) {
        Highcharts.chart(configs.chartId, data);
        addSwitchBtn();
    }

    function createBarChart() {
        pivot.highcharts.getData({
            type: "bar"
        }, createAndUpdateBarChart, createAndUpdateBarChart);
    }

    function createAndUpdateBarChart(data, rawData) {
        if (data.yAxis == undefined) data.yAxis = {};
        // apply the number formatting from the pivot table to the tooltip
        data.tooltip = {
            pointFormat: pivot.highcharts.getPointYFormat(rawData.meta.formats[0])
        }
        Highcharts.chart(configs.chartId, data);
        addSwitchBtn();
    }

    function customizeToolbar(toolbar) {
        var tabs = toolbar.getTabs(); // get all tabs from the toolbar
        if(configs.enableLocal) {
            toolbar.getTabs = function() {
                return tabs;
            }
        } else {
            toolbar.getTabs = function() {
                delete tabs[0]; // delete the first tab
                return tabs;
            }
        }
    };

    function customizeCellFunction(cellBuilder, cellData) {
        cellBuilder.style = {
            "font-size": "16px"
        }
    }
}
