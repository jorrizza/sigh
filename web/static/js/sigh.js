/* Makes Sigh single-dimension arrays into multi-dimension arrays
 * flot uses. */
function sigh_flotdata (data) {
  var r = [];

  for (var i = 0; i < data.length; i++) {
    r.push([i, data[i]]);
  }

  return [{
            data: r,
            color: '#0000FF',
            label: label
          }];
}

function sigh_update_hourly () {
  var hourly = $('#hourly');
  if (hourly) {
    $.ajax({
             dataType: 'json',
             url: 'hourly',
             success: function(data) {
               $.plot(hourly, sigh_flotdata(data));
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
             success: function(data) {
               $.plot(daily, sigh_flotdata(data));
             }
           });
  }
  if (weekly) {
    $.ajax({
             dataType: 'json',
             url: 'weekly',
             success: function(data) {
               $.plot(weekly, sigh_flotdata(data));
             }
           });
  }
  if (monthly) {
    $.ajax({
             dataType: 'json',
             url: 'monthly',
             success: function(data) {
               $.plot(monthly, sigh_flotdata(data));
             }
           });
  }
  if (yearly) {
    $.ajax({
             dataType: 'json',
             url: 'yearly',
             success: function(data) {
               $.plot(yearly, sigh_flotdata(data));
             }
           });
  }


});