// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function () {
  $('input.tags').tagsInput({
    'unique':true,
    'delimiter':" ",
    'defaultText':'add a scope',
    'height':'78px',
    'width':'295px'
  });  
});

var chart;
function createChart(days, times, uri) {
   chart = new Highcharts.Chart({
      chart: {
         renderTo: 'chart',
         defaultSeriesType: 'line',
         marginRight: 30,
         marginBottom: 50
      },
      title: { text: 'Daily access rate for client' },
      subtitle: { text: uri },
      xAxis: {
         categories: days
      },
      yAxis: {
         title: { text: 'Number of requests' },
         plotLines: [{ value: 0, width: 1, color: '#808080' }]
      },
      tooltip: {
         formatter: function() {
           return 'Accesses ' + this.x +'<br/><b>' + this.y + ' times</b>';
         }
      },
      legend: {
         layout: 'vertical',
         align: 'right',
         verticalAlign: 'top',
         x: -10,
         y: 10,
         borderWidth: 0
      },
      series: [{
         name: 'accesses',
         data: times
      }]
   });
};


