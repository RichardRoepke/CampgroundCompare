# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("input[data-global]").click ->
    elements = document.querySelectorAll($(this).data("global"))
    for element in elements
      if $(this).data("type") == "copy"
        destination = $(element).data("element")
        origin = $(element).data("mirror")
        foundDestination = document.getElementById(destination)
        foundOrigin = document.getElementById(origin)
        foundDestination.value = foundOrigin.value
      else
        token = $(element).data("element")
        foundElement = document.getElementById(token)
        foundElement.value = $(element).data("transfer")
  $("input[data-copy]").click ->
    destination = $(this).data("element")
    origin = $(this).data("mirror")
    foundDestination = document.getElementById(destination)
    foundOrigin = document.getElementById(origin)
    foundDestination.value = foundOrigin.value