# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("input[pending]").click ->
    $.post '/pending',
      { field1: "hello", field2 : "hello2"},
        success  : (data, status, xhr) ->
            console.log("SUCCESS: " + data)
        error    : (xhr, status, err) ->
            console.log("ERROR: " + err)
        complete : (xhr, status) ->
            console.log("COMPLETE")