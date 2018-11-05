// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .
//= require reports_kit/application

window.onload = function() {
  $("#check-pending").click(function(){
    var totalParks = parseInt($("#pending-parks").val());
    var newParks = 0;
    var oldParks = 0;
    var failedRequests = 0;
    for (i = 1; i <= totalParks; i++) {
      $.post('/pending', { id: i }, function(data, status){
        console.log(data);
        if (data.ParkStatus == 'ADDED'){
          newParks++;
        } else if (data.ParkStatus == 'NOT FOUND') {
          failedRequests++;
        } else {
          oldParks++;
        }
        updateStatusBars(newParks, oldParks, failedRequests, totalParks);
      }).fail(function(response){
        failedRequests++;
        updateStatusBars(newParks, oldParks, failedRequests, totalParks);
      });
    }
  });
};

function updateStatusBars(newParks, oldParks, failed, maximum) {
  document.getElementById("new-progress").style = "width: " + parseFloat(newParks/maximum*100) + "%";
  document.getElementById("old-progress").style = "width: " + parseFloat(oldParks/maximum*100) + "%";
  document.getElementById("failed-progress").style = "width: " + parseFloat(failed/maximum*100) + "%";

  document.getElementById("progress-number").innerHTML = parseInt(newParks + oldParks + failed) + "/" + parseInt(maximum);

  document.getElementById("added-parks").innerHTML = parseInt(newParks) + " new parks were added.";
  document.getElementById("old-parks").innerHTML = parseInt(oldParks) + " parks were found to have no differences between the databases or were already present.";
  document.getElementById("failed-request").innerHTML = parseInt(failed) + " requests failed.";
}