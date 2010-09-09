var label = null;

function get_label (prefix) {
  if (!prefix && !label) {
    $.ajax({
             dataType: 'json',
             url: 'unit',
             async: false,
             success: function (data) {
               label = data;
             }
           });
  } else if (prefix) {
    $.ajax({
             dataType: 'json',
             url: prefix + '/unit',
             async: false,
             success: function (data) {
               label = data;
             }
           });
  }
}

function sigh_update_hourly () {
  var hourly = $('#hourly');

  if (hourly.hasClass('graph')) {
    get_label();
    $.ajax({
             dataType: 'json',
             url: 'hourly',
             success: function (data) {
               $.plot(hourly, [{
                                 data: data,
                                 label: label,
                                 color: '#0000FF'
                               }], {
                                 xaxis: {
                                   mode: 'time',
                                   timeformat: '%H:%M',
                                   minTickSize: [10, "minute"]
                                 }
                               });
             }
           });
    window.setTimeout(sigh_update_hourly, interval * 1000);
  }
}

$(function () {
    sigh_update_hourly();

    var daily = $('#daily');
    var weekly = $('#weekly');
    var monthly = $('#monthly');
    var yearly = $('#yearly');
    var combine = $('#combine');

    if (daily.hasClass('graph')) {
      get_label();
      $.ajax({
               dataType: 'json',
               url: 'daily',
               success: function (data) {
                 $.plot(daily, [{
                                  data: data,
                                  label: label,
                                  color: '#0000FF'
                                }], {
                                  xaxis: {
                                    mode: 'time',
                                    timeformat: '%H:%M',
                                    minTickSize: [1, "hour"]
                                  }
                                });
               }
             });
    }
    if (weekly.hasClass('graph')) {
      get_label();
      $.ajax({
               dataType: 'json',
               url: 'weekly',
               success: function (data) {
                 $.plot(weekly, [{
                                   data: data,
                                   label: label,
                                   color: '#0000FF'
                                 }], {
                                   xaxis: {
                                     mode: 'time',
                                     timeformat: '%y-%m-%d',
                                     minTickSize: [1, "day"]
                                   }
                                 });
               }
             });
    }
    if (monthly.hasClass('graph')) {
      get_label();
      $.ajax({
               dataType: 'json',
               url: 'monthly',
               success: function (data) {
                 $.plot(monthly, [{
                                    data: data,
                                    label: label,
                                    color: '#0000FF'
                                  }], {
                                    xaxis: {
                                      mode: 'time',
                                      timeformat: '%y-%m-%d',
                                      minTickSize: [3, "day"]
                                    }
                                  });
               }
             });
    }
    if (yearly.hasClass('graph')) {
      get_label();
      $.ajax({
               dataType: 'json',
               url: 'yearly',
               success: function (data) {
                 $.plot(yearly, [{
                                   data: data,
                                   label: label,
                                   color: '#0000FF'
                                 }], {
                                   xaxis: {
                                     mode: 'time',
                                     timeformat: '%y-%m',
                                     minTickSize: [1, "month"]
                                   }
                                 });
               }
             });
    }

    if (combine.hasClass('graph')) {
      var first_data = null;
      var second_data = null;
      var first_label = null;
      var second_label = null;

      function get_first_data () {
        $.ajax({
                 dataType: 'json',
                 url: $('#first_collector').val() + '/' + $('#combine_scope').val(),
                 success: function (data) {
                   first_data = data;
                   get_second_data();
                 }
               });
      }

      function get_second_data () {
        $.ajax({
                 dataType: 'json',
                 url: $('#second_collector').val() + '/' + $('#combine_scope').val(),
                 success: function (data) {
                   second_data = data;
                   combine_graph();
                 }
               });
      }

      function combine_graph () {
        var timeformat = null;
        var minTickSize = null;

        switch ($('#combine_scope').val()) {
        case 'hourly':
          timeformat = '%H:%M';
          minTickSize = [10, 'minute'];
          break;
        case 'daily':
          timeformat = '%H:%M';
          minTickSize = [1, 'hour'];
          break;
        case 'weekly':
          timeformat = '%y-%m-%d';
          minTickSize = [1, 'day'];
          break;
        case 'monthly':
          timeformat = '%y-%m-%d';
          minTickSize = [3, 'day'];
          break;
        case 'yearly':
          timeformat = '%y-%m';
          minTickSize = [1, 'month'];
          break;
        }

        get_label($('#first_collector').val());
        first_label = label;
        get_label($('#second_collector').val());
        second_label = label;

        $.plot(combine, [{
                           data: first_data,
                           label: first_label,
                           color: '#0000FF',
                           yaxis: 1
                         },
                         {
                           data: second_data,
                           label: second_label,
                           color: '#FF0000',
                           yaxis: 2
                         }], {
                           xaxis: {
                             mode: 'time',
                             timeformat: timeformat,
                             minTickSize: minTickSize
                           }
                         });
      }
    }

    $('#combine_collectors').click(function () {
                                     get_first_data();
                                   });
  });

