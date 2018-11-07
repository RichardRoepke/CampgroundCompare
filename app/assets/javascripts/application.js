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
  if ($("#pending-parks").val() > 0) {
    setInterval(updateStatusBars, 2000);
  }
};

function updateStatusBars() {
  var totalParks = $("#pending-parks").val();
  var newParks = 0;
  var oldParks = 0;
  var failed = 0;

  $.post('/pending', { totalParks: totalParks }, function(data, status){
    console.log(data);

    if (data.Result != "DONE") {
      newParks = data.Added;
      oldParks = data.Unneeded;
      failed = data.Failed;

      document.getElementById("new-progress").style = "width: " + parseFloat(newParks/totalParks*100) + "%";
      document.getElementById("old-progress").style = "width: " + parseFloat(oldParks/totalParks*100) + "%";
      document.getElementById("failed-progress").style = "width: " + parseFloat(failed/totalParks*100) + "%";

      document.getElementById("progress-number").innerHTML = parseInt(newParks + oldParks + failed) + "/" + parseInt(totalParks);

      document.getElementById("added-parks").innerHTML = parseInt(newParks) + " new parks were added.";
      document.getElementById("old-parks").innerHTML = parseInt(oldParks) + " parks were found to have no differences between the databases or were already present.";
      document.getElementById("failed-request").innerHTML = parseInt(failed) + " requests failed.";
    }
  }).fail(function(response){
    console.log(response);
  });
}