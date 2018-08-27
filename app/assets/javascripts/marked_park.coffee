# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("input[data-transfer]").click ->
    token = $(this).data("element")
    foundElement = document.getElementById(token)
    foundElement.value = $(this).data("transfer")