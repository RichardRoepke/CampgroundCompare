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
        if !foundDestination.value || $(this).data("global") != "[data-blank]"
          foundDestination.value = foundOrigin.value
        validateField(foundDestination.value, foundOrigin.value, $(foundDestination).data("row"))
      else
        token = $(element).data("element")
        foundElement = document.getElementById(token)
        foundElement.value = $(element).data("transfer")
        mirrorToken = $(foundElement).data("mirror")
        mirrorElement = document.getElementById(mirrorToken)
        validateField(foundElement.value, mirrorElement.value, $(foundElement).data("row"))
  $("input[data-copy]").click ->
    destination = $(this).data("element")
    origin = $(this).data("mirror")
    foundDestination = document.getElementById(destination)
    foundOrigin = document.getElementById(origin)
    foundDestination.value = foundOrigin.value
    validateField(foundDestination.value, foundOrigin.value, $(foundDestination).data("row"))
  $("input[data-transfer]").click ->
    token = $(this).data("element")
    foundElement = document.getElementById(token)
    foundElement.value = $(this).data("transfer")
    mirrorToken = $(foundElement).data("mirror")
    mirrorElement = document.getElementById(mirrorToken)
    validateField(foundElement.value, mirrorElement.value, $(foundElement).data("row"))
  $("input[data-submit]").click (event) ->
    elements = document.querySelectorAll("tr")
    for element in elements
      if element.id != ''
        if !element.classList.contains("table-success")
          event.preventDefault()
  $("textarea").focusout ->
    mirror = document.getElementById($(this).data("mirror"))
    validateField(mirror.value, $(this).context.value, $(this).data("row"))

validateField =(firstValue, secondValue, rowID) ->
  if rowID != undefined
    row = document.getElementById(rowID)
    if firstValue != secondValue
        row.classList.remove("table-warning", "table-success")
        row.classList.add("table-danger")
      else
        row.classList.remove("table-warning", "table-danger")
        row.classList.add("table-success")
      