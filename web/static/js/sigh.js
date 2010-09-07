function sigh_update_hourly () {
  var hourly = $('#hourly');
  if (hourly) {
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
  }
  window.setTimeout(sigh_update_hourly, interval * 1000);
}

$(function () {
  sigh_update_hourly();

  var daily = $('#daily');
  var weekly = $('#weekly');
  var monthly = $('#monthly');
  var yearly = $('#yearly');

  if (daily) {
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
  if (weekly) {
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
  if (monthly) {
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
  if (yearly) {
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


});