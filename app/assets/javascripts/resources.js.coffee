# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  change_labels = (val) ->
    if val == "FinancialResource"
      $('label[for=resource_unit_of_measurement]').html "Currency (e.g. €, $...)"
    else
      $('label[for=resource_unit_of_measurement]').html "Unit (e.g. Kg, %...)"

  $('#resource_resource_type').change ->
    change_labels $('#resource_resource_type').val()

  change_labels $('#resource_resource_type').val()