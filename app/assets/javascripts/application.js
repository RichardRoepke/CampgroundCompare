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
    var completedRequests = 0;
    for (i = 1; i <= totalParks; i++) {
      $.post('/pending', { id: i }, function(data, status){
        completedRequests++;
        updateStatusBars(completedRequests, totalParks);
      });
    }
  });
};

function updateStatusBars(completed, maximum) {
  document.getElementById("completed-progress").style = "width: " + parseFloat(completed/maximum*100) + "%";
}